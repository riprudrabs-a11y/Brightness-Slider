# Brightness Edge Slider

A custom, high-performance desktop brightness slider for Windows built with AutoHotkey v2. The tool lets you control screen brightness by scrolling on the far-right edge of the monitor, with a custom sun-to-moon visual interface, smooth color changes, low-brightness dimming, and a full dark mode.

## 📝 Project Details

* **Time to Build:** Built through multiple testing and improvement phases, including input handling, lag reduction, UI design, startup setup, and full dark mode.
* **Developer:** Solo custom Windows utility project.
* **Main Goal:** Create a faster and better-looking brightness control than the default Windows brightness popup, while keeping the scroll interaction simple and easy to use.
* **Main Software Used:** AutoHotkey v2, Windows WMI brightness control, and optional Twinkle Tray fallback support.

---

### 📁 Files

1. **brightness_edge_slider.ahk:** Main AutoHotkey v2 script. This is the file you run to use the brightness slider.
2. **README.md:** Project explanation, setup notes, and science-fair style overview.

---

## 🛠️ Software Requirements

* Windows computer
* **AutoHotkey v2 installer/exe:** This is required because it runs the `.ahk` script.
* **brightness_edge_slider.ahk:** This is the code file for the brightness slider.
* **Optional: Twinkle Tray:** This is only used as a backup brightness app if Windows native brightness control cannot control the monitor.

---

## 💻 Apps Used

* **AutoHotkey v2:** This is the main app used to run the code. The AutoHotkey `.exe` opens and runs `brightness_edge_slider.ahk`.
* **Code Editor:** A coding app such as Visual Studio Code, Notepad, or the AutoHotkey editor can be used to write and edit the script.
* **Windows Brightness / WMI:** The script first tries to change brightness directly through Windows.
* **Twinkle Tray:** This is optional. It can be used as a backup if Windows cannot control the brightness of the monitor.
* **Windows Startup Folder:** This is used so the brightness slider can automatically run when the computer starts.

---

## ⚙️ Setup Instructions

1. **Install AutoHotkey v2:** Download and install AutoHotkey v2 so Windows knows how to run `.ahk` files.
2. **Put the Script in a Folder:** Keep `brightness_edge_slider.ahk` in a folder where you will not delete it.
3. **Run the Script:** Double-click `brightness_edge_slider.ahk`. AutoHotkey will run it in the background.
4. **Optional Twinkle Tray Setup:** If your brightness does not change, install Twinkle Tray. The script can use it as a backup method.
5. **Startup Shortcut:** The script automatically creates a shortcut in the Windows Startup folder so it can start by itself when you log in.
6. **Test It:** Move your mouse to the far-right edge of the screen and scroll.

---

## ✨ Main Features

The project works like a hidden edge control for brightness:

1. **Right Edge Scroll Control:** When the mouse is on the far-right edge of the screen, scrolling changes brightness instead of scrolling the app underneath.
2. **Custom Visual Slider:** A small floating slider appears near the mouse with a sun icon at the top, a moon icon at the bottom, and a live percent label.
3. **Smooth Color Transition:** The slider color changes smoothly from dark moon colors to blue, then into warm sun colors.
4. **Low Brightness Overlay:** When the brightness gets very low, a transparent black overlay makes the screen look darker than the monitor's normal minimum brightness.
5. **Full Dark Mode:** Scrolling below `0%` enters `dark` mode, making the screen fully black. Moving the mouse or pressing any key exits back to `0%`.
6. **Startup Shortcut:** The script automatically creates a Windows Startup shortcut so it can run after login.

---

## ⚙️ How It Works

This project connects mouse input, Windows brightness control, and a custom interface:

