## 📋 This folder contains Valdation tests done to check sensors/hardware parts

## 🛠️ Hardware Components & Test Results

| 🔢 | 🖥️ **Hardware Name** | ✅ **Test Results** | 📜 **Test Code** |
|---|----------------------|----------------------|------------------|
| 1 | **MAX7219 LED Matrix 8x32** | Showed text and scrolling text as expected. | `Display Test Code` |
| 2 | **Analog Voltage Sensor (LDR SENSOR)** | The default setting decreases voltage with more light. Adjusted code to reverse effect, working properly. | Code from ArduinoExamples: `Analog->AnalogInOutSerial` with minor changes. |
| 3 | **Speaker + Max98357 (Amplifier)** | Initially had connection issues; resolved after web search. Beeping sound confirmed. | Our Git under `SpeakerWithButton.io` |
| 4 | **Button (Given with ESP32)** | Tested with the speaker, works properly. | See above (#3) |
| 5 | **Neopixel - Smart LED 8x8** | Worked as expected (All LEDs turned on). | Code from ArduinoExamples: `Adafruit NeoPixel->Simple` |
| 6 | **Neopixel - Smart LED 16x16** | Worked as expected. One LED isn’t working. | Code from ArduinoExamples: `Adafruit NeoPixel->Simple` |

📌 **Notes:** 
- All tests were conducted with the appropriate hardware setups and verified through multiple trials.
- Code snippets used were sourced from ArduinoExamples with necessary adjustments.

📎 *For additional details or troubleshooting, please refer to the respective test codes and documentation.* 🚀

