        /*************************************************************/ 
        /*                       Define Statements                   */ 
        /*************************************************************/ 

//colors
#define OFF             0               // Defines OFF as decimal value 0
#define RED             1               // Defines RED as decimal value 1
#define GREEN           2               // Defines GREEN as decimal value 2
#define YELLOW          3               // Defines YELLOW as decimal value 3
//class info
#define Semester        1               // Type 0 for Sp, 1 for Fa
#define Year            24              // Type 2 digits year
#define Session_Number  1               // Type Session Number 1 through 5
#define Table_Number    14              // Type Table Number from 01 through 14

//LED bits
#define     SEC_LED     PORTEbits.RE2   // Defines SEC_LED as PORTD bit RE2
#define     MODE_LED    PORTEbits.RE1   // Defines MODE_LED as PORTE bit RE1 to differentiate day/night mode

#define     NS_RED      PORTAbits.RA1   // Defines NS_RED as PORTA bits RA1
#define     NS_GREEN    PORTAbits.RA2   // Defines NS_GREEN as PORTA bit RA2
#define     NSLT_RED    PORTBbits.RB3   // Defines NS_LT RED as PORTB bit RB3
#define     NSLT_GREEN  PORTBbits.RB4   // Defines NS_LT GREEN as PORTB bit RB4

#define     EW_RED      PORTBbits.RB5   // Defines EW_RED as PORTB bit RB5
#define     EW_GREEN    PORTBbits.RB6   // Defines EW_GREEN as PORTB bit RB6
#define     EWLT_RED    PORTBbits.RB7   // Defines EWLT_RED as PORTB bit RB7
#define     EWLT_GREEN  PORTEbits.RE0   // Defines EWLT_GREEN as PORTE bit RE0

//#define     NSPED_SW    PORTAbits.RA3   // Defines NS_PED as PORTA bit RA3 for Ped-switch
//#define     EWPED_SW    PORTAbits.RA4   // Defines EW_PED as PORTA bit RA4 for Ped-switch
#define     NSLT_SW     PORTAbits.RA5   // Defines NS_LT as PORTA bit RA5 for left turn
#define     EWLT_SW     PORTCbits.RC0   // Defines EW_LT as PORTC bit RC0 for left turn

//Wait times
#define PEDESTRIAN_NS_WAIT  8           // Walking time for NS ped crossing
#define NS_WAIT             7           // Through traffic time for NS
#define EW_LT_WAIT          8           // Left turn time for EW
#define PEDESTRIAN_EW_WAIT  7           // Walking time for EW ped crossing
#define EW_WAIT             6           // Through traffic time for EW
#define NS_LT_WAIT          7           // Left turn time for NS

#define NIGHT_NS_WAIT       6           // Through traffic time for NS at night
#define NIGHT_EW_LT_WAIT    7           // Left turn time for EW at night
#define NIGHT_EW_WAIT       6           // Through traffic time for EW at night
#define NIGHT_NS_LT_WAIT    8           // Left turn time for NS at night