1. **Edge Detection:** The script constantly checks whether the mouse is inside a thin zone on the far-right side of the current monitor.
2. **Scroll Blocking:** AutoHotkey's `#HotIf` system captures `WheelUp` and `WheelDown` only inside that edge zone, which stops webpages or file explorer windows from scrolling underneath.
3. **Instant UI Update:** The visual slider updates immediately when the wheel moves, so the interface feels responsive even if the real monitor takes a moment to change.
4. **Debounced Hardware Update:** The script waits briefly after scrolling before sending the brightness command. This prevents Windows or Twinkle Tray from being spammed with too many brightness updates at once.
5. **Native Brightness First:** The script first tries to control brightness using Windows WMI through `WmiMonitorBrightnessMethods`.
6. **Twinkle Tray Fallback:** If native Windows brightness control does not work, the script can fall back to Twinkle Tray command-line control.
7. **Dark Mode Wakeup:** In full dark mode, an `InputHook` watches for keyboard input and a small timer watches for mouse movement. Either one exits full dark mode immediately.

---

## 🧪 Build and Debugging History

### Phase 1: Basic Right-Edge Scrolling

The first version focused on detecting the right edge of the monitor and changing brightness with the mouse wheel. The edge zone was made wider so fast scrolling would not accidentally leave the control area.

### Phase 2: Stopping Background Scrolling

Scrolling on the screen edge originally also scrolled whatever app was underneath. This was fixed with AutoHotkey's `#HotIf` hotkey condition, which captures the wheel only when the mouse is in the edge zone.

### Phase 3: Reducing Lag

Sending a brightness command on every tiny wheel movement caused lag. The script now updates the UI instantly, then waits before sending one final brightness value to the hardware. It also skips duplicate brightness sends.

### Phase 4: Custom Visual Interface

A custom borderless AutoHotkey GUI was added. It includes a percent label, sun and moon symbols, a vertical progress bar, and smooth color changes between dark and bright states.

### Phase 5: Better Low Brightness

Some monitors stop getting darker after a certain point. To solve this, the script adds a transparent black overlay under low brightness levels so the screen can continue to visually dim.

### Phase 6: Full Dark Mode

After reaching `0%`, scrolling down one more time enters a full black screen mode. The mode exits when the user moves the mouse or presses a key, returning safely to `0%`.

---

## 🔬 Science Fair Sections

### [1] Introduction

The goal of this project is to create a custom brightness slider that feels faster and more useful than the default Windows brightness controls. Instead of opening a settings menu, the user can move the mouse to the right edge of the screen and scroll to control brightness.

### [2] Hypothesis

If brightness control is handled with a custom AutoHotkey script that separates the visual update from the slower hardware update, then the brightness slider will feel more responsive, because the user interface can change instantly while the actual monitor command is sent only after scrolling slows down.

### [3] Analysis

The script uses AutoHotkey v2 to detect mouse position and capture scroll input only near the right edge of the screen. It stores the current brightness value, updates a custom GUI, and then uses a timer to delay the hardware brightness command. This debounce system reduces lag because the script avoids sending too many brightness commands at once. For very low brightness, the script uses a fullscreen black overlay with transparency, which creates extra dimming even when the monitor's physical brightness cannot go lower.

### [4] Results

The project successfully created a custom brightness control that works from the right edge of the screen. The final version includes smooth scrolling, a custom visual slider, automatic startup, low-brightness dimming, and a full dark mode that exits with mouse or keyboard input.

---

## 🎮 How To Use

1. Install AutoHotkey v2.
2. Run `brightness_edge_slider.ahk`.
3. Move the mouse to the far-right edge of the screen.
4. Scroll up to increase brightness.
5. Scroll down to decrease brightness.
6. At `0%`, scroll down one more time to enter `dark` mode.
7. Move the mouse or press any key to exit `dark` mode.

---

## 📌 Notes

* Some monitors support native Windows brightness control, and some do not.
* If native control does not work, Twinkle Tray can be used as a fallback.
* The visual slider is designed to update instantly, even if the physical brightness takes a moment to catch up.
* Full dark mode is only a screen overlay. It does not turn off the monitor.
* The project is not a separate `.exe` by itself. AutoHotkey is the `.exe` that runs the `.ahk` code file.
