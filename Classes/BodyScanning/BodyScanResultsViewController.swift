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
    
    // MARK: - Initialization
    
    /// Initialize with a scan result
    /// - Parameter scanResult: The scan result to display
    public init(scanResult: ScanResult) {
        self.scanResult = scanResult
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
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        navigationItem.rightBarButtonItem = exportButton
        
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
    
    // MARK: - Error Handling
    
    private func handleError(_ message: String) {
        activityIndicator.stopAnimating()
        DMGUtilities.showAlert(
            withTitle: "Error",
            message: message,
            in: self
        )
    }
}

// MARK: - WKNavigationDelegate

extension BodyScanResultsViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Here we'll inject the data after template loads
        // For now, just stop the spinner
        activityIndicator.stopAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error.localizedDescription)
    }
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // Only allow loading the initial file URL
        if navigationAction.navigationType == .other {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
}

