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

class VideoCameraPhotosViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackTreshold: UIStackView!
    @IBOutlet weak var textTreshold: UITextField!

    var yellowView: UIView?

    var autoVideoStart = true
    var originalImageFromPicker: UIImage?
    var imageFromVideo: UIImage?
    var previewLayer: AVCaptureVideoPreviewLayer?

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
        //        if passioSDK.status.architecture == .v13 {
        //            stackTreshold.isHidden = false
        //            textTreshold.delegate = self
        //            textTreshold.isHidden = false
        //            textTreshold.text = String(passioSDK.v13cuttoffThreshold)
        //        } else {
        //            stackTreshold.isHidden = true
        //        }

        super.viewDidLoad()
        title = tabBarItem?.title ?? "Video Camera Photos"
        allButtons.forEach {
            $0.roundMyCornerWith(radius: 12)
        }
        let cell = UINib(nibName: "VCPTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "VCPTableViewCell")
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
        DispatchQueue.global(qos: .userInitiated).async {
            self.passioSDK.startFoodDetection(foodRecognitionDelegate: self) { (ready) in
                if !ready {
                    print("SDK was not configures correctly")
                }
            }
        }
        
    }

    func stopFoodDetection() {
        passioSDK.stopFoodDetection()
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        passioSDK.removeVideoLayer()
    }

    func setupPreviewLayer() {
        guard previewLayer == nil else { return } // Will block duplicate layer
        if let previewLayer = passioSDK.getPreviewLayerWithGravity() {// getPreviewLayer() {
            self.previewLayer = previewLayer
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.insertSublayer(previewLayer, at: 0)
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

    func detectCandidatesInImagePassio(image: UIImage) {

        yellowView?.removeFromSuperview()
        tableView.isHidden = false
        activityIndicator.startAnimating()
        let newHeight = imageView.frame.width * image.size.height / image.size.width
        imageViewHeight.constant = newHeight

        let detectionConfig = FoodDetectionConfiguration(detectBarcodes: true,
                                                         detectPackagedFood: true,
                                                         nutritionFacts: true)
        passioSDK.detectFoodWithText(image: image, detectionConfig: detectionConfig) { candidates in
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

            candidates?.observasions?.forEach {
                let topCandidate = $0.topCandidates(1)
                if  let candidate = topCandidate.first {
                    let text = candidate.string
//                    let range:Range<String.Index> = text.startIndex..<text.endIndex
//                    print (" text = \(text)")
//                    if let boundingBox = try? candidate.boundingBox(for: range) {
//                        print (" boundingBox = \(boundingBox)")
//                    }

                    if text == "KIND" || text.lowercased() == "nutrition facts" {
                        let range: Range<String.Index> = text.startIndex..<text.endIndex
                        if let rectObservation = try? candidate.boundingBox(for: range) {
                            self.tableView.isHidden = true
                            print("rectObservation = \(rectObservation.boundingBox)")
                            let bounds = self.passioSDK.transformCGRectForm(boundingBox: rectObservation.boundingBox,
                                                                             toRect: self.imageView.bounds)

                            let newView = UIView(frame: bounds)

                            newView.backgroundColor = .yellow
                            newView.alpha = 0.5
                            self.yellowView = newView
                            self.imageView.addSubview(newView)
                        }
                    }
                }
            }
        }
    }

    func drawBoundingBox(rect: VNRectangleObservation) -> CGRect {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0,
                                                                         y: imageView.frame.height)

        let scale = CGAffineTransform.identity.scaledBy(x: imageView.frame.width,
                                                        y: imageView.frame.height)

        let bounds = rect.boundingBox.applying(scale).applying(transform)

        createLayer(in: bounds)
        return bounds
    }

    func createLayer(in rect: CGRect) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.cornerRadius = 10
        maskLayer.opacity = 0.75
        maskLayer.borderColor = UIColor.red.cgColor
        maskLayer.borderWidth = 5.0

        view.layer.insertSublayer(maskLayer, at: 1)
    }

}

extension VideoCameraPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

extension VideoCameraPhotosViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        candidatesForTable.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VCPTableViewCell",
                                                       for: indexPath) as? VCPTableViewCell,
              candidatesForTable.count > indexPath.row else {
                  return UITableViewCell()

              }
        let candidate = candidatesForTable[indexPath.row]

        cell.imageCropped.image = candidate.croppedImage

        let detected = passioSDK.lookupPassioIDAttributesFor(passioID: candidate.passioID)?.name ?? "\(candidate.passioID)" // "No name"

        //   let odName = passioSDK.lookupPassioIDAttributesFor(passioID: candidate.passioID)?.name ?? "No name"
        //
        //        let pIDHNN = candidate.hnnCandidate?.passioID ?? ""
        //        let conHNN = candidate.hnnCandidate?.confidence.roundDigits(afterDecimal: 2) ?? 0
        //        let nameHNN = passioSDK.lookupPassioIDAttributesFor(passioID: pIDHNN )?.name ?? "No name"
        //
        //        let pIDKNN = candidate.knnCandidate?.passioID ?? ""
        //        let conKNN = candidate.knnCandidate?.confidence.roundDigits(afterDecimal: 2) ?? 0
        //        let nameKNN = passioSDK.lookupPassioIDAttributesFor(passioID: pIDKNN )?.name ?? "No name"

        cell.labelVoting.text = "\(detected) \(candidate.confidence.roundDigits(afterDecimal: 2))"
        //        O: \(odName) \(candidate.odCandidate.confidence.roundDigits(afterDecimal: 2))
        //        H: \(nameHNN) \(conHNN)
        //        K: \(nameKNN) \(conKNN)
        //        """
        return cell
    }

}

extension VideoCameraPhotosViewController: UITableViewDelegate {

}

extension VideoCameraPhotosViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            // mostSeen: PassioID?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {
        DispatchQueue.main.async {
            if let image = image {
                self.imageFromVideo = image
                let newHeight = self.imageView.frame.width * image.size.height / image.size.width
                self.imageViewHeight.constant = newHeight
            }
            if let candidates = candidates?.detectedCandidates {
                self.candidatesForTable = candidates
            }
        }
    }

}

extension VideoCameraPhotosViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textTreshold {
            closeKeyBoard()
        }
        return true
    }

    @objc func closeKeyBoard() {

//        if let text = textTreshold.text,
//           let value = Double(text),
//           0 < value,
//           value < 1 {
//            let twoDigit = Double(Int(value*100))/100
//            PassioCoreSDK.shared.v13cuttoffThreshold = twoDigit
//        }
//        textTreshold.text = String(PassioCoreSDK.shared.v13cuttoffThreshold)
//        textTreshold.resignFirstResponder()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let kbToolBarView = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let kbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: nil, action: nil)
        let bottonOk = UIBarButtonItem(title: "OK".localized, style: .plain, target: self, action: #selector(closeKeyBoard))
        kbToolBarView.items = [kbSpacer, bottonOk, kbSpacer]
        kbToolBarView.tintColor = .white

        return true
    }

}
