# Sensor Status App

## Overview
The Sensor Status App is a Flutter application that displays the status and uptime of various sensors. It features a list view of sensors, a bar chart visualization of sensor uptimes, and the ability to refresh sensor statuses.

## Requirements
- Flutter SDK: 2.5.0 or higher

- Dart: 2.14.0 or higher

## Dependencies
- provider: ^6.0.5 (For state management)

- fl_chart: ^0.63.0 (For creating bar charts)

## Setup and Running the App

### Step 1: Set Up Flutter
Ensure you have Flutter installed on your machine. If not, follow the official Flutter installation guide: https://flutter.dev/docs/get-started/install

### Step 2: Get the Project Files
Obtain the project files from the zip file.

### Step 3: Install Dependencies
Navigate to the project directory in your terminal and run:
flutter pub get

### Step 4: Run the App
To run the app on Chrome with device preview:

flutter run -d chrome --web-renderer html

To run on a mobile emulator or physical device:

1. Ensure you have an emulator running or a device connected

2. Run: 
flutter run

### Design Decisions and Assumptions

State Management: Using Provider for its simplicity and effectiveness.

Chart Visualization: Using fl_chart for a balance of customization and ease of use.

Sensor Data: Each sensor has an id, name, status (online/offline), and uptime percentage.

Refresh Functionality: Simulates data refresh by randomly changing 1-3 sensors' status.

UI Layout: Column layout with chart at top and sensor list below.

Color Coding: Green for online sensors, red for offline.

Responsive Design: Optimized for mobile but should work on various screen sizes.


# flutter
