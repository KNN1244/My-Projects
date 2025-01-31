#pragma config OSC = INTIO67
#pragma config WDT = OFF
#pragma config LVP = OFF
#pragma config BOREN = OFF

#include <stdio.h>
#include <stdlib.h>
#include <xc.h>
#include <math.h>
#include <p18f4620.h>
#include <string.h>

#include "main.h"
#include "utils.h"
#include "Main_Screen.h"
#include "ST7735_TFT.h"
#include "Interrupt.h"

        /*************************************************************/ 
        /*                       Prototype Section                   */ 
        /*************************************************************/ 


void Set_NS(char color);            // Sets NS traffic light color
void Set_NSLT(char color);          // Sets NSLT traffic light color
void Set_EW(char color);            // Sets EW traffic light color
void Set_EWLT(char color);          // Sets EWLT traffic light color
void PED_Control( char Direction, char Num_Sec);
                                    // Pedestrian countdown function
void Day_Mode();                    // Contains the Day mode sequence
void Night_Mode();                  // Contains the Night mode sequence
void Do_Flashing();                 // Contains the Flashing mode sequence

        /*************************************************************/ 
        /*                       Define Statements                   */ 
        /*************************************************************/ 


#define _XTAL_FREQ  8000000         // Set operation for 8 Mhz
#define TMR_CLOCK   _XTAL_FREQ/4    // Timer Clock 2 Mhz

        /*************************************************************/ 
        /*                   Variable declaration                    */ 
        /*************************************************************/ 


char dir;
char Count;                         // RAM variable for Second Count
char PED_Count;                     // RAM variable for Second Pedestrian Count

char  MODE;                         // RAM variable for day/night mode
char direction;                     // RAM variable for direction
float volt;                         // RAM variable for light sensor voltage

extern char Light_Sensor;           // RAM variable for sensor mode (day/night)

char INT0_Flag;                     // RAM variable for interrupt flag 0
char INT1_Flag;                     // RAM variable for interrupt flag 1
char INT2_Flag;                     // RAM variable for interrupt flag 2

char NS_PED_SW = 0;                 // RAM variable for NS ped count activation
char EW_PED_SW = 0;                 // RAM variable for EW ped count activation

char Flashing_Request = 0;          // RAM variable for flashing input
char Flashing_Status = 0;           // RAM variable for flashing status

        /*************************************************************/ 
        /*                       Main Function                       */ 
        /*************************************************************/ 

void main() 
{ 
    OSCCON = 0x70;                  // set the system clock to be 8MHz
    Init_TRIS();                    // Initialize the I/O ports A-E
    Init_ADC();                     // Initialize the Analog to Digital registers
    Init_UART();                    // Initialize the serial port and CPU clock speed
    Initialize_LCD_Screen();        // Initialize the LCD Screen
    RBPU = 0;                       // Port B is internally pulled up to high
    Init_INTERRUPT();               // Initialize the Interrupt routine
    /*
    while (1) 
    {                               // Do nothing,  
        if (INT0_Flag == 1) 
        { 
            INT0_Flag = 0;          // clear the flag 
            printf("INT0 interrupt pin detected \r\n"); 
                                    // print a message that INT0 has occurred 
        } 
        if (INT1_Flag == 1) 
        { 
            INT1_Flag = 0;          // clear the flag 
            printf("INT1 interrupt pin detected \r\n"); 
                                    // print a message that INT1 has occurred 
        } 
        if (INT2_Flag == 1) 
        { 
            INT2_Flag = 0;          // clear the flag 
            printf("INT2 interrupt pin detected \r\n"); 
                                    // print a message that INT2 has occurred 
        }   
    } 
    */
    while(1)
    {
        volt = Read_Ch_Volt(0, 5);  // Read the light resistor voltage
        Light_Sensor = volt<2.5?1:0;// Ture if less than 2.5 V
        if (Flashing_Request == 1)  // Check for flashing interrupt event
        { 
            Flashing_Request = 0;   // Reset the request
            Flashing_Status = 1;    // The status is on until another request is sent
            Do_Flashing();          // Do the flashing sequence
        } 
        if (Light_Sensor == 1)
        {
            Day_Mode();             // If ture, activate day mode
        }
        else
        {
            Night_Mode();           // If false, activate night mode
        }
    }
}

        /*************************************************************/ 
        /*   Do_Flashing : Function to flash red in all directions   */ 
        /*************************************************************/

