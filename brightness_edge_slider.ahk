#Requires AutoHotkey v2.0
#SingleInstance Force

; Right-edge brightness slider for Twinkle Tray.
; Scroll on the far-right edge of any monitor to change brightness.

EdgeWidth := 36
ScrollStep := 2
HardwareDelayMs := 320
HideDelayMs := 1100
PanelWidth := 64
PanelHeight := 338
ScreenEdgeGap := 0
TwinkleTrayPath := EnvGet("LocalAppData") . "\Programs\twinkle-tray\Twinkle Tray.exe"
UseNativeBrightnessFirst := true
CreateStartupShortcut := true
SyncWithHardwareOnWake := false
DimOverlayStart := 22
MaxDimOverlayAlpha := 145

CurrentBrightness := 50
IsActive := false
LastMonitor := { Left: 0, Top: 0, Right: A_ScreenWidth, Bottom: A_ScreenHeight, X: 0, Y: 0 }
LastSentBrightness := -1
LastDimAlpha := -1
DimOverlayVisible := false
CachedDimBounds := ""
IsFullDark := false
DarkInputHook := ""
DarkMouseX := 0
DarkMouseY := 0

DimGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
DimGui.BackColor := "000000"
DimGui.Hide()

FullDarkGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
FullDarkGui.BackColor := "000000"
FullDarkGui.Hide()

BrightnessGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
BrightnessGui.BackColor := "070810"
BrightnessGui.MarginX := 10
BrightnessGui.MarginY := 10

BrightnessGui.SetFont("s10", "Segoe UI")
TopIcon := BrightnessGui.Add("Text", "xm w44 h28 Center cFFE66D", Chr(0x263C))
TopIcon.SetFont("s19", "Segoe UI Symbol")

PercentLabel := BrightnessGui.Add("Text", "xm w44 h24 Center cF7F7FF", "50%")
PercentLabel.SetFont("s9 Bold", "Segoe UI")

TrackGlow := BrightnessGui.Add("Progress", "xm+10 y+4 w24 h218 Vertical Smooth Background10121F cFFD447", CurrentBrightness)
TrackShell := BrightnessGui.Add("Progress", "xm+14 yp w16 h218 Vertical Smooth Background20243A cFFD447", CurrentBrightness)
TrackGlow.Move(20, 71, 24, 218)
TrackShell.Move(24, 71, 16, 218)

BottomIcon := BrightnessGui.Add("Text", "xm y+12 w44 h28 Center cD9E4FF", Chr(0x263E))
BottomIcon.SetFont("s18", "Segoe UI Symbol")

BrightnessGui.Hide()
EnsureStartupShortcut()

#HotIf MouseOnRightEdge()
WheelUp::{
    global ScrollStep
    AdjustSlider(ScrollStep)
}

WheelDown::{
    global ScrollStep
    AdjustSlider(-ScrollStep)
}
#HotIf

MouseOnRightEdge() {
    global EdgeWidth, LastMonitor

    monitor := GetMouseMonitor()
    LastMonitor := monitor
    return (monitor.X >= monitor.Right - EdgeWidth
        && monitor.Y >= monitor.Top
        && monitor.Y <= monitor.Bottom)
}

GetMouseMonitor() {
    CoordMode "Mouse", "Screen"
    MouseGetPos &x, &y

    Loop MonitorGetCount() {
        MonitorGet A_Index, &left, &top, &right, &bottom
        if (x >= left && x <= right && y >= top && y <= bottom) {
            return { Left: left, Top: top, Right: right, Bottom: bottom, X: x, Y: y }
        }
    }

    return { Left: 0, Top: 0, Right: A_ScreenWidth, Bottom: A_ScreenHeight, X: x, Y: y }
}

GetActualBrightness() {
    try {
        for property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness") {
            return property.CurrentBrightness
        }
    }

    return 50
}

