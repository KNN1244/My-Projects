#include <stdio.h>
#include <stdlib.h>
#include <xc.h>
#include <math.h>
#include <p18f4620.h>
#include <usart.h>
#include <string.h>
#include "main.h"
#include "ST7735_TFT.h"
#include "Interrupt.h"
#include "utils.h"
#include "Main_Screen.h"
#include "I2C.h"
#include "I2C_Support.h"
#include "Fan_Support.h"

#pragma config OSC = INTIO67
#pragma config WDT = OFF
#pragma config LVP = OFF
#pragma config BOREN = OFF

        /*************************************************************/ 
        /*                       Define Statement                    */ 
        /*************************************************************/ 

#define _XTAL_FREQ  8000000             // Set operation for 8 Mhz

        /*************************************************************/ 
        /*             Variable and Array declarations               */ 
        /*************************************************************/ 

char FAN, duty_cycle;                   // toggle variable and PWM duty cycle tracking variable
char tempSecond = 0xff;  
char second = 0x00; 
char minute = 0x00; 
char hour = 0x00; 
char dow = 0x00; 
char day = 0x00; 
char month = 0x00; 
char year = 0x00; 
char setup_second, setup_minute, setup_hour, setup_day, setup_month, setup_year; 
char alarm_second, alarm_minute, alarm_hour, alarm_date; 
char setup_alarm_second, setup_alarm_minute, setup_alarm_hour; 

short Nec_OK = 0;                       // Used to see if button code is valid
char Nec_Button;                        // Stores the button code from ISR
extern unsigned long long Nec_code;     // Stores the full IR signal from remote

char array1[21]={0xa2,0x62,0xe2,0x22,0x02,0xc2,0xe0,0xa8,0x90,0x68,0x98,0xb0,0x30,0x18,0x7a,0x10,0x38,0x5a,0x42,0x4a,0x52};               
                                        // Contains the placement code for the 21 buttons 
char txt1[21][4] ={"CH-\0","CH \0", "CH+\0","|<<\0",">>|\0",">||\0","VL-\0","VL+\0","EQ \0"," 0 \0"
,"100\0","200\0"," 1 \0"," 2 \0"," 3 \0"," 4 \0"," 5 \0"," 6 \0"," 7 \0"," 8 \0"," 9 \0"};
                                        // Contains the text representing the 21 buttons 
int color[21]={RD,RD,RD,BU,BU,GR,MA,MA,MA,BK,BK,BK,BK,BK,BK,BK,BK,BK,BK,BK,BK};
                                        // Contains the color of the 21 buttons 
char colorD1[21] = {0x01,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
char colorD2[21] = {0x00,0x00,0x00,0x04,0x04,0x02,0x05,0x05,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
char colorD3[21] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07};
                                        // Used to display the correct color on the RGB LEDs

        /*************************************************************/ 
        /*                       Main Function                       */ 
        /*************************************************************/ 

void main()
{
    Init_UART();                        // Set up terminal communication
    OSCCON = 0x70;                      // Set CPU clock to 8 Mhz
    nRBPU = 0;                          // Enable PORTB internal pull up resistor
    Init_TRIS();                        // Initialize port I/O modes
    ADCON1 = 0x0F;                      // Digital I/O Mode
     
    PORTB = 0;                          // Clear the RGB LED outputs
    PORTE = 0;
 
    Initialize_LCD_Screen();            // Set up the LCD screen
    Init_Interrupt();                   // Set up the Interrupt routines
    TMR3L = 0x00;                       // Clear timer 3 
    T3CON = 0x03;                       // Initialize TMR3 with 1:1 prescaler
    
    I2C_Init(100000);                   // Initialize the I2C communications
    DS1621_Init();                      // Initialize the Temp Sensor

    Nec_code = 0x0;                     // Clear code
    
    FAN_EN = 0;                         // clear fan enable
    FAN_PWM = 1;                        // Initialize the pwm signal
    FANON_LED = 0;
    duty_cycle = 50;                    // Initial fan at half speed
    do_update_pwm(duty_cycle);          // Update the CCP module output

    while(1)
    {
        DS3231_Read_Time();             // Read the time constantly
        if(tempSecond != second)        // check if the time have changed
        { 
            tempSecond = second;        // Reset the temp to the new time
            char tempC = DS1621_Read_Temp(); // Read the temperature
            char tempF = (tempC * 9 / 5) + 32; // Convert the temperature
            int rpm = get_RPM();        // Store the rpm reading from TACH
            Set_DC_RGB(duty_cycle);     // Set D2's color based on duty cycle
            Set_RPM_RGB(rpm);           // Set D3's color based on rpm
            printf("%02x:%02x:%02x %02x/%02x/%02x",hour,minute,second,month,day,year); 
                                        // Print out selected variables from time reading
            printf(" Temperature = %d degreesC = %d degreesF\r\n", tempC, tempF); 
                                        // Print out the temperature and converted readings
            printf("RPM = %d  dc = %d\r\n", rpm, duty_cycle); 
                                        // Print out the speed and duty cycle of the fan
        }
        
        if (Nec_OK == 1)                // Checks to see if a correct signal is read 
        {
            Nec_OK = 0;                 // Reset to receive another button code
            Enable_INT_Interrupt();     // Reset the interrupt settings
            printf ("NEC_Button = %x \r\n", Nec_Button);  
                                        // Write button code to terminal
            char found = 0xff;          // Used to store the placement of a button code
            for (int i = 0; i < 21; i++)// look for code using a FOR loop
            {
                if (Nec_Button == array1[i])
                {
                    found = i;          // if code exists, return the location
                    break;
                }
            }

            if (found != 0xff) 
            {
				printf ("Key Location = %d \r\n\n", found);
                                        // Write the button location to terminal
                fillCircle(Circle_X, Circle_Y, Circle_Size, color[found]); 
                drawCircle(Circle_X, Circle_Y, Circle_Size, ST7735_WHITE);  
                drawtext(Text_X, Text_Y, txt1[found], ST7735_WHITE, ST7735_BLACK,TS_1);
                                        // Draws a white circle with white text and fills it with
                                        // corresponding color in the array
                
                if (found == 8)         // if the EQ button is pressed
                    DS3231_Setup_Time();// Reset the time to the preprogrammed time
                if (found == 5)         // if the Play/Pause button is pressed
                    Toggle_Fan();       // Turn on or off the fan
                if (found == 6)         // if the minus button is pressed
                    Decrease_Speed();   // Decrease the duty cycle of the pwm signal
                if (found == 7)         // if the plus button is pressed
                    Increase_Speed();   // Increase the duty cycle of the pwm signal
			
                KEY_PRESSED = 1;        // Turns on KEY_PRESSED LED
                Do_Beep();              // Beeps for one sec, wait one more sec
                do_update_pwm(duty_cycle); // Reset CCP module output for PWM signal
                KEY_PRESSED = 0;        // Turns off KEY_PRESSED LED
            }
        }
    }
    
}


