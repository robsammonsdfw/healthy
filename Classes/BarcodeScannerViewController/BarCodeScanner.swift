//
//  BarCodeScanner.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/9/23.
//

import AVFoundation
import Vision
import UIKit

/// Handles barcode scanning of UPCs.
class BarCodeScanner: UIViewController, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var backCamera: AVCaptureDevice?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureOutput: AVCapturePhotoOutput?
    private var shutterButton: UIButton!
    private var closeButton: UIButton!

    /// Closure that will be called when a user successfully scanns a UPC.
    @objc public var didScanUPCCodeCallback: ((_ upcInfo: [String : Any]) -> Void)?

    private lazy var detectBarcodeRequest: VNDetectBarcodesRequest = {
        return VNDetectBarcodesRequest(completionHandler: { (request, error) in
            guard error == nil else {
                self.showAlert(withTitle: "Barcode Error", message: error!.localizedDescription)
                return
            }
            self.processClassification(for: request)
        })
    }()
   
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addShutterButton()
        addCloseButton()

        checkPermissions()
        setupCameraLiveView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Every time the user re-enters the app, we must be sure we have access to the camera.
        checkPermissions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Upon closing of view, stop the capture session.
        captureSession.stopRunning()
    }

    // MARK: - User interface
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Camera
    
    private func checkPermissions() {
        let mediaType = AVMediaType.video
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)

        switch status {
        case .denied, .restricted:
            displayNotAuthorizedUI()
        case.notDetermined:
            // Prompt the user for access.
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                guard granted != true else { return }

                // The UI must be updated on the main thread.
                DispatchQueue.main.async {
                    self.displayNotAuthorizedUI()
                }
            }

        default: break
        }
    }

    private func setupCameraLiveView() {
        // Set up the camera session.
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1280x720

        // Set up the video device.
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }
        }

        // Make sure the actually is a back camera on this particular iPhone.
        guard let backCamera = backCamera else {
            showAlert(withTitle: "Camera error", message: "There seems to be no camera on your device.")
            return
        }

        // Set up the input and output stream.
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(captureDeviceInput)
        } catch {
            showAlert(withTitle: "Camera error", message: "Your camera can't be used as an input device.")
            return
        }

        // Initialize the capture output and add it to the session.
        captureOutput = AVCapturePhotoOutput()
        captureOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        captureSession.addOutput(captureOutput!)

        // Add a preview layer.
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer!.videoGravity = .resizeAspectFill
        cameraPreviewLayer!.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = view.frame

        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)

        // Start the capture session.
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    @objc private func captureImage() {
        let settings = AVCapturePhotoSettings()
        captureOutput?.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData) {

            // Convert image to CIImage.
            guard let ciImage = CIImage(image: image) else {
                fatalError("Unable to create \(CIImage.self) from \(image).")
            }

            // Perform the classification request on a background thread.
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation.up, options: [:])

                do {
                    try handler.perform([self.detectBarcodeRequest])
                } catch {
                    self.showAlert(withTitle: "Error Decoding Barcode", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - User interface
    
    private func displayNotAuthorizedUI() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: 20))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Please grant access to the camera for scanning barcodes."
        label.sizeToFit()

        let button = UIButton(frame: CGRect(x: 0, y: label.frame.height + 8, width: view.frame.width * 0.8, height: 35))
        button.layer.cornerRadius = 10
        button.setTitle("Grant Access", for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 4.0/255.0, green: 92.0/255.0, blue: 198.0/255.0, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        let containerView = UIView(frame: CGRect(
            x: view.frame.width * 0.1,
            y: (view.frame.height - label.frame.height + 8 + button.frame.height) / 2,
            width: view.frame.width * 0.8,
            height: label.frame.height + 8 + button.frame.height
            )
        )
        containerView.addSubview(label)
        containerView.addSubview(button)
        view.addSubview(containerView)
    }

    private func addShutterButton() {
        let width: CGFloat = 75
        let height = width
        shutterButton = UIButton()
        view.addSubview(shutterButton)

        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44).isActive = true
        shutterButton.layer.cornerRadius = width / 2
        shutterButton.layer.borderColor = UIColor.white.cgColor
        shutterButton.layer.borderWidth = 3.0
        let image = UIImage(named: "714-camera")?.withRenderingMode(.alwaysTemplate)
        shutterButton.setImage(image, for: .normal)
        shutterButton.tintColor = UIColor.white
        shutterButton.backgroundColor = UIColor.clear
        
        shutterButton.contentVerticalAlignment = .center
        shutterButton.contentHorizontalAlignment = .center

        shutterButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
    }

    private func addCloseButton() {
        let width: CGFloat = 44
        let height = width
        closeButton = UIButton()
        view.addSubview(closeButton)

        closeButton.layer.cornerRadius = width / 2
        closeButton.backgroundColor = UIColor.init(displayP3Red: 1, green: 1, blue: 1, alpha: 0.8)
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        let image = UIImage(named: "cross-out")?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = UIColor.black

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 44).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
     
    @objc func closeView() {
        self.dismiss(animated: true)
    }
    
    private func showInfo(for payload: String) {
        guard payload.count > 0 else {
            return
        }
        //print(payload)
        let upcDict = ["UPC" : payload ]
        didScanUPCCodeCallback?(upcDict)
    }

    // MARK: - Vision
    
    func processClassification(for request: VNRequest) {
        DispatchQueue.main.async {
            if let bestResult = request.results?.first as? VNBarcodeObservation,
                let payload = bestResult.payloadStringValue {
                self.showInfo(for: payload)
            } else {
                self.showAlert(withTitle: "Unable to extract results",
                               message: "Cannot extract barcode information from data. Please try again.")
            }
        }
    }

    // MARK: - Helper functions
    
    @objc private func openSettings() {
        let settingsURL = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsURL) { _ in
            self.checkPermissions()
        }
    }

    private func showAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
