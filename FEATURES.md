# AutoQuitController - Feature Overview

## Core Features

### 1. Scheduled Force Quit
- Set specific times to automatically force quit applications
- Works regardless of app state (music playing, unsaved work, etc.)
- Uses `NSRunningApplication.forceTerminate()` for guaranteed termination

### 2. Flexible Scheduling
- **One-time schedules**: Quit an app once at a specific time
- **Daily schedules**: Quit every day at the same time
- **Weekday schedules**: Quit Monday-Friday
- **Weekend schedules**: Quit Saturday-Sunday
- **Custom schedules**: Select specific days of the week

### 3. Warning System
- Configurable warnings 0-60 minutes before quit
- Push notifications via UserNotifications framework
- Helps users save work before apps are quit

### 4. App Whitelist
- Protect apps from being automatically quit
- Visual indicator in schedule list
- Easy toggle in Apps tab

### 5. Pause/Resume
- Temporarily disable all schedules without deleting them
- Visual status indicator in UI
- Useful for temporary exceptions

### 6. Quit Logs
- History of all quit actions
- Shows success/failure status
- Timestamps for each action
- Keeps last 100 entries

### 7. Running App Detection
- Real-time list of all running applications
- App icons and bundle identifiers
- Refresh button to update list
- Search functionality

## Additional Features

### User Interface
- Modern SwiftUI design
- Tab-based navigation (Schedules, Apps, Settings)
- Status bar showing active schedules
- Clean, intuitive controls

### Data Persistence
- All schedules saved to UserDefaults
- Persists across app restarts
- JSON encoding for complex data structures

### Notifications
- Request permissions on first launch
- Configurable on/off toggle
- Warning notifications before quit
- Confirmation notifications after quit

## Technical Implementation

### Architecture
- **MVVM Pattern**: ObservableObject for state management
- **Singleton Services**: ScheduleService and QuitManager
- **Combine Framework**: Reactive updates for schedule changes

### Key Components

1. **AppModel**: Central state management
   - Schedule storage and persistence
   - Whitelist management
   - Logging functionality
   - Settings management

2. **ScheduleService**: Background scheduler
   - Timer-based checking (every minute)
   - Day-of-week matching
   - Notification handling
   - Quit execution

3. **QuitManager**: App termination
   - Force quit functionality
   - Graceful quit attempt (optional)
   - Error handling

4. **Views**:
   - `ScheduleView`: Manage schedules
   - `AppListView`: View/manage running apps
   - `SettingsView`: App settings and logs

## Use Cases

1. **Productivity**: Quit distracting apps during work hours
2. **Break Enforcement**: Force quit work apps during break times
3. **Resource Management**: Quit resource-heavy apps at specific times
4. **Parental Control**: Limit app usage times
5. **Battery Management**: Quit apps during low-power hours

## Safety Features

- Whitelist protection for critical apps
- Pause functionality for temporary exceptions
- Warning notifications before quit
- Logging for audit trail
- Visual indicators for whitelisted apps

## Future Enhancement Ideas

- Idle time-based quitting (quit after X minutes of inactivity)
- Resource usage monitoring
- Different schedules for weekdays/weekends
- App groups/categories
- Export/import schedules
- Menu bar app option
- Keyboard shortcuts
- AppleScript support

