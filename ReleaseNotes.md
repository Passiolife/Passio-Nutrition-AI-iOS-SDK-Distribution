# Passio SDK V2.2.9  Release Notes

## V2.2.9

### No API changes
### Models 
* Number of food items recognized via HNN: 4164
* Nutrition database version: passio_nutrition.4165.0.301


## V2.2.7

### No API changes
### Models 
* Number of food items recognized via HNN: 4122
* Nutrition database version: passio_nutrition.4123.0.301

### Under the hood
* The SDK will recognize food only if the phone is stable. This improves overall recognition results and the weight calculations stability. 

## V2.2.5
### No API changes
### Models 
* Number of food items recognized via HNN: 4111
* Nutrition database version: passio_nutrition.4111.0.301



## V2.2.3
### API changes

Added to PassioConfiguration a new variable onlyUseLatestModels. If set to true the SDK will not use previously installed models. 
```swift
public struct PassioConfiguration : Equatable {
/// Only use latest models. Don't use models previously installed.
public var onlyUseLatestModels = false
```

### Models 
* Number of food items recognized via HNN: 4099
* Nutrition database version: passio_nutrition.4100.0.301


## V2.2.2 
### API changes

```swift
    public func removeVidoeLayer()
```
was renamed

```swift 
    public func removeVideoLayer()
```

### Models 

No updates

## V2.2.1 

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