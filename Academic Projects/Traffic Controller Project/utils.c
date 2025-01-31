#include <stdio.h>
#include <stdlib.h>
#include <xc.h>
#include <p18f4620.h>

#include "main.h"
#include "utils.h"
#include "ST7735_TFT.h"
#include "Main_Screen.h"

        /*************************************************************/ 
        /*                   Variable declaration                    */ 
        /*************************************************************/ 

extern char found;
extern char Nec_code1;
extern short nec_ok;
extern char array1[21];
extern char duty_cycle;
extern char direction;

        /*************************************************************/ 
        /*          Init_ADC : Function to initialize ADC            */ 
        /*************************************************************/

void Init_ADC(void) 
{ 
    ADCON0=0x01;                    // select channel AN0, and turn on the ADC subsystem 
    ADCON1=0x0E;                    // select pins AN0 as analog input
    ADCON2=0xA9;                    // right justify the result. Set the bit conversion 
                                    // time (TAD) and acquisition time 
}

        /*************************************************************/ 
        /*          Init_TRIS : Function to initialize I/O modes     */ 
        /*************************************************************/

void Init_TRIS(void)
{
    TRISA = 0xF9;                   // PORTA bits 7-3 and bit 0 are input
    TRISB = 0x07;                   // PORTB bits 2-0 are input
    TRISC = 0x01;                   // PORTC bit 0 is input
    TRISD = 0x00;                   // Every other ports and bits are output
    TRISE = 0x00;
}

        /*************************************************************/ 
        /*       Initializing Serial Port for TeraTerm               */ 
        /*************************************************************/ 

void Init_UART(void)
{
    OpenUSART (USART_TX_INT_OFF & USART_RX_INT_OFF &
    USART_ASYNCH_MODE & USART_EIGHT_BIT & USART_CONT_RX &
    USART_BRGH_HIGH, 25);
    OSCCON = 0x70;
}

void putch (char c)
{
    while (!TRMT);
    TXREG = c;
}

        /*************************************************************/ 
        /* Do_Beep : Function to make a buzzing noise in 2 sec cycle */ 
        /*************************************************************/

void Do_Beep(void)
{
    Activate_Buzzer();
    Wait_One_Second();
    Deactivate_Buzzer();
    Wait_One_Second();

}

        /*************************************************************/ 
        /* Do_Beep_Good : Function to */ 
        /*************************************************************/

void Do_Beep_Good(void)
{
										// to be added in later lab

}

        /*************************************************************/ 
        /* Do_Beep_Bad: Function to */ 
        /*************************************************************/

void Do_Beep_Bad(void)
{
										// to be added in later lab

}

        /*************************************************************/ 
        /*     Activate_Buzzer : Function to make a buzzing noise    */ 
        /*************************************************************/

void Activate_Buzzer(void)
{
    PR2 = 0b11111001 ;
    T2CON = 0b00000101 ;
    CCPR2L = 0b01001010 ;
    CCP2CON = 0b00111100 ;
}

        /*************************************************************/ 
        /*   Activate_Buzzer_500Hz : Function to make a 500Hz sound  */ 
        /*************************************************************/

void Activate_Buzzer_500Hz(void)
{
										// to be added in later lab
}

        /*************************************************************/ 
        /*    Activate_Buzzer_2kHz : Function to make a 2kHz sound   */ 
        /*************************************************************/

void Activate_Buzzer_2KHz(void)
{
										// to be added in later lab
}

        /*************************************************************/ 
        /*    Activate_Buzzer_4kHz : Function to make a 4kHz sound   */ 
        /*************************************************************/

void Activate_Buzzer_4KHz(void)
{
										// to be added in later lab
}

        /*************************************************************/ 
        /*       Deactivate_Buzzer : Function to stop the buzzer     */ 
        /*************************************************************/

void Deactivate_Buzzer(void)
{
    CCP2CON = 0x0;
	PORTCbits.RC1 = 0;
}

        /*************************************************************/ 
        /*  Wait_Half_Second : Function to count 500ms using Timer0  */ 
        /*************************************************************/
    
void Wait_Half_Second()
{
    T0CON = 0x03;                   // Timer 0, 16-bit mode, prescaler 1:16
    TMR0L = 0x90;                   // set the lower byte of TMR
    TMR0H = 0x0A;                   // set the upper byte of TMR
    INTCONbits.TMR0IF = 0;          // clear the Timer 0 flag
    T0CONbits.TMR0ON = 1;           // Turn on the Timer 0
    while (INTCONbits.TMR0IF == 0); // wait for the Timer Flag to be 1 for done
    T0CONbits.TMR0ON = 0;           // turn off the Timer 0
}

        /*************************************************************/ 
        /* Wait_One_Second_Soft : wait 1 second using software delay */ 
        /*************************************************************/

