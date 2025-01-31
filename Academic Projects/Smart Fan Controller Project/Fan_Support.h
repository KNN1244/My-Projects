        /*************************************************************/ 
        /*                       Prototype Section                   */ 
        /*************************************************************/ 

int get_RPM();
void Toggle_Fan();
void Turn_Off_Fan();
void Turn_On_Fan();
void Increase_Speed();
void Decrease_Speed();
void do_update_pwm(char);
void Set_DC_RGB(int);
void Set_RPM_RGB(int);
void Set_TempC_RGB(signed char);

        /*************************************************************/ 
        /*                       Define Statements                   */ 
        /*************************************************************/ 

#define FAN_EN          PORTAbits.RA3
#define FAN_PWM         PORTCbits.RC2
#define FANON_LED       PORTAbits.RA1
