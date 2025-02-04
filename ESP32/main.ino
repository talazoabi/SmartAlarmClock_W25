#include <Arduino.h>
#include <WiFiManager.h>
#include <WiFi.h>
#include "MyDisplay.h"
#include "MyFirebase.h"
#include "MyAudio.h"
#include "MyButtons.h"
#include "MyClock.h"
#include "secrets.h"
#include "parameters.h"

WiFiManager wifiManager;
char buffer[64];

//###### Memory ######
void freeHeap(int num);
//###### WiFi ######
void InitWiFi();
void resetESP();
//###### Audio ######
void InitSDCard();
void playAudio();
void DestroyAudio();
bool playFile(const char *file);
bool playText(const char *text);
void playTime();
void playDate();
void playDay();
void playTasks();
void playWeather();
//###### Time ######
void configNTP();
void configTime();
void updateTime();
//###### Display ######
void updateMode();
void showTime();
void showDate();
void showDay();
void showReminders();
void showWeather();
void showMessage();
//###### Tasks ######
bool isGetTask();
void insertTask(string& id_task, String& str_doc_task);
void insertEvent(string& id_task, String& str_doc_task);
//###### Alarms ######
bool isGetClock();
bool isGetAlarm();
pair<pair<String,String>,String> get_pair(String& alarm_id , int day);
void alarmDataExtraction(String& str_document);
void insert_alarm(String& alarm_id, String& days_doc_str, String& clock, String& label, String& alarm_isEnabled, String& snoozeTime);
void insertAlarmsId(String& alarm_id,String& clock, String& label, String& alarm_isEnabled, String& snoozeTime);
void update_alarmID(String alarm_id, String& updated_json_str);
void delete_alarm(String alarm_id);
void removeAlarmsId(String& alarm_id);
void clear_alarmId(String alarm_id);
void stopAlarmFunc(String jsonPath);
void calculateTimeSnooze();
void snoozeAlarmFunc();
void changeRingtoneName();
void updateStopAlarm();
//###### print func ######
void print_map();
void print_vector();
void printMapSnooze();
void print_tasks();
//###### Firebase ######
void FirebaseInit();
void StreamCallBackRoot(FirebaseStream data);
void DemoStreamCallback(FirebaseStream data);
void DemoStreamTimeoutCallback(bool timeout);
void streamCallbackAlarms(FirebaseStream& data, bool first_call, String alarms_doc_str);
void StreamCallBackTasks(FirebaseStream& data, bool is_first_call_tasks, String str_doc_tasks);
void StreamCallBackEvents(FirebaseStream& data, bool is_first_call_tasks, String str_doc_tasks);
void StreamCallBackSettings(String& setting_doc_str);

// ############################## Setup ##############################
void setup()
{
    // Initialize Serial
    Serial.begin(115200);
    freeHeap(1);  // Free heap size 1: 181488 bytes // Free heap size 1: 179536 bytes

    // Initialize Display
    DisplayInit();
    freeHeap(2); // Free heap size 2: 181256 bytes // Free heap size 2: 184288 bytes

    // Initialize WiFi
    InitWiFi();
    Serial.println("*WiFi init.*");
    freeHeap(3); // Free heap size 3: 133920 bytes // Free heap size 3: 136188 bytes // new ESP Free heap size 3: 150436 bytes

    // Initialize Time
    _Display.print("NTP");
    Serial.println("*ntp sync*");
    configNTP();
    

    // Initialize Firebase
    FirebaseInit();
    FirebaseStreamRoot();
    freeHeap(4); // Free heap size 4: 108460 bytes // Free heap size 4: 111368 bytes // new Free heap size 4: 123248 bytes

    // Initialize Audio
    DestroyAudio();
    InitSDCard();

    // Initialize Buttons
    initButtons();
    freeHeap(5); // Free heap size 5: 80748 bytes // Free heap size 5: 83652 bytes // new ESP Free heap size 5: 127056 bytes

}


// ############################## Loop ##############################

