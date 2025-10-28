# HoldDownButton2 Demo App

A SwiftUI demo app for a customizable “Hold Down Button” with status display, progress bar, and navigation.

## Features

- **HoldDownButton2**: A button that displays different statuses (Start, Pause, Stop, Ready) and provides a progress bar when pressed and held.
- **Customizable colors and texts**: Default values for status texts and colors can be changed centrally or overwritten on the button.
- **Navigation**: NavigationStack with sample pages (demo, settings) and toolbar buttons.

![sample](Button2/docs.docc/FlowChart1.png)

<p align="center">
  <img src="Button2/docs.docc/FlowChart1.png" width="450">
</p>

## Main components

- `HoldDownButton2`: The main button with status and progress display.
- `ContentView`: Start view with navigation and example of button usage.
- `NavigationButton`: Auxiliary view for NavigationStack.
- `DemoView_` and `SettingsView_`: Example pages for navigation.

## Customization

Customize default values for texts and colors in the dictionaries `defaultStatusTexts` and `defaultStatusColors`. Additional UI elements can be expanded in the same way.

## Preview
<p align="center">
  <img src="Button2/docs.docc/HoldDownButton.gif" width="450">
</p>

The app displays a button with status display and progress bar. The toolbar can be used to navigate to demo and settings pages.

## Requirements

- macOS
- Xcode 16
- SwiftUI

## Getting started

1. Open the project in Xcode.
2. Run (`Cmd+R`).

---
