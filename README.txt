BLUETOOTH CHAT APP
=================

A Flutter-based Bluetooth messaging application that enables direct communication between devices using Bluetooth Classic. The app supports both one-to-one and group messaging with a host-based group management system.

FEATURES
========

Core Features
------------
* One-to-one Bluetooth messaging
* Group chat with host management
* Message persistence with SQLite
* File and image sharing
* Message status tracking (sent, delivered, read)
* Connection status monitoring
* Offline message queuing

Group Management
---------------
* Host-based group creation
* Member management (add/remove)
* Group dissolution by host
* Member join/leave functionality
* Group message broadcasting

Message Types Support
-------------------
* Text messages
* Images
* Files
* Location sharing (planned)
* Contact sharing (planned)
* Audio messages (planned)

PROJECT STRUCTURE
===============

bluetooth_chat/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── screens/
│   │   ├── chat_screen.dart      # Individual chat UI
│   │   ├── device_list_screen.dart # Device discovery and connection
│   │   └── group_management_screen.dart # Group management UI
│   ├── models/
│   │   ├── chat_message.dart     # Message data model
│   │   ├── chat_group.dart       # Group data model
│   │   ├── bluetooth_device.dart # Device model
│   │   └── message_reaction.dart # Message reactions
│   ├── services/
│   │   ├── bluetooth_service.dart # Bluetooth communication
│   │   ├── database_service.dart  # Local storage
│   │   ├── group_service.dart    # Group management
│   │   ├── media_service.dart    # Media handling
│   │   └── message_queue_service.dart # Offline queue
│   └── widgets/
│       ├── message_bubble.dart   # Message display
│       └── device_tile.dart      # Device list item

TECHNICAL DETAILS
===============

Services
--------
1. BluetoothService
   - Device discovery and pairing
   - Connection management
   - Message sending/receiving
   - Group broadcasting

2. DatabaseService
   - SQLite message persistence
   - Chat history management
   - Message search and filtering

3. GroupService
   - Group creation and management
   - Member handling
   - Host privileges

4. MediaService
   - Image handling
   - File sharing
   - Future media types support

Models
------
1. ChatMessage
   - Text, image, and file support
   - Message status tracking
   - Timestamp and sender info

2. ChatGroup
   - Host and member management
   - Group metadata
   - Permission handling

SETUP INSTRUCTIONS
================

Prerequisites
------------
* Flutter SDK (2.19.0 or higher)
* Android Studio / Xcode
* Physical devices for testing (Bluetooth emulation is not supported)

Installation Steps
----------------
1. Clone the repository:
   git clone https://github.com/yourusername/bluetooth_chat.git

2. Install dependencies:
   cd bluetooth_chat
   flutter pub get

3. Configure platform-specific settings:

Android Configuration
-------------------
Add to android/app/src/main/AndroidManifest.xml:

<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

iOS Configuration
---------------
Add to ios/Runner/Info.plist:

<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need Bluetooth permission for chat</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Need Bluetooth permission for chat</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photos for sharing images.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for taking photos.</string>

USAGE GUIDE
==========

One-to-One Chat
--------------
1. Launch the app
2. Enable Bluetooth if not enabled
3. Select a paired device from the list
4. Start chatting with text, images, or files

Group Chat (Host)
---------------
1. Tap the group icon
2. Create a new group
3. Add members from paired devices
4. Start group conversation

Group Chat (Member)
-----------------
1. Receive group invitation
2. Join group
3. Participate in group conversation
4. Leave group when needed

ERROR HANDLING
============
The app includes comprehensive error handling for:
* Bluetooth connection failures
* Message delivery failures
* Group management errors
* File transfer issues
* Permission denials

FUTURE ENHANCEMENTS
=================
Planned features include:
* End-to-end encryption
* Message reactions
* Voice messages
* Location sharing
* Contact sharing
* Message search
* Cloud backup
* Read receipts
* Message translation
* User presence status

CONTRIBUTING
===========
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

KNOWN ISSUES
===========
* Bluetooth discovery may take longer on some devices
* Large file transfers might be slow
* Group chat synchronization can be delayed in poor connectivity

TROUBLESHOOTING
=============
Common issues and solutions:

1. Bluetooth not connecting
   - Ensure both devices have Bluetooth enabled
   - Check if devices are paired
   - Restart Bluetooth on both devices

2. Messages not sending
   - Verify connection status
   - Check if device is in range
   - Ensure message queue is not full

LICENSE
=======
This project is licensed under the MIT License - see the LICENSE file for details.

ACKNOWLEDGMENTS
=============
* Flutter Bluetooth Serial package
* SQLite for Flutter
* Flutter community for support and guidance

CONTACT
=======
Your Name - @yourtwitter
Project Link: https://github.com/yourusername/bluetooth_chat 