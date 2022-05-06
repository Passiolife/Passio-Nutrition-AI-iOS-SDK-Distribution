# Passio Nutrition-AI Migration from SDK 1.4.x to 2.x 

Before you continue, please make sure you have a new key for version 2.x. The 1.4.x will not work with 2.x SDK!

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
8) ```isReadyForNutrition``` was removed use ```isReadyForDetection```

The servingSizeQuantity was modified from 
```swift
public var servingSizeQuantity: Int
```
to:
```swift
public var servingSizeQuantity: Double
```

### Changes to the functions
1) The function ```func searchForFood(byText: String) -> [String]``` return value was modified to ```-> [PassioIDAndName]```. 
2) Removed ```func lookupPassioIDAttributesFor(name: String) -> PassioIDAttributes?``` use instead ```func searchForFood(byText: String) -> [PassioIDAndName]``` and then use the PassioID to lookup the PassioIDAttributes using ```func lookupPassioIDAttributesFor(passioID: PassioID) -> PassioIDAttributes?```. 


the function
```swift
public func lookupNameForPassioID(passioID: PassioNutritionAISDK.PassioID) -> String?
```
was renamed to 
```swift 
public func lookupIconFor(passioID: PassioNutritionAISDK.PassioID, size: PassioNutritionAISDK.IconSize = IconSize.px90, entityType: PassioNutritionAISDK.PassioIDEntityType = .item) -> (UIImage, Bool)
```
where the Bool Returns: UIImage and a bool, The boolean is true if the icons is food icon or false if it's a placeholder icon. If you get false you can use the asycronous funcion to "fetchIconFor" the icons from

```swift 
public func fetchIconFor(passioID: PassioNutritionAISDK.PassioID, size: PassioNutritionAISDK.IconSize = IconSize.px90, entityType: PassioNutritionAISDK.PassioIDEntityType = .item, completion: @escaping (UIImage?) -> Void)
```

Added UIImageView extension please check demo app to check how to use it. 

```swift
extension UIImageView {
    public func loadPassioIconBy(passioID: PassioNutritionAISDK.PassioID, entityType: PassioNutritionAISDK.PassioIDEntityType, size: PassioNutritionAISDK.IconSize = .px90, completion: @escaping (PassioNutritionAISDK.PassioID, UIImage) -> Void)
}
```


### Removed from the SDK
1) References to logo detection 
2) ```status.mode == .isReadyForNutrition``` use only ```.isReadyForDetection```

all the images from PassioIDAttributes and PassioFoodItemData where removed. 
```swift
public var image: UIImage? { get }
public var imageName: String { get }
```


### PassioDownloadDelegate was merged into the PassioStatusDelegate
```swift
public protocol PassioStatusDelegate : AnyObject {
    func passioStatusChanged(status: PassioNutritionAISDK.PassioStatus)
    func passioProcessing (filesLeft: Int)
    func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL])
    func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int)
    func downloadingError(message: String)
}
```

<sup>Copyright 2022 Passio Inc</sup>