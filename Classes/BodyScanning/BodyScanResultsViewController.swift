//
//  BodyScanResultsViewController.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 12/20/24.
//

import PDFKit
import UIKit
import WebKit

/// Displays a body scan result in a web view using the report template
@objcMembers public class BodyScanResultsViewController: UIViewController {

    // MARK: - Types

    /// Data structure that combines health report and measurements for JSON encoding
    private struct CombinedReportData: Encodable {
        let healthReport: HealthReport
        let measurements: Measurements?
        let scanDate: Date
        let scanId: String

        enum CodingKeys: String, CodingKey {
            case healthReport = "health_report"
            case measurements
            case scanDate = "scan_date"
            case scanId = "scan_id"
        }
    }

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

    private enum ExportOption {
        case pdf
        case print
        case share

        var title: String {
            switch self {
            case .pdf: return "Save as PDF"
            case .print: return "Print Report"
            case .share: return "Share Report"
            }
        }

        var icon: String {
            switch self {
            case .pdf: return "doc.pdf"
            case .print: return "printer"
            case .share: return "square.and.arrow.up"
            }
        }
    }

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

        // Add export menu button
        let exportMenu = UIMenu(
            title: "",
            children: [
                UIAction(
                    title: ExportOption.pdf.title,
                    image: UIImage(systemName: ExportOption.pdf.icon),
                    handler: { [weak self] _ in self?.createAndSharePDF() }
                ),
                UIAction(
                    title: ExportOption.print.title,
                    image: UIImage(systemName: ExportOption.print.icon),
                    handler: { [weak self] _ in self?.printReport() }
                ),
            ])