void Do_Flashing()
{
    while (Flashing_Status == 1)    // Activates only when the status is one
    {
        if (Flashing_Request == 0)  // Make sure that a second request is not sent
        {
            Set_NS(RED);            // Set all traffic signals to red
            Set_EW(RED);
            Set_NSLT(RED);
            Set_EWLT(RED);
            Wait_One_Second();      // Wait one second
            Set_NS(OFF);            // Turn all signals off
            Set_EW(OFF);
            Set_NSLT(OFF);
            Set_EWLT(OFF);
            Wait_One_Second();      // Wait one second
        }                           
        else if (Flashing_Request == 1)
        {                           // When second request is sent clear both flags
            Flashing_Request = 0;   
            Flashing_Status = 0;    // Clearing status flag stops the while loop
        }
    }
}

        /*************************************************************/ 
        /*          Set_NS : Function to set NS LED's color          */ 
        /*************************************************************/

void Set_NS(char color) 
{ 
    direction = NS; 
    update_LCD_color (direction, color); 
    switch (color) 
    { 
    case OFF: NS_RED =0;NS_GREEN=0;break; // Turns off the NS LED 
    case RED: NS_RED =1;NS_GREEN=0;break; // Sets NS LED RED 
    case GREEN: NS_RED =0;NS_GREEN=1;break; // sets NS LED GREEN 
    case YELLOW: NS_RED =1;NS_GREEN=1;break; // sets NS LED YELLOW 
    } 
}

        /*************************************************************/ 
        /*        Set_NSLT : Function to set NSLT LED's color        */ 
        /*************************************************************/

void Set_NSLT(char color) 
{ 
    direction = NSLT; 
    update_LCD_color (direction, color); 
    switch (color) 
    { 
    case OFF: NSLT_RED =0;NSLT_GREEN=0;break; // Turns off the NSLT LED 
    case RED: NSLT_RED =1;NSLT_GREEN=0;break; // Sets NSLT LED RED 
    case GREEN: NSLT_RED =0;NSLT_GREEN=1;break; // sets NSLT LED GREEN 
    case YELLOW: NSLT_RED =1;NSLT_GREEN=1;break; // sets NSLT LED YELLOW 
    } 
}

        /*************************************************************/ 
        /*          Set_EW : Function to set EW LED's color          */ 
        /*************************************************************/

void Set_EW(char color) 
{ 
    direction = EW; 
    update_LCD_color (direction, color); 
    switch (color) 
    { 
    case OFF: EW_RED =0;EW_GREEN=0;break; // Turns off the EW LED 
    case RED: EW_RED =1;EW_GREEN=0;break; // Sets EW LED RED 
    case GREEN: EW_RED =0;EW_GREEN=1;break; // sets EW LED GREEN 
    case YELLOW: EW_RED =1;EW_GREEN=1;break; // sets EW LED YELLOW 
    } 
}

        /*************************************************************/ 
        /*        Set_EWLT : Function to set EWLT LED's color        */ 
        /*************************************************************/

void Set_EWLT(char color) 
{ 
    direction = EWLT; 
    update_LCD_color (direction, color); 
    switch (color) 
    { 
    case OFF: EWLT_RED =0;EWLT_GREEN=0;break; // Turns off the EWLT LED 
    case RED: EWLT_RED =1;EWLT_GREEN=0;break; // Sets EWLT LED RED 
    case GREEN: EWLT_RED =0;EWLT_GREEN=1;break; // sets EWLT LED GREEN 
    case YELLOW: EWLT_RED =1;EWLT_GREEN=1;break; // sets EWLT LED YELLOW 
    } 
}

        /*************************************************************/ 
        /*   PED_Control : Function to count down on 7-seg displays  */ 
        /*************************************************************/

