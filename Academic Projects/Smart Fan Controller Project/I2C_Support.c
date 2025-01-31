#include <stdio.h>

#include <p18f4620.h>
#include "I2C_Support.h"
#include "I2C.h"

        /*************************************************************/ 
        /*                       Define Statements                   */ 
        /*************************************************************/ 

#define ACCESS_CFG      0xAC
#define START_CONV      0xEE
#define READ_TEMP       0xAA
#define CONT_CONV       0x02
#define ACK     1
#define NAK     0

        /*************************************************************/ 
        /*                  Variable declarations                    */ 
        /*************************************************************/ 

extern unsigned char second, minute, hour, dow, day, month, year;
extern unsigned char setup_second, setup_minute, setup_hour, setup_day, setup_month, setup_year;
extern unsigned char alarm_second, alarm_minute, alarm_hour, alarm_date;
extern unsigned char setup_alarm_second, setup_alarm_minute, setup_alarm_hour;

        /*************************************************************/ 
        /*         DS1621_Read_Temp : Read the temperature           */ 
        /*************************************************************/ 

int DS1621_Read_Temp()
{
char Device = 0x48;                   // Correct device address
char Cmd = READ_TEMP;
char Data_Ret;    
    I2C_Start();                      // Start I2C protocol
    I2C_Write((Device << 1) | 0);     // Device address
    I2C_Write(Cmd);                   // Send register address
    I2C_ReStart();                    // Restart I2C
    I2C_Write((Device << 1) | 1);     // Initialize data read
    Data_Ret = I2C_Read(NAK);         // Read temperature data with NAK
    I2C_Stop(); 
    return Data_Ret;
}

        /*************************************************************/ 
        /*   DS1621_Read_Temp_Bad : Read the temperature badly       */ 
        /*************************************************************/ 

int DS1621_Read_Temp_Bad()
{
char Device = 0x49;                   // Incorrect device address
char Cmd = READ_TEMP;
char Data_Ret;    
    I2C_Start();                      // Start I2C protocol
    I2C_Write((Device << 1) | 0);     // Device address
    I2C_Write(Cmd);                   // Send register address
    I2C_ReStart();                    // Restart I2C
    I2C_Write((Device << 1) | 1);     // Initialize data read
    Data_Ret = I2C_Read(NAK);         // Read temperature data with NAK
    I2C_Stop(); 
    return Data_Ret;
}

        /*************************************************************/ 
        /*       DS1621_Init : Initialize temperature sensor         */ 
        /*************************************************************/ 

void DS1621_Init()
{
char Device = 0x48;
    I2C_Write_Cmd_Write_Data (Device, ACCESS_CFG, CONT_CONV); 
    I2C_Write_Cmd_Only(Device, START_CONV);
}

        /*************************************************************/ 
        /*        DS3231_Read_Time : Read the time and date          */ 
        /*************************************************************/ 

void DS3231_Read_Time()
{
char Device = 0x68;                   // Device address for RTC
char Address = 0x00; 
char Data_Ret;    
    I2C_Start();                      // Start I2C protocol
    I2C_Write((Device << 1) | 0);     // DS3231 address Write mode
    I2C_Write(Address);               // Send register address
    I2C_ReStart();                    // Restart I2C
    I2C_Write((Device << 1) | 1);     // Initialize data read
    second = I2C_Read(ACK);           // Read the data from second to year
    minute = I2C_Read(ACK);           // Using I2C_Read() and sending acknowledge
    hour   = I2C_Read(ACK);
    dow    = I2C_Read(ACK);
    day    = I2C_Read(ACK);
    month  = I2C_Read(ACK);
    year   = I2C_Read(NAK);           // Send NAK to end the data read
    I2C_Stop();         
}

        /*************************************************************/ 
        /*      DS3231_Setup_Time : Setup the time and date          */ 
        /*************************************************************/ 

void DS3231_Setup_Time()
{
char Device = 0x68;
char Address = 0x00;
second = 0x35;                        // Setup time is 5:20:30
minute = 0x20;
hour   = 0x05;
dow    = 0x03;                        // Tuesday the 12th of November, 2024
day    = 0x12;
month  = 0x11;
year   = 0x24;
    I2C_Start();                      // Start I2C protocol
    I2C_Write((Device << 1) | 0);     // Device address Write mode
    I2C_Write(Address);               // Send register address
    I2C_Write(second);                // Write the second data to register
    I2C_Write(minute);                // Write the second data to register
    I2C_Write(hour);                  // Write the second data to register
    I2C_Write(dow);                   // Write the second data to register
    I2C_Write(day);                   // Write the second data to register
    I2C_Write(month);                 // Write the second data to register
    I2C_Write(year);                  // Write the second data to register
    I2C_Stop(); 
}