void loop()
{
    updateTime();
    updateMode();

    if (isTask) {
      showMessage();
    }

    switch (mode)
    {
      case 1:
      if(!displayOff){
        if (!isTask && !isAlarm)
          showTime();
          modeChanged = false;
          break;
      }
      case 2:
      if(!displayOff){
        if (!isTask && !isAlarm)
          showDate();
          modeChanged = false;
          break;
      }
      case 3:
      if(!displayOff){
        if (!isTask && !isAlarm)
          showDay();
          modeChanged = false;
          break;
      }
      case 4:
      if(!displayOff){
        if (!isTask && !isAlarm)
          showReminders();
          modeChanged = false;
          break;
      }
      case 5:
      if(!displayOff){
        if (!isTask && !isAlarm)
          showWeather();
          modeChanged = false;
          break;
      }
    }


    if ((!isAlarm && !isTask) && isButtonPressed(BUTTON_DO_PIN) == SHORT_PRESS)
    {
      if(!displayOff && !audio.isRunning()){
          if (mode == 1) {
            playTime();
          }
          else if (mode == 2) {
            // Serial.println("playing date");
            playDate();
          }
          else if (mode == 3) {
            // Serial.println("playing day");
            playDay();
          }
          else if (mode == 4) {
            // Serial.println("playing tasks");
            playTasks();
          }
          else if (mode == 5) {
            // Serial.println("playing tasks");
            playWeather();
          }
      }
    }
// --------- Display --------- //
    int val = analogRead(INPUT_PIN);
    if (autoBrightness)
      _Display.setIntensity(15 - (val / (4095 / 15)));
    else
    {
      _Display.setIntensity(_Brightness);
    }
    _Display.displayAnimate();

// --------- ----- --------- //
    playAudio();
    if (sec < millis()) { //loop every 1 second
      if(isTask) Serial.println("isTask is true");
      else Serial.println("prsent task is false");
      if(stopAlarm) Serial.println("stopAlarm is true");
      else Serial.println("stopAlarm is false");
      if(isAlarm) Serial.println("isAlarm is true");
      else Serial.println("isAlarm is false");
      Serial.println("numTaskToday = ");
      Serial.println(numTaskToday);
      Serial.println("Temperature =");
      Serial.println(weatherDeg);
      Serial.println("ringtone =");
      Serial.println(_Ringtone);
      if(lightEnable) Serial.println("lightEnable is true");
      else Serial.println("lightEnable is false");
      freeHeap(123);

      sec = millis() + 1000;
      
      if (mode == 1) {
        Serial.print("Mode 1 - Time is: ");
        Serial.println(_Time);
      }
      else if (mode == 2) {
        Serial.print("Mode 2 - Date is: ");
        Serial.println(_Date);
      }
      else if (mode == 3) {
        Serial.print("Mode 3 - Day is: ");
        Serial.println(_Day);
      }
      else if (mode == 4) {
        Serial.print("Mode 4 - Taks have: ");
        Serial.println(numTaskToday);
      }
      else if (mode == 5) {
        Serial.print("Mode 5 - Weather: ");
        Serial.println(weatherDeg);
      }
      

      if (!stopAlarm && (isGetAlarm() || isGetTask())) {
          Serial.println("Alarm\Task  is on !");
          printMapSnooze();
          if (!isAlarm && isGetAlarm()) { // new alarm
              startAlarm = millis();
              isAlarm = true;
              isGradual = true;
              sButtonPressed = false;
              strip.clear();  
              strip.show();
          }
          if(!isTask && isGetTask()){ // new task
              isTask=true;
              startAlarm = millis();
          }
          if(isTask){
              sprintf(buffer, "You have a task now: %s", msg.c_str());
              if(!audio.isRunning()){
                  playText(buffer);
              }
          }
          else {
              _Display.displayAnimate();
              int dday = map_id_to_days[alarm_ID.c_str()][0];
              pair<pair<String,String>,String> curr_alarm = get_pair(alarm_ID, dday);

              char buff[64];
              String ilabel = curr_alarm.second;
              Serial.println("label = ");
              Serial.println(ilabel);
                sprintf(buff, "%s", curr_alarm.second == String("null") ? "Alarm" : (curr_alarm.second).c_str());
              if (_Display.displayAnimate()) {
                  _Display.displayText(buff, PA_CENTER, 30, 0, PA_SCROLL_LEFT, PA_SCROLL_LEFT);
              }
              else{
                Serial.println("#### NO DISPLAY ####");
              }

              sprintf(buffer,"Alarms/%s.mp3", _Ringtone.c_str());
              if(playFile(buffer)){
                Serial.println("playing...");
              }
          }
      }
      else {
          if(isTask){
              isTask = false;
          }
          else {
              Serial.println("update isAlarm to false");
              isAlarm = false;
          }
      }

      if(lightEnable && !isAlarm){
          // Serial.println("in loop isEnable");
          changeColor();
      }

      if(isGradual){
        gradualSunrise();
      }

    } //every second 

    if (WiFi.status() != WL_CONNECTED && sec_wifi < millis()) {
        wifiCounter++;
        cnctDsble = true;
        sec_wifi = millis() + 5000;
        Serial.println("No WiFi");
        is_first_call_root = true;
        _Display.print("No WiFi");
        if(wifiCounter >= 60){
          resetESP();
        }
        unsigned long startTime = millis();
        while (!audio.isRunning() && millis() - startTime < 3000) {
            updateMode();
            if (modeChanged) {
                break;
            }
        }
    }

    int press = isButtonPressed(BUTTON_ALARM_PIN);
    if (audio.isRunning())
    {         
      audio.loop();
      if (isAlarm && press == SHORT_PRESS) {
          //snooze
          audio.stopSong();
          // char path_char [1024];
          // sprintf(path_char,"/App/Alarms/%s",  alarm_ID.c_str());
          // Serial.println("snooooooooooze is : ");
          // Serial.print("path_char is : ");
          // Serial.println(path_char);
          snoozeAlarmFunc();
          isAlarm = false;
          stopAlarm = true;
          isGradual = false;
          sButtonPressed = true;
          strip.clear();  
          strip.show();
          currentPixel = 0;
      }          
      else if ((isAlarm || isTask) && press == LONG_PRESS) {
          audio.stopSong();
          if (isTask) {
              stopAlarm = true;
              isTask = false;
              _Display.displayClear();
              sprintf(buffer,"App/Tasks/%s",task_id.c_str());
              Firebase.RTDB.deleteNode(&fbdo1, buffer);
              fbdo1.clear();
          }
          else if(isAlarm){
            char path_char [1024];
            sprintf(path_char,"/App/Alarms/%s",  alarm_ID.c_str());
            stopAlarmFunc(path_char);
            
            isAlarm = false;
            stopAlarm = true;
            isGradual = false;
            sButtonPressed = true;
            strip.clear();  
            strip.show();
            currentPixel = 0;
          }
      } //end of stopAlarm


    } //end of audio running

    if (isAlarm && press == SHORT_PRESS) {
        //snooze
        if (audio.isRunning()){
            audio.stopSong();
        }
        // char path_char [1024];
        // sprintf(path_char,"App/Alarms/%s",  alarm_ID.c_str());
        snoozeAlarmFunc();
        isAlarm = false;
        stopAlarm = true;
        isGradual = false;
        sButtonPressed = true;
        strip.clear();  
        strip.show();
        currentPixel = 0;
    }

    else if ((isTask || isAlarm) && press == LONG_PRESS){
        if (audio.isRunning()){
            audio.stopSong();
        }
        if (isTask){
            stopAlarm = true;
            isTask = false;
            sprintf(buffer,"App/Tasks/%s",task_id.c_str());
            Firebase.RTDB.deleteNode(&fbdo1, buffer);
        }
        else if(isAlarm) {
            char path_char [1024];
            isAlarm = false;
            stopAlarm = true;
            isGradual = false;
            sButtonPressed = true;
            strip.clear();  
            strip.show();
            currentPixel = 0;
            
            sprintf(path_char,"App/Alarms/%s",  alarm_ID.c_str());
            stopAlarmFunc(path_char);
        }
    }

    if(cnctDsble){
        // Serial.println("#########");
        // freeHeap(500);
        // Serial.println("#########");
        if(WiFi.status() == WL_CONNECTED){
            char text[40];
            char path_char [1024];
            Serial.println("Connection re-established");
            _Display.print("WiFi OK");
            sprintf(text, "/%s/WiFi/connected.mp3", _Language.c_str());
            playFile(text);
            delay(2000);
            cnctDsble = false;
            wifiCounter = 0;
            for (const auto& entry : map_id_to_enable_offline) {
              string alarm_id = entry.first;   // Access the key             
              sprintf(path_char,"App/Alarms/%s",  alarm_id.c_str());
              stopAlarmFunc(path_char);
          }
          map_id_to_enable_offline.clear();

        }
        // Serial.println("#########");
        // freeHeap(501);
        // Serial.println("#########");
        
        if(stopAlarm && press == LONG_PRESS){
            sButtonPressed = true;
            map_id_to_enable_offline[alarm_ID.c_str()] = "false";
        }
    }

    updateStopAlarm();

}