void PED_Control(char Direction, char Num_Sec)
{
char i;                             // Indexing variable
    for (i = Num_Sec-1; i>0; i--)   // Wait for Num_Sec-1 so that biggest num
    {                               // is not shown while beeping and updating the LCD
        update_LCD_PED_Count(direction, i);
        Wait_One_Second_With_Beep();
    }
    update_LCD_PED_Count(direction, i);
    Wait_One_Second_With_Beep();    // Beep and update one last time at index 0
    if (Direction == NS) 
        NS_PED_SW = 0;              // Clear Ped switch varibles so that they
    if (Direction == EW)            // are reset to zero
        EW_PED_SW = 0;
}

        /*************************************************************/ 
        /*     Day_Mode : Function to activate day time sequence     */ 
        /*************************************************************/

void Day_Mode()
{
    MODE_LED = 1;                   // Turns on MODE_LED
    MODE = 1;                       // Sets MODE to day which is displayed as D
    
    Set_EW(RED);                    // Set EW Red
    Set_EWLT(RED);                  // Set EW Left turns RED
    Set_NSLT(RED);                  // Set NS Left turns RED
    
    Set_NS(GREEN);                  // NS through traffic section
    if (NS_PED_SW == 1)             // with PED control checking
    {
        PED_Control(NS,PEDESTRIAN_NS_WAIT);
    }                               // Sets the countdown in NS direction
    Wait_N_Seconds(NS_WAIT);
    Set_NS(YELLOW);       
    Wait_N_Seconds(3);
    Set_NS(RED);
    
    if (EWLT_SW == 1)               // EW Left turn checking
    {
        Set_EWLT(GREEN);            // EW Left turn traffic section
        Wait_N_Seconds(EW_LT_WAIT);
        Set_EWLT(YELLOW);
        Wait_N_Seconds(3);
        Set_EWLT(RED);
    }
    
    Set_EW(GREEN);                  // EW through traffic section
    if (EW_PED_SW == 1)             // with PED control checking
    {
        PED_Control(EW,PEDESTRIAN_EW_WAIT);
    }                               // Sets the countdown in EW direction
    Wait_N_Seconds(EW_WAIT);
    Set_EW(YELLOW);
    Wait_N_Seconds(3);
    Set_EW(RED);
    
    if (NSLT_SW == 1)               // NS Left turn checking
    {
        Set_NSLT(GREEN);            // NS Left turn traffic section
        Wait_N_Seconds(NS_LT_WAIT);
        Set_NSLT(YELLOW);
        Wait_N_Seconds(3);
        Set_NSLT(RED);
    }
}

        /*************************************************************/ 
        /*   Night_Mode : Function to activate night time sequence   */ 
        /*************************************************************/

void Night_Mode()
{
    MODE_LED = 0;                   // Turns off MODE_LED
    MODE = 0;                       // Sets MODE to night which is displayed as N
    NS_PED_SW = 0;                  // Clear ped count flags so that they don't
    EW_PED_SW = 0;                  // carry over to night mode
    
    Set_EW(RED);                    // Set EW Red
    Set_EWLT(RED);                  // Set EW Left turns RED
    Set_NSLT(RED);                  // Set NS Left turns RED
    
    Set_NS(GREEN);                  // NS through traffic section
    Wait_N_Seconds(NIGHT_NS_WAIT);
    Set_NS(YELLOW);       
    Wait_N_Seconds(3);
    Set_NS(RED);
    
    if (EWLT_SW == 1)               // EW Left turn checking
    {
        Set_EWLT(GREEN);            // EW Left turn traffic section
        Wait_N_Seconds(NIGHT_EW_LT_WAIT);
        Set_EWLT(YELLOW);
        Wait_N_Seconds(3);
        Set_EWLT(RED);
    }
    
    Set_EW(GREEN);                  // EW through traffic section
    Wait_N_Seconds(NIGHT_EW_WAIT);
    Set_EW(YELLOW);
    Wait_N_Seconds(3);
    Set_EW(RED);
    
    if (NSLT_SW == 1)               // NS Left turn checking
    {
        Set_NSLT(GREEN);            // NS Left turn traffic section
        Wait_N_Seconds(NIGHT_NS_LT_WAIT);
        Set_NSLT(YELLOW);
        Wait_N_Seconds(3);
        Set_NSLT(RED);
    }
}