        let exportButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            menu: exportMenu
        )

        // Add 3D view button
        let threeDButton = UIBarButtonItem(
            image: UIImage(systemName: "view.3d"),
            style: .plain,
            target: self,
            action: #selector(show3DView)
        )

        navigationItem.rightBarButtonItems = [threeDButton]

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
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Loading

    private func loadHealthReport() {
        activityIndicator.startAnimating()
        debugPrint(
            "[BodyScanResultsViewController] Loading health report for scan: \(scanResult.id)")
        PrismScannerManager.shared.fetchHealthReport(forScan: scanResult.id) {
            [weak self] report, error in
            guard let self else { return }

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
      guard let currentProfile = PrismScannerManager.shared.currentProfile else {
        handleError("Could not load current user")
        return
      }
        guard let reportURL = Bundle.main.url(forResource: "index", withExtension: "html"),
            let templateString = try? String(contentsOf: reportURL, encoding: .utf8)
        else {
            handleError("Could not find report template")
            return
        }

        let reportDirectoryURL = reportURL.deletingLastPathComponent()

        // Get measurements and user data
        let measurements = scanResult.measurements
        let report = healthReport

        // Calculate bilateral averages
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

        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: scanResult.createdAt)


        // Create replacements dictionary
        var replacements: [String: String] = [
            // Demographics
            "{{USER_NAME}}": currentProfile.firstName + " " + currentProfile.lastName,
            "{{SCAN_DATE}}": formattedDate,
            "{{USER_AGE}}": "\(report?.user.age ?? 0) years",
            "{{USER_GENDER}}": report?.user.sex ?? "--",
            "{{USER_HEIGHT}}": formatHeight(report?.user.height ?? 0),
            "{{USER_WEIGHT}}": formatWeight(report?.user.weight ?? 0),

            // Measurements
            "{{MEASUREMENT_NECK}}": formatMeasurement(measurements?.neckFit ?? 0),
            "{{MEASUREMENT_CHEST}}": formatMeasurement(measurements?.chestFit ?? 0),
            "{{MEASUREMENT_WAIST}}": formatMeasurement(measurements?.waistFit ?? 0),
            "{{MEASUREMENT_ARMS}}": formatMeasurement(armsAverage),
            "{{MEASUREMENT_THIGHS}}": formatMeasurement(thighsAverage),
            "{{MEASUREMENT_CALVES}}": formatMeasurement(calvesAverage),
        ]

        // Add any additional health report data if needed
        if let report = report {
            // Current values
            replacements["{{CURRENT_WEIGHT}}"] = formatWeight(report.user.weight)
            replacements["{{TARGET_WEIGHT}}"] = formatWeight(report.user.weight * 0.85)  // Example: 15% reduction

            // Summary metrics
            replacements["{{BODY_FAT_PERCENTAGE}}"] = String(
                format: "%.1f%%", report.bodyFatPercentageReport.bodyFatPercentage)
            replacements["{{FAT_MASS}}"] = String(
                format: "%.1f lbs", report.fatMassReport.fatMass * 2.20462)
            replacements["{{LEAN_MASS}}"] = String(
                format: "%.1f lbs", report.leanMassReport.leanMass * 2.20462)
            replacements["{{WAIST_RATIO}}"] = String(
                format: "%.2f", report.waistToHeightRatioReport.waistToHeightRatio)

            // Metabolism
            let metabolism = report.metabolismReport
            replacements["{{METABOLISM_WEIGHT_LOSS}}"] = String(
                format: "%d", metabolism.energyExpenditures.sedentary.cutTdee.maximum)
            replacements["{{METABOLISM_MAINTAIN}}"] = String(
                format: "%d", metabolism.energyExpenditures.sedentary.maintainTdee)
            replacements["{{METABOLISM_MUSCLE_GAIN}}"] = String(
                format: "%d", metabolism.energyExpenditures.sedentary.buildTdee.maximum)
            replacements["{{METABOLISM_BMR}}"] = String(format: "%d", metabolism.basalMetabolicRate)

            // Body Fat
            let bodyFatRanges: [(min: Double?, max: Double?)] = [
                (nil, 12.9),  // LOW (0-12.9%)
                (13.0, 17.9),  // MINIMUM (13-17.9%)
                (18.0, 27.9),  // HEALTHY (18-27.9%)
                (28.0, 31.9),  // HIGH (28-31.9%)
                (32.0, nil),  // UNHEALTHY (32%+)
            ]
            let bodyFatGradientPosition = calculateGradientPosition(
                value: report.bodyFatPercentageReport.bodyFatPercentage,
                ranges: bodyFatRanges
            )
            replacements["{{BODY_FAT_MARKER_POSITION}}"] = String(
                format: "%.1f", bodyFatGradientPosition)
            replacements["{{BODY_FAT_PERCENTILE_POSITION}}"] = String(
                report.bodyFatPercentageReport.percentile.userPercentile.value)

            // Fat Mass
            let fatMassRanges: [(min: Double?, max: Double?)] = [
                (nil, 9.6),  // VERY LOW
                (9.7, 13.4),  // LOW
                (13.5, 20.9),  // HEALTHY
                (21.0, 23.8),  // HIGH
                (23.9, nil),  // UNHEALTHY
            ]
            let fatMassGradientPosition = calculateGradientPosition(
                value: report.fatMassReport.fatMass,
                ranges: fatMassRanges
            )
            replacements["{{FAT_MASS_MARKER_POSITION}}"] = String(
                format: "%.1f", fatMassGradientPosition)
            replacements["{{FAT_MASS_PERCENTILE_POSITION}}"] = String(
                report.fatMassReport.percentile.userPercentile.value)

            // Lean Mass
            let leanMassRanges: [(min: Double?, max: Double?)] = [
                (nil, 50.9),  // VERY LOW
                (51.0, 53.9),  // LOW
                (54.0, 61.4),  // HEALTHY
                (61.5, 65.1),  // HEALTHY
                (65.2, nil),  // HEALTHY
            ]
            let leanMassGradientPosition = calculateGradientPosition(
                value: report.leanMassReport.leanMass,
                ranges: leanMassRanges
            )
            replacements["{{LEAN_MASS_MARKER_POSITION}}"] = String(
                format: "%.1f", leanMassGradientPosition)
            replacements["{{LEAN_MASS_PERCENTILE_POSITION}}"] = String(
                report.leanMassReport.percentile.userPercentile.value)

            // Waist Ratio
            let waistRatioRanges: [(min: Double?, max: Double?)] = [
                (nil, 0.49),  // IN_RANGE (0-0.49)
                (0.5, 0.59),  // HIGH (0.5-0.59)
                (0.6, nil),  // VERY_HIGH (0.6+)
            ]
            let waistRatioGradientPosition = calculateGradientPosition(
                value: report.waistToHeightRatioReport.waistToHeightRatio,
                ranges: waistRatioRanges
            )
            replacements["{{WAIST_RATIO_MARKER_POSITION}}"] = String(
                format: "%.1f", waistRatioGradientPosition)
            replacements["{{WAIST_RATIO_PERCENTILE_POSITION}}"] = String(
                report.waistToHeightRatioReport.percentile.userPercentile.value)

            // Debug position text
            replacements["{{BODY_FAT_DEBUG}}"] = String(
                format: "%.1f%% (Gradient: %.1f%%, Percentile: %d%%)",
                report.bodyFatPercentageReport.bodyFatPercentage,
                bodyFatGradientPosition,
                report.bodyFatPercentageReport.percentile.userPercentile.value)

            replacements["{{FAT_MASS_DEBUG}}"] = String(
                format: "%.1f lbs (Gradient: %.1f%%, Percentile: %d%%)",
                report.fatMassReport.fatMass * 2.20462,
                fatMassGradientPosition,
                report.fatMassReport.percentile.userPercentile.value)

            replacements["{{LEAN_MASS_DEBUG}}"] = String(
                format: "%.1f lbs (Gradient: %.1f%%, Percentile: %d%%)",
                report.leanMassReport.leanMass * 2.20462,
                leanMassGradientPosition,
                report.leanMassReport.percentile.userPercentile.value)

            replacements["{{WAIST_RATIO_DEBUG}}"] = String(
                format: "%.2f (Gradient: %.1f%%, Percentile: %d%%)",
                report.waistToHeightRatioReport.waistToHeightRatio,
                waistRatioGradientPosition,
                report.waistToHeightRatioReport.percentile.userPercentile.value)

            // Add age range replacements
            replacements["{{BODY_FAT_AGE_RANGE}}"] = String(
                format: "%d-%d",
                report.bodyFatPercentageReport.percentile.userAgeRange.low,
                report.bodyFatPercentageReport.percentile.userAgeRange.high)

            replacements["{{FAT_MASS_AGE_RANGE}}"] = String(
                format: "%d-%d",
                report.fatMassReport.percentile.userAgeRange.low,
                report.fatMassReport.percentile.userAgeRange.high)

            replacements["{{LEAN_MASS_AGE_RANGE}}"] = String(
                format: "%d-%d",
                report.leanMassReport.percentile.userAgeRange.low,
                report.leanMassReport.percentile.userAgeRange.high)

            replacements["{{WAIST_RATIO_AGE_RANGE}}"] = String(
                format: "%d-%d",
                report.waistToHeightRatioReport.percentile.userAgeRange.low,
                report.waistToHeightRatioReport.percentile.userAgeRange.high)

            // Add summary text based on health labels
            let bodyFatLabel = report.bodyFatPercentageReport.healthLabel.userHealthLabel.value
            let fatMassLabel = report.fatMassReport.healthLabel.userHealthLabel.value
            let leanMassLabel = report.leanMassReport.healthLabel.userHealthLabel.value
            let waistRatioLabel = report.waistToHeightRatioReport.healthLabel.userHealthLabel.value

            replacements["{{SUMMARY_TEXT}}"] = String(
                format:
                    "Your body fat percentage is %@, with fat mass in the %@ range. "
                    + "Your lean mass is %@, and your waist-to-height ratio is %@.",
                bodyFatLabel,
                fatMassLabel,
                leanMassLabel,
                waistRatioLabel
            )
        }

        // Perform replacements
        var htmlString = templateString
        replacements.forEach { key, value in
            htmlString = htmlString.replacingOccurrences(of: key, with: value)
        }

        // Load the modified HTML
        webView.loadHTMLString(htmlString, baseURL: reportDirectoryURL)
    }

    // Helper function to format height
    private func formatHeight(_ meters: Double) -> String {
        let inches = meters * 39.3701
        let feet = Int(inches / 12)
        let remainingInches = Int(inches.truncatingRemainder(dividingBy: 12))
        return "\(feet)'\(remainingInches)\""
    }

    // Helper function to format weight
    private func formatWeight(_ kg: Double) -> String {
        let lbs = kg * 2.20462
        return String(format: "%.1f lbs", lbs)
    }

    // MARK: - Actions

    private func printReport() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Health Report"

        printController.printInfo = printInfo
        printController.printFormatter = webView.viewPrintFormatter()

        printController.present(animated: true) { _, isPrinted, error in
            if let error = error {
                self.handleError("Failed to print: \(error.localizedDescription)")
            }
        }
    }

    private func createAndSharePDF() {
        activityIndicator.startAnimating()

        let pdfGenerator = BodyScanResultsPDF(
            scanResult: scanResult,
            assetUrls: assetUrls,
            parentViewController: self
        )

        pdfGenerator.generatePDF { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()

            switch result {
            case .success(let pdfURL):
                let activityVC = UIActivityViewController(
                    activityItems: [pdfURL],
                    applicationActivities: nil
                )
                self.present(activityVC, animated: true)

            case .failure(let error):
                self.handleError("Failed to create PDF: \(error.localizedDescription)")
            }
        }
    }

    @objc private func show3DView() {
        guard let urls = assetUrls,
            urls["model"] != nil,
            urls["texture"] != nil,
            urls["material"] != nil
        else {
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
            let url = URL(string: previewUrl)
        {

            debugPrint("[BodyScanResultsViewController] Fetching preview image from:", previewUrl)

            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self else { return }

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

                debugPrint(
                    "[BodyScanResultsViewController] Created data URL with length:", dataUrl.count)

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
        // Add detailed measurements logging
        debugPrint("[BodyScanResultsViewController] Raw Measurements Data:")
        if let measurements = scanResult.measurements {
            debugPrint("  - Neck:", measurements.neckFit ?? "nil")
            debugPrint("  - Chest:", measurements.chestFit ?? "nil")
            debugPrint("  - Waist:", measurements.waistFit ?? "nil")
            debugPrint("  - Mid Arm Left:", measurements.midArmLeftFit ?? "nil")
            debugPrint("  - Mid Arm Right:", measurements.midArmRightFit ?? "nil")
            debugPrint("  - Thigh Left:", measurements.thighLeftFit ?? "nil")
            debugPrint("  - Thigh Right:", measurements.thighRightFit ?? "nil")
            debugPrint("  - Calf Left:", measurements.calfLeftFit ?? "nil")
            debugPrint("  - Calf Right:", measurements.calfRightFit ?? "nil")
        } else {
            debugPrint("  No measurements available")
        }

        let combinedData = CombinedReportData(
            healthReport: report,
            measurements: scanResult.measurements,
            scanDate: scanResult.createdAt,
            scanId: scanResult.id
        )

        // Convert to JSON
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let jsonData = try? encoder.encode(combinedData),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            handleError("Failed to encode report data")
            return
        }

        // Properly escape the image URL for JavaScript
        let imageUrlString = imageDataUrl?.replacingOccurrences(of: "\"", with: "\\\"") ?? ""

        // First, ensure the DOM is ready
        let readyCheckScript = """
                (function() {
                    if (document.readyState === 'complete') {
                        return true;
                    }
                    return false;
                })()
            """

        webView.evaluateJavaScript(readyCheckScript) { [weak self] result, error in
            guard let self = self else { return }

            let isReady = (result as? Bool) ?? false
            debugPrint("[BodyScanResultsViewController] DOM ready state:", isReady)

            // Inject data with a slight delay to ensure DOM is fully ready
            DispatchQueue.main.asyncAfter(deadline: .now() + (isReady ? 0 : 0.5)) {
                let script = """
                        try {
                            console.log('Starting data injection');
                            window.reportData = \(jsonString);
                            
                            // Update measurements first
                            if (typeof window.updateMeasurements === 'function') {
                                console.log('Calling updateMeasurements with:', window.reportData.measurements);
                                window.updateMeasurements(window.reportData.measurements);
                            } else {
                                console.error('updateMeasurements function not found');
                            }
                            
                            // Then update health report
                            if (typeof window.updateHealthReport === 'function') {
                                console.log('Calling updateHealthReport');
                                window.updateHealthReport(window.reportData.healthReport);
                            } else {
                                console.error('updateHealthReport function not found');
                            }
                            
                            // Finally update avatar
                            const todayAvatar = document.getElementById('today-avatar');
                            if (todayAvatar) {
                                todayAvatar.style.minHeight = '300px';
                                todayAvatar.style.display = 'block';
                                
                                const imageUrl = "\(imageUrlString)";
                                if (imageUrl) {
                                    todayAvatar.style.backgroundImage = `url("\(imageUrlString)")`;
                                }
                            }
                            
                            // Hide future avatar section
                            const futureAvatarCol = document.querySelector('#avatar-section .col-6:last-child');
                            if (futureAvatarCol) {
                                futureAvatarCol.style.display = 'none';
                                const todayAvatarCol = document.querySelector('#avatar-section .col-6:first-child');
                                if (todayAvatarCol) {
                                    todayAvatarCol.className = 'col-12 text-center p-0';
                                }
                            }
                        } catch (error) {
                            console.error('Error in data injection:', error);
                            console.error('Error stack:', error.stack);
                        }
                    """

                self.webView.evaluateJavaScript(script) { result, error in
                    if let error = error {
                        debugPrint(
                            "[BodyScanResultsViewController] JavaScript evaluation error:", error)
                        self.handleError("Failed to update report: \(error.localizedDescription)")
                    } else {
                        debugPrint("[BodyScanResultsViewController] Successfully injected data")
                    }
                }
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
        case (let value?, nil): return value  // Only left present
        case (nil, let value?): return value  // Only right present
        case (nil, nil): return 0  // Neither present
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

    // Modify WKNavigationDelegate to handle the test
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        debugPrint("[BodyScanResultsViewController] WebView finished loading")

        // Verify JavaScript environment
        let verificationScript = """
                (function() {
                    console.log('Verification running');
                    console.log('window.updateHealthReport:', typeof window.updateHealthReport);
                    console.log('window.updateMeasurements:', typeof window.updateMeasurements);
                    
                    // Check if elements exist
                    const elements = {
                        neck: document.getElementById('neck-circumference'),
                        chest: document.getElementById('chest-circumference'),
                        waist: document.getElementById('waist-circumference'),
                        arms: document.getElementById('arms-circumference'),
                        thighs: document.getElementById('thighs-circumference'),
                        calves: document.getElementById('calves-circumference')
                    };
                    
                    console.log('Elements found:', Object.entries(elements).map(([id, el]) => `${id}: ${!!el}`).join(', '));
                    
                    return {
                        updateHealthReportExists: typeof window.updateHealthReport === 'function',
                        updateMeasurementsExists: typeof window.updateMeasurements === 'function',
                        elements: Object.entries(elements).map(([id, el]) => [id, !!el])
                    };
                })();
            """

        webView.evaluateJavaScript(verificationScript) { result, error in
            if let error = error {
                debugPrint("[BodyScanResultsViewController] Verification error:", error)
            } else {
                debugPrint("[BodyScanResultsViewController] Verification result:", result ?? "nil")
            }

            // Now proceed with data injection
            self.injectHealthReportData()
        }
    }

    public func webView(
        _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
    ) {
        debugPrint("[BodyScanResultsViewController] WebView failed to load:", error)
        handleError("Failed to load report view: \(error.localizedDescription)")
    }

    // Add helper function to calculate gradient bar position
    private func calculateGradientPosition(value: Double, ranges: [(min: Double?, max: Double?)])
        -> Double
    {
        // First find the total range
        let minValue = ranges.compactMap { $0.min }.min() ?? ranges[0].max! * 0.5
        let maxValue = ranges.compactMap { $0.max }.max() ?? ranges.last!.min! * 1.5
        let totalRange = maxValue - minValue

        // Calculate the relative position
        let relativePosition = (value - minValue) / totalRange

        // Convert to percentage (0-100)
        let percentage = relativePosition * 100.0

        // Clamp between 0 and 100
        return max(0, min(100, percentage))
    }
}

// MARK: - WKNavigationDelegate

extension BodyScanResultsViewController: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        debugPrint(
            "[BodyScanResultsViewController] Deciding policy for:",
            navigationAction.request.url?.absoluteString ?? "unknown URL")
        // Allow all navigation while debugging
        decisionHandler(.allow)
    }
}
