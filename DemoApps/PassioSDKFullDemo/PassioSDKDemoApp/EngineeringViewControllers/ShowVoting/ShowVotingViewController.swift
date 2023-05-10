//
//  ShowVotingViewController
//
//  Copyright © 2023 PassioLife Inc All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Vision
import PassioNutritionAISDK

class ShowVotingViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet weak var tableView: UITableView!

    var autoVideoStart = true
    var originalImageFromPicker: UIImage?
    var imageFromVideo: UIImage?
    var videoLayer: AVCaptureVideoPreviewLayer?

    var videoisOn = false {
        didSet {
            if videoisOn {
                imageView.image = nil
                startFoodDetection()
            } else {
                stopFoodDetection()
            }
        }
    }

    let passioSDK = PassioNutritionAI.shared
//    var rectForScalling = CGRect(x: 0, y: 0, width: 0, height: 0)
    // original setup

    var candidatesForTable = [DetectedCandidate]() {
        didSet {
           // print("CompoundCandidate == \(candidatesForTable)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        title = tabBarItem?.title ?? "PhotoVotingViewController"
        allButtons.forEach {
            $0.roundMyCornerWith(radius: 12)
        }
        let cell = UINib(nibName: "VotingTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "VotingTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if imageView.image == nil {
        }
        if autoVideoStart {
            toggleVideo()
            autoVideoStart = false
        }
//        videoisOn()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.image = nil
        stopFoodDetection()
    }

    func startFoodDetection() {
        setupPreviewLayer()
        passioSDK.startFoodDetection(foodRecognitionDelegate: self) { (ready) in
            if !ready {
                print("SDK was not configured correctly")
            }
        }
    }

    func stopFoodDetection() {
        passioSDK.stopFoodDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
    }

    func setupPreviewLayer() {
        guard videoLayer == nil else { return } // Will block duplicate layer
        if let videoLayer = passioSDK.getPreviewLayer() {// getPreviewLayer() {
            self.videoLayer = videoLayer
            videoLayer.frame = view.bounds
            view.layer.insertSublayer(videoLayer, at: 0)
        }
    }

    @IBAction func takeAPhoto(_ sender: UIButton) {
        videoisOn = false
        getImagePickerAndSetupUI(withSourceType: .camera)
    }

    @IBAction func searchAlbum(_ sender: UIButton) {
        videoisOn = false
        getImagePickerAndSetupUI(withSourceType: .photoLibrary)
    }

    @IBAction func toggleVideo(_ sender: UIButton? = nil) {
        if videoisOn {
            imageView.image = imageFromVideo ?? nil
        }
        videoisOn.toggle()
    }

    func getImagePickerAndSetupUI(withSourceType: UIImagePickerController.SourceType) {
        activityIndicator.startAnimating()
        candidatesForTable = []
        let picker = UIImagePickerController()
        picker.sourceType = withSourceType
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

//    func detectCandidatesInImagePassio(image: UIImage) {
//        activityIndicator.startAnimating()
//        let newHeight = imageView.frame.width * image.size.height / image.size.width
//        imageViewHeight.constant = newHeight
//       // rectForScalling = CGRect(x: 0, y: 0, width: imageView.frame.width, height: newHeight)
//        // print("rectForScalling == \(rectForScalling)")
//
//        passioSDK.detectFoodCandidatesIn(image: image) { (candidates) in
//            if candidates.isEmpty {
//                self.candidatesForTable = []
//            } else {
//                self.candidatesForTable = candidates
//            }
//            self.activityIndicator.stopAnimating()
//        }
//    }

    func detectCandidatesInImagePassio(image: UIImage) {
        activityIndicator.startAnimating()
        let newHeight = imageView.frame.width * image.size.height / image.size.width
        imageViewHeight.constant = newHeight
       // rectForScalling = CGRect(x: 0, y: 0, width: imageView.frame.width, height: newHeight)
        // print("rectForScalling == \(rectForScalling)")

  //      passioSDK.detectFoodCandidatesIn(image: image) { (candidates) in

        let detectionConfig = FoodDetectionConfiguration(detectBarcodes: true,
                                                         detectPackagedFood: true,
                                                         nutritionFacts: false)
        passioSDK.detectFoodIn(image: image, detectionConfig: detectionConfig) { candidates in
            if let detected = candidates?.detectedCandidates {
                self.candidatesForTable += detected
            }
            self.activityIndicator.stopAnimating()

            candidates?.barcodeCandidates?.forEach {
                let barcode = $0.value
                let rect = $0.boundingBox
                self.passioSDK.fetchPassioIDAttributesFor(barcode: barcode) { pidAttributes in
                    if let pid = pidAttributes {
                    let pseudo = DetectedCandidatesStruct(passioID: pid.passioID,
                                                       confidence: 1,
                                                       boundingBox: rect,
                                                       croppedImage: nil)
                        self.candidatesForTable.append(pseudo)
                    }
                }
            }

            candidates?.packagedFoodCandidates?.forEach {
                self.passioSDK.fetchPassioIDAttributesFor(packagedFoodCode: $0.packagedFoodCode) { pidAttributes in
                    if let pid = pidAttributes {
                    let pseudo = DetectedCandidatesStruct(passioID: pid.passioID,
                                                       confidence: 1,
                                                       boundingBox: CGRect(x: 0, y: 0, width: 0, height: 0),
                                                       croppedImage: nil)
                        self.candidatesForTable.append(pseudo)
                    }
                }
            }
        }

    }

}

extension ShowVotingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.originalImageFromPicker = pickedImage
            self.imageView.image = pickedImage
            self.detectCandidatesInImagePassio(image: pickedImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        activityIndicator.stopAnimating()
        picker.dismiss(animated: true)
    }

}

extension ShowVotingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        candidatesForTable.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VotingTableViewCell",
                                                       for: indexPath) as? VotingTableViewCell,
            candidatesForTable.count > indexPath.row else {
                return UITableViewCell()

        }
        let candidate = candidatesForTable[indexPath.row]
        cell.imageCropped.image = candidate.croppedImage
        let detected = passioSDK.lookupPassioIDAttributesFor(passioID: candidate.passioID)?.name ?? "\(candidate.passioID)"
        cell.labelVoting.text = "\(detected) \(candidate.confidence.roundDigits(afterDecimal: 2))"
        return cell
    }

}

extension ShowVotingViewController: UITableViewDelegate {

}

extension ShowVotingViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {
        DispatchQueue.main.async {
            if let image = image {
                self.imageFromVideo = image
                let newHeight = self.imageView.frame.width * image.size.height / image.size.width
                self.imageViewHeight.constant = newHeight
            }
            if let visCandidates = candidates?.detectedCandidates {
                self.candidatesForTable = visCandidates
            }
        }
    }

}
