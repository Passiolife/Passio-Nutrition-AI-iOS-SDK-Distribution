//
//  OnBoardingViewController.swift
//  BaseApp
//
//  Created by Zvika on 1/26/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

final class TutorialViewController: UIViewController {

    // MARK: - @IBOutlets
    @IBOutlet weak var infoVwHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var totaltimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var videoProgressView: UIProgressView!
    @IBOutlet weak var buttonForward: UIButton!
    @IBOutlet var stepViews: [UIView]!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var labelHeader: UILabel!
    @IBOutlet weak var labelDirections: UILabel!
    @IBOutlet weak var buttonStartTracking: UIButton!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonPausePlay: UIButton!
    @IBOutlet weak var buttonRewind: UIButton!

    // MARK: - properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    private var viewNumber = 0
    private let bundlePod =  PassioInternalConnector.shared.bundleForModule
    private let canRunVolume = PassioNutritionAI.shared.availableVolumeDetectionModes.contains(.dualWideCamera)

    private let minimummProgress = 0.0
    private var totalTime = 0.0
    private let seekDuration = 5.0

    private let screenHeight = UIScreen.main.bounds.height

    private let Headers = ["Identify Meals", "Estimate Weight", "Build Recipes", "Track Progress"]

    private let directions = [ """
    With your phones camera, instantly identify packaged & non-packaged foods, capture nutrition lables, and scan barcodes.
    """,
    """
    Measure food amounts without a physical scale and automatically determine serving size for all your food entries.
    """,
      """
    As you prepare your favorite meals, quickly capture all your ingredients on the countertop. Then edit and save custom recipes.
    """,
      """
    Easily stay on top of your nutrition goals by viewing daily, weekly, and monthly progress trackers for calories and macros.
    """]

    // MARK: - View's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if viewNumber == stepViews.count-1 {
            buttonStartTracking.setTitle("Start tracking!", for: .normal)
            buttonWidth.constant = 343
        } else {
            buttonStartTracking.setTitle("Next", for: .normal)
            buttonWidth.constant = 180
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupViews()
        setupVideoPlayer()
        setupVideoPlayerObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.seek(to: .zero)
        setPlayPauseButtonImage(imageName: "play")
        player?.pause()
    }

    deinit {

    }
}

// MARK: - Configure UI
extension TutorialViewController {

