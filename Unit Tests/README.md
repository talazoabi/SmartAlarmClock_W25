## 📋 This folder contains Valdation tests done to check sensors/hardware parts

## 🛠️ Hardware Components & Test Results

| # | **Hardware** | **Results** | **Test Code** |
|---|------------|------------|------------|
| 1 | MAX7219 LED Matrix 8x32 | Showed text and scrolling text as expected. | [Display Test Code](https://lastminuteengineers.com/max7219-dot-matrix-arduino-tutorial/) |
| 2 | Analog Voltage Sensor (LDR) | Adjusted code to reverse effect, working properly. | `Analog->AnalogInOutSerial` |
| 3 | Speaker + Max98357 | Initially had connection issues, resolved. Beeping sound confirmed. | `SpeakerWithButton.io` |
| 4 | Button (ESP32) | Tested with speaker, works properly. | See #3 |
| 5 | Neopixel - LED 8x8 | Worked as expected (All LEDs turned on). | `Adafruit NeoPixel->Simple` |
| 6 | Neopixel - LED 16x16 | Worked as expected. One LED isn’t working. | `Adafruit NeoPixel->Simple` |

📌 **Notes:**
- Tests were verified through multiple trials.
- Code snippets were sourced from ArduinoExamples with necessary adjustments.
- Further refinements may be needed for the Neopixel 16x16 due to one non-functioning LED.

📎 *For more details or troubleshooting, refer to the test codes and documentation.* 🚀
