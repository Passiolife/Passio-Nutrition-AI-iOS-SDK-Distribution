//
//  ViewController.swift
//  AppModule
//
//  Created by zvika on 1/21/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
import PassioNutritionAISDK

#if canImport(PassioAppModule)
import PassioAppModule
#endif

class EntryViewController: UIViewController {

    @IBOutlet weak var labelDownloading: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonStart: UIButton!

    var passioConfig = PassioConfiguration(key: passioSDKKey)

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonStart.isHidden = true
        PassioNutritionAI.shared.statusDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        configurePassioSDK()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }

    @objc func didBecomeActive() {
        configurePassioSDK()
    }

    func configurePassioSDK() {
        DispatchQueue.main.async {
            self.labelDownloading.text = "Configuring SDK"
            self.labelDownloading.isHidden = false
            self.buttonStart.isHidden = true
        }
        PassioNutritionAI.shared.statusDelegate = self
        PassioNutritionAI.shared.configure(passioConfiguration: passioConfig) { status in
            print(" passioSDKState === \(status)")
            self.configUIAfterStateChange(status: status)

        }

    }

    @IBAction func startPassioAppModule(_ sender: UIButton) {
        let mode = PassioNutritionAI.shared.status.mode
        navigationController?.navigationBar.isHidden = false
        if mode == .isReadyForDetection {
            let passioExternalConnector = PassioExternalConnector.shared
            let passioInternalConnector = PassioInternalConnector.shared
            passioInternalConnector.startPassioAppModule(passioExternalConnector: passioExternalConnector,
                                                         presentingViewController: self,
                                                         withDismissAnimation: true,
                                                         passioConfiguration: passioConfig) { (_) in
            }
        } else {
            configurePassioSDK()
        }
    }

    func configUIAfterStateChange(status: PassioStatus) {
        DispatchQueue.main.async { [self] in
            switch status.mode {
            case .isReadyForDetection:
                buttonStart.setTitle("Start Nutrition-AI", for: .normal)
                activityIndicator.stopAnimating()
                buttonStart.isHidden = false
                labelDownloading.isHidden = true
            default:
                break
            }
        }
    }

}

extension EntryViewController: PassioStatusDelegate {

    func passioStatusChanged(status: PassioStatus) {
        configUIAfterStateChange(status: status)
    }

    func passioProcessing(filesLeft: Int) {
        DispatchQueue.main.async {
            self.labelDownloading.text = "Files left to Process \(filesLeft)"
        }
    }

    func completedDownloadingAllFiles(filesLocalURLs: [FileLocalURL]) {
        DispatchQueue.main.async {
            self.labelDownloading.text = "Completed downloading all files"
        }
    }

    func completedDownloadingFile(fileLocalURL: FileLocalURL, filesLeft: Int) {
        DispatchQueue.main.async {
            self.labelDownloading.text = "Files left to download \(filesLeft)"
        }
    }

    func downloadingError(message: String) {
        print("downloadError   ---- =\(message)")
        DispatchQueue.main.async {
            self.labelDownloading.text = "\(message)"
            self.activityIndicator.stopAnimating()
        }
    }

}
