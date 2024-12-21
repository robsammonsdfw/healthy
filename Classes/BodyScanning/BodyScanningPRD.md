# Body Scanning Feature PRD (Embrace Health Only)
Version 1.0

## Overview
Body Scanning is a new feature in DietMasterGo that allows users to track their body composition and visualize their progress using 3D body scanning technology powered by PrismSDK.

## User Flow

### Entry Points
1. Main Screen
   - "Start Body Scan" button
   - "View Scan Results" button
   - Location: Below steps counter in main dashboard
   - Visibility: Only shown to logged-in users who are using the Embrace Health replica.

2. Settings
   - "Body Scan Settings" button in app settings
   - Opens body scan profile configuration
   - Calls UpdateProfile() in PrismSDK when user updates the profile

### Scanning Process
1. Initial Setup
   - Create PrismSDK user on first scan attempt
   - Required profile data:
     * Height
     * Weight
     * Sex
     * Date of Birth
     * Goal Weight
   - If profile incomplete, redirect to Body Scan Settings

2. Scan Initiation
   - Validate one scan per calendar month limit
   - Check camera permissions
   - Launch PrismSDK scanner UI

3. Post-Scan Processing
   - Poll for results every 15 seconds
   - Increase to 30-second intervals after 2 minutes
   - Maximum timeout: 10 minutes
   - Background behavior: Continue polling unless app is terminated

### Results Notification
1. Local Notification
   - Trigger when scan results available
   - If app in foreground: Show alert dialog
   - If app in background: Show system notification
   - Tapping notification opens scan results view

### Scan Results View
1. List View
   - TableView of all user's scans
   - Sort: Most recent first
   - User can swipe to delete a scan
   - Each row shows:
     * Scan date
     * Basic measurements preview
     * Status (Processing/Complete)

2. Detail View
   - WebView showing PrismSDK scan results
   - Export button in top-right corner
   - Export options:
     * "With your Name": Include PII
     * "Mask Your Information": Use persistent pseudonym
     * PDF format
     * Share sheet for export destination

### Future You Feature
1. Availability
   - Only after completing first scan
   - Access from scan results view

2. Visualization
   - Side-by-side comparison
   - Left: Latest scan
   - Right: AI-generated future projection
   - Based on:
     * Current measurements
     * Goal weight
     * Timeline to goal

### Settings
1. Body Scan Profile
   - Access via app settings
   - Required fields:
     * Height
     * Weight
     * Sex
     * Date of Birth
     * Goal Weight
   - Validation rules TBD
   - Save/Update to both local and PrismSDK

## Technical Requirements

### Data Storage
1. Local Storage
   - Profile settings
   - Pseudonym for masked exports (in Keychain)
   - Need a userId for PrismSDK, use DMUser.userId.
   - DO NOT Share any Email addresses with PrismSDK.

2. PrismSDK Integration
   - User creation/management
   - Scan data sync
   - Results retrieval
   - PrismSDK stores scans in the cloud, so we don't need to worry about storing them locally.

### Permissions
1. Required
   - Camera access
   - Notification permissions

### Background Processing
1. Result Polling
   - Start: 15-second intervals
   - After 2 minutes: 30-second intervals
   - Timeout: 10 minutes
   - Handle app state changes
   - Cancel on app termination

## Limitations
- One scan per calendar month per user
- iOS 15.0+ required (PrismSDK requirement)

## Questions to Resolve
1. Profile Requirements
   - Confirm required fields with PrismSDK
   - Validation rules for each field
2. Future You Feature
   - Technical feasibility with PrismSDK
   - Where do we initiate the Future You feature?
3. Export Format
   - PDF template design
   - We'll have a webview that displays the results, so we can use the same format.
   - How can we convert the webview to a PDF? It must be processed locally on the device.

## Documentation Links

### PrismSDK Documentation
- Main Documentation: https://prism-labs.notion.site/iOS-SDK-Prism-Bodymapping-Bundle-8fe5a83ec9db4b17a35addf6f0b23286
- iOS SDK Overview: https://prism-labs.notion.site/iOS-SDK-Prism-Bodymapping-Bundle-8fe5a83ec9db4b17a35addf6f0b23286#466046c387a34aa09eef3956db0c499e
- The main documentation is where we can learn about the SDK and what it can do and how to integrate it.
- iOS SDK Repository: https://github.com/prismlabs-tech/prismsdk-ios
- The SDK repository contains no example or documentation.
- Example App: https://github.com/prismlabs-tech/prismsdk-example-ios
- Example App provides all of the features as an example.
- Hosted API Docs: https://docs.prismlabs.tech/api-reference-dev
- Hosted API is where we can learn about API calls that the SDK makes.