void freeHeap(int num)
{
  size_t freeHeap = esp_get_free_heap_size();
  Serial.print("Free heap size ");
  Serial.print(num);
  Serial.print(": ");
  Serial.print(freeHeap);
  Serial.print(" bytes\n");
}

void InitWiFi() {
    bool wifiCnct;
    char text[30];
    _Display.print("WiFi");
    wifiCnct = wifiManager.autoConnect(WIFI_SSID, WIFI_PASSWORD); // password protected ap

    if (wifiCnct) {
        Serial.println("Connected to Wi-Fi");
        wifiConnected = true;
    } else {
      Serial.println("Failed to connect to Wi-Fi");
      ESP.restart();
      delay(1000);
    }
}

void resetESP(){
    Serial.println("****** Reset *******");
    _Display.print("Reset");
    delay(1500);
    wifiManager.resetSettings();
    ESP.restart();
}

void updateMode() {
    int rButton = isButtonPressed(BUTTON_RESET_PIN);
    if (isButtonPressed(BUTTON_NEXT_PIN) == SHORT_PRESS) // if pressed change mode
    {
        if(!displayOff){
          mode = mode == 5 ? 1 : mode + 1;
          modeChanged = true;
        }
    }
  else if (rButton == SHORT_PRESS) { // turn off screen
      if(!displayOff){
        _Display.displayClear();
        displayOff = true;
      } else{
        displayOff = false;
    }
  } else if (rButton == LONG_PRESS) { // reset
      resetESP();
  }
  

    if (isButtonPressed(BUTTON_DO_PIN) == SHORT_PRESS)
    {
      if(!displayOff && !audio.isRunning()){
          if (mode == 1) {
            playTime();
          }
          else if (mode == 2) {
            // Serial.println("playing date");
            playDate();
          }
          else if (mode == 3) {
            // Serial.println("playing day");
            playDay();
          }
          else if (mode == 4) {
            playTasks();
            // Serial.println("playing tasks");
          }
          else if (mode == 5) {
            playWeather();
            // Serial.println("playing Weather");
          }
      }
    }
}

// ############################## Audio ##############################

void InitSDCard()
{
    pinMode(SD_CS, OUTPUT);
    digitalWrite(SD_CS, HIGH);
    SPI.begin(SPI_SCK, SPI_MISO, SPI_MOSI);
    SPI.setFrequency(1000000);
    if (!SD.begin(SD_CS))
    {
        Serial.println("SD Card Mount Failed");
        while (true)
          ;
    }
    else{
      Serial.println("SD Card init successfully");
    }
}

void DestroyAudio()
{
  if (!audioDestroyed)
  {
    Serial.print("Audio destroyed\n");
    audio.~Audio();
    audioDestroyed = true;
    audioInit = false;
    isPressed = false;
    freeHeap(8);
  }
  Serial.print("EXIT Audio destroyed\n");
}

void playAudio()
{
  if (audioInit)
  {
    if (audio.isRunning())
      audio.loop();
    else
      DestroyAudio();
  }
}

bool playFile(const char *file)
{
    Serial.print(file);
    if (SD.open(file))
      Serial.println(" exist");
    else
      Serial.println(" does not exist");


    if (!audioInit)
    {     
      new (&audio) Audio();
      audioDestroyed = false;
      audio.setPinout(I2S_BCLK, I2S_LRC, I2S_DOUT);
      audio.setVolume(_Volume);

      if (!audio.connecttoFS(SD, file))
      {
        Serial.println("PROBLEM");
        DestroyAudio();
        return false;
      }
      
      audioInit = true;
      return true;
    }

    return true;   
}

bool playText(const char *text)
{
  if (!audioInit)
  {
    new (&audio) Audio();
    audioDestroyed = false;
    audio.setPinout(I2S_BCLK, I2S_LRC, I2S_DOUT);
    audio.setVolume(_Volume);

    if (!audio.connecttospeech(text, "en"))
    {
      Serial.println("PPROBLEM");
      DestroyAudio();
      return false;
    }

    audioInit = true;
    return true;
  }
}

void playTime() {
    String hh=_Time.substring(0,2);
    String mm = _Time.substring(3, 5);
    sprintf(buffer,"/%s/%s/%s_%s.mp3",_Language.c_str() ,hh.c_str(),hh.c_str(),mm.c_str());
    Serial.println("buffer = ");
    Serial.println(buffer);
    if(playFile(buffer)){
      Serial.println("playing Time...");
    }
    Serial.print("path: ");
    Serial.println(buffer);
}

