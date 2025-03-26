//
//  HomeScreenButton.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 12/20/24.
//

import UIKit

/// A custom UIView that displays a centered image and label with a button in the lower left corner.
/// Fixed size of 167x115 points.
///
/// Usage in Objective-C:
/// ```objc
/// HomeScreenButton *button = [[HomeScreenButton alloc] initWithImage:image text:@"Button Text"];
/// [button setCornerButtonImage:[UIImage imageNamed:@"cornerIcon"]];
/// button.cornerButtonTapped = ^{
///     // Handle corner button tap
/// };
/// ```
@objc public final class HomeScreenButton: UIView {
    // MARK: - Private Properties
    /// Vertical stack view that contains the imageView and label
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    /// 30x30 image view displayed in the center of the view
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Label displayed below the centered image
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    /// 30x30 button positioned in the lower left corner
    private let cornerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Style the button
        button.layer.cornerRadius = 15.0
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 1.0
        button.clipsToBounds = true
        button.tintColor = .black
        button.backgroundColor = .white
        
        // Add these lines to properly size the image
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        
        return button
    }()
    
    /// Container view that handles the border
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Public Properties
    /// Closure that gets called when the corner button is tapped
    @objc public var cornerButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    /// Creates a new HomeScreenButton with the specified image and text
    /// - Parameters:
    ///   - image: The image to display in the center
    ///   - text: The text to display below the image
    @objc public init(image: UIImage?, text: String) {
        super.init(frame: .zero)
        setupView()
        configure(with: image, text: text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Private Methods
    /// Sets up the view hierarchy and constraints
    private func setupView() {
        // Add containerView first
        addSubview(containerView)
        
        // Add other subviews to the main view (not the container)
        addSubview(stackView)
        addSubview(cornerButton)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        // Setup corner button action
        cornerButton.addTarget(self, action: #selector(cornerButtonAction), for: .touchUpInside)
        
        // Set default corner button image
        setCornerButtonImage(UIImage(named: "Icon feather-plus"))
        
        backgroundColor = .white
        clipsToBounds = false
        
        // Move shadow styling to main view (remove border since it's now on container)
        layer.shadowColor = UIColor(hex: "#d7d7d7")?.cgColor
        layer.shadowOffset = CGSize(width: 4, height: 3)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 2
        layer.masksToBounds = false
        
        // Configure constraints
        NSLayoutConstraint.activate([
            // Container view constraints - 1 point smaller on each side
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            // Rest of existing constraints remain the same
            widthAnchor.constraint(equalToConstant: 167),
            heightAnchor.constraint(equalToConstant: 115),
            
            // ImageView size constraints
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            
            // Center stack view
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Corner button constraints
            cornerButton.widthAnchor.constraint(equalToConstant: 30),
            cornerButton.heightAnchor.constraint(equalToConstant: 30),
            cornerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -6),
            bottomAnchor.constraint(equalTo: cornerButton.bottomAnchor, constant: -6)
        ])
    }
    
    /// Called when the corner button is tapped
    @objc private func cornerButtonAction() {
        cornerButtonTapped?()
    }
    
    // MARK: - Public Methods
    /// Updates the center image and text label
    /// - Parameters:
    ///   - image: The image to display in the center
    ///   - text: The text to display below the image
    @objc public func configure(with image: UIImage?, text: String) {
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = AppConfiguration.menuIconColor
        label.text = text
    }
    
    /// Sets the image for the corner button
    /// - Parameter image: The image to display in the corner button
    @objc public func setCornerButtonImage(_ image: UIImage?) {
        cornerButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        cornerButton.tintColor = .black
    }
    
    // MARK: - UIView Overrides
    /// Returns the intrinsic content size of 167x115 points
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 167, height: 115)
    }
}

/// Factory methods for creating HomeScreenButton instances
@objc public extension HomeScreenButton {
    /// Creates a pre-configured body scanning button with camera icon
    class func createBodyScanningButton() -> HomeScreenButton {
        let button = HomeScreenButton(
            image: UIImage(named: "camera-4-512"),
            text: "Body Scan"
        )
        
        // Make sure we can use Auto Layout with this view
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    class func createBodyScanResultsButton() -> HomeScreenButton {
        let button = HomeScreenButton(
            image: UIImage(named: "user-3-512"),
            text: "Scan Results"
        )

        button.setCornerButtonImage(UIImage(named: "up_arrow_icon"))

        // Make sure we can use Auto Layout with this view
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }
}
