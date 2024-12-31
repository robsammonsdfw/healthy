import UIKit
import SceneKit

/// Displays a 3D model of a body scan using SceneKit
class BodyScan3DViewController: UIViewController {
    
    // MARK: - Properties
    
    /// The scan result to display
    private let scanResult: ScanResult
    
    /// The pre-fetched asset URLs
    private let assetUrls: [String: String]?
    
    /// Main SceneKit view
    private lazy var sceneView: SCNView = {
        let view = SCNView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.allowsCameraControl = true // Enables pinch to zoom, pan to rotate
        view.autoenablesDefaultLighting = true
        return view
    }()
    
    /// Loading indicator
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    /// Error message label
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    /// Controls whether the model is spinning
    private var isSpinning = true
    
    /// Rotation action for continuous spinning
    private var spinningAction: SCNAction {
        // Rotate around X axis for a proper turntable effect
        let rotation = SCNAction.rotateBy(x: 2 * .pi, y: 0, z: 0, duration: 8)
        return SCNAction.repeatForever(rotation)
    }
    
    /// Button to toggle spinning
    private lazy var spinButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "pause.circle"),
            style: .plain,
            target: self,
            action: #selector(toggleSpinning)
        )
    }()
    
    // MARK: - Initialization
    
    init(scanResult: ScanResult, assetUrls: [String: String]?) {
        self.scanResult = scanResult
        self.assetUrls = assetUrls
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadModel()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Format the date for the title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        title = dateFormatter.string(from: scanResult.createdAt)
        
        view.backgroundColor = .systemBackground
        
        // Add spin toggle button
        navigationItem.rightBarButtonItem = spinButton
        
        view.addSubview(sceneView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Model Loading
    
    private func loadModel() {
        activityIndicator.startAnimating()
        errorLabel.isHidden = true
        
        if let urls = assetUrls {
            // Use existing URLs
            guard let modelUrl = urls["model"],
                  let textureUrl = urls["texture"],
                  let materialUrl = urls["material"] else {
                showError("Missing required 3D model files")
                return
            }
            
            downloadModelFiles(
                modelUrl: modelUrl,
                textureUrl: textureUrl,
                materialUrl: materialUrl
            )
        } else {
            // Fallback to fetching URLs if not provided
            PrismScannerManager.shared.fetchAssetUrls(forScan: scanResult.id) { [weak self] urls, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.showError("Failed to fetch model: \(error.localizedDescription)")
                    return
                }
                
                guard let modelUrl = urls?["model"],
                      let textureUrl = urls?["texture"],
                      let materialUrl = urls?["material"] else {
                    self.showError("Missing required 3D model files")
                    return
                }
                
                self.downloadModelFiles(
                    modelUrl: modelUrl,
                    textureUrl: textureUrl,
                    materialUrl: materialUrl
                )
            }
        }
    }
    
    private func downloadModelFiles(modelUrl: String, textureUrl: String, materialUrl: String) {
        guard let modelURL = URL(string: modelUrl),
              let textureURL = URL(string: textureUrl),
              let materialURL = URL(string: materialUrl) else {
            showError("Invalid model URLs")
            return
        }
        
        let downloadGroup = DispatchGroup()
        var modelData: Data?
        var textureData: Data?
        var materialData: Data?
        var downloadError: Error?
        
        // Download model file
        downloadGroup.enter()
        URLSession.shared.dataTask(with: modelURL) { data, _, error in
            defer { downloadGroup.leave() }
            if let error = error {
                downloadError = error
                return
            }
            modelData = data
        }.resume()
        
        // Download texture file
        downloadGroup.enter()
        URLSession.shared.dataTask(with: textureURL) { data, _, error in
            defer { downloadGroup.leave() }
            if let error = error {
                downloadError = error
                return
            }
            textureData = data
        }.resume()
        
        // Download material file
        downloadGroup.enter()
        URLSession.shared.dataTask(with: materialURL) { data, _, error in
            defer { downloadGroup.leave() }
            if let error = error {
                downloadError = error
                return
            }
            materialData = data
        }.resume()
        
        // Process downloaded files
        downloadGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            if let error = downloadError {
                self.showError("Failed to download model: \(error.localizedDescription)")
                return
            }
            
            guard let modelData = modelData,
                  let textureData = textureData,
                  let materialData = materialData else {
                self.showError("Failed to download all required files")
                return
            }
            
            self.processDownloadedFiles(
                modelData: modelData,
                textureData: textureData,
                materialData: materialData
            )
        }
    }
    
    private func processDownloadedFiles(modelData: Data, textureData: Data, materialData: Data) {
        // Create temporary directory for model files
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        do {
            try FileManager.default.createDirectory(at: tempDirectory, 
                                                  withIntermediateDirectories: true)
            
            // Save files
            let modelUrl = tempDirectory.appendingPathComponent("model.obj")
            let textureUrl = tempDirectory.appendingPathComponent("texture.png")
            let materialUrl = tempDirectory.appendingPathComponent("material.mtl")
            
            try modelData.write(to: modelUrl)
            try textureData.write(to: textureUrl)
            try materialData.write(to: materialUrl)
            
            // Load model into SceneKit
            let scene = try SCNScene(url: modelUrl)
            
            // Create a container node for the model
            let containerNode = SCNNode()
            
            // Move all child nodes to the container
            while let childNode = scene.rootNode.childNodes.first {
                childNode.removeFromParentNode()
                containerNode.addChildNode(childNode)
            }
            
            // Get bounding sphere for positioning calculation
            let (_, radius) = containerNode.boundingSphere
            
            // Apply Prism's positioning calculations
            let y = (-0.9665 * radius)
            let z = (-2.274 * radius) + 1.218
            
            // Set position and rotation using Prism's values
            containerNode.position = SCNVector3(x: 0, y: y, z: z)
            containerNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: .pi / 2)
            
            // Apply texture
            if let texture = UIImage(data: textureData) {
                containerNode.enumerateChildNodes { node, _ in
                    node.geometry?.firstMaterial?.diffuse.contents = texture
                }
            }
            
            // Add container to scene
            scene.rootNode.addChildNode(containerNode)
            
            // Start spinning animation
            containerNode.runAction(spinningAction)
            
            // Set up camera using Prism's default values
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 1.0)
            cameraNode.rotation = SCNVector4(0, 0, 0, 0)
            cameraNode.orientation = SCNVector4(x: 0, y: 0, z: 0, w: 1.0)
            cameraNode.camera?.fieldOfView = 60
            scene.rootNode.addChildNode(cameraNode)
            
            // Add lights
            let ambientLight = SCNNode()
            ambientLight.light = SCNLight()
            ambientLight.light?.type = .ambient
            ambientLight.light?.intensity = 100
            scene.rootNode.addChildNode(ambientLight)
            
            let directionalLight = SCNNode()
            directionalLight.light = SCNLight()
            directionalLight.light?.type = .directional
            directionalLight.light?.intensity = 800
            directionalLight.position = SCNVector3(2, 5, 5)
            scene.rootNode.addChildNode(directionalLight)
            
            // Display the scene
            sceneView.scene = scene
            sceneView.pointOfView = cameraNode
            
            // Clean up
            activityIndicator.stopAnimating()
            try FileManager.default.removeItem(at: tempDirectory)
            
        } catch {
            showError("Failed to process model: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
        }
    }
    
    @objc private func toggleSpinning() {
        isSpinning.toggle()
        
        if let containerNode = sceneView.scene?.rootNode.childNodes.first {
            if isSpinning {
                containerNode.runAction(spinningAction)
                spinButton.image = UIImage(systemName: "pause.circle")
            } else {
                containerNode.removeAllActions()
                spinButton.image = UIImage(systemName: "play.circle")
            }
        }
    }
} 