void playDate() {
    char fileName[30];
    sprintf(fileName, "/%s/Dates/%02s_%02s_%04s.mp3", _Language, String(day).c_str(), String(month).c_str(), String(2000 + year).c_str());
    if (!playFile(fileName))
    {
      sprintf(fileName, "Today is %s %d, %d", months[month], day, 2000 + year);
      playText(fileName);
    }
}

void playDay() {
  sprintf(buffer, "/%s/Days/%s.mp3", _Language.c_str(), _Day.c_str());
  playFile(buffer);
  Serial.print("path: ");
  Serial.println(buffer);
}

void playWeather() {
  char degText[40];
  if(WiFi.status() == WL_CONNECTED){
      sprintf(degText,"It's %d degrees in Haifa",  weatherDeg);
      playText(degText);
  } else{
      sprintf(degText, "/%s/WiFi/checkWiFi.mp3", _Language.c_str());
      playFile(degText); 
  }
}

void playTasks() {

  char text[200];
  DestroyAudio();
  if(WiFi.status() == WL_CONNECTED){
      sprintf(text, "You have %s %s for today. %s", numTaskToday == 0 ? "no" : String(numTaskToday).c_str(), numTaskToday == 1 ? " task" : " tasks", numTaskToday == 0 ? "have fun" : "have a good day");
      playText(text);
  } else{
      sprintf(text, "/%s/WiFi/checkWiFi.mp3", _Language.c_str());
      playFile(text); 
  }
}

// ############################## Time / Clock ##############################
void configNTP()
{
  struct tm timeinfo;
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer1, ntpServer2);
  while (!getLocalTime(&timeinfo))
  {
      Serial.println("Failed to obtain time");
  }
  Serial.println("time obtained");
  _Day = int_to_string_days[timeinfo.tm_wday].substr(0, 3).c_str();
}

void updateTime() { 
    struct tm timeinfo;
    char appBuffer[64];
    if (!getLocalTime(&timeinfo))
    {
        Serial.println("Failed to obtain time");
        return;
    }

    setVars(&timeinfo);
    if (m == 0 && s >= 3 && s < 5 && !audio.isRunning())
    {
        char fileName[25];
        sprintf(fileName, "%s/%02s/%02s_%02s.mp3", _Language.c_str(), String(h).c_str(), String(h).c_str(), String(m).c_str());
        if (!playFile(fileName))
        {
            sprintf(fileName, "it is: %02s:%02s %s", String(h).c_str(), String(m).c_str(), h < 12 ? "am" : "pm");
            playText(fileName);
        }
    }

    _Day = int_to_string_days[wday - 1].substr(0, 3).c_str();

    sprintf(buffer, "%d%c%d%c%d", day, '.', month, '.', year);
    sprintf(appBuffer, "%02d%02d%d", day, month, year);

    _Date = buffer;
    _appDate = appBuffer;

    if (showSec)
        sprintf(buffer, "%02d%c%02d%c%c%c", h, ':', m, ':', s / 10 + 1, s % 10 + 1);
    else
        sprintf(buffer, "%02d%c%02d", h, ':', m);

    _Time = buffer;
    time_FB_format = timeinfo;
}

// ################################# Display #################################
void showWeather(){
  char degText[10];
  sprintf(degText,"%d C",  weatherDeg);
  _Display.print(degText);
}

void showTime()
{
    _Display.print(_Time.c_str());
}

void showDate() {
    _Display.print(_Date.c_str());

}

void showDay() {
    _Display.print(_Day.c_str());
}

void showReminders() {
  // Serial.println("### in showReminders ###");  
  if(changedTasks){
      int num_msg=0;
      tasks_for_today = "Tasks for today: ";
      for(auto it = tasks_map.begin(); it != tasks_map.end(); it++){
          Serial.println("it second.first");
          Serial.println(it->second.first);
          if(it->second.first.startsWith(_appDate.c_str())){
            num_msg++;
            Serial.println("num_msg++");
            sprintf(buffer,"task%d :  %s  ",num_msg,it->second.second.c_str());
            tasks_for_today+=buffer;
          }
      }
      numTaskToday = num_msg;
      changedTasks = false;
  }

    if(numTaskToday == 0){
        tasks_for_today = "No tasks for today - have fun";
    }

    if(_Display.displayAnimate()) {
      _Display.displayText(tasks_for_today.c_str(), PA_CENTER, 30, 100, PA_SCROLL_LEFT, PA_SCROLL_LEFT);
    }
}

void showMessage(){
    sprintf(buffer,"You have a task now : %s. ",msg.c_str());
    if (_Display.displayAnimate()){
      _Display.displayText(buffer, PA_CENTER, 50, 100, PA_SCROLL_LEFT, PA_SCROLL_LEFT);
    }
}

void changeColor() {
    Serial.println("### in changeColor ###");
  // Set all pixels to the current color
      if(currentColor.equals("White"))
        setAllPixels(255, 255, 255);  // White
      else if(currentColor.equals("Red"))
        setAllPixels(255, 0, 0);  // Red
      else if(currentColor.equals("Green"))
        setAllPixels(0, 255, 0);  // Green
      else if(currentColor.equals("Blue"))
        setAllPixels(0, 0, 255);  // Blue
      else if(currentColor.equals("Pink"))
        setAllPixels(255, 20, 147);  // Pink
      else if(currentColor.equals("Orange"))
        setAllPixels(200, 100, 0);  // Orange
      else
        setAllPixels(255, 255, 255);
}

void setAllPixels(int r, int g, int b) {
  Serial.println("### in SetAllPixels");
  for (int i = 0; i < NUMPIXELS; i++) {
    strip.setPixelColor(i, strip.Color(r, g, b));  // Set pixel color
  }
  strip.show();  // Update the NeoPixel matrix
}
// ################################# Firebase ################################
void FirebaseInit()
{
    // Initialize Firebase
    config.host = DATABASE_URL;
    config.api_key = API_KEY;
    config.token_status_callback = tokenStatusCallback;

    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
}

