//
//  PassioModelsDownloadService.swift
//  SDKApp
//
//  Created by zvika on 5/21/20.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import Foundation
import PassioNutritionAISDK

protocol ExternalModelsDownloadingServiceDelegate: AnyObject {
    func allfilesDownloaded(filesLocalURLs: [FileLocalURL])
    func fileDownloaded(fileLocalURL: FileLocalURL)
    func errorDownloading(message: String)
}

class ExternalModelsDownloadingService: NSObject {

    let fileManager = FileManager.default
    let bucketURL = URL(string: "https://storage.googleapis.com/passiosdk/ios_models/")

    private var localCacheURL: URL? {
        let fileManager = FileManager.default
        let appSupportDir = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask,
                                                 appropriateFor: nil, create: true)
        guard let passioURL = appSupportDir?.appendingPathComponent("tempPassioModels",
                                                                    isDirectory: true) else {
                                                                        return nil
        }
        try? fileManager.createDirectory(at: passioURL, withIntermediateDirectories: true, attributes: nil)
        return passioURL
    }

    weak var delegate: ExternalModelsDownloadingServiceDelegate?

    private var urLQueue = [URL]()
    private var fileLocalURLs = [URL]()

    func startDownloading(fileNames: [FileName]) {
        guard bucketURL != nil else {
            delegate?.errorDownloading(message: "No bucketURL was set")
            return
        }
        let urls = getURLSFromFileTypes(fileNames: fileNames)
        print("111  urLQueue for = \(urLQueue)")
        urLQueue += urls
        print("222  urLQueue for = \(urLQueue)")
        urLQueue.forEach {
            print("urLQueue for = \($0)")
            let fileName = $0.lastPathComponent
            if let newLocation = localCacheURL?.appendingPathComponent(fileName),
                fileManager.fileExists(atPath: newLocation.path) {
                print("*** \(fileName) ***File Already exists no need to download ")
                removeURLFromList(url: newLocation, fileName: fileName)
            } else {
                let task = URLSession.shared.downloadTask(with: $0) { localURL, urlResponse, error in
                    if self.urLQueue.isEmpty {
                        // this means it was cancelled
                        return
                    }
                    guard let response = urlResponse as? HTTPURLResponse  else {
                        self.cancelDownloading()
                        self.delegate?.errorDownloading(message: "No response code")
                        return
                    }
                    if let error = error {
                        // self.cancelDownloading()
                        self.delegate?.errorDownloading(message: "Error Downloading =\(error.localizedDescription)\n\(String(describing: localURL))")
                        return
                    } else if response.statusCode == 403 {
                        self.cancelDownloading()
                        self.delegate?.errorDownloading(message: "Response.statusCode \(response.statusCode)")
                        return
                    } else if let localURL = localURL, response.statusCode == 200 {
                        // print("localURL 9899 = \(localURL)")
                        self.newLocalURL(localURL: localURL, fileName: fileName)
                    }
                }
                task.resume()
            }
        }
    }

    private func getURLSFromFileTypes(fileNames: [FileName] ) -> [URL] {
        guard let bucketURL = bucketURL else { return [] }
        return fileNames.compactMap { bucketURL.appendingPathComponent($0) }
    }

    func cancelDownloading() {
        urLQueue = []
    }

    func newLocalURL(localURL: URL, fileName: FileName ) {
        guard let newLocation = localCacheURL?.appendingPathComponent(fileName) else { return }
        do {
            if fileManager.fileExists(atPath: newLocation.path) {
                try fileManager.removeItem(at: newLocation)
            }
            try fileManager.moveItem(at: localURL, to: newLocation)
        } catch {
            print("Can't write to \(newLocation)")
        }
        removeURLFromList(url: newLocation, fileName: fileName)
    }

    func removeURLFromList(url: URL, fileName: String) {
        fileLocalURLs.append(url)
        urLQueue = urLQueue.filter { $0.lastPathComponent != fileName }
        delegate?.fileDownloaded(fileLocalURL: url)
        print("Download of \(fileName) completed.")
        if urLQueue.isEmpty {
            delegate?.allfilesDownloaded(filesLocalURLs: fileLocalURLs)
        }
    }
}
