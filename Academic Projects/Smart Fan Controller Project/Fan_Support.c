#include <p18f4620.h>
#include "main.h"
#include "Fan_Support.h"
#include "stdio.h"
#include "utils.h"

        /*************************************************************/ 
        /*                  Variable declarations                    */ 
        /*************************************************************/ 

extern char FAN;
extern char duty_cycle;

        /*************************************************************/ 
        /*          get_RPM : Returns the RPM of the fan             */ 
        /*************************************************************/ 

int get_RPM()
{
    int RPS = TMR3L / 2;                    // read the count. Since there are 2 pulses per rev 
                                            // then RPS = count /2 
    TMR3L = 0;                              // clear out the count 
    return (RPS * 60);                      // return RPM = 60 * RPS
}

        /*************************************************************/ 
        /*          Toggle_Fan : Toggles the fan on or off           */ 
        /*************************************************************/ 

void Toggle_Fan()
{
    if (FAN == 0)                           // if FAN is at zero turn on the fan
        Turn_On_Fan();
    else                                    // else turn off the fan
        Turn_Off_Fan(); 
}

        /*************************************************************/ 
        /*          Turn_Off_Fan : Turns the fan off                 */ 
        /*************************************************************/ 

void Turn_Off_Fan()
{
    FAN = 0;                                // Toggle FAN for next use 
    FAN_EN = 0;                             // Stop the fan through the enable pin
    FANON_LED = 0;                          // Turn the fan led off
}

        /*************************************************************/ 
        /*          Turn_On_Fan : Turns the fan on                   */ 
        /*************************************************************/ 

void Turn_On_Fan()
{
    FAN = 1;                                // Toggle FAN for next use
    do_update_pwm(duty_cycle);              // Change the pwm output
    FAN_EN = 1;                             // Start the fan by connecting to ground
    FANON_LED = 1;                          // Turn the fan led on
}

        /*************************************************************/ 
        /*       Increase_Speed : Increases the PWM duty cycle       */ 
        /*************************************************************/ 

void Increase_Speed()
{
    if (duty_cycle >= 100)                  // if duty cycle is at max
    {
        Do_Beep();                          // Beep twice without changing the duty cycle
        Do_Beep();
        duty_cycle = 100;
        do_update_pwm(duty_cycle);          // Reset the pwm output at 100%
    }
    else                                    // if duty cycle is less than max speed
    {
        duty_cycle = duty_cycle + 0x05;        // Add 5% to the duty cycle
        do_update_pwm(duty_cycle);          // Update the pwm output
    }
}

        /*************************************************************/ 
        /*       Decrease_Speed : Decreases the PWM duty cycle       */ 
        /*************************************************************/ 

void Decrease_Speed()
{
    if (duty_cycle <= 0)                    // if duty cycle is at zero
    {
        Do_Beep();                          // Beep twice without changing the duty cycle
        Do_Beep();
        duty_cycle = 0;
        do_update_pwm(duty_cycle);          // Reset the pwm output at 0%
    }
    else                                    // if duty cycle is greater than zero
    {
        duty_cycle = duty_cycle - 0x05;        // Subtract 5% to the duty cycle
        do_update_pwm(duty_cycle);          // Update the pwm output
    }
}

        /*************************************************************/ 
        /*   do_update_pwm : Updates CCP output using duty cycle     */ 
        /*************************************************************/

void do_update_pwm(char duty_cycle) 
{ 
float dc_f; 
int dc_I;  
    PR2 = 0b00000100 ;                      // set the frequency for 25 Khz 
    T2CON = 0b00000111 ;                    //
    dc_f = ( 4.0 * duty_cycle / 20.0) ;     // calculate factor of duty cycle versus a 25 Khz 
                                            // signal  
    dc_I = (int) dc_f;                      // get the integer part 
    if (dc_I > duty_cycle) dc_I++;          // round up function 
    CCP1CON = ((dc_I & 0x03) << 4) | 0b00001100;  
    CCPR1L = (dc_I) >> 2;  
}

        /*************************************************************/ 
        /*   Set_DC_RGB : Changes the RGB color based on duty cycle  */ 
        /*************************************************************/

void Set_DC_RGB(int duty_cycle)
{
    int color = duty_cycle/10;              // color is the second digit of duty cycle
    if (color > 7) color = 7;               // duty cycle > 70% is set to white
    PORTB = color << 3;                     // Output color to PORTB bits 3 to 5
}

        /*************************************************************/ 
        /*     Set_RPM_RGB : Changes the RGB color based on RPM      */ 
        /*************************************************************/

void Set_RPM_RGB(int rpm)
{
    int color = (rpm / 500) + 1;            // set color with appropriate value
    if (rpm == 0) color = 0;                // account for the case where rpm is zero
    if (color > 7) color = 7;               // rpm > 3000 is set to white 
    PORTE = color;                          // Output color to PORTE
}

void Set_TempC_RGB(signed char)
{
    
}
