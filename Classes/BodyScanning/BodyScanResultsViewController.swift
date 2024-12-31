//
//  BodyScanResultsViewController.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 12/20/24.
//

import UIKit
import WebKit

/// Displays a body scan result in a web view using the report template
@objcMembers public class BodyScanResultsViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Web view for displaying the scan report
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = false
        config.mediaTypesRequiringUserActionForPlayback = .all
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.scrollView.bounces = true
        return webView
    }()
    
    /// Activity indicator for loading states
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    /// The scan result to display
    private let scanResult: ScanResult
    
    /// The health report data
    private var healthReport: HealthReport?
    
    /// Dictionary of asset URLs for 3D viewing
    private let assetUrls: [String: String]?
    
    // MARK: - Initialization
    
    /// Initialize with a scan result and asset URLs
    /// - Parameters:
    ///   - scanResult: The scan result to display
    ///   - assetUrls: Dictionary of asset URLs for 3D viewing
    public init(scanResult: ScanResult, assetUrls: [String: String]?) {
        self.scanResult = scanResult
        self.assetUrls = assetUrls
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHealthReport()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = "Back"
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Health Report"
        view.backgroundColor = .systemBackground
        
        // Add export button
        let exportButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(exportTapped)
        )
        
        // Add 3D view button
        let threeDButton = UIBarButtonItem(
            image: UIImage(systemName: "cube.fill"),
            style: .plain,
            target: self,
            action: #selector(show3DView)
        )
        
        // Set both buttons
        navigationItem.rightBarButtonItems = [exportButton, threeDButton]
        
        // Add subviews
        view.addSubview(webView)
        view.addSubview(activityIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Loading
    
    private func loadHealthReport() {
        activityIndicator.startAnimating()
        debugPrint("[BodyScanResultsViewController] Loading health report for scan: \(scanResult.id)")
        PrismScannerManager.shared.fetchHealthReport(forScan: scanResult.id) { [weak self] report, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(error.localizedDescription)
                return
            }
            
            guard let report = report else {
                self.handleError("No report data available")
                return
            }
            
            self.healthReport = report
            self.loadReportTemplate()
        }
    }
    
    private func loadReportTemplate() {
        // Try to find the report template in the bundle
        guard let reportURL = Bundle.main.url(
            forResource: "index",
            withExtension: "html"
        ) else {
            handleError("Could not find report template")
            return
        }
        
        let reportDirectoryURL = reportURL.deletingLastPathComponent()
        debugPrint("[BodyScanResultsViewController] Report directory:", reportDirectoryURL)
        debugPrint("[BodyScanResultsViewController] Report URL:", reportURL)
        
        // Debug: Check if styles.css exists
        if let stylesURL = Bundle.main.url(forResource: "styles", withExtension: "css") {
            debugPrint("[BodyScanResultsViewController] Found styles.css at:", stylesURL)
        } else {
            debugPrint("[BodyScanResultsViewController] ⚠️ styles.css not found")
        }
        
        webView.loadFileURL(reportURL, allowingReadAccessTo: reportDirectoryURL)
    }
    
    // MARK: - Actions
    
    @objc private func exportTapped() {
        // Export functionality will be added later
        DMGUtilities.showAlert(
            withTitle: "Coming Soon",
            message: "Export functionality will be available in a future update.",
            in: self
        )
    }
    
    @objc private func show3DView() {
        guard let urls = assetUrls,
              urls["model"] != nil,
              urls["texture"] != nil,
              urls["material"] != nil else {
            DMGUtilities.showAlert(
                withTitle: "Cannot Load 3D Model",
                message: "The required 3D model files are not available.",
                in: self
            )
            return
        }
        
        let threeDVC = BodyScan3DViewController(scanResult: scanResult, assetUrls: urls)
        navigationController?.pushViewController(threeDVC, animated: true)
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ message: String) {
        activityIndicator.stopAnimating()
        DMGUtilities.showAlert(
            withTitle: "Error",
            message: message,
            in: self
        )
    }
    
    private func injectHealthReportData() {
        guard let report = healthReport else { return }
        
        debugPrint("[BodyScanResultsViewController] Injecting health report data")
        
        // First fetch the image data if we have a preview URL
        if let previewUrl = assetUrls?["preview"],
           let url = URL(string: previewUrl) {
            
            debugPrint("[BodyScanResultsViewController] Fetching preview image from:", previewUrl)
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    debugPrint("[BodyScanResultsViewController] Error fetching image:", error)
                    return
                }
                
                guard let data = data else {
                    debugPrint("[BodyScanResultsViewController] No image data received")
                    return
                }
                
                // Get MIME type or default to image/png
                let mimeType = response?.mimeType ?? "image/png"
                
                // Convert to base64 data URL
                let base64String = data.base64EncodedString()
                let dataUrl = "data:\(mimeType);base64,\(base64String)"
                
                debugPrint("[BodyScanResultsViewController] Created data URL with length:", dataUrl.count)
                
                // Now inject the data
                DispatchQueue.main.async {
                    self.injectReportWithImageData(report: report, imageDataUrl: dataUrl)
                }
            }
            task.resume()
        } else {
            // No preview URL, just inject the report
            injectReportWithImageData(report: report, imageDataUrl: nil)
        }
    }
    
    private func injectReportWithImageData(report: HealthReport, imageDataUrl: String?) {
        // Convert to JSON with pretty printing for debugging
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        guard let jsonData = try? encoder.encode(report),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            handleError("Failed to encode health report data")
            return
        }
        
        // Properly escape the image URL for JavaScript
        let imageUrlString = imageDataUrl?.replacingOccurrences(of: "\"", with: "\\\"") ?? ""
        
        // Format measurements from scan result
        let measurementsScript = formatMeasurementsScript()
        
        // Inject data via JavaScript with additional error handling
        let script = """
            try {
                console.log('Starting data injection');
                window.healthReport = \(jsonString);
                
                // Hide the future avatar column
                const futureAvatarCol = document.querySelector('#avatar-section .col-6:last-child');
                if (futureAvatarCol) {
                    futureAvatarCol.style.display = 'none';
                    
                    // Make the today avatar take full width
                    const todayAvatarCol = document.querySelector('#avatar-section .col-6:first-child');
                    if (todayAvatarCol) {
                        todayAvatarCol.className = 'col-12 text-center p-0';
                    }
                }
                
                const todayAvatar = document.getElementById('today-avatar');
                console.log('Found today-avatar element:', todayAvatar ? 'yes' : 'no');
                
                if (todayAvatar) {
                    todayAvatar.style.minHeight = '300px';
                    todayAvatar.style.display = 'block';
                    
                    const imageUrl = "\(imageUrlString)";
                    if (imageUrl) {
                        console.log('Setting image data URL of length:', imageUrl.length);
                        todayAvatar.style.backgroundImage = `url("${imageUrl}")`;
                    }
                }
                
                // Update measurements
                \(measurementsScript)
                
                if (typeof window.updateHealthReport === 'function') {
                    window.updateHealthReport(window.healthReport);
                }
            } catch (error) {
                console.error('Error in data injection:', error);
            }
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                debugPrint("[BodyScanResultsViewController] JavaScript evaluation error:", error)
                self.handleError("Failed to update report: \(error.localizedDescription)")
            } else {
                debugPrint("[BodyScanResultsViewController] Successfully injected data")
            }
        }
    }
    
    // Format measurements with proper units
    private func formatMeasurement(_ value: Double) -> String {
        // Convert measurements to inches for display (PrismSDK returns meters)
        let metersToInches = 39.3701
        let inches = value * metersToInches
        return String(format: "%.1f\"", inches)
    }
    
    // Helper to safely calculate average of bilateral measurements
    private func calculateBilateralAverage(left: Double?, right: Double?) -> Double {
        switch (left, right) {
        case (let left?, let right?): return (left + right) / 2  // Both values present
        case (let value?, nil): return value                      // Only left present
        case (nil, let value?): return value                      // Only right present
        case (nil, nil): return 0                                 // Neither present
        }
    }
        
    // Helper function to format measurements script
    private func formatMeasurementsScript() -> String {
        // Get measurements from scan result
        let measurements = scanResult.measurements
        
        // Calculate averages for bilateral measurements
        let armsAverage = calculateBilateralAverage(
            left: measurements?.midArmLeftFit,
            right: measurements?.midArmRightFit
        )
        let thighsAverage = calculateBilateralAverage(
            left: measurements?.thighLeftFit,
            right: measurements?.thighRightFit
        )
        let calvesAverage = calculateBilateralAverage(
            left: measurements?.calfLeftFit,
            right: measurements?.calfRightFit
        )
        
        // Create JavaScript to update measurement values
        return """
            // Update measurement values
            const measurements = {
                neck: document.getElementById('neck-circumference'),
                chest: document.getElementById('chest-circumference'),
                waist: document.getElementById('waist-circumference'),
                arms: document.getElementById('arms-circumference'),
                thighs: document.getElementById('thighs-circumference'),
                calves: document.getElementById('calves-circumference')
            };
            
            // Update each measurement if available
            if (measurements) {
                // Set measurements using actual values
                const values = {
                    neck: '\(formatMeasurement(measurements?.neckFit ?? 0))',
                    chest: '\(formatMeasurement(measurements?.chestFit ?? 0))',
                    waist: '\(formatMeasurement(measurements?.waistFit ?? 0))',
                    arms: '\(formatMeasurement(armsAverage))',
                    thighs: '\(formatMeasurement(thighsAverage))',
                    calves: '\(formatMeasurement(calvesAverage))'
                };
                
                // Set values
                Object.entries(values).forEach(([key, value]) => {
                    if (measurements[key]) {
                        measurements[key].textContent = value;
                    }
                });
                
                // Log available measurements for debugging
                console.log('Available scan measurements:', values);
            }
        """
    }
}

// MARK: - WKNavigationDelegate

extension BodyScanResultsViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        
        // Test if JavaScript is working
        webView.evaluateJavaScript("console.log('Navigation complete')") { result, error in
            if let error = error {
                debugPrint("[BodyScanResultsViewController] Console log error:", error)
            }
        }
        
        injectHealthReportData()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("[BodyScanResultsViewController] Navigation failed:", error)
        handleError(error.localizedDescription)
    }
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        debugPrint("[BodyScanResultsViewController] Deciding policy for:", navigationAction.request.url?.absoluteString ?? "unknown URL")
        // Allow all navigation while debugging
        decisionHandler(.allow)
    }
}