void FirebaseStreamRoot()
{
    Firebase.RTDB.beginStream(&streamRoot, "/App");
    Firebase.RTDB.setStreamCallback(&streamRoot, StreamCallBackRoot, DemoStreamTimeoutCallback);  
}

//########## StreamCallBack ##########
void DemoStreamCallback(FirebaseStream data)
{
  Serial.printf("sream path, %s\nevent path, %s\ndata type, %s\nevent type, %s\n\n",
                data.streamPath().c_str(),
                data.dataPath().c_str(),
                data.dataType().c_str(),
                data.eventType().c_str());
  printResult(data); // see addons/RTDBHelper.h
  Serial.println();
}

void DemoStreamTimeoutCallback(bool timeout) {
    if (timeout){
        Serial.println("Stream timeout, resume streaming...");
    }
}

void StreamCallBackSettings(String& setting_doc_str){
  Serial.println("### in callBackSettings ###\n");
  JsonDocument doc;
  deserializeJson(doc, setting_doc_str);
  _Language = doc["Language"].as<String>();
  Serial.println(_Language);
  _Volume = doc["Volume"].as<int>();
  Serial.println(_Volume);
  _Brightness = doc["Brightness"].as<int>();
  currentColor = doc["Color"].as<String>();
  Serial.println("currentColor = ");
  Serial.println(currentColor);
  Serial.println(_Brightness);
  _Ringtone = doc["Ringtone"].as<String>();
  lightEnable = doc["lightEnabled"].as<bool>();
  if(!lightEnable){
      strip.clear();  
      strip.show();
  }

  autoBrightness = doc["autoBrightness"].as<bool>();
  Serial.println(_Ringtone);
  showSec = doc["showSeconds"].as<bool>();
  _Display.setIntensity(_Brightness);
  audio.setVolume(_Volume);
}

void streamCallbackAlarms(FirebaseStream& data, bool first_call, String alarms_doc_str)
{ 
  Serial.println("### in callBackAlarms ###");
  Serial.println();

  if(first_call){
      JsonDocument doc;
      deserializeJson(doc, alarms_doc_str);
      for(JsonPair kv : doc.as<JsonObject>()){
          String jval = kv.value().as<String>();
          String alarm_id = kv.key().c_str();
          alarmDataExtraction(jval);
      }
  }
   else{
      if(data.dataType() == "null"){
        String alarm_id = data.dataPath().substring(8);
        delete_alarm(alarm_id.c_str());
      }
      else if(data.eventType() == "patch"){
        String alarm_id = data.dataPath().substring(8);
        String str_data = data.jsonString();
        update_alarmID(alarm_id,str_data);
        
      }
      else{
        String str_data = data.jsonString();
        alarmDataExtraction(str_data); 
      }
        
   }

  Serial.println();
}


void StreamCallBackTasks(FirebaseStream& data, bool is_first_call_tasks, String str_doc_tasks){
  Serial.println("### in callbackTasks ###");
  Serial.println();

  if (is_first_call_tasks){
    JsonDocument doc;
    deserializeJson(doc, str_doc_tasks);
    for(JsonPair kv : doc.as<JsonObject>()){
        string id_task = kv.key().c_str();
        String str_doc_task = kv.value().as<String>();
        insertTask(id_task,str_doc_task);
    }
  }
  else{
    if(data.dataType() == "null"){
      string id_task = data.dataPath().substring(7).c_str();
      String date_task = tasks_map[id_task].first;
      if(date_task.startsWith(_appDate.c_str())/*formatDate().c_str())*/){
        numTaskToday-=1;
      }
      tasks_map.erase(id_task);
    } else{
      string id_task = data.dataPath().substring(7).c_str();
      String str_doc_task = data.jsonString();
      insertTask(id_task,str_doc_task);
    }
  }
  changedTasks = true;
  printMapTasks();
}

void StreamCallBackEvents(FirebaseStream& data, bool is_first_call_tasks, String str_doc_tasks){
  Serial.println("### in callbackEvents ###");
  Serial.println();

  if (is_first_call_tasks){
    JsonDocument doc;
    deserializeJson(doc, str_doc_tasks);
    for(JsonPair kv : doc.as<JsonObject>()){
        string id_task = kv.key().c_str();
        String str_doc_task = kv.value().as<String>();
        insertEvent(id_task,str_doc_task);
    }
  }
  else{
    if(data.dataType() == "null"){
      string id_task = data.dataPath().substring(7).c_str();
      String date_task = tasks_map[id_task].first;
      if(date_task.startsWith(_appDate.c_str())/*formatDate().c_str())*/){
        numTaskToday-=1;
      }
      tasks_map.erase(id_task);
    } else{
      string id_task = data.dataPath().substring(7).c_str();
      String str_doc_task = data.jsonString();
      insertEvent(id_task,str_doc_task);
    }
  }
  changedTasks = true;
  printMapTasks();
}