## Technical Integration

### Overall
- We can use Swift 5.0 for any new code we write. It must be compatiable with Objective-C.
- We can only use UIKit for layouts. Do not use SwiftUI.
- Objective-C should only be used for integration into the existing codebase, where needed.
- All APIs should support iOS 15.0 and above.
- Feature must be gated based on the AppConfiguration.enableBodyScanning flag.
- Comment each variable and function with a detailed description of what it does.
- Any and all files related to Body Scanning should be in the /Classes/BodyScanning directory.
- Update this PRD with any new information as we learn it or things change.

### SDK API Keys and Info.plist Configuration
Per their docs, if you include a PrismSDK-Info.plist file when no values are passed creating their API Client, it will use the values in the file. Here is the format below. We prefer to pass the values directly to avoid any issues with the file.

#### Development
``` xml
<key>API_KEY</key>
<string>{{ADD SANDBOX KEY HERE}}</string>
<key>API_URL</key>
<string>https://sandbox-api.hosted.prismlabs.tech</string>
<key>PLIST_VERSION</key>
<string>1</string>
<key>CLIENT_APP_ID</key>
<string>{{App Bundle ID}}</string>
```

#### Production
``` xml
<key>API_KEY</key>
<string>{{ADD PRODUCTION KEY HERE}}</string>
<key>API_URL</key>
<string>https://api.hosted.prismlabs.tech</string>
<key>PLIST_VERSION</key>
<string>1</string>
<key>CLIENT_APP_ID</key>
<string>{{App Bundle ID}}</string>
```

### Architecture Updates
1. PrismScannerManager (Primary Integration Point)
   - Expand current singleton to handle all Prism interactions
   - Add user management methods
   - Add scan history management
   - Add profile management
   - Add Future You prediction handling
   - Add PDF export functionality

2. New Classes Required
   - BodyScanResultsViewController (TableView for scan history)
   - BodyScanDetailViewController (WebView for scan results)
   - BodyScanSettingsViewController (Profile management)
   - BodyScanFutureViewController (Future You comparison)
   - BodyScanProfileManager (Handle profile data persistence)

### Class Modifications Required
1. DietMasterGoViewController
   - Add scan initiation logic to bodyScanningPlusBtn action
   - Add results viewing logic
   - Update UI visibility based on Embrace Health status
   - We'll need to add a button to handle viewing the scan results.

2. AppDelegate
   - Already initializes PrismScannerManager
   - Add background task handling for scan processing
   - Add notification registration

3. DMAuthManager Integration
   - Add PrismSDK user creation on login or app launch.
   - Sync DMUser profile data with Prism profile, but the user's DOB is not available in DMUser, so we'll need a settings view. The user can override any setting. The settings will need to be stored locally, perhaps in the keychain so it's persistant across installs.

### Data Flow
1. User Authentication
   - DMAuthManager logs in user
   - PrismScannerManager creates/updates Prism user
   - Profile data synced between systems. DMUser has most of the fields, but PrismSDK has some additional fields. Thus we'll need a settings view.

2. Scan Process
   - DietMasterGoViewController initiates scan
   - PrismScannerManager handles scanning UI
   - Background task manages polling
   - NotificationCenter broadcasts scan completion

3. Results Management
   - PrismScannerManager caches scan metadata locally.
   - Create an object to store the scan metadata, which comes in as JSON.
   - Results fetched from PrismSDK on demand
   - PDF generation handled locally. The template for PDF will be a local file.

### Key Technical Considerations
1. Background Processing
   - Handle app termination cleanup
   - Only need to support iOS 15+

2. Error Handling
   - Network connectivity issues
   - Timeout handling
   - Permission denials
   - Profile validation failures

### Health Report Data
1. Data Source
   - Direct API endpoint: `/scans/{scanId}/health-report`
   - Contains comprehensive health assessment including:
     * Body Fat Percentage Analysis
     * Lean Mass Analysis
     * Fat Mass Analysis
     * Waist Circumference Analysis
     * Waist-to-Hip Ratio Analysis
     * Waist-to-Height Ratio Analysis
     * Metabolism Report

2. Report Components
   - User Demographics
   - Scan Details
   - Body Composition Analysis
   - Comparative Analysis (percentiles)
   - Metabolic Assessment
   - Health Risk Indicators

3. Integration Points
   - Fetched when viewing scan results
   - Used to populate health report template
   - Provides data for visualization components
   - Supports PDF export functionality
