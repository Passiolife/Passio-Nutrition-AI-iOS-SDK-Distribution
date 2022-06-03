# Passio SDK V2.2.1  Release Notes

### Models 

* Number of food items recognized via HNN: 4091
* Nutrition database version: passio_nutrition.4091.0.301

### API changes

The food search by text is now using fuzzy string search with returns search results even if the use is spelling mistakes or similar string. We had change the function from direct returns to completion results

```swift 
public func searchForFood(byText: String) -> [PassioNutritionAISDK.PassioIDAndName]
```
to
```swift
public func searchForFood(byText: String, completion: @escaping ([PassioNutritionAISDK.PassioIDAndName]) -> Void)
```

### API additions

Add to the  AmountEstimate protocol , moveDevice variable
```swift 
public protocol AmountEstimate {
    /// Scanned Volume estimate in ml
    var volumeEstimate: Double? { get }
    /// Scanned Amount in grams
    var weightEstimate: Double? { get }
    /// The quality of the estimate (eventually for feedback to the user or SDK-based app developer)
    var estimationQuality: PassioNutritionAISDK.EstimationQuality? { get }
    /// Hints how to move the device for better estimation.
    var moveDevice: PassioNutritionAISDK.MoveDirection? { get }
    /// The Angel in radians from the perpendicular surface.
    var viewingAngle: Double? { get }
}
```

```swift
public enum MoveDirection : String {
    case away
    case ok
    case up
    case down
    case around
}
```


Version 2.1.6 which is still in Beta is not recommended for production. APIs are subject to change from version to version.

### Models 

Internal volume optimization. 

No API changes.
No updates to the models. 

# Passio SDK V2.1.5 Beta Release Notes
Version 2.1.5 which is still in Beta is not recommended for production. APIs are subject to change from version to version.

### Models

* Number of food items recognized via HNN: 4049
* Nutrition database version: passio_nutrition.4049.0.300

## Remove from the SDK 

all the image
```swift
public var image: UIImage? { get }
public var imageName: String { get }
```

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

Also added UIImageView extension please check demo app to check how to use it. 

```swift
extension UIImageView {
    public func loadPassioIconBy(passioID: PassioNutritionAISDK.PassioID, entityType: PassioNutritionAISDK.PassioIDEntityType, size: PassioNutritionAISDK.IconSize = .px90, completion: @escaping (PassioNutritionAISDK.PassioID, UIImage) -> Void)
}
```

# Passio SDK V2.1.4 Beta Release Notes

Version 2.1.4 which is still in Beta is not recommended for production. APIs are subject to change from version to version.

## New for V2.1.4

Version 2.1.4 was focused on improving weight/volume estimation with no API changes. 

## New for V2.1.3

### Models

* Number of food items recognized via HNN: 3907
* Number of logos recognized: 300
* Nutrition database version: passio_nutrition.3907.0.300

### API Updates
The servingSizeQuantity was modified from 
```swift
public var servingSizeQuantity: Int
```
to:
```swift
public var servingSizeQuantity: Double
```

## New for V2.1.2

### API updates 

* In the  DetectedCandidate the 
```swift 
var scannedVolume: Double? { get }
var scannedWeight: Double? { get }
```
were replaced by 
```swift 
/// Scanned AmountEstimate
    var amountEstimate: PassioNutritionAISDK.AmountEstimate? { get }
```

```swift
public protocol DetectedCandidate {
    /// PassioID recognized by the MLModel
    var passioID: PassioNutritionAISDK.PassioID { get }
    /// Confidence (0.0 to 1.0) of the associated PassioID recognized by the MLModel
    var confidence: Double { get }
    /// boundingBox CGRect representing the predicted bounding box in normalized coordinates.
    var boundingBox: CGRect { get }
    /// The image that the detection was preformed upon
    var croppedImage: UIImage? { get }
    /// Scanned AmountEstimate
    var amountEstimate: PassioNutritionAISDK.AmountEstimate? { get }
}
```

```swift
public protocol AmountEstimate {
    var volumeEstimate: Double? { get }
    /// Scanned Amount in grams
    var weightEstimate: Double? { get }
    /// The quality of the estimate (eventually for feedback to the user or SDK-based app developer)
    var estimationQuality: PassioNutritionAISDK.EstimationQuality? { get }
}
```

```swift 
public enum EstimationQuality {
    case good
    case fair
    case poor
}
```

The functions of PassioDownloadDelegate were merged in to the PassioStatusDelegate
```swift
public protocol PassioStatusDelegate : AnyObject {

    func passioStatusChanged(status: PassioNutritionAISDK.PassioStatus)

    func passioProccessing(filesLeft: Int)

    func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL])

    func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int)

    func downloadingError(message: String)
}
```

* Renaming:
```swift
public func listFoodEnabledForWeightEstimation() -> public func listFoodEnabledForAmountEstimation()
```
* Renaming:
```swift
public func transformCGRectForm(boundingBox: CGRect, toPreviewLayerRect preview: CGRect) -> CGRect 
to
public func transformCGRectForm(boundingBox: CGRect, toRect: CGRect) -> CGRect
```
* Renaming:
```swift
case autoUpdateFailed to case modelsDownloadFailed
``` 


## New for V2.1.1
* The ML models are compressed. 
* iPhone with DUAL WIDE Camera (iPhone 11, 12) can perform weight estimation of several foods. iPhone 13 and more foods will be added in upcoming releases.
* Data from Open Food Facts (https://en.openfoodfacts.org) was added to the SDK. Each food that contains data from Open Food Facts will be marked by ```public var isOpenFood: Bool.```

This record contains information from Open Food Facts (https://en.openfoodfacts.org), which is made available here under the Open Database License (https://opendatacommons.org/licenses/odbl/1-0)

##  Passio Nutrition-AI Migration from SDK 1.4.x to 2.x:
* Follow the directions in [Migration from 1.4 to 2.1 ](./Migration1.4to2.1.md). 

## To install SDK 2.x - follow README file

* Download the ```PassioSDKQuickStart.zip``` or the ```PassioSDKFullDemo.zip``` and copy the ```PassioSDKiOS.xcframework``` to your project. Make sure you have followed the directions in the README files.
* The SDK will only run on iOS 13 or newer.. The XCFramework is compiled for min iOS version 12.0.

## OpenFood  license copy
Passio Nutrition-AI SDK added data from Open Food Facts (https://en.openfoodfacts.org/).

<sup>Copyright 2022 Passio Inc</sup>