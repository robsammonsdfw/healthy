import Foundation
import UIKit
import PrismSDK
import Security
import SwiftUI

/// Manages all interactions with PrismSDK including user management, scanning, and result handling.
/// This class serves as the primary integration point between DMG and PrismSDK.
@objcMembers public class PrismScannerManager: NSObject, @unchecked Sendable {
    /// Shared singleton instance. Used to maintain a single point of access throughout the app.
    public static let shared: PrismScannerManager = {
        let instance = PrismScannerManager()
        return instance
    }()
    
    /// Holds reference to the current scanning session view controller
    private var sessionViewController: PrismSessionViewController?
    /// Completion handler for the current scanning session
    private var completionHandler: ((Error?) -> Void)?
    /// PrismSDK API client instance
    private var apiClient: ApiClient?
    
    // MARK: - Constants
    
    /// Keys used for storing data in the Keychain
    private enum KeychainKeys {
        /// Key for storing the user's Prism profile data
        static let profileData = "com.dmg.prism.profile"
        /// Key for storing the user's pseudonym (used for masked exports)
        static let pseudonym = "com.dmg.prism.pseudonym"
    }
    
    /// Notification names used for broadcasting events
    private enum NotificationNames {
        /// Posted when the user's profile is updated
        static let profileUpdated = "PrismProfileUpdatedNotification"
    }
    
    /// Environment-specific configuration
    private enum Environment {
        #if DEBUG
        static let apiURL = "https://sandbox-api.hosted.prismlabs.tech"
        static var apiKey: String { 
            debugPrint("[PrismScanner] Using DEBUG environment")
            return AppConfiguration.bodyScanningDevKey 
        }
        #else
        static let apiURL = "https://api.hosted.prismlabs.tech"
        static var apiKey: String { 
            debugPrint("[PrismScanner] Using PRODUCTION environment")
            return AppConfiguration.bodyScanningProdKey 
        }
        #endif
    }
    
    // MARK: - Properties
    
