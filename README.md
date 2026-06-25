# Arduino Piezo Drums

A miniature, highly responsive 5-piece electronic drum kit built using an Arduino Mega 2560 and piezoelectric sensors. This project bridges physical percussion with web-based audio synthesis using the Web Serial API.

## 📝 Project Details
* **Time to Build:** 2 months (Includes learning curve, circuit design, software integration, and troubleshooting).
* **Developer:** Solo project by a middle schooler with 5 years of Vex IQ robotics experience.
* **Resources Used:** Built using open-source Arduino community guides and Web Serial documentation, adapted for this custom 5-drum configuration.
  
 ---
 
### Files
1. Folder HTML Code: This is the folder that has the HTML webpage and all the sounds(Make sure the sounds are in the same folder)
2. Arduino Drums Case .mhtml: This is a onshape 3d print that you can use for the case for the project
3. Ardunio drums.fzz: this is the fritzing file if you want to see
4. Drums_fritzing.png: this is a image if you dont have fritzing
5. Arduino_drums.ino: ardunio ide code make sure to uplode into ardunio
   

---

## 🛠️ Components
* 1 x Arduino Mega 2560
* 5 x 35mm Piezoelectric discs
* 5 x 1MΩ Resistors (to stabilize the piezo signal and bleed off excess voltage)
* 1 x 220 Ω Resistor (for LED current limiting)
* 3 x 5mm Diffused Red LEDs
* 2 x 5mm Diffused Blue LEDs
* 7 x Male-to-Male jumper wires
* 10 x Male-to-Female jumper wires
* 1 x USB 2.0 Type A to B cable

---

## 🥁 The Drum Kit Layout
The kit features 5 total sound triggers divided into standard acoustic categories:

### The 3 Main Components:
1. **Kick Drum** (Bass)
2. **Snare Drum**
3. **Hi-Hat** (Features Open/Closed logic)

### The 2 Secondary Components:
4. **Tom-Toms**
5. **Crash Cymbal**

---

## ⚙️ How It Works (The Logic)

This project connects hardware and software together using electrical signals:

1. **Vibration Capture:** When a piezo disc is pressed or tapped, it sends an analog signal to the Arduino Mega.
2. **Level Classification:** The code tracks the touch duration and assigns it a "Speed Level" tier:
   * **Level 1 (Short/Fast):** Triggers a high-pitched, fast playback speed.
   * **Level 2 (Normal):** Triggers a standard playback speed.
   * **Level 3 (Long/Slow):** Triggers a deep, low-pitched playback speed.
3. **Visual Feedback:** The corresponding LED lights up dynamically using Pulse Width Modulation (`analogWrite`) mapped directly to the peak envelope of your hit.
4. **Web Audio Output:** The Arduino sends the drum name and level tier over a 115,200 baud Serial connection. The custom HTML/JavaScript webpage uses the Web Serial API to read this data, clone the audio sample, apply the calculated `playbackRate`, and play the sound instantly.

---

## 🔬 Science Fair Sections

### [1] Introduction
The goal of this project is to see if you can use piezoelectric sensors and a running HTML program so that whenever you touch a sensor, it sends a small signal. An LED lights up, and the Arduino microcontroller receives the signal and passes it to the HTML program, which plays sounds based on how much time you press the sensor.

### [2] Hypothesis
If a piezoelectric sensor is tapped or pressed for different lengths of time, then the Arduino will measure the exact duration of the touch, instantly light up an LED, and signal an HTML program to alter the playback pitch and speed of a drum sound based on that duration, because the microcontroller can translate varying physical vibration times into distinct digital speed categories.

### [3] Analysis
The system uses an envelope-following algorithm to track physical vibrations. When a sensor is struck, the Arduino captures the input data. Once the sensor's voltage falls back below the threshold, the total duration of the hit is calculated. The data is split into three duration tiers and transmitted over a 115,200 baud Serial connection via Web Serial API to the browser. The HTML program dynamically modifies the `playbackRate` property of the audio elements based on these tiers, shifting the pitch and speed of the drum sample to match the player's touch.

### [4] Results
The project successfully achieved real-time, touch-duration audio manipulation. Testing showed that lighter, crisper taps successfully triggered fast playback speeds (pitching the sample up), while longer, heavier presses accurately triggered slower, deeper playback speeds. Simultaneously, the LEDs successfully matched the intensity of the hits using Pulse Width Modulation (`analogWrite`) mapped to the sensor's peak electrical envelope.
