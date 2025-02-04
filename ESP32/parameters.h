
#ifndef PARAMETERS_H
#define PARAMETERS_H

// ### DISPLAY ###
#define HARDWARE_TYPE MD_MAX72XX::FC16_HW
#define MAX_DEVICES 4

#define CLK_PIN   14
#define DATA_PIN  13
#define CS_PIN    12

// # LDR SENSOR #
#define INPUT_PIN 39 // which is "VN" pin

// # NEOPIXEL 8x8 #
#define PIN            22              // Pin connected to NeoPixel matrix
#define NUMPIXELS      64            // 16x16 matrix = 256 pixels
#define MATRIX_WIDTH   8             // Matrix width (16x16)
#define MATRIX_HEIGHT  8             // Matrix height (16x16)
#define BRIGHT_NESS    25       


// ### CLOCK ###
const char* ntpServer1 = "pool.ntp.org";
const char* ntpServer2 = "time.nist.gov";
const long gmtOffset_sec = 3600 * 2;
const int daylightOffset_sec = 3600;

// ### BUTTONS ###
#define BUTTON_NEXT_PIN 32 
#define BUTTON_ALARM_PIN 33
#define BUTTON_RESET_PIN 15
#define BUTTON_DO_PIN 4

// ### AUDIO ###
// # SD Card Pins #
#define SD_CS          5
#define SPI_MOSI      23 
#define SPI_MISO      19 //
#define SPI_SCK       18

// # Audio Pins #
#define I2S_BCLK 26
#define I2S_LRC 25
#define I2S_DOUT 27

// ### FONT ###
#define FONT_SIZE 2


#endif