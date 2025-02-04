#ifndef DISPLAY_H
#define DISPLAY_H

// Include Libraries
#include <Adafruit_NeoPixel.h>
#include <MD_Parola.h>
#include <MD_MAX72xx.h>
#include <SPI.h>
#include "Font.h"
#include "parameters.h"

// // Define PINs
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW
// #define MAX_DEVICES 4

// #define CLK_PIN   14
// #define DATA_PIN  13
// #define CS_PIN    12

// #define INPUT_PIN 39 // which is "VN" pin


// #define PIN            22              // Pin connected to NeoPixel matrix
// #define NUMPIXELS      64            // 16x16 matrix = 256 pixels
// #define MATRIX_WIDTH   8             // Matrix width (16x16)
// #define MATRIX_HEIGHT  8             // Matrix height (16x16)
// #define BRIGHT_NESS    25       

// Define Display
MD_Parola _Display = MD_Parola(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

Adafruit_NeoPixel strip(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

// unsigned long previousMillis = 0;  // Stores the last time a LED was updated
// const long interval = 1000;        // Interval (1000 ms = 1 second)
int currentPixel = 0;              // Tracks which LED to turn on next
String currentColor = "White";
bool lightEnable = false;
// bool updLight = true;
bool enableAux = false;
bool displayOff = false;


void DisplayInit() {
  _Display.begin();
  _Display.setFont(0, numeric7Se);
  _Display.setTextAlignment(PA_CENTER);
  strip.begin();    // Initialize NeoPixel matrix
  strip.setBrightness(BRIGHT_NESS);  // Set initial brightness (can be adjusted)
  strip.show();     // Initialize all pixels to 'off'
}



void gradualSunrise() {
    // unsigned long currentMillis = millis();  // Get the current time

    // Check if 1 second has passed (non-blocking)
    // if (currentMillis - previousMillis >= interval) {
      // previousMillis = currentMillis;  // Save the last time a LED was updated

      // Turn on the next LED
    if (currentPixel < NUMPIXELS) {
      strip.setPixelColor(currentPixel, strip.Color(255, 255, 0));  //  color
      strip.show();  // Update the strip
      currentPixel++;  // Move to the next LED
      if(currentPixel == NUMPIXELS - 1){
        currentPixel = 0;
      }
    }
    // }

}
#endif