void StreamCallBackRoot(FirebaseStream data){
  Serial.println("### in callbackROOT ###");
  Serial.println();

  Serial.printf("sream path, %s\nevent path, %s\ndata type, %s\nevent type, %s\n\n",
                 data.streamPath().c_str(),
                 data.dataPath().c_str(),
                 data.dataType().c_str(),
                 data.eventType().c_str());
  if (is_first_call_root){
     is_first_call_root = false;
      String str_data = data.jsonString();
      JsonDocument doc_root;
      deserializeJson(doc_root, str_data);
      for(JsonPair kv : doc_root.as<JsonObject>()){
          String root_child = kv.key().c_str();
          if(root_child == "Alarms"){
              Serial.println("### root_child = Alarms ###");
              String alarms_doc_str = kv.value().as<String>();
              Serial.println("### callBack ALARMS ###");
              streamCallbackAlarms(data, true, alarms_doc_str);
          } else if (root_child == "Settings"){
            Serial.println("### root_child = Settings ###");
            String settings_doc_str = kv.value().as<String>();
            Serial.println("### callBack SETTINGS ###");
            StreamCallBackSettings(settings_doc_str);
            changeRingtoneName();
          } else if (root_child == "Tasks"){
            Serial.println("### root_child = tasks ###");
            String tasks_doc_str = kv.value().as<String>();
            Serial.println("### callBack TASKS ###");
            StreamCallBackTasks(data, true, tasks_doc_str);
            print_tasks();
          }
          else if (root_child == "Weather"){
            Serial.println("root_child == Weather");
            weatherDeg = doc_root["Weather"].as<int>();
            Serial.println(weatherDeg);
          }
          else{
            Serial.println("### root_child = GoogleEvents ###");
            String events_doc_str = kv.value().as<String>();
            Serial.println("### callBack TASKS ###");
            StreamCallBackEvents(data, true, events_doc_str);
          }
          
      }
  }
  else{
      Serial.println("Event path:");
      Serial.println(data.dataPath().c_str());
      if(data.dataPath().startsWith("/Alarms")){
          String str_data = data.jsonString();
          Serial.println("### callBack ALARMS ###");
          Serial.println("data = ");
          Serial.println(str_data);
          streamCallbackAlarms(data, false, str_data);
    } else if ( data.dataPath().startsWith("/Settings")){
          String str_data = data.jsonString();
          Serial.println("### callBack SETTINGS ###");
          StreamCallBackSettings(str_data);
          changeRingtoneName();
    } else if (data.dataPath().startsWith("/Tasks")) {
          String str_data = data.jsonString();
          Serial.println("### callBack TASKS ###");
          StreamCallBackTasks(data, false, str_data);
          print_tasks();
    } 
    else if (data.dataPath().startsWith("/Weather")) {
          weatherDeg = data.intData();
          Serial.println("WeatherDeg =");
          Serial.println(weatherDeg);
    }
    else{
        Serial.println("GoogleEvents");
        String str_data = data.jsonString();
        Serial.println("### callBack googleEvents ###");
        StreamCallBackEvents(data, false, str_data);
    }
  }
}
// ####### end of streamCallBack #######

//########## Alarm Handling ##########
void alarmDataExtraction(String& str_document){
  Serial.println("### in alarmDataExtraction ###");

  JsonDocument jdoc;
  deserializeJson(jdoc, str_document);  
  String clock = jdoc["Time"].as<String>();
  Serial.println("clock =");
  Serial.println(clock);
  String str_days = jdoc["selectedDays"].as<String>();
  String alarm_id = jdoc["Id"].as<String>();
  string str_alarm_id = alarm_id.c_str();
  Serial.print("alarm id is : ");
  Serial.println(alarm_id.c_str());
  String alarm_isEnabled = jdoc["isEnabled"].as<String>();
  Serial.println(alarm_isEnabled.c_str());
  String alarm_label = jdoc["Label"].as<String>();
  Serial.println(alarm_label.c_str());

  if (map_id_to_days.find(str_alarm_id) != map_id_to_days.end()){
      clear_alarmId(alarm_id);
  }
  insert_alarm(alarm_id, str_days, clock, alarm_label, alarm_isEnabled, clock);
}

void stopAlarmFunc(String jsonPath) {
  string alarm_id_str = alarm_ID.c_str();
  int dday = map_id_to_days[alarm_id_str][0];
  pair<pair<String,String>,String> curr_alarm = get_pair(alarm_ID, dday);
  FirebaseJson json;

  if (Firebase.ready()) {
    
    // Read the existing JSON object from Firebase
    if (Firebase.RTDB.getJSON(&fbdo, jsonPath)) {
      json = fbdo.jsonObject(); // Get the existing JSON object

      // Update a specific field within the JSON object
      json.set("isEnabled", "false");  // Update the "description" field

      // Write the updated JSON object back to Firebase
      if (Firebase.RTDB.setJSON(&fbdo, jsonPath, &json)) {
        Serial.println("Field updated successfully within JSON.");
      } else {
        Serial.println("Failed to update field within JSON.");
        Serial.println(fbdo.errorReason());
      }
      json.clear();

    } else {
      Serial.println("Failed to get JSON from Firebase.");
      Serial.println(fbdo.errorReason());
    }
  } else{ //offline
    
    map_id_to_enable[alarm_id_str] = "false";
    map_id_to_snooze[alarm_id_str] = curr_alarm.first.first;
  }

  fbdo.clear();  
}

void calculateTimeSnooze() {
        // Parse the time string
        Serial.print("======== in calculateTimeSnooze ====");
         
        // Add 5 minutes to the time
        time_FB_format.tm_min += 2;
            
        // Normalize the time (this handles minute overflow, etc.)
        mktime(&time_FB_format);

        // Convert back to string format
        char buffer[30];
        strftime(buffer, sizeof(buffer), "%H:%M", &time_FB_format);
        
        Serial.println(buffer);
        snoozeTime = String(buffer);
        
    
}

void snoozeAlarmFunc() {
    calculateTimeSnooze();

    string alarm_id_str = alarm_ID.c_str();
    map_id_to_snooze[alarm_id_str] = snoozeTime;
}

bool isGetClock() {
    Serial.println("### in isGetClock ###");

    int currentDay = string_to_int_days2[_Day.c_str()];
    if (alarms[currentDay].empty()) {
        Serial.println("No alarms for today.");
        return false;
    }
    for(pair<pair<String,String>,String> p : alarms[currentDay]){
        String isEnable = map_id_to_enable[p.first.second.c_str()];
        String snoozedTime = map_id_to_snooze[p.first.second.c_str()];
        
        Serial.println("_Time = ");
        Serial.println(_Time);
        Serial.println("alarm time");
        Serial.println(p.first.first);
        Serial.println("label: ");
        Serial.println(p.second);
        Serial.println("mode: ");
        Serial.println(isEnable);
        Serial.println("snooze: ");
        Serial.println(snoozedTime);
        if(isEnable == "true" && ((p.first).first == _Time.substring(0,5) || snoozedTime == _Time.substring(0,5))) {
            Serial.println("NIIIIIIIIIIIIIIIICEEE");
            Serial.println(p.first.second.c_str());
            alarmON = true;
            alarm_ID = p.first.second;
            return true;
        }
        else if (alarmON && !sButtonPressed){
          snoozeAlarmFunc();
        }
    }

    if(alarmON){
        isGradual = false;
        alarmON = false;
        strip.clear();  
        strip.show();
        currentPixel = 0;
    }

    return false;
}