    /// Current user's Prism profile. Automatically saves to Keychain when updated.
    private(set) var currentProfile: PrismUserProfile? {
        didSet {
            saveProfileToKeychain()
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.profileUpdated), 
                                         object: self)
        }
    }
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern.
    /// Sets up notifications and loads any existing profile from Keychain.
    private override init() {
        super.init()
        loadProfileFromKeychain()
        setupNotifications()
    }
    
    /// Configures notification observers for user state changes
    private func setupNotifications() {
        // User login state changes
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleUserLoginStateChange(_:)),
            name: NSNotification.Name(UserLoginStateDidChangeNotification),
            object: nil)
            
        // User info updates (height, weight, etc)
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleUserInfoUpdate(_:)),
            name: NSNotification.Name("DMReloadDataNotification"),
            object: nil)
    }
    
    // MARK: - Public Methods
    
    /// Initializes the PrismSDK with the appropriate API key and configuration
    public func configure() {
        let config = PrismConfiguration(
            apiKey: Environment.apiKey,
            apiURL: Environment.apiURL,
            clientAppId: Bundle.main.bundleIdentifier ?? ""
        )
        
        initialize(with: config)
    }
    
    /// Initializes the PrismSDK with the provided configuration
    /// Also attempts to create/update Prism user if someone is already logged in
    /// - Parameter config: The PrismSDK configuration
    private func initialize(with config: PrismConfiguration) {
        guard let baseURL = URL(string: config.apiURL) else {
            print("Error: Invalid API URL")
            return
        }
        
        let credentials = ApiClientBearerToken(config.apiKey)
        apiClient = ApiClient(baseURL: baseURL, clientCredentials: credentials)
        
        // Try to create/update user if already logged in
        let authManager = DMAuthManager.sharedInstance()
        if let currentUser = authManager.loggedInUser() {
            createOrUpdatePrismUser(from: currentUser)
        }
    }
    
    /// Updates the user's profile in PrismSDK and locally
    /// - Parameters:
    ///   - profile: The updated profile information
    ///   - completion: Called with error if update fails, nil if successful
    public func updateProfile(_ profile: PrismUserProfile, completion: @escaping (Error?) -> Void) {
        guard let apiClient = apiClient else {
            completion(NSError(domain: "PrismScannerManager", code: -1, 
                             userInfo: [NSLocalizedDescriptionKey: "API client not initialized"]))
            return
        }
        
        // Create user client and existing user model
        let userClient = UserClient(client: apiClient)
        let existingUser = ExistingUser(
            token: profile.userId,
            sex: Sex(rawValue: profile.gender),
            birthDate: profile.dateOfBirth,
            weight: Weight(value: Double(profile.weight), unit: .pounds),
            height: Height(value: Double(profile.height), unit: .inches)
        )
        
        Task {
            do {
                _ = try await userClient.update(user: existingUser)
                DispatchQueue.main.async {
                    self.currentProfile = profile
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    /// Fetches scans for the current user
    /// - Parameters:
    ///   - limit: Maximum number of scans to return per page (default: 25)
    ///   - cursor: Pagination cursor for fetching next page
    ///   - completion: Called with scans data and error if any
    @objc public func fetchScans(limit: Int = 25, 
                                  cursor: String? = nil,
                                  completion: @escaping (Any?, Error?) -> Void) {
        guard let apiClient = apiClient,
              let profile = currentProfile else {
            completion(nil, NSError(domain: "PrismScannerManager", 
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Missing profile or API client"]))
            return
        }

        let scanClient = ScanClient(client: apiClient)
        
        Task {
            do {
                let response = try await scanClient.getScans(
                    forUser: profile.userId,
                    limit: limit,
                    cursor: cursor,
                    order: .descending
                )
                
                debugPrint("[PrismScanner] Raw API Response: \(response)")
                
                // No need to convert to JSON, just pass the Paginated<Scan> directly
                DispatchQueue.main.async {
                    completion(response, nil)
                }
                
            } catch {
                debugPrint("[PrismScanner] ❌ Error fetching scans: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    /// Starts a new body scanning session
    /// - Parameter completion: Called when scan completes or fails
    public func startScan(completion: @escaping (Error?) -> Void) {
        guard apiClient != nil else {
            completion(NSError(domain: "PrismScannerManager", code: -1, 
                             userInfo: [NSLocalizedDescriptionKey: "API client not initialized"]))
            return
        }
        
        // Store completion handler for later
        self.completionHandler = completion
        
        // Create session view controller with custom theme using app's menu icon color
        let theme = PrismThemeConfiguration(primaryColor: Color(AppConfiguration.menuIconColor),
                                          secondaryColor: Color(AppConfiguration.menuIconColor),
                                           tertiaryColor: Color(AppConfiguration.menuIconColor),
                                     iconBackgroundColor: Color(AppConfiguration.menuIconColor))
        let sessionVC = PrismSessionViewController(theme: theme, delegate: self)
        self.sessionViewController = sessionVC
        
        // Present scanner UI
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(sessionVC, animated: true)
        }
    }
    
    /// Handles uploading scan data to server
    /// - Parameters:
    ///   - archiveURL: Local URL of the scan archive
    private func uploadScan(from archiveURL: URL) {
        guard let apiClient = apiClient,
              let profile = currentProfile else {
            completionHandler?(NSError(domain: "PrismScannerManager", code: -1,
                                     userInfo: [NSLocalizedDescriptionKey: "Missing profile or API client"]))
            return
        }

        // Create scan client
        let scanClient = ScanClient(client: apiClient)
        
        Task {
            do {
                // Create scan record on server
                let scan = try await scanClient.createScan(
                    NewScan(
                        deviceConfigName: "IPHONE_SCANNER",
                        userToken: profile.userId,
                        bodyfatMethod: .tina_fit, // Default method per PRD
                        assetConfigId: .objTextureBased // Default format per PRD
                    )
                )
                
                // Start polling for results
                startPollingForResults(scanId: scan.id)
                
                // Get upload URL
                let uploadUrl = try await scanClient.uploadUrl(forScan: scan.id)
                
                // Rename archive with scan ID
                let newFileName = "scan_\(scan.id).zip"
                let newFileURL = archiveURL.deletingLastPathComponent().appendingPathComponent(newFileName)
                try FileManager.default.moveItem(at: archiveURL, to: newFileURL)
                
                // Create uploader
                let uploader = FileUploader()
                
                // Upload file
                uploader.upload(file: newFileURL, to: URL(string: uploadUrl.url)!)
                
                // Notify completion
                DispatchQueue.main.async {
                    self.completionHandler?(nil)
                    
                    // Post notification that scan was uploaded
                    NotificationCenter.default.post(
                        name: NSNotification.Name("DMBodyScanUploadedNotification"),
                        object: nil,
                        userInfo: ["scanId": scan.id]
                    )
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.completionHandler?(error)
                }
            }
        }
    }
    
    /// Deletes a scan with the given ID
    /// - Parameters:
    ///   - scanId: The ID of the scan to delete
    ///   - completion: Called with error if deletion fails, nil if successful
    @objc public func deleteScan(withId scanId: String, completion: @escaping (Error?) -> Void) {
        guard let apiClient = apiClient else {
            completion(NSError(domain: "PrismScannerManager", 
                             code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "API client not initialized"]))
            return
        }

        let scanClient = ScanClient(client: apiClient)
        
        Task {
            do {
                try await scanClient.deleteScan(scanId)
                debugPrint("[PrismScanner] Successfully deleted scan: \(scanId)")
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                debugPrint("[PrismScanner] ❌ Error deleting scan: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    // MARK: - Asset Management
    
    /// Asset URL option types that can be used in Objective-C
    @objc public enum PrismAssetUrlOption: Int {
        case model = 0
        case texture = 1
        
        // Convert to PrismSDK AssetUrls.Option
        var sdkOption: AssetUrls.Option {
            switch self {
            case .model: return .model
            case .texture: return .texture
            }
        }
    }
    
    /// Fetches all asset URLs for a specific scan
    /// - Parameters:
    ///   - scanId: The ID of the scan to fetch assets for
    ///   - completion: Called with AssetUrls object or error
    @objc public func fetchAssetUrls(forScan scanId: String, 
                                    completion: @escaping ([String: String]?, Error?) -> Void) {
        guard let apiClient = apiClient else {
            completion(nil, NSError(domain: "PrismScannerManager", 
                                  code: -1, 
                                  userInfo: [NSLocalizedDescriptionKey: "API client not initialized"]))
            return
        }

        let scanClient = ScanClient(client: apiClient)
        
        Task {
            do {
                let assetUrls = try await scanClient.assetUrls(forScan: scanId)
                debugPrint("[PrismScanner] Successfully fetched asset URLs for scan: \(scanId)")
                
                // Convert AssetUrls to dictionary for Objective-C
                // Only include URLs that are not nil
                var urlDict: [String: String] = [:]
                
                if let modelUrl = assetUrls.model {
                    urlDict["model"] = modelUrl
                }
                
                if let textureUrl = assetUrls.texture {
                    urlDict["texture"] = textureUrl
                }
                
                DispatchQueue.main.async {
                    completion(urlDict, nil)
                }
            } catch {
                debugPrint("[PrismScanner] ❌ Error fetching asset URLs: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    /// Fetches a specific asset URL for a scan using Objective-C compatible option enum
    /// - Parameters:
    ///   - scanId: The ID of the scan
    ///   - option: The type of asset to fetch (e.g., model, texture, preview)
    ///   - completion: Called with URL string or error
    @objc public func fetchAssetUrl(forScan scanId: String,
                                   option: PrismAssetUrlOption,
                                   completion: @escaping (String?, Error?) -> Void) {
        guard let apiClient = apiClient else {
            completion(nil, NSError(domain: "PrismScannerManager", 
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "API client not initialized"]))
            return
        }

        let scanClient = ScanClient(client: apiClient)
        
        Task {
            do {
                let url = try await scanClient.assetUrl(forScan: scanId, option: option.sdkOption)
                debugPrint("[PrismScanner] Successfully fetched \(option) URL for scan: \(scanId)")
                debugPrint("[PrismScanner] Asset URL: \(url)")
                
                DispatchQueue.main.async {
                    completion(url, nil)
                }
            } catch {
                debugPrint("[PrismScanner] ❌ Error fetching asset URL: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    /// Creates a body shape prediction for a scan
    /// - Parameters:
    ///   - scanId: The ID of the scan to create prediction for
    ///   - targetWeight: Optional target weight for prediction
    ///   - targetBodyfat: Optional target body fat percentage
    ///   - completion: Called with prediction data or error
    @objc public func createBodyShapePrediction(forScan scanId: String,
                                               targetWeight: NSNumber?,
                                               targetBodyfat: NSNumber?,
                                               completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let apiClient = apiClient else {
            completion(nil, NSError(domain: "PrismScannerManager", 
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "API client not initialized"]))
            return
        }

        let scanClient = ScanClient(client: apiClient)
        let payload = BodyShapePredictionPayload(
            scanId: scanId,
            predictionType: "standard",
            targetWeight: targetWeight?.floatValue,
            targetBodyfat: targetBodyfat?.floatValue
        )
        
        Task {
            do {
                let prediction = try await scanClient.createBodyShapePrediction(payload)
                debugPrint("[PrismScanner] Successfully created prediction for scan: \(scanId)")
                
                // Convert prediction to dictionary for Objective-C
                let predictionDict: [String: Any] = [
                    "id": prediction.id,
                    "scanId": prediction.scanId,
                    "status": prediction.status,  // Assuming this is already a String
                    "createdAt": prediction.createdAt
                ]
                
                DispatchQueue.main.async {
                    completion(predictionDict, nil)
                }
            } catch {
                debugPrint("[PrismScanner] ❌ Error creating prediction: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    /// Fetches the health report for a scan
    /// - Parameters:
    ///   - scanId: The ID of the scan to fetch the health report for
    ///   - completion: Called with health report data or error
    /// API Docs: https://prism-labs.notion.site/Health-Assessment-Endpoint-03f086089b104c259127ee15cc3eae7f#bfd2116de60c4d088bf2374207187600
    @objc public func fetchHealthReport(forScan scanId: String, 
                                      completion: @escaping (HealthReport?, Error?) -> Void) {
        guard let apiClient = apiClient,
              let baseURL = URL(string: Environment.apiURL) else {
            completion(nil, NSError(domain: "PrismScannerManager", 
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "API client not initialized"]))
            return
        }

        let finalURL = baseURL.appendingPathComponent("scans/\(scanId)/health-report")
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Environment.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json;v=1", forHTTPHeaderField: "Accept")
        
        // Add debug logging
        debugPrint("[PrismScanner] Requesting health report from: \(finalURL)")
        debugPrint("[PrismScanner] Using auth token: \(Environment.apiKey)")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkingError.notAnHttpResponse
                }
                
                // Add debug logging
                debugPrint("[PrismScanner] Response status code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    debugPrint("[PrismScanner] Response body: \(responseString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    // Try to decode error response
                    if let prismError = try? JSONDecoder().decode(PrismError.self, from: data) {
                        throw NetworkingError.responseFailure(prismError)
                    }
                    throw NetworkingError.requestFailure
                }
                
                // Configure decoder for ISO8601 dates with fractional seconds
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Create date formatter that handles ISO8601 with fractional seconds
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container,
                        debugDescription: "Expected ISO8601 date string")
                }
                
                // Decode response into HealthReport model
                let healthReport = try decoder.decode(HealthReport.self, from: data)
                
                debugPrint("[PrismScanner] Successfully fetched health report for scan: \(scanId)")
                
                DispatchQueue.main.async {
                    completion(healthReport, nil)
                }
                
            } catch {
                debugPrint("[PrismScanner] ❌ Error fetching health report: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Creates or updates a Prism user based on DMG user data
    /// - Parameter dmUser: The DMG user to create/update in Prism
    private func createOrUpdatePrismUser(from dmUser: DMUser) {
        guard let apiClient = apiClient else { return }
        
        // Create date from birthDate if available, otherwise use a default date
        let birthDate = dmUser.birthDate as Date? ?? Date(timeIntervalSince1970: 0)
        
        let newUser = NewUser(
            token: String(format: "dmg_%@", dmUser.userId.stringValue),
            sex: Sex(rawValue: mapGender(dmUser.gender.intValue)) ?? .neutral,
            usaResidence: nil,
            birthDate: birthDate,
            weight: Weight(value: Double(dmUser.weightGoal.floatValue), unit: .pounds),
            height: Height(value: Double(dmUser.height.floatValue), unit: .inches),
            researchConsent: false,
            termsOfService: TermsOfService(accepted: true, version: nil)
        )
        
        // Create profile outside of async context
        let profile = PrismUserProfile()
        profile.userId = newUser.token
        profile.firstName = dmUser.firstName
        profile.lastName = dmUser.lastName
        profile.height = dmUser.height.floatValue
        profile.weight = dmUser.weightGoal.floatValue
        profile.gender = mapGender(dmUser.gender.intValue)
        profile.dateOfBirth = dmUser.birthDate as Date?
        profile.goalWeight = dmUser.weightGoal.floatValue

        debugPrint("[PrismScanner] Attempting to create/update user with token: \(newUser.token)")
        Task { [profile] in  // Capture profile explicitly
            do {
                let userClient = UserClient(client: apiClient)
                let result = try await userClient.create(user: newUser)
                debugPrint("[PrismScanner] Successfully created/updated user: \(result)")
                
                DispatchQueue.main.async { [weak self] in
                    debugPrint("[PrismScanner] Updating current profile for user: \(profile.userId)")
                    self?.currentProfile = profile
                }
                
            } catch {
                debugPrint("[PrismScanner] ❌ Error creating/updating Prism user: \(error)")
                debugPrint("[PrismScanner] Failed user data: \(newUser)")
            }
        }
    }
    
    /// Maps DMG gender codes to Prism gender strings
    /// - Parameter dmGender: DMG gender code (1 = male, 0 = female)
    /// - Returns: Prism gender string ("male", "female", or "neutral")
    private func mapGender(_ dmGender: Int) -> String {
        switch dmGender {
        case 0: return "female"
        case 1: return "male"
        default: return "neutral"
        }
    }
    
    // MARK: - Keychain Storage
    
    /// Saves the current profile to Keychain for persistence
    private func saveProfileToKeychain() {
        guard let profile = currentProfile,
              let data = try? JSONEncoder().encode(profile) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeychainKeys.profileData,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Loads any saved profile from Keychain
    private func loadProfileFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeychainKeys.profileData,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        if let data = result as? Data,
           let profile = try? JSONDecoder().decode(PrismUserProfile.self, from: data) {
            currentProfile = profile
        }
    }
    
    // MARK: - Notification Handlers
    
    /// Handles user login/logout notifications
    /// Creates/updates Prism user on login, clears profile on logout
    @objc private func handleUserLoginStateChange(_ notification: Notification) {
        let authManager = DMAuthManager.sharedInstance()
        if let currentUser = authManager.loggedInUser() {
            createOrUpdatePrismUser(from: currentUser)
        } else {
            // User logged out, clear profile
            currentProfile = nil
        }
    }
    
    /// Handles user info updates (height, weight, etc)
    @objc private func handleUserInfoUpdate(_ notification: Notification) {
        let authManager = DMAuthManager.sharedInstance()
        if let currentUser = authManager.loggedInUser() {
            // Only update if we have a profile already
            if currentProfile != nil {
                createOrUpdatePrismUser(from: currentUser)
            }
        }
    }
    
    // MARK: - Scan Polling
    
    private struct ScanPollingState {
        let scanId: String
        let startTime: Date
        var lastPollTime: Date
        var pollInterval: TimeInterval // 15 or 30 seconds
    }
    
    private var pollingState: ScanPollingState?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private func startPollingForResults(scanId: String) {
        // Cancel any existing polling
        stopPolling()
        
        // Create new polling state
        pollingState = ScanPollingState(
            scanId: scanId,
            startTime: Date(),
            lastPollTime: Date(),
            pollInterval: 15.0
        )
        
        // Start background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.stopPolling()
        }
        
        // Start polling
        checkScanStatus()
    }
    
    private func stopPolling() {
        pollingState = nil
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func checkScanStatus() {
        guard let state = pollingState else { return }
        
        // Check if we've exceeded timeout (10 minutes)
        if Date().timeIntervalSince(state.startTime) > 600 {
            stopPolling()
            debugPrint("[PrismScanner] Scan polling timed out after 10 minutes")
            return
        }
        
        // Check if we should increase poll interval (after 2 minutes)
        if Date().timeIntervalSince(state.startTime) > 120 && state.pollInterval == 15.0 {
            pollingState?.pollInterval = 30.0
        }
        
        // Poll for scan status
        Task {
            do {
                let scan = try await ScanClient(client: apiClient!).getScan(forScan: state.scanId)
                
                if scan.status == .ready {
                    // Scan is ready - notify user
                    scheduleLocalNotification(title: "Body Scan Complete",
                                           body: "Your body scan results are ready to view!",
                                           scanId: scan.id)
                    stopPolling()
                    return
                } else if scan.status == .failed {
                    // Scan failed - stop polling
                    scheduleLocalNotification(title: "Scan Failed",
                                           body: "There was a problem processing your scan. Please try again.",
                                           scanId: scan.id)
                    stopPolling()
                    return
                }
                
                // Schedule next poll
                DispatchQueue.main.asyncAfter(deadline: .now() + state.pollInterval) { [weak self] in
                    self?.checkScanStatus()
                }
                
            } catch {
                debugPrint("[PrismScanner] Error polling scan status: \(error)")
                // On error, try again after interval
                DispatchQueue.main.asyncAfter(deadline: .now() + state.pollInterval) { [weak self] in
                    self?.checkScanStatus()
                }
            }
        }
    }
    
    private func scheduleLocalNotification(title: String, body: String, scanId: String) {
        // Request permission if needed
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                
                // Add scan ID to user info
                content.userInfo = ["scanId": scanId]
                
                // Create trigger for immediate delivery
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                // Create request
                let request = UNNotificationRequest(
                    identifier: "scan-\(scanId)",
                    content: content,
                    trigger: trigger
                )
                
                // Schedule notification
                UNUserNotificationCenter.current().add(request)
            }
        }
        
        // Also post local notification for in-app handling
        NotificationCenter.default.post(
            name: NSNotification.Name("DMBodyScanCompletedNotification"),
            object: nil,
            userInfo: ["scanId": scanId]
        )
    }
}

// MARK: - PrismSessionViewControllerDelegate

extension PrismScannerManager: PrismSessionViewControllerDelegate {
    /// Called when a scan is completed and archive is available
    public func prismSession(_ controller: PrismSessionViewController, didRecieveArchive archive: URL) {
        // Upload the scan data
        debugPrint("[PrismScanner] Scan completed with archive at: \(archive)")
        uploadScan(from: archive)
    }
    
    /// Called when the scanning status changes
    public func prismSession(_ controller: PrismSessionViewController, didChangeStatus status: CaptureSessionState) {
        debugPrint("[PrismScanner] Scan status changed to: \(status)")
    }
    
    /// Called when the scanning session is about to dismiss
    public func prismSession(willDismiss controller: PrismSessionViewController) {
        controller.dismiss(animated: true) {
            self.sessionViewController = nil
        }
    }
}

// MARK: - Models

/// Represents a user's profile in PrismSDK
@objcMembers public class PrismUserProfile: NSObject, Codable, @unchecked Sendable {
    public var userId: String = ""
    public var firstName: String = ""
    public var lastName: String = ""
    public var height: Float = 0
    public var weight: Float = 0
    public var gender: String = ""
    public var dateOfBirth: Date?
    public var goalWeight: Float = 0
    
    public override init() {
        super.init()
    }
}

/// Configuration for PrismSDK initialization
private struct PrismConfiguration {
    let apiKey: String
    let apiURL: String
    let clientAppId: String
}

/// Model for scan measurements
@objcMembers public class ScanMeasurements: NSObject, Codable {
    public var neckFit: Double = 0
    public var shoulderFit: Double = 0
    public var upperChestFit: Double = 0
    public var chestFit: Double = 0
    public var lowerChestFit: Double = 0
    public var waistFit: Double = 0
    public var waistNavyFit: Double = 0
    public var stomachFit: Double = 0
    public var hipsFit: Double = 0
    public var upperThighLeftFit: Double = 0
    public var upperThighRightFit: Double = 0
    public var thighLeftFit: Double = 0
    public var thighRightFit: Double = 0
    public var lowerThighLeftFit: Double = 0
    public var lowerThighRightFit: Double = 0
    public var calfLeftFit: Double = 0
    public var calfRightFit: Double = 0
    public var ankleLeftFit: Double = 0
    public var ankleRightFit: Double = 0
    public var midArmRightFit: Double = 0
    public var midArmLeftFit: Double = 0
    public var lowerArmRightFit: Double = 0
    public var lowerArmLeftFit: Double = 0
    public var waistToHipRatio: Double = 0
}

/// Model for body fat data
@objcMembers public class BodyFatData: NSObject, Codable {
    public var bodyfatMethod: String = ""
    public var bodyfatPercentage: Double = 0
    public var fatMass: Double = 0
    public var leanMass: Double = 0
    public var leanMassPercentage: Double = 0
}

