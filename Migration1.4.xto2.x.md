# Passio Nutrition-AI Migration from SDK 1.4.x to 2.x 

### Remove SDK 1.4.x

1) Open project and delete the PassioSDKiOS framework

### Add the new SDK 2.x
1) Drag and Drop the new "PassioNutritionAISDK.xcframework" to the project (select copy if needed)
2) In Projects > Targets > Your App > Frameworks, Libraries, and Embedded Content. Set the "PassioNutritionAISDK.xcframework" to "Embed & Sign"

### Find and Replace all 
1)  ```import PassioSDKiOS``` with ```import PassioNutritionAISDK```
2)  ```PassioSDK.shared``` with ```PassioNutritionAI.shared```
3) ```detectOCR``` with ```detectPackagedFood```
4) ```ocrCandidates``` with ```packagedFoodCandidates```
5) ```fetchPassioIDAttributesFor(ocrcode: $0``` with ```fetchPassioIDAttributesFor(packagedFoodCode: $0.packagedFoodCode)```
6) ```autoUpdate``` with ```sdkDownloadsModels```
7) ```isAutoUpdating``` with ```isDownloadingModels```

### Changes to the functions
1) The function ```func searchForFood(byText: String) -> [String]``` return value was modified to ```-> [PassioIDAndName]```. 
2) Removed ```func lookupPassioIDAttributesFor(name: String) -> PassioIDAttributes?``` use instead ```func searchForFood(byText: String) -> [PassioIDAndName]``` and then use the PassioID to lookup the PassioIDAttributes using ```func lookupPassioIDAttributesFor(passioID: PassioID) -> PassioIDAttributes?```. 

### Removed from the SDK
1) References to logo detection 
2) ```status.mode == .isReadyForNutrition``` use only ```.isReadyForDetection```


### PassioDownloadDelegate was merged into the PassioStatusDelegate
```swift
public protocol PassioStatusDelegate : AnyObject {
    func passioStatusChanged(status: PassioNutritionAISDK.PassioStatus)
    func passioProccessing(filesLeft: Int)
    func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL])
    func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int)
    func downloadingError(message: String)
}
```

<sup>Copyright 2022 Passio Inc</sup>