bool isGetAlarm() {
    Serial.println("### in isGetAlarm ###");

    int currentDay = string_to_int_days1[_Day.c_str()];

    return currentDay >=0 && currentDay <7 && isGetClock();
}

void updateStopAlarm() {
  // 59800
  if (millis() - startAlarm > 60000) {
    stopAlarm = false;

  } 
}

pair<pair<String,String>,String> get_pair(String& alarm_id , int day) {
    Serial.println("### in get_pair ###");
    Serial.println();

    for(pair<pair<String,String>,String> p : alarms[day]){
        if((p.first).second == alarm_id){
            return p;
        }
    }
    return pair<pair<String,String>,String>(pair<String,String>("",""),"");
}


//######### Fetch Alarm #########
void insertAlarmsId(String& alarm_id,String& clock, String& label, String& alarm_isEnabled, String& snoozeTime){
  Serial.println("### in insertAlarmsId ###");
  Serial.println();

  string alarm_id_str = alarm_id.c_str();
  for(int d : map_id_to_days[alarm_id.c_str()]){
    pair<String,String> new_pair_clock(clock,alarm_id);
    pair<pair<String,String>,String> new_pair_en(new_pair_clock, label);
    alarms[d].insert(new_pair_en);
  }
  map_id_to_enable[alarm_id_str] = alarm_isEnabled;
  map_id_to_snooze[alarm_id_str] = snoozeTime;
}

void update_alarmID(String alarm_id, String& updated_json_str){
    Serial.println("### in update_alarmId ###");
    Serial.println();
    Serial.println(updated_json_str.c_str());

      string alarm_id_str = alarm_id.c_str();
      int d = map_id_to_days[alarm_id_str][0];
      JsonDocument update_doc;
      deserializeJson(update_doc, updated_json_str);
      String clock = update_doc["Time"].as<String>();
      String alarm_enable = update_doc["isEnabled"].as<String>();
      String alarm_label = update_doc["Label"].as<String>();

      if(clock == "null"){
        clock = get_pair(alarm_id,d).first.first;
      }
      if(alarm_enable == "null"){
        alarm_enable = map_id_to_enable[alarm_id_str];
    }

    removeAlarmsId(alarm_id);
    String str_days = update_doc["selectedDays"].as<String>();
    if(str_days == "null"){
        insertAlarmsId(alarm_id, clock, alarm_label, alarm_enable, clock);
    }
    else{
      map_id_to_days[alarm_id_str].clear();
      JsonDocument days_doc;
      deserializeJson(days_doc, str_days);
      for(JsonPair kv : days_doc.as<JsonObject>() ){
          if(kv.value().as<bool>()){
              int day = string_to_int_days1[kv.key().c_str()];
              map_id_to_days[alarm_id_str].push_back(day);
              pair<String,String> new_pair_clock(clock, alarm_id);
              pair<pair<String,String>,String> new_pair_enable(new_pair_clock, alarm_label);
              alarms[day].insert(new_pair_enable);
        }
      }
        insertAlarmsId(alarm_id, clock, alarm_label, alarm_enable, clock);
    }
}

void clear_alarmId(String alarm_id) {
  Serial.println("### in clear_alarmId ###");
  Serial.println();

  string alarm_id_str = alarm_id.c_str();
  for(int d : map_id_to_days[alarm_id_str]) {
    pair<pair<String,String>,String> p = get_pair(alarm_id,d);
    alarms[d].erase(p);
  }
  map_id_to_days[alarm_id_str].clear();
  map_id_to_enable.erase(alarm_id_str);
  map_id_to_snooze.erase(alarm_id_str);
}

void removeAlarmsId(String& alarm_id){
  Serial.println("### in removeAlarmsId ###");
  Serial.println();
  string alarm_id_str = alarm_id.c_str();
  for(int d : map_id_to_days[alarm_id_str]){
    pair<pair<String,String>,String> p = get_pair(alarm_id,d);
    alarms[d].erase(p);
  }
  map_id_to_enable.erase(alarm_id_str);
  map_id_to_snooze.erase(alarm_id_str);
}

//######### New Alarm #########

void insert_alarm(String& alarm_id, String& days_doc_str, String& clock, String& label, String& alarm_isEnabled, String& snoozeTime){
    Serial.println("### in insert_alarm ###");
    Serial.println();
    int i = 0;
    vector<int> vec_days;
    JsonDocument days_doc;
    deserializeJson(days_doc, days_doc_str);
    for(JsonPair kv : days_doc.as<JsonObject>() ){
        if(kv.value().as<bool>()){
            i++;
            Serial.println("i =");
            Serial.println(i);
            int cDay = string_to_int_days1[kv.key().c_str()];
            vec_days.push_back(cDay);
            pair<String,String> new_pair_clock(clock,alarm_id);
            pair<pair<String,String>,String> pair_with_enable(new_pair_clock, label);
            Serial.println("pair.first.first = ");
            Serial.println(pair_with_enable.first.first);
            Serial.println("pair.first.second = ");
            Serial.println(pair_with_enable.first.second);
            Serial.println("pair.second = ");
            Serial.println(pair_with_enable.second);
            alarms[cDay].insert(pair_with_enable);
            print_vector();
      }
    }
    if(i == 0){ //all days are off -> alarm is for today
      Serial.println("all days are off so alarm is for TODAY");
      Serial.println("_Day =");
      Serial.println(_Day);
      int cDay = string_to_int_days2[_Day.c_str()];
      Serial.println("cDay =");
      Serial.println(cDay);
      vec_days.push_back(cDay);
      pair<String,String> new_pair_clock(clock,alarm_id);
      pair<pair<String,String>,String> pair_with_enable(new_pair_clock, label);
      Serial.println("pair.first.first = ");
      Serial.println(pair_with_enable.first.first);
      Serial.println("pair.first.second = ");
      Serial.println(pair_with_enable.first.second);
      Serial.println("pair.second = ");
      Serial.println(pair_with_enable.second);
      alarms[cDay].insert(pair_with_enable);

    }
    string str_alarm_id = alarm_id.c_str();
    map_id_to_days[str_alarm_id] = vec_days;
    map_id_to_enable[str_alarm_id] = alarm_isEnabled;
    map_id_to_snooze[str_alarm_id] = snoozeTime;


}

