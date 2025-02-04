#ifndef MYCLOCK_H
#define MYCLOCK_H

#include <time.h>
#include <string>
#include <sstream>
#include <map>
#include "parameters.h"

using std::string;

// const char* ntpServer1 = "pool.ntp.org";
// const char* ntpServer2 = "time.nist.gov";
// // const char* ntpServer1 = "ntp.technion.ac.il";
// // const char* ntpServer2 = "ntp.technion.ac.il";

// const long gmtOffset_sec = 3600 * 2;
// const int daylightOffset_sec = 3600;

bool showSec = false;

// Time
String _Date; 
String _Time; 
String _Day;
String _appDate;
String snoozeTime;
struct tm time_FB_format;

uint32_t sec = millis();
uint32_t sec_wifi = millis();
unsigned long startAlarm;

bool isAlarm = false;
bool stopAlarm = false;
bool isGradual = false;
bool alarmON = false;



uint16_t h, m, s;
uint8_t wday;
int day;
int month;
int year;

std::map<int, string> int_to_string_days = {
    {0, "Sunday"},
    {1, "Monday"},
    {2, "Tuesday"},
    {3, "Wednesday"},
    {4, "Thursday"},
    {5, "Friday"},
    {6, "Saturday"}
};

char months[13][10] = {"", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};

void setVars(struct tm *p_tm)
{
    h = p_tm->tm_hour;
    m = p_tm->tm_min;
    s = p_tm->tm_sec;

    day = p_tm->tm_mday;
    month = p_tm->tm_mon + 1;
    year = p_tm->tm_year - 100;

    wday = p_tm->tm_wday + 1;
}

#endif