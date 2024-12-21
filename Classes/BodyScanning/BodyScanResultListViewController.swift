//
//  BodyScanResultListViewController.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 12/20/24.
//

import UIKit
import PrismSDK

/// Displays a list of body scan results in a table view
@objcMembers public class BodyScanResultListViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Table view for displaying scan results
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(BodyScanResultCell.self, forCellReuseIdentifier: BodyScanResultCell.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.separatorStyle = .singleLine
        table.backgroundColor = .systemBackground
        return table
    }()
    
    /// Activity indicator for loading states
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    /// Array of scan results to display
    private var scanResults: [ScanResult] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    /// Tracks if we're currently loading more results
    private var isLoading = false
    
    /// Cursor for pagination
    private var nextCursor: String?
    
    /// Number formatter for weight conversion
    private let weightFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadScans()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Scan History"
        view.backgroundColor = .systemBackground
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Loading
    
    @objc private func refreshData() {
        nextCursor = nil
        loadScans()
    }
    
    private func loadScans() {
        guard !isLoading else { return }
        isLoading = true
        
        if scanResults.isEmpty {
            activityIndicator.startAnimating()
        }
        
        PrismScannerManager.shared.fetchScans(limit: 25, cursor: nextCursor) { [weak self] result, error in
            guard let self = self else { return }
            
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
            
            if let error = error {
                self.handleError(error)
                return
            }
            
            // Handle PrismSDK.Paginated<Scan> response
            if let paginated = result as? Paginated<Scan> {
                // Convert PrismSDK.Scan objects to our ScanResult model
                let newScans = paginated.results.map { prismScan -> ScanResult in
                    // Create measurements from scan data
                    let measurements = Measurements(
                        weight: Measurement(
                            value: prismScan.weight.value,
                            unit: prismScan.weight.unit.rawValue
                        ),
                        bodyFat: prismScan.bodyfat.flatMap { bodyfat in
                            bodyfat.bodyfatPercentage.map { percentage in
                                Measurement(value: percentage, unit: "%")
                            }
                        },
                        muscleMass: prismScan.bodyfat.flatMap { bodyfat in
                            bodyfat.leanMass.map { mass in
                                Measurement(value: mass, unit: "kg")
                            }
                        }
                    )
                    
                    return ScanResult(
                        id: prismScan.id,
                        createdAt: prismScan.createdAt,
                        status: prismScan.status.rawValue,
                        measurements: measurements
                    )
                }
                
                DispatchQueue.main.async {
                    if self.nextCursor == nil {
                        self.scanResults = newScans
                    } else {
                        self.scanResults.append(contentsOf: newScans)
                    }
                    self.nextCursor = paginated.pageInfo.cursor
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        DMGUtilities.showAlert(withTitle: "Error", 
                             message: error.localizedDescription,
                               in: self)
    }
}

// MARK: - UITableViewDataSource

extension BodyScanResultListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanResults.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BodyScanResultCell.reuseIdentifier, for: indexPath) as! BodyScanResultCell
        cell.configure(with: scanResults[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let scan = scanResults[indexPath.row]
            
            // Show confirmation alert
            let alert = UIAlertController(
                title: "Delete Scan",
                message: "Are you sure you want to delete this scan? This action cannot be undone.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                // Show loading indicator
                self.activityIndicator.startAnimating()
                
                // Call delete API
                PrismScannerManager.shared.deleteScan(withId: scan.id) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.activityIndicator.stopAnimating()
                    
                    if let error = error {
                        DMGUtilities.showAlert(
                            withTitle: "Error",
                            message: "Failed to delete scan: \(error.localizedDescription)",
                            in: self
                        )
                        return
                    }
                    
                    // Remove from local array and update UI
                    self.scanResults.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            })
            
            present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate

extension BodyScanResultListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let scan = scanResults[indexPath.row]
        let resultsVC = BodyScanResultsViewController(scanResult: scan)
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Load more results when user scrolls near bottom
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        if offset > contentHeight - screenHeight * 1.5 {
            loadScans()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Only trigger refresh if pulled down at least 60 points
        if scrollView.contentOffset.y < -60 {
            refreshData()
        }
    }
}

// MARK: - BodyScanResultCell

private class BodyScanResultCell: UITableViewCell {
    static let reuseIdentifier = "BodyScanResultCell"
    
    private let weightFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        contentView.addSubview(statusLabel)
        
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(detailsLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            statusLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(with scan: ScanResult) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        dateLabel.text = dateFormatter.string(from: scan.createdAt)
        
        var details = [String]()
        
        // Body Fat
        if let measurements = scan.measurements,
           let bodyFat = measurements.bodyFat,
           let formattedBodyFat = weightFormatter.string(from: NSNumber(value: bodyFat.value)) {
            details.append("• Body Fat: \(formattedBodyFat)\(bodyFat.unit)")
        }
        
        // Weight
        if let measurements = scan.measurements,
           let weight = measurements.weight {
            let weightLbs = weight.value * 2.20462 // Convert kg to lbs
            if let formattedWeight = weightFormatter.string(from: NSNumber(value: weightLbs)) {
                details.append("• Weight: \(formattedWeight) lbs")
            }
        }
        
        // Muscle Mass (using bodyFat.leanMass if available)
        if let measurements = scan.measurements,
           let muscleMass = measurements.muscleMass {
            let muscleMassLbs = muscleMass.value * 2.20462 // Convert kg to lbs
            if let formattedMass = weightFormatter.string(from: NSNumber(value: muscleMassLbs)) {
                details.append("• Muscle Mass: \(formattedMass) lbs")
            }
        }
        
        detailsLabel.text = details.joined(separator: "\n")
        
        statusLabel.text = "\(scan.status.capitalized)"
        statusLabel.backgroundColor = UIColor.statusColor(for: scan.status)
        statusLabel.textColor = UIColor.statusTextColor(for: scan.status)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Add extension for status colors
private extension UIColor {
    static func statusColor(for status: String) -> UIColor {
        switch status.lowercased() {
        case "created":
            return .systemGray.withAlphaComponent(0.2)
        case "processing":
            return .systemYellow.withAlphaComponent(0.2)
        case "ready":
            return .systemGreen.withAlphaComponent(0.2)
        case "failed":
            return .systemRed.withAlphaComponent(0.2)
        default:
            return .systemGray.withAlphaComponent(0.2)
        }
    }
    
    static func statusTextColor(for status: String) -> UIColor {
        switch status.lowercased() {
        case "created":
            return .systemGray
        case "processing":
            return .systemYellow
        case "ready":
            return .systemGreen
        case "failed":
            return .systemRed
        default:
            return .systemGray
        }
    }
}

// MARK: - Models

/// Represents a scan result from the API
public struct ScanResult {
    public let id: String
    public let createdAt: Date
    public let status: String
    public let measurements: Measurements?
}

/// Represents measurement data from a scan
public struct Measurements {
    public let weight: Measurement?
    public let bodyFat: Measurement?
    public let muscleMass: Measurement?
    
    public init(weight: Measurement?, bodyFat: Measurement?, muscleMass: Measurement?) {
        self.weight = weight
        self.bodyFat = bodyFat
        self.muscleMass = muscleMass
    }
}

/// Represents a single measurement with value and unit
public struct Measurement {
    public let value: Double
    public let unit: String
    
    public init(value: Double, unit: String) {
        self.value = value
        self.unit = unit
    }
    
    public var formatted: String {
        return String(format: "%.1f %@", value, unit)
    }
}