void Wait_One_Sec_Soft(void)
{
    for (int k=0;k<0xffff;k++);
}

        /*************************************************************/ 
        /*    Wait_One_Second_With_Beep : Wait 1 second with Sound   */ 
        /*************************************************************/

void Wait_One_Second_With_Beep()	//creates one second delay as well as sound buzzer
{
    SEC_LED = 1;                    // Lights up for 500 msec
    Draw_Star();                    // Star is shown 500 msec
    Activate_Buzzer();              // Makes buzzer noise
    Wait_Half_Second();             // Wait for half second (or 500 msec)

    SEC_LED = 0;                    // Is off for 500 msec
    Erase_Star();                   // Star is not shown for 500 msec
    Deactivate_Buzzer();            // Stops buzzer noise
    Wait_Half_Second();             // Wait for half second (or 500 msec)
    update_LCD_misc();              // Update the LCD screen
}

        /*************************************************************/ 
        /*          Wait_N_Second : Function to wait N seconds       */ 
        /*************************************************************/

void Wait_N_Seconds (char seconds) 
{ 
char I;                             // Indexing variable
    for (I = seconds; I> 0; I--)    // Loop for seconds times
    {                               // Update the count on LCD
        update_LCD_count(direction, I);
        Wait_One_Second();          // Wait a second
    } 
    update_LCD_count(direction, 0); // Update LCD for one last time
} 

        /*************************************************************/ 
        /*          Wait_One_Second : Function to wait 1 second      */ 
        /*************************************************************/

void Wait_One_Second()				//creates one second delay and blinking asterisk
{
    SEC_LED = 1;                    // Lights up for 500 msec
    Draw_Star();                    // Star is shown 500 msec
    Wait_Half_Second();             // Wait for half second (or 500 msec)
    SEC_LED = 0;                    // Is off for 500 msec
    Erase_Star();                   // Star is not shown for 500 msec
    Wait_Half_Second();             // Wait for half second (or 500 msec)
    update_LCD_misc();              // Update the LCD screen
}

        /*************************************************************/ 
        /*          do_update_pwm : Function to      */ 
        /*************************************************************/

void do_update_pwm(char duty_cycle) 
{ 
										// to be added in later lab
}

        /*************************************************************/ 
        /*          Set_RGB_color : Function to      */ 
        /*************************************************************/

void Set_RGB_Color(char color)
{
										// to be added in later lab
}

        /*************************************************************/ 
        /*     Read_Ch_Volt : Function to read channel voltage       */ 
        /*************************************************************/

float Read_Ch_Volt(char ch_num, float ref_V) 
{ 
    ADCON0 = ch_num * 0x4 + 1;      // sets given AN_pin to analog mode
    int ADC_Result = get_full_ADC();// Reading the step number from A to D converter
    float Volt = ADC_Result * (ref_V / 1024); 
                                    // Covert step readings to V
    return (Volt);                  // Return V
}  

        /*************************************************************/ 
        /*          get_full_ADC : Function to read ADC              */ 
        /*************************************************************/

unsigned int get_full_ADC(void)
{
unsigned int result;
   ADCON0bits.GO=1;                 // Start Conversion
   while(ADCON0bits.DONE==1);       // wait for conversion to be completed
   result = (ADRESH * 0x100) + ADRESL;
                                    // combine result of upper byte and lower byte into result
   return result;                   // return the result.
}

        /*************************************************************/ 
        /*   check_for_button_input : Function to              */ 
        /*************************************************************/

char check_for_button_input(void)
{ 
										// to be added in later lab
}

        /*************************************************************/ 
        /*       bcd_2_dec : Function to convert BCD to decimal      */ 
        /*************************************************************/

char bcd_2_dec (char bcd)
{
    int dec;
    dec = ((bcd >> 4) * 10) + (bcd & 0x0f);
    return dec;
}

        /*************************************************************/ 
        /*       dec_2_bcd : Function to convert decimal to BCD      */ 
        /*************************************************************/

int dec_2_bcd (char dec)
{
    int bcd;
    bcd = ((dec / 10) << 4) + (dec % 10);
    return bcd;
}