    private func configureUI() {

        infoVwHeightConstraint.constant = (screenHeight * (280/896))
        labelHeader.font = UIFont.systemFont(ofSize: (screenHeight * (40/896)), weight: .bold)
        labelDirections.font = UIFont.systemFont(ofSize: (screenHeight * (16/896)))

        customizeNavForModule(withBackButton: false)
        addSkipButton()
        buttonStartTracking.roundMyCornerWith(radius: 4)

        navigationController?.navigationBar.tintColor = .white

        if !canRunVolume {
            let secondView = stepViews[1]
            secondView.removeFromSuperview()
        }
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(goback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
        let swipeL = UISwipeGestureRecognizer(target: self, action: #selector(nextPage))
        swipeL.direction = .left
        view.addGestureRecognizer(swipeL)
    }

    private func setupViews() {

        let customBase = UIColor(named: "CustomBase", in: bundlePod, compatibleWith: nil)
        buttonStartTracking.tintColor = customBase

        if  viewNumber < stepViews.count {

            if viewNumber > 0 {
                navigationItem.hidesBackButton = false
            }

            stepViews.enumerated().forEach {

                $0.1.roundMyCorner()

                if $0.0 == viewNumber {
                    $0.1.backgroundColor = customBase
                } else {
                    $0.1.backgroundColor = .lightGray
                }
            }

            labelHeader.text = Headers[viewNumber]
            labelDirections.text = directions[viewNumber]

        } else {
            continueToApp()
        }
    }
}

// MARK: - Video Player methods
extension TutorialViewController {

    private func setupVideoPlayer() {

        if player == nil {

            let filename = "onboarding-0\(viewNumber+1)"
            guard let urlForVideo = Bundle.main.url(forResource: filename, withExtension: "mp4") else {
                return
            }

            let playerItem = AVPlayerItem(url: urlForVideo)
            player = AVPlayer(playerItem: playerItem)

            setCurrentAndTotalTime(playerItem: playerItem)

            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspect
            playerLayer?.frame = videoView.bounds

            if let pLayer = playerLayer {
                videoView.layer.addSublayer(pLayer)
            }

            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    private func setupVideoPlayerObserver() {

        guard let player = player else { return }

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),
                                        queue: DispatchQueue.main) { [weak self] (_) -> Void in

            guard let self = self else { return }

            if player.currentItem?.status == .readyToPlay {

                let time = CMTimeGetSeconds(player.currentTime())
                self.currentTimeLabel.text = self.stringFromTimeInterval(interval: time)
                self.videoProgressView.progress = Float(time / self.totalTime)
            }
        }
    }
}

// MARK: - Helper methods
extension TutorialViewController {

    private func setCurrentAndTotalTime(playerItem: AVPlayerItem) {

        let duration = playerItem.asset.duration
        let seconds = CMTimeGetSeconds(duration)
        totalTime = seconds
        totaltimeLabel.text = stringFromTimeInterval(interval: seconds)

        let duration1 = playerItem.currentTime()
        let seconds1 = CMTimeGetSeconds(duration1)
        currentTimeLabel.text = stringFromTimeInterval(interval: seconds1)
    }

    @objc private func playerDidFinishPlaying() {

        player?.pause()
        player?.seek(to: .zero)
        videoProgressView.progress = Float(minimummProgress)
        currentTimeLabel.text = stringFromTimeInterval(interval: 0.0)
        setPlayPauseButtonImage(imageName: "play")
    }

    private func addSkipButton() {

        navigationItem.setLeftBarButton(nil, animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "".localized, style: .plain, target: nil, action: nil)
    }

    @objc private func goback() {

        if viewNumber > 1 {
            navigationController?.dismiss(animated: true)
        }
    }

    @objc private func continueToApp() {
        let vc = MyLogViewController()
        navigationController?.setViewControllers([vc], animated: true)
    }

    private func setPlayPauseButtonImage(imageName: String) {

        let image = UIImage(named: imageName, in: bundlePod, compatibleWith: nil)
        buttonPausePlay.setImage(image, for: .normal)
    }

    private func stringFromTimeInterval(interval: TimeInterval) -> String {

        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - @IBActions
extension TutorialViewController {

    @IBAction func nextPage(_ sender: Any) {

        if viewNumber == 3 {
            continueToApp()

        } else {

            let vc = TutorialViewController()

            if viewNumber == 0, !canRunVolume {
                vc.viewNumber = viewNumber + 2
            } else {
                vc.viewNumber = viewNumber + 1
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func onPlayPause(_ sender: UIButton) {

        if player?.rate == 1 {

            player?.pause()
            setPlayPauseButtonImage(imageName: "play")

        } else {

            player?.play()
            setPlayPauseButtonImage(imageName: "pause")
        }
    }

    @IBAction func onRewind(_ sender: UIButton) {

        guard let player = player else { return }
        setPlayPauseButtonImage(imageName: "pause")

        let playerCurrenTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrenTime - seekDuration
        if newTime < 0 { newTime = 0 }

        player.pause()

        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.seek(to: selectedTime)

        player.play()
    }

    @IBAction func onForward(_ sender: UIButton) {

        guard let player = player else { return }

        setPlayPauseButtonImage(imageName: "pause")

        if let duration = player.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            let newTime = playerCurrentTime + seekDuration

            if newTime < CMTimeGetSeconds(duration) {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player.seek(to: selectedTime)
            }

            player.pause()
            player.play()
        }
    }

    @IBAction func onBeginning(_ sender: UIButton) {

        guard let player = player else { return }
        player.seek(to: .zero)
    }
}
