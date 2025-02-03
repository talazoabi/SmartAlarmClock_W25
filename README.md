![WiseRise](https://github.com/talazoabi/SmartAlarmClock_W25/blob/main/Assets/gif_wiserise.gif)

## WiseRise - A Smart Alarm Clock Project by :  Tala Zoabi & Maher Bitar
  
## Details about the project
**WiseRise** is an advanced smart alarm clock designed to improve productivity and efficiency. It integrates an Arduino-based ESP32 microcontroller and a Flutter-based Android app, which communicates seamlessly to manage tasks, set alarms, and sync with Google Calendar.

## Features
- **Personalized Alarm Experience**  
   WiseRise allows users to set custom alarms for specific dates and times, ensuring they never miss an important event. The system also features a **gradual wake-up light**, creating a more natural waking experience. Additionally, users can snooze alarms for a few extra minutes or choose from a variety of ringtones, adding a personal touch to the wake-up process. 

- **Task Management and Integration**
   One of the standout features of WiseRise is its integration with **Google Calendar**, providing real-time reminders throughout the day. In addition to calendar events, users can receive **voice reminders** for upcoming tasks, making it easier to stay on top of their schedule throughout the day.. This feature also includes **manual task input** for users who prefer to add tasks themselves.

- **Settings Control and User Interface**  
   The **Settings Control** system allows users to customize their experience by adjusting various features of the alarm clock. Users can control the **screen brightness** manually or enable **auto-brightness**, which adjusts based on ambient light in the room. The system also lets users control the **alarm volume**, set whether to **show seconds** in the time display, choose the **language** for the interface, and select their preferred **ringtone** for the alarm. This level of customization ensures the user experience is tailored to individual preferences.  Additionally, the system supports **offline functionality**, ensuring that the alarm will still work even without an active internet connection.

- **Button and Physical Control**  
   Physical buttons on the device provide users with convenient control over essential functions. Buttons allow for easy **snooze** activation, alarm dismissal, and toggling between different display modes. Users can also press a button to hear a summary of their tasks for the day or manually toggle through the different screen displays. The **button control** allows for a hands-on experience, perfect for users who prefer tactile interactions rather than relying on touchscreens.
 
## Folder description :
* ESP32: source code for the esp side (firmware).
* Documentation: wiring diagram + basic operating instructions
* Unit Tests: tests for individual hardware components (input / output devices)
* flutter_app : dart code for our Flutter app.
* Parameters: contains description of configurable parameters 
* Assets: 3D printed parts, Audio files used in this project, 

## Arduino/ESP32 libraries used in this project:
* Firebase Esp32 Client - Version 4.4.16
* ESP32-audioI2S-master - Version 3.0.13
* Adafruit NeoPixel - Version 1.12.3
* WiFiManager - Version 2.0.17
* ArduinoJson - Version 7.2.1
* MD_MAX72XX - Version 3.5.1
* MD_Parola - Version 3.7.3
* NTPClient - Version 3.2.1

## Hardware used in this project:
* ESP32
* MAX7219 8x32
* MAX98357
* micro-SD Card Module
* NeoPixel Matrix 8x8
* Light Sensor (LDR)
* Buttons X4

## Connection Diagram:
![WiseRise](https://github.com/talazoabi/SmartAlarmClock_W25/blob/main/Documentation/ConnectionDiagram.png)
## Project Poster:
![WiseRise](https://drive.google.com/file/d/1BfUkYLTmGm8Da4HlLJOf0UwWCrKVhTiH/view)
 
This project is part of ICST - The Interdisciplinary Center for Smart Technologies, Taub Faculty of Computer Science, Technion
https://icst.cs.technion.ac.il/
