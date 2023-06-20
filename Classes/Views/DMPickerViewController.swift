//
//  DMPickerViewController.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/20/23.
//

import UIKit

@objc protocol DMPickerViewDataSource {
    var name: String { get }
}

/// Empty row for the picker.
class DMEmptyRow: NSObject, DMPickerViewDataSource {
    let name = ""
}

/// Controller that displays a picker for the user to choose and
/// option from.
class DMPickerViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private var navController: UINavigationController?
    private lazy var pickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    /// Mutable array that holds the data for the picker to display.
    private var dataSourceArray: [DMPickerViewDataSource] = []
    /// If there should be a row added that's blank.
    private var showNoneRow = false
    
    /// Closure that will be called when a user selects an option. Note, this could be called
    /// multiple times as the user makes their selection.
    @objc public var didSelectOptionCallback: ((_ object: DMPickerViewDataSource, _ row: Int) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(pickerView)
        pickerView.dataSource = self
        pickerView.delegate = self
        // Constrain
        let layoutGuide = view.safeAreaLayoutGuide
        pickerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 0).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: 0).isActive = true
        pickerView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 0).isActive = true
        pickerView.bottomAnchor.constraint(lessThanOrEqualTo: layoutGuide.bottomAnchor, constant: 0).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    // MARK: - Public
    
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
        self.title = "Select Option"
        controller.present(navController, animated: true, completion: nil)
    }
    
    /// Dismisses the presented picker, if visible.
    @objc public func dismissPicker() {
        navController?.dismiss(animated: true)
    }
    
    @objc public func setDataSource(dataArray: [DMPickerViewDataSource]?, showNoneRow: Bool) {
        dataSourceArray.removeAll()
        guard let dataArray = dataArray else {
            return
        }
        if showNoneRow {
            let none = DMEmptyRow()
            dataSourceArray.append(none)
        }
        dataSourceArray.append(contentsOf: dataArray)
        pickerView.reloadAllComponents()
    }
    
    // MARK: Picker DataSource / Delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSourceArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = dataSourceArray[row]
        return item.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let item = dataSourceArray[row]
        didSelectOptionCallback?(item, row)
    }
}
