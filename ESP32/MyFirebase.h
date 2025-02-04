#ifndef MYFIREBASE_H
#define MYFIREBASE_H

#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>
#include <set>
#include <unordered_map>
#include <vector>
#include <map>
#include <utility>
#include <string>
#include <ArduinoJson.h>


using std::string;
using std::vector;
using std::set;
using std::pair;
using std::unordered_map;

FirebaseAuth auth;
FirebaseConfig config;

FirebaseData streamRoot;
FirebaseData fbdo;
FirebaseData fbdo1;


std::map<string, int> string_to_int_days1 = {
    {"Sunday", 0},
    {"Monday", 1},
    {"Tuesday", 2},
    {"Wednesday", 3},
    {"Thursday", 4},
    {"Friday", 5},
    {"Saturday", 6}
};

std::map<string, int> string_to_int_days2 = {
    {"Sun", 0},
    {"Mon", 1},
    {"Tue", 2},
    {"Wed", 3},
    {"Thu", 4},
    {"Fri", 5},
    {"Sat", 6}
};

vector<set<pair<pair<String,String>,String> > > alarms(7);
unordered_map<string,vector<int>> map_id_to_days;
unordered_map<string,String> map_id_to_enable;
unordered_map<string,String> map_id_to_snooze;
unordered_map<string,String> map_id_to_enable_offline;

// Tasks
int numTaskToday = 0;
bool isTask = false;
unordered_map<string,pair<String,String>> tasks_map;// id->(task_date,task_message)
bool is_first_call_root = true;
String msg;
bool changedTasks = false;
string tasks_for_today = "";
string task_id="";
String alarm_ID="";

// WIFI
bool wifiConnected = false;
bool cnctDsble = false;
int wifiCounter = 0;

// Settings
bool autoBrightness = false;
String _Language = "English";
String _Ringtone = "ringtone1";
int _Volume = 10;
int _Brightness = 10;
int weatherDeg = 17;


#endif
