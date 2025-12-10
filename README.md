# AutoQuitController

A lightweight macOS application that automatically force quits selected applications at user-defined times. Perfect for managing app usage, enforcing breaks, or ensuring apps don't run during specific hours.

## Features

### Core Functionality
- **Scheduled Force Quit**: Set specific times to automatically force quit applications
- **Recurring Schedules**: Daily, weekly, or custom day patterns
- **One-time Schedules**: Schedule apps to quit once at a specific time
- **Force Quit**: Apps are forcefully terminated regardless of their state (e.g., music playing, unsaved work)

### Additional Features
- **Warning Notifications**: Get notified before apps are quit (configurable 0-60 minutes)
- **App Whitelist**: Protect certain apps from being automatically quit
- **Pause/Resume**: Temporarily pause all schedules without deleting them
- **Quit Logs**: View history of all quit actions with success/failure status
- **Running App Detection**: See all currently running apps and manage them
- **Clean UI**: Modern SwiftUI interface with tab navigation

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later (for building from source)

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/tipsio239/AutoQuitController.git
cd AutoQuitController
```

2. Open the project in Xcode:
```bash
open AutoQuitController.xcodeproj
```

3. Build and run (⌘R) or create an archive for distribution

### First Launch

On first launch, the app will request notification permissions. Grant these permissions to receive warnings before apps are quit.

## Usage

### Creating a Schedule

1. Go to the **Schedules** tab
2. Click **Add Schedule**
3. Select an app from the list
4. Set the quit time
5. Choose repeat options:
   - **One-time**: App quits once at the specified time
   - **Daily**: App quits every day at the specified time
   - **Weekdays**: App quits Monday-Friday
   - **Weekends**: App quits Saturday-Sunday
   - **Custom**: Select specific days
6. Set warning minutes (0-60) to receive a notification before quit
7. Click **Add**

### Managing Apps

- **Apps Tab**: View all running apps and add them to the whitelist
- **Whitelist**: Whitelisted apps will never be automatically quit, even if scheduled
- **Refresh**: Click refresh to update the list of running apps

### Settings

- **Pause All Schedules**: Temporarily disable all schedules
- **Show Notifications**: Toggle notification display
- **Quit Logs**: View history of all quit actions
- **Clear Logs**: Remove all log entries

## How It Works

1. The app runs a background timer that checks schedules every minute
2. When a scheduled time matches the current time, the app is force quit using `NSRunningApplication.forceTerminate()`
3. All actions are logged with timestamps and success status
4. Notifications are sent before quit (if configured) and after quit

## Permissions

The app requires the following permissions:
- **Notifications**: To warn you before apps are quit
- **Accessibility** (if needed): Some system apps may require additional permissions

Note: The app is not sandboxed to allow force quitting other applications. This is necessary for the core functionality.

## Troubleshooting

### App Not Quitting
- Ensure the app is not whitelisted
- Check that the schedule is enabled
- Verify the schedule time matches the current time
- Check the quit logs for error messages

### Notifications Not Showing
- Check macOS notification settings for AutoQuitController
- Ensure "Show notifications" is enabled in Settings
- Grant notification permissions when prompted

### Schedule Not Triggering
- Verify the schedule is enabled (toggle switch is on)
- Check that the current day matches the repeat days (if set)
- Ensure the app is not paused

## Technical Details

- **Language**: Swift 5.0+
- **Framework**: SwiftUI, AppKit
- **Architecture**: MVVM with ObservableObject
- **Data Persistence**: UserDefaults (JSON encoding)
- **Scheduling**: Timer-based with minute precision

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Disclaimer

This app forcefully terminates applications, which may result in data loss if applications have unsaved work. Use responsibly and ensure important work is saved before scheduled quit times.

