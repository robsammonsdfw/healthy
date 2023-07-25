//
//  MenuViewController.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/21/23.
//

import UIKit
import JJFloatingActionButton

/// Menu floating action button that allows a user to
/// navigate between the different screens in DMG.
class MainMenuFAB: NSObject, UINavigationControllerDelegate {
    /// The colors of the button and images.
    private let buttonColor:UIColor = .white
    private let buttonImageColor:UIColor = AppConfiguration.homeIconForegroundColor
    
    /// The navigation controller that the FAB is presented in and uses
    /// for navigation.
    private var navigationController:UINavigationController?
    
    /// The different controllers we're navigating to.
    private lazy var rootViewController = {
        return DietMasterGoViewController()
    }()
    private lazy var myLogViewController = {
        return MyLogViewController()
    }()
    private lazy var myGoalViewController = {
        return MyGoalViewController()
    }()
    private lazy var mealPlanViewController = {
        return MealPlanViewController()
    }()
    private lazy var appSettingsViewController = {
        return DMSettingsViewController()
    }()
    private lazy var myMovesViewController = {
        return MyMovesViewController()
    }()

    /// Action button that will show menu items.
    private lazy var actionButton = {
        let actionButton = JJFloatingActionButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        // Configure the main action button.
        actionButton.buttonDiameter = 60
        actionButton.itemSizeRatio = CGFloat(0.75)
        actionButton.buttonImageSize = CGSize(width: 35, height: 35)
        let image = UIImage(named: "popup icon")?.withRenderingMode(.alwaysTemplate)
        actionButton.buttonImage = image
        actionButton.buttonColor = buttonColor
        actionButton.buttonImageColor = buttonImageColor
        return actionButton
    }()
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Setup the buttons that appear from the FAB.
        actionButton.configureDefaultItem { item in
            item.titlePosition = .trailing
            let fontSize = UIFont.systemFontSize * 1.15
            item.titleLabel.font = .boldSystemFont(ofSize: fontSize)
            item.titleLabel.textColor = .white
            item.buttonColor = self.buttonColor
            item.buttonImageColor = self.buttonImageColor
            item.imageSize = CGSize(width: 25, height: 25)
        }
        
        let homeImage = UIImage(named: "Icon awesome-home")?.withRenderingMode(.alwaysTemplate)
        actionButton.addItem(title: "Home", image: homeImage) { item in
            self.navigationController?.popToRootViewController(animated: false)
        }

        let weightImage = UIImage(named: "Icon awesome-weight")?.withRenderingMode(.alwaysTemplate)
        actionButton.addItem(title: "Weight", image: weightImage) { item in
            self.navigationController?.setViewControllers([self.rootViewController, self.myGoalViewController], animated: false)
        }

        let logImage = UIImage(named: "Icon metro-spoon-fork")?.withRenderingMode(.alwaysTemplate)
        actionButton.addItem(title: "MyLog", image: logImage) { item in
            self.navigationController?.setViewControllers([self.rootViewController, self.myLogViewController], animated: false)
        }

        let myMealsImage = UIImage(named: "Icon ionic-ios-journal")?.withRenderingMode(.alwaysTemplate)
        actionButton.addItem(title: "MyMeals", image: myMealsImage) { item in
            self.navigationController?.setViewControllers([self.rootViewController, self.mealPlanViewController], animated: false)
        }

        if AppConfiguration.enableMyMoves {
            let myMovesImage = UIImage(named: "Icon awesome-dumbbell")?.withRenderingMode(.alwaysTemplate)
            actionButton.addItem(title: "MyMoves", image: myMovesImage) { item in
                self.navigationController?.setViewControllers([self.rootViewController, self.myMovesViewController], animated: false)
            }
        }

        let settingsImage = UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate)
        actionButton.addItem(title: "Settings", image: settingsImage) { item in
            self.navigationController?.pushViewController(self.appSettingsViewController, animated: true)
        }
    }
    
    // MARK: - Public
    
    /// Presents the FAB in the navigation controller provided.
    /// The reason a navigation controller is required is because when a
    /// user selects an item in the menu, it's popped or pushed onto the stack.
    @objc public func presentInNavController(controller: UINavigationController?) {
        guard let controller = controller else { return }
        navigationController = controller
        navigationController?.delegate = self
        
        controller.view.addSubview(actionButton)
        let safeAreaLayoutGuide = controller.view.safeAreaLayoutGuide
        actionButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
    
    /// Resets to Home.
    @objc public func resetToHome() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Hide on settings.
        if viewController == self.appSettingsViewController {
            actionButton.isHidden = true
            return
        }
        // Hide on message view.
        if viewController.isKind(of: MessageViewController.self) {
            actionButton.isHidden = true
            return
        }
        // Hide on ExercisesDetailViewController
        if viewController.isKind(of: ExercisesDetailViewController.self) {
            actionButton.isHidden = true
            return
        }
        // Hide on DetailViewController
        if viewController.isKind(of: DetailViewController.self) {
            actionButton.isHidden = true
            return
        }
        // Hide on MealPlanDetailViewController
        if viewController.isKind(of: MealPlanDetailViewController.self) {
            actionButton.isHidden = true
            return
        }
        // Hide on AppSettings
        if viewController.isKind(of: AppSettings.self) {
            actionButton.isHidden = true
            return
        }
        actionButton.isHidden = false
    }
}
