//
//  EngineeringViewController.swift
//  BaseSDK
//
//  Created by zvika on 6/26/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class EngineeringViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let cellID = "generic"
    let model = ["Video, Camera, Photos",
                 "Tracking - Video"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EngineeringViewController"
        view.backgroundColor = UIColor(named: "CustomBack")// , in: connector.bundleForModule, compatibleWith: nil)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
            return UIStatusBarStyle.lightContent
        }

    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }

}

extension EngineeringViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = model[indexPath.row]
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .clear
        return cell
    }

}

extension EngineeringViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let votingVC = VideoCameraPhotosViewController()
            navigationController?.pushViewController(votingVC, animated: true)
        case 1:
            let trackingVC = TrackingViewController()
            navigationController?.pushViewController(trackingVC, animated: true)
        default:
            let logVC = ShowVotingViewController()
            navigationController?.pushViewController(logVC, animated: true)
        }
    }

}
