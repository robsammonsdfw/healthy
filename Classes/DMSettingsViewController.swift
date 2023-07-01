//
//  DMSettingsViewController.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/29/23.
//

import UIKit
import SafariServices

/// The main entry point for settings.
@objc class DMSettingsViewController : UIViewController {
    let accountCode = DMGUtilities.configValue(forKey: "account_code")
    /// Two optional buttons for a custom implementation if account_code
    /// is "trdietpro".
    private lazy var mwlbookletButton: UIButton = {
        let button = defaultButton()
        button.setTitle("View MWL Booklet", for: .normal)
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = UIColor(hex: "#F2C53Dff") // Yellow.
        return button
    }()
    private lazy var hcgbookletButton: UIButton = {
        let button = defaultButton()
        button.setTitle("View HCG Booklet", for: .normal)
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = UIColor(hex: "#F2C53Dff") // Yellow.
        return button
    }()
    
    private lazy var optionalSettingsButton: UIButton = {
        let button = defaultButton()
        button.setTitle("Optional Settings", for: .normal)
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = UIColor(hex: "#F2C53Dff") // Yellow.
        return button
    }()
    private lazy var customFoodsButton: UIButton = {
        let button = defaultButton()
        button.setTitle("My Custom Foods", for: .normal)
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = UIColor(hex: "#F2C53Dff") // Yellow.
        return button
    }()
    private lazy var addCustomFoodButton: UIButton = {
        let button = defaultButton()
        button.setTitle("Add Custom Food", for: .normal)
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = UIColor(hex: "#F2C53Dff") // Yellow.
        return button
    }()
    private lazy var downSyncButton: UIButton = {
        let button = defaultButton()
        button.setTitle("Update Local Data", for: .normal)
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = .lightGray
        return button
    }()
    private lazy var upSyncButton: UIButton = {
        let button = defaultButton()
        button.setTitle("Send Local Data", for: .normal)
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = .lightGray
        return button
    }()
    private lazy var foodsUpdateButton: UIButton = {
        let button = defaultButton()
        button.setTitle("Update Local Foods", for: .normal)
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = .lightGray
        return button
    }()
    private lazy var logoutButton: UIButton = {
        let button = defaultButton()
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = .black
        return button
    }()
    private lazy var safetyButton: UIButton = {
        let button = defaultButton()
        button.setTitle("Safety Guidelines & Sources", for: .normal)
        button.configuration = .borderless()
        return button
    }()
    private lazy var lastSyncLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    private lazy var versionLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "App version: " + UIApplication.version
        label.textAlignment = .center
        return label
    }()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        optionalSettingsButton.addTarget(self, action: #selector(showOptionalSettings), for: .touchUpInside)
        customFoodsButton.addTarget(self, action: #selector(showCustomFoods), for: .touchUpInside)
        addCustomFoodButton.addTarget(self, action: #selector(showAddCustomFood), for: .touchUpInside)
        downSyncButton.addTarget(self, action: #selector(performDownSync), for: .touchUpInside)
        upSyncButton.addTarget(self, action: #selector(performUpSync), for: .touchUpInside)
        foodsUpdateButton.addTarget(self, action: #selector(updateFoodDatabase), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logOutUser), for: .touchUpInside)
        safetyButton.addTarget(self, action: #selector(showSafetyGuidelines), for: .touchUpInside)

        let padding:CGFloat = 30
        let spacing:CGFloat = 12
        let layoutGuide = self.view.safeAreaLayoutGuide

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Show add'l buttons if we're TR Diet Pro.
        if accountCode == "trdietpro" {
            mwlbookletButton.addTarget(self, action: #selector(showMWLBooklet), for: .touchUpInside)
            hcgbookletButton.addTarget(self, action: #selector(showHCGBooklet), for: .touchUpInside)
            stackView.addArrangedSubview(mwlbookletButton)
            stackView.setCustomSpacing(spacing, after: mwlbookletButton)
            stackView.addArrangedSubview(hcgbookletButton)
            stackView.setCustomSpacing(padding, after: hcgbookletButton)
        }
        
        stackView.addArrangedSubview(optionalSettingsButton)
        stackView.setCustomSpacing(spacing, after: optionalSettingsButton)
        stackView.addArrangedSubview(customFoodsButton)
        stackView.setCustomSpacing(spacing, after: customFoodsButton)
        stackView.addArrangedSubview(addCustomFoodButton)
        stackView.setCustomSpacing(padding, after: addCustomFoodButton)

        stackView.addArrangedSubview(lastSyncLabel)
        stackView.setCustomSpacing(spacing, after: lastSyncLabel)
        stackView.addArrangedSubview(downSyncButton)
        stackView.setCustomSpacing(spacing, after: downSyncButton)
        stackView.addArrangedSubview(upSyncButton)
        stackView.setCustomSpacing(spacing, after: upSyncButton)
        stackView.addArrangedSubview(foodsUpdateButton)
        stackView.setCustomSpacing(spacing, after: foodsUpdateButton)
        stackView.setCustomSpacing(padding, after: foodsUpdateButton)
        
        stackView.addArrangedSubview(logoutButton)
        stackView.setCustomSpacing(padding, after: logoutButton)

        stackView.addArrangedSubview(safetyButton)
        stackView.setCustomSpacing(padding, after: safetyButton)

        stackView.addArrangedSubview(versionLabel)
        view.addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
        stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: padding * 2).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: layoutGuide.bottomAnchor, constant: -padding).isActive = true

        updateLastSyncLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Settings";
        navigationController?.navigationBar.barStyle = .black;
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isTranslucent = false

        updateLastSyncLabel()
    }

    private func updateLastSyncLabel() {
        let dateString = DMGUtilities.lastSyncDateString()
        let serverFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverFormat
        let syncDate = dateFormatter.date(from: dateString)

        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        let syncStringFormatted = dateFormatter.string(from: syncDate!)
        
        lastSyncLabel.text = "Last sync: " + syncStringFormatted
    }
    
    private func defaultButton() -> UIButton {
        let button = UIButton.init(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.bordered()
        config.titleAlignment = .center
        config.baseBackgroundColor = .lightGray
        config.baseForegroundColor = .black
        config.buttonSize = .medium
        button.configuration = config
        
        return button
    }
    
    // MARK: - Actions

    /// Custom action for TRDietPro.
    @objc private func showMWLBooklet() {
        let url = URL(string: "http://www.Lifestylestech.com/TampaRejuv/mwl_manual_june_2013_mobile.pdf")!
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true)
    }
    /// Custom action for TRDietPro.
    @objc private func showHCGBooklet() {
        let url = URL(string: "http://www.Lifestylestech.com/TampaRejuv/hcg_manual_june_2013_mobile.pdf")!
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true)
    }

    @objc private func showOptionalSettings() {
        let controller = AppSettings()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func showCustomFoods() {
        let engine = DietmasterEngine.sharedInstance()
        engine?.taskMode = "View"

        let controller = FoodsSearch()
        controller.searchType = .myFoods
        controller.title = "My Foods"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func showAddCustomFood() {
        let engine = DietmasterEngine.sharedInstance()
        engine?.taskMode = ""
        
        let controller = ManageFoods(food: nil)
        controller?.hideAddToLog = true
        navigationController?.pushViewController(controller!, animated: true)
    }

    @objc private func performDownSync() {
        DMActivityIndicator.show()
        DMMyLogDataProvider.syncDatabase { completed, error in
            DMActivityIndicator.hide()
            if error != nil {
                DMGUtilities.showAlert(withTitle: "Error", message: error!.localizedDescription, in: nil)
                return
            }
            
            DMActivityIndicator.showCompletedIndicator()
            self.lastSyncLabel.text = "Last Sync: " + DMGUtilities.lastSyncDateString()
        }
    }

    @objc private func performUpSync() {
        DMActivityIndicator.show()
        DMMyLogDataProvider.uploadDatabase(completionBlock: { completed, error in
            DMActivityIndicator.hide()
            if error != nil {
                DMGUtilities.showAlert(withTitle: "Error", message: error!.localizedDescription, in: nil)
                return
            }
            DMActivityIndicator.showCompletedIndicator()
        })
    }

    @objc private func updateFoodDatabase() {
        DMActivityIndicator.show()
        let dataProvider = DMMyLogDataProvider()
        let dateString = DMGUtilities.lastFoodSyncDateString()
        dataProvider.syncFoods(dateString, pageNumber: 1, fetchedItems: []) { completed, error in
            DMActivityIndicator.hide()
            if error != nil {
                DMGUtilities.showAlert(withTitle: "Error", message: error!.localizedDescription, in: nil)
                return
            }
            DMGUtilities.setLastFoodSyncDate(Date.now)
            DMActivityIndicator.showCompletedIndicator()
        }
    }

    @objc private func logOutUser() {
        DMAuthManager.sharedInstance().logoutCurrentUser()
    }

    @objc private func showSafetyGuidelines() {
        let url = URL(string: "https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html")!
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true)
    }

}

/// Extension to provide app version.
/// Defaults to x.x x.
extension UIApplication {
    static var release: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.x"
    }
    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String? ?? "x"
    }
    static var version: String {
        return "\(release) Build: \(build)"
    }
}
