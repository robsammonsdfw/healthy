//
//  LogDaySummaryView.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/21/23.
//

import UIKit

/// View that displays the recommended and remaining calories/fat/protein
/// for their day's food log.
class LogDaySummaryView : UIView {
    private lazy var recommendedView = {
        let view = SummaryView()
        view.getComposedStackView()?.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var remainingView = {
        let view = SummaryView()
        view.getComposedStackView()?.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var lineView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppConfiguration.footerTextColor
        return view
    }()
    
    private lazy var infoButton = {
        let button = UIButton(type: .infoLight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = AppConfiguration.footerTextColor
        return button
    }()
    
    /// Closure that will be called when the user presses the info button.
    @objc public var didSelectInfoButtonCallback: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = AppConfiguration.footerColor
        self.addSubview(lineView)
        self.layer.cornerRadius = 25
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        guard let recommendedView = recommendedView.getComposedStackView(),
                let remainingView = remainingView.getComposedStackView() else { return }
        self.addSubview(recommendedView)
        self.addSubview(remainingView)
        
        let layoutGuide = self.safeAreaLayoutGuide
        recommendedView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        recommendedView.trailingAnchor.constraint(equalTo: lineView.leadingAnchor, constant: 0).isActive = true
        recommendedView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        recommendedView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -12).isActive = true
        
        remainingView.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 0).isActive = true
        remainingView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        remainingView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        remainingView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -12).isActive = true
        
        setRecommendedLabels(calorie: "0g", carbs: "0g", protein: "0g", fat: "0g")
        setRemainingLabels(calorie: "0g", carbs: "0g", protein: "0g", fat: "0g")

        self.addSubview(infoButton)
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        
        lineView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true

        infoButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        infoButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        infoButton.widthAnchor.constraint(equalToConstant: 26).isActive = true
    }
    
    @objc private func infoButtonPressed() {
        didSelectInfoButtonCallback?()
    }
    
    // MARK: - Public
    
    @objc public func setRecommendedLabels(calorie: String,
                                     carbs: String,
                                     protein: String,
                                     fat: String) {
        recommendedView.setLabels(calorieTitle: "Recommended", calorie: calorie,
                                  carbsTitle: "Carbs", carbs: carbs,
                                  proteinLabel: "Protein",
                                  protein: protein, fatLabel: "Fat", fat: fat)
    }
    
    @objc public func setRemainingLabels(calorie: String,
                                     carbs: String,
                                     protein: String,
                                     fat: String) {
        remainingView.setLabels(calorieTitle: "Remaining", calorie: calorie,
                                carbsTitle: "Carbs", carbs: carbs,
                                proteinLabel: "Protein", protein: protein,
                                fatLabel: "Fat", fat: fat)
    }

}

/// Builds a summary view of Calories, Carbs, Fat, and Protein
/// in a column.
class SummaryView: NSObject {
    /// The stack view that will be returned once the view is
    /// created.
    private var stackView:UIStackView?
    
    private lazy var caloriesTitleLabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 11)
        view.textColor = AppConfiguration.footerTextColor
        view.text = "Calories"
        return view
    }()
    private lazy var caloriesLabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        view.textColor = AppConfiguration.footerTextColor
        view.text = "0g"
        return view
    }()

    private lazy var carbsTitleLabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 11)
        view.textColor = AppConfiguration.footerTextColor
        view.text = "Carbs"
        return view
    }()
    private lazy var carbsLabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.textColor = AppConfiguration.footerTextColor
        view.text = "0g"
        return view
    }()

    private lazy var proteinTitleLabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 11)
        view.textColor = AppConfiguration.footerTextColor
        view.text = "Protein"
        return view
    }()
    private lazy var proteinLabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.textColor = AppConfiguration.footerTextColor
        view.text = "0g"
        return view
    }()

    private lazy var fatTitleLabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 11)
        view.textColor = AppConfiguration.footerTextColor
        view.text = "Fat"
        return view
    }()
    private lazy var fatLabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.textColor = AppConfiguration.footerTextColor
        view.text = "0g"
        return view
    }()

    override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        stackView = UIStackView()
        stackView?.alignment = .center
        stackView?.axis = .vertical
        
        stackView?.addArrangedSubview(caloriesTitleLabel)
        stackView?.setCustomSpacing(1, after: caloriesTitleLabel)
        stackView?.addArrangedSubview(caloriesLabel)
        stackView?.setCustomSpacing(3, after: caloriesLabel)
        stackView?.addArrangedSubview(carbsTitleLabel)
        stackView?.setCustomSpacing(1, after: carbsTitleLabel)
        stackView?.addArrangedSubview(carbsLabel)
        stackView?.setCustomSpacing(5, after: carbsLabel)
        stackView?.addArrangedSubview(proteinTitleLabel)
        stackView?.setCustomSpacing(1, after: proteinTitleLabel)
        stackView?.addArrangedSubview(proteinLabel)
        stackView?.setCustomSpacing(5, after: proteinLabel)
        stackView?.addArrangedSubview(fatTitleLabel)
        stackView?.setCustomSpacing(1, after: fatTitleLabel)
        stackView?.addArrangedSubview(fatLabel)
    }
    
    /// Returns the stackView that should be displayed to
    /// the user.
    public func getComposedStackView() -> UIStackView? {
        return stackView
    }
        
    /// Updates the strings for the labels within the view.
    public func setLabels(calorieTitle: String, calorie: String,
                          carbsTitle: String, carbs: String,
                          proteinLabel: String, protein: String,
                          fatLabel: String, fat: String) {
        self.caloriesTitleLabel.text = calorieTitle
        self.caloriesLabel.text = calorie
        
        self.carbsTitleLabel.text = carbsTitle
        self.carbsLabel.text = carbs
        
        self.proteinTitleLabel.text = proteinLabel
        self.proteinLabel.text = protein
        
        self.fatTitleLabel.text = fatLabel
        self.fatLabel.text = fat
    }
}