AdjustSlider(amount) {
    global CurrentBrightness, IsActive, IsFullDark, HardwareDelayMs, HideDelayMs, SyncWithHardwareOnWake

    if (IsFullDark) {
        ExitFullDark()
        return
    }

    if (!IsActive) {
        if (SyncWithHardwareOnWake)
            CurrentBrightness := GetActualBrightness()
        IsActive := true
    }

    if (amount < 0 && CurrentBrightness <= 0) {
        EnterFullDark()
        return
    }

    CurrentBrightness := Clamp(CurrentBrightness + amount, 0, 100)
    UpdateVisuals(CurrentBrightness)
    PositionGui()

    SetTimer SendHardwareUpdate, -HardwareDelayMs
    SetTimer HideGui, -HideDelayMs
}

UpdateVisuals(value) {
    global TrackShell, TrackGlow, PercentLabel, TopIcon, BottomIcon

    color := GetBrightnessColor(value)
    TrackShell.Opt("c" . color)
    TrackGlow.Opt("c" . color)
    TrackShell.Value := value
    TrackGlow.Value := value
    PercentLabel.Text := value . "%"
    UpdateDimOverlay(value)

    TopIcon.Opt(value >= 65 ? "cFFE66D" : "c6D7285")
    BottomIcon.Opt(value <= 35 ? "cE4ECFF" : "c6E7590")
}

GetBrightnessColor(value) {
    stops := [
        { At: 0, Color: "01030A" },
        { At: 10, Color: "07102B" },
        { At: 26, Color: "123778" },
        { At: 44, Color: "286CC2" },
        { At: 60, Color: "347DBB" },
        { At: 64, Color: "72C7EE" },
        { At: 65, Color: "BDE7F6" },
        { At: 66, Color: "F4D17A" },
        { At: 68, Color: "F5B74E" },
        { At: 78, Color: "FFB43E" },
        { At: 100, Color: "FFE66D" }
    ]

    Loop stops.Length - 1 {
        left := stops[A_Index]
        right := stops[A_Index + 1]

        if (value <= right.At) {
            progress := (value - left.At) / (right.At - left.At)
            return LerpHexColor(left.Color, right.Color, Clamp(progress, 0, 1))
        }
    }

    return stops[stops.Length].Color
}

LerpHexColor(fromColor, toColor, progress) {
    from := HexToRgb(fromColor)
    to := HexToRgb(toColor)

    r := Round(from.R + (to.R - from.R) * progress)
    g := Round(from.G + (to.G - from.G) * progress)
    b := Round(from.B + (to.B - from.B) * progress)

    return Format("{:02X}{:02X}{:02X}", r, g, b)
}

HexToRgb(color) {
    return {
        R: Integer("0x" . SubStr(color, 1, 2)),
        G: Integer("0x" . SubStr(color, 3, 2)),
        B: Integer("0x" . SubStr(color, 5, 2))
    }
}

PositionGui() {
    global BrightnessGui, LastMonitor, PanelWidth, PanelHeight, ScreenEdgeGap

    monitor := LastMonitor
    y := Clamp(monitor.Y - Floor(PanelHeight / 2), monitor.Top + 12, monitor.Bottom - PanelHeight - 12)
    x := monitor.Right - PanelWidth - ScreenEdgeGap

    BrightnessGui.Show("x" . x . " y" . y . " w" . PanelWidth . " h" . PanelHeight . " NoActivate")
}

UpdateDimOverlay(value) {
    global DimGui, DimOverlayStart, MaxDimOverlayAlpha, LastDimAlpha, DimOverlayVisible, CachedDimBounds

    if (value > DimOverlayStart) {
        if (DimOverlayVisible) {
            DimGui.Hide()
            DimOverlayVisible := false
            LastDimAlpha := -1
        }
        return
    }

    alpha := Round(((DimOverlayStart - value) / DimOverlayStart) * MaxDimOverlayAlpha)
    alpha := Clamp(alpha, 0, MaxDimOverlayAlpha)

    if (DimOverlayVisible && alpha = LastDimAlpha)
        return

    if (!IsObject(CachedDimBounds))
        CachedDimBounds := GetVirtualMonitorBounds()

    bounds := CachedDimBounds
    DimGui.Show("x" . bounds.Left . " y" . bounds.Top . " w" . bounds.Width . " h" . bounds.Height . " NoActivate")
    WinSetTransparent alpha, "ahk_id " . DimGui.Hwnd
    LastDimAlpha := alpha
    DimOverlayVisible := true
}

