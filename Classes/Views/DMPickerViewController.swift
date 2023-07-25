//
//  DMPickerViewController.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/20/23.
//

import UIKit

/// Empty row for the picker.
class DMEmptyRow: NSObject, DMPickerViewDataSource {
    let name = ""
}

/// Controller that displays a picker for the user to choose and
/// option from.
class DMPickerViewController : BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private weak var presentingController: UIViewController?
    private var navController: UINavigationController?
    private var pickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    /// Mutable array that holds the data for the picker to display.
    private var dataSourceArray: [DMPickerViewDataSource] = []
    /// If there should be a row added that's blank.
    private var showNoneRow = false
    
    /// Sets the selected index on the picker.
    @objc public var selectedIndex = 0

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
    
    /// Presents the picker in a bottom sheet with default index selected (0).
    @objc public func presentPicker(in controller: UIViewController) {
        self.presentPicker(in: controller, selectedIndex: 0)
    }

    /// Presents the picker in a bottom sheet with optional selected index.
    @objc public func presentPicker(in controller: UIViewController, selectedIndex: Int) {
        self.navController = UINavigationController(rootViewController: self)
        guard let navController = navController else { return }
        navController.setNavigationBarHidden(false, animated: false)
        navController.modalPresentationStyle = .pageSheet
        let rightButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        self.navigationItem.rightBarButtonItem = rightButton
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        self.title = "Select Option"
        self.selectedIndex = selectedIndex
        presentingController = controller
        presentingController?.present(navController, animated: true, completion: {
            self.pickerView.selectRow(self.selectedIndex, inComponent: 0, animated: true)
        })
    }
    
    /// Dismisses the presented picker, if visible.
    @objc public func dismissPicker() {
        presentingController?.dismiss(animated: true)
        navController = nil
        selectedIndex = 0
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
