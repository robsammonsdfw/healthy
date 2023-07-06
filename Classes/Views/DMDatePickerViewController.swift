//
//  DMDatePickerViewController.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/21/23.
//

import UIKit

/// Controller that displays a date picker for the user to choose from.
class DMDatePickerViewController : BaseViewController {
    private var navController: UINavigationController?
    private weak var presentingController: UIViewController?
    private var pickerView = {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .date
        pickerView.preferredDatePickerStyle = .wheels
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    /// Closure that will be called when a user selects an option. Note, this could be called
    /// multiple times as the user makes their selection.
    @objc public var pickerDateChangedCallback: ((_ date: Date) -> Void)?
    /// Closure that's called when the user presses done.
    @objc public var didSelectDateCallback: ((_ date: Date) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        pickerView.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(pickerView)
        // Constrain
        let layoutGuide = view.safeAreaLayoutGuide
        pickerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 0).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: 0).isActive = true
        pickerView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 0).isActive = true
        pickerView.bottomAnchor.constraint(lessThanOrEqualTo: layoutGuide.bottomAnchor, constant: 0).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    /// Called when date changed.
    @objc private func dateChanged() {
        pickerDateChangedCallback?(pickerView.date)
    }
    
    // MARK: - Public
    
    /// Sets the date on the picker. Defaults to current date if none provided.
    @objc public func setDate(_ date: Date?) {
        guard let date = date else { return }
        pickerView.date = date
    }
    
    /// Presents the picker in a bottom sheet.
    @objc public func presentPicker(in controller: UIViewController) {
        navController = UINavigationController(rootViewController: self)
        guard let navController = navController else { return }
        navController.setNavigationBarHidden(false, animated: false)
        navController.modalPresentationStyle = .pageSheet
        let rightButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        self.navigationItem.rightBarButtonItem = rightButton
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        self.title = "Select Date"
        presentingController = controller
        presentingController?.present(navController, animated: true, completion: {
            self.pickerDateChangedCallback?(self.pickerView.date)
        })
    }
    
    /// Dismisses the presented picker, if visible.
    @objc public func dismissPicker() {
        presentingController?.dismiss(animated: true) {
            self.didSelectDateCallback?(self.pickerView.date)
            self.navController = nil
            self.presentingController = nil
        }
    }
}