EnterFullDark() {
    global CurrentBrightness, IsActive, IsFullDark, FullDarkGui, BrightnessGui, PercentLabel, DarkInputHook, DarkMouseX, DarkMouseY

    CurrentBrightness := 0
    IsActive := true
    IsFullDark := true
    UpdateVisuals(0)
    PercentLabel.Text := "dark"
    BrightnessGui.Hide()

    CoordMode "Mouse", "Screen"
    MouseGetPos &DarkMouseX, &DarkMouseY

    bounds := GetVirtualMonitorBounds()
    FullDarkGui.Show("x" . bounds.Left . " y" . bounds.Top . " w" . bounds.Width . " h" . bounds.Height . " NoActivate")
    WinSetTransparent 255, "ahk_id " . FullDarkGui.Hwnd

    DarkInputHook := InputHook()
    DarkInputHook.KeyOpt("{All}", "N")
    DarkInputHook.OnKeyDown := ExitFullDarkByKey
    DarkInputHook.Start()

    SetTimer WatchFullDarkMouse, 30
}

ExitFullDarkByKey(inputHook, vk, sc) {
    ExitFullDark()
}

WatchFullDarkMouse() {
    global IsFullDark, DarkMouseX, DarkMouseY

    if (!IsFullDark)
        return

    CoordMode "Mouse", "Screen"
    MouseGetPos &x, &y
    if (Abs(x - DarkMouseX) > 2 || Abs(y - DarkMouseY) > 2)
        ExitFullDark()
}

ExitFullDark() {
    global CurrentBrightness, IsFullDark, FullDarkGui, DarkInputHook

    if (!IsFullDark)
        return

    IsFullDark := false
    CurrentBrightness := 0
    FullDarkGui.Hide()
    SetTimer WatchFullDarkMouse, 0

    try {
        DarkInputHook.Stop()
    }

    UpdateVisuals(0)
    SendHardwareUpdate()
}

GetVirtualMonitorBounds() {
    left := 0
    top := 0
    right := A_ScreenWidth
    bottom := A_ScreenHeight

    Loop MonitorGetCount() {
        MonitorGet A_Index, &monitorLeft, &monitorTop, &monitorRight, &monitorBottom

        if (A_Index = 1) {
            left := monitorLeft
            top := monitorTop
            right := monitorRight
            bottom := monitorBottom
        } else {
            left := Min(left, monitorLeft)
            top := Min(top, monitorTop)
            right := Max(right, monitorRight)
            bottom := Max(bottom, monitorBottom)
        }
    }

    return { Left: left, Top: top, Width: right - left, Height: bottom - top }
}

SendHardwareUpdate() {
    global CurrentBrightness, LastSentBrightness, TwinkleTrayPath, UseNativeBrightnessFirst

    if (CurrentBrightness = LastSentBrightness)
        return

    if (UseNativeBrightnessFirst && SetNativeBrightness(CurrentBrightness)) {
        LastSentBrightness := CurrentBrightness
        return
    }

    if (FileExist(TwinkleTrayPath)) {
        try {
            Run('"' . TwinkleTrayPath . '" --All --Set=' . CurrentBrightness, , "Hide")
            LastSentBrightness := CurrentBrightness
        }
    }
}

SetNativeBrightness(value) {
    try {
        methods := ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
        didSet := false

        for method in methods {
            method.WmiSetBrightness(0, value)
            didSet := true
        }

        return didSet
    }

    return false
}

EnsureStartupShortcut() {
    global CreateStartupShortcut

    if (!CreateStartupShortcut)
        return

    startupLink := A_Startup . "\Brightness Edge Slider.lnk"
    if (FileExist(startupLink))
        return

    try {
        shell := ComObject("WScript.Shell")
        shortcut := shell.CreateShortcut(startupLink)
        shortcut.TargetPath := A_AhkPath
        shortcut.Arguments := '"' . A_ScriptFullPath . '"'
        shortcut.WorkingDirectory := A_ScriptDir
        shortcut.IconLocation := A_AhkPath
        shortcut.Save()
    }
}

HideGui() {
    global BrightnessGui, IsActive

    BrightnessGui.Hide()
    IsActive := false
}

Clamp(value, minValue, maxValue) {
    return Max(minValue, Min(maxValue, value))
}
