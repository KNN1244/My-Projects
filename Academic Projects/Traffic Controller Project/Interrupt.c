#include <xc.h>
#include <p18f4620.h>
#include "Interrupt.h"

extern char INT0_Flag;
extern char INT1_Flag;
extern char INT2_Flag;
extern char EW_PED_SW;
extern char NS_PED_SW;
extern char MODE;

extern char Flashing_Request;

void Init_INTERRUPT()
{   // clearing the interrupt flags
    INTCONbits.INT0IF = 0;    // INT0 IF is in INTCON 
    INTCON3bits.INT1IF = 0;   // INT1 IF is in INTCON3 
    INTCON3bits.INT2IF = 0;   // INT2 IF is in INTCON3 
    // 1 for low to high, 0 for high to low
    INTCON2bits.INTEDG0 = 0;  // INT0 EDGE is in INTCON2 
    INTCON2bits.INTEDG1 = 0;  // INT1 EDGE is in INTCON2 
    INTCON2bits.INTEDG2 = 0;  // INT2 EDGE is in INTCON2 
    // Enable all external interrupt pins
    INTCONbits.INT0IE = 1;    // INT0 IE is in INTCON 
    INTCON3bits.INT1IE = 1;   // INT1 IE is in INTCON3 
    INTCON3bits.INT2IE = 1;   // INT2 IE is in INTCON3 
    INTCONbits.GIE=1;   // Set the Global Interrupt Enable 
}

void interrupt  high_priority chkisr()
{
    if (INTCONbits.INT0IF == 1) INT0_ISR(); // check if INT0 has occurred			
    if (INTCON3bits.INT1IF == 1) INT1_ISR(); // check if INT0 has occurred			
    if (INTCON3bits.INT2IF == 1) INT2_ISR(); // check if INT0 has occurred			
}

void INT0_ISR()
{
    INTCONbits.INT0IF=0; // Clear the interrupt flag
    if (MODE == 1) // Only turn on Ped count on day mode
        NS_PED_SW = 1;      // NS Ped count is set
}

void INT1_ISR()
{
    INTCON3bits.INT1IF=0; // Clear the interrupt flag
    if (MODE == 1)// Only turn on Ped count on day mode
        EW_PED_SW = 1;      // EW Ped count is set
}

void INT2_ISR()
{
    INTCON3bits.INT2IF=0; // Clear the interrupt flag
    Flashing_Request = 1;         // Set the programmed flag
}