void delete_alarm(String alarm_id){
  Serial.println("### in delete_alarm ###");
  Serial.println();
  string alarm_id_str = alarm_id.c_str();
    for(int d : map_id_to_days[alarm_id_str]) {
        pair<pair<String,String>,String> p = get_pair(alarm_id,d);
        alarms[d].erase(p);
    }
    map_id_to_days.erase(alarm_id_str);
    map_id_to_enable.erase(alarm_id_str);
    map_id_to_snooze.erase(alarm_id_str);
}

//########## Task/GoogleEvents Handling ##########
bool isGetTask() {
  Serial.println("### in isGetTask ###");
  Serial.println();

  String tmp_current_time = _appDate;// formatDate();
  Serial.print("current date (_appDate) = ");
  Serial.println(tmp_current_time);
  tmp_current_time+=_Time;
  Serial.print("current date = ");
  Serial.println(tmp_current_time);
  for(auto it = tasks_map.begin(); it != tasks_map.end(); it++){
    if(it->second.first == tmp_current_time) {
      msg = it->second.second;
      task_id = it->first;
      return true;
    }
  }
  task_id="";
  msg="";
  return false;
}

void insertTask(string& id_task, String& str_doc_task){
        Serial.println("### in insert_task ###");

        JsonDocument doc_task;
        deserializeJson(doc_task, str_doc_task);
        String date_task = doc_task["Date"].as<String>().c_str();

        if(date_task == _appDate.c_str()){
          numTaskToday+=1;
        }
        String message_task = doc_task["Label"].as<String>();
        String clock_task = doc_task["Time"].as<String>().c_str();
        date_task+=clock_task;

        pair<String,String> new_pair_task(date_task, message_task);
        tasks_map[id_task] = new_pair_task;
}

void insertEvent(string& id_task, String& str_doc_task) {
        Serial.println("### in insert_event ###");
        Serial.println();

        JsonDocument doc_task;
        deserializeJson(doc_task, str_doc_task);
        String date_task = doc_task["Date"].as<String>().c_str();

        if(date_task == _appDate.c_str()){
          numTaskToday+=1;
        }
        String message_task = doc_task["Summary"].as<String>();
        String clock_task = doc_task["Start"].as<String>().c_str();
        String duration_task = doc_task["Duration"].as<String>().c_str();
        date_task+=clock_task;
        // ---- added ----
        message_task += String(" at ");
        message_task += clock_task;
        message_task += String(" for ");
        message_task += duration_task;
 
        pair<String,String> new_pair_task(date_task, message_task);

        tasks_map[id_task] = new_pair_task;
}

//########## other ##########
void changeRingtoneName(){
    if(_Ringtone == "Ringtone 1")
        _Ringtone = String("ringtone1");
    else if (_Ringtone == "Ringtone 2")
        _Ringtone = String("ringtone2");
    else if(_Ringtone == "Ringtone 3")
        _Ringtone = String("ringtone3");
    else if(_Ringtone == "Ringtone 4")
        _Ringtone = String("ringtone4");
    else
        _Ringtone = String("ringtone5");

}

//########## print functions ##########
void print_map() {
  Serial.println("printing map");
    for(auto it = map_id_to_days.begin(); it != map_id_to_days.end(); it++) {
        Serial.print(it->first.c_str());
        Serial.print(" : ");
        for(int d : it->second){
            Serial.print(d);
            Serial.print(" ");
        }
        Serial.println();
    }

}

void print_tasks() {
  Serial.println("printing tasks");
    for(auto it = tasks_map.begin(); it != tasks_map.end(); it++) {
        Serial.print(it->first.c_str());
        Serial.print(" : ");
        Serial.print(it->second.first.c_str());
        Serial.println("  ");
        Serial.print(it->second.second.c_str());
    }
}

void print_vector() {
    Serial.println("printing vector");
    for(int i = 0; i < 7; i++) {
        Serial.print("day ");
        Serial.print(i);
        Serial.print(" : ");
        for(pair<pair<String,String>,String> p : alarms[i]){
          Serial.print("the id ");
            Serial.print(p.first.second.c_str());
            Serial.print(" have clock : ");
            Serial.print(p.first.first.c_str());
            Serial.print(p.second);
            Serial.print(" :) ");
        }
        Serial.println();
    }
}

void printMapTasks(){
  for(auto it = tasks_map.begin(); it != tasks_map.end(); it++){
    Serial.print("id = ");
    Serial.print(it->first.c_str());
    Serial.print(" --> date_task: ");
    Serial.print(it->second.first.c_str());
    Serial.print(" , message_task:");
    Serial.println(it->second.second.c_str());
  }

}

void printMapSnooze(){
  for(auto it = map_id_to_snooze.begin(); it != map_id_to_snooze.end(); it++){
    Serial.print("id = ");
    Serial.print(it->first.c_str());
    Serial.print(" --> snoozeTime: ");
    Serial.print(it->second.c_str());
  }

}

