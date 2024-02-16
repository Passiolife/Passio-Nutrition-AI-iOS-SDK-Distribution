# Passio Nutrition-AI iOS SDK

## Now available as Swift package at: https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution

## Overview

Welcome to Passio Nutrition-AI iOS SDK!

Feel free to watch the video we posted with the integration directions: https://www.youtube.com/watch?v=mZZAgJ2gWpc&t=192s

When integrated into your app the SDK provides you with food recognition and nutrition assistant technology. The SDK creates a video preview layer and outputs foods recognized by our computer vision technology in the video feed of your live camera along with nutrition data related to the recognized foods.

As the developer, you have complete control of when to turn on/off the SDK and to configure the outputs which includes: 
- food names (e.g. banana, hamburger, fruit salad, quest chocolate bar)
- lists of alternatives for recognized foods (e.g., _soy milk_ would be an alternative of a visually recognized class _milk_)
- barcodes detected on food packages
- packaged foods recognized by the text detected on food packages
- nutrition information detected on food packages via Passio's Nutrition Facts reader which returns information written in Nutrition Facts labels
- nutrition information associated with the foods
- food weight and volume for certain foods

By default the SDK does not record/store any photos or videos. Instead, as the end user hovers over a food item with his/her camera phone, the SDK recognizes and identifies food items in real time. This hovering action is only transitory/temporary while the end user is pointing the camera at a particular item and is not recorded or stored within the SDK. As a developer, you can configure the SDK to capture images or videos and store them in your app.


## BEFORE YOU CONTINUE:

1. Passio Nutrition-AI SDK added data from Open Food Facts (https://en.openfoodfacts.org/). Each food that contains data from Open Food Facts will be marked by public var isOpenFood: Bool.. In case you choose to set ```isOpenFood = true``` you agree to abide by the terms of the Open Food Facts license agreement (https://opendatacommons.org/licenses/odbl/1-0) and their terms of use (https://world.openfoodfacts.org/terms-of-use) and you will have to add to the UI the following license copy:

"This record contains information from Open Food Facts (https://en.openfoodfacts.org), which is made available here under the Open Database License (https://opendatacommons.org/licenses/odbl/1-0)"

2. To use the SDK sign up at https://www.passio.ai/nutrition-ai. The SDK WILL NOT WORK without a valid SDK key.


## Minimum Requirements

In order to use the PassioSDK your app needs to meet the following minimal requirements:

* The SDK will only run on iOS 13 or newer.
* Passio SDK can only be used on a device and will not run on a simulator
* The SDK requires access to iPhone's camera
* Weight/Volume estimation will run only on iPhones with Dual Wide Camera (not on DualCamera). 
    * iPhone 11 Pro & Pro Max
    * iPhone 12 mini, Pro & pro Max
    * iPhone 13 Pro & Pro Max
    * iPhone 14, Pro, Pro Max & Plus

## Getting the ml models to the device

The SDK will automatically download the models according to the SDK version, by default the SDK will download compressed files. The download is faster and lighter, and it will take several seconds to decompress on the device. To download uncompressed files and shorter processing on the device you can set a flag below to false.
```swift
PassioNutritionAI.shared.requestCompressedFiles = false
```

After obtaining special approval the developer can also host the models on an internal server.
```swift
var passioConfig = PassioConfiguration(key: "your_key")
passioConfig.sdkDownloadsModels = false
```
 In that case, the models be served  directly to the SDK. To find out more about this special configuration please contact us. 

## Try first to run the Quick Start Demo

  A fast and easy way to get started with the SDK is to test it inside of PassioSDKQuickStart Demo App included in this package. Here are the steps:
  
  1. Open the project in Xcode:
  2. Replace the SDK Key in the PassioQuickStartViewController.swift file with the key you obtained by signing up at https://www.passio.ai/nutrition-ai
  3. Connect your iPhone and run
  4. Modify the app bundle from "com.PassioDemoApp.demo" to "com.yourcompany...."
  5. Run the demo app on your iPhone.
  6. For support, please contact support@passiolife.com

***

## Adding the PassioNutritionAISDK (based on your Xcode version).

<span style="color:red; font-size:18px">
Manual Installation For Xcode lower than 14.3:
</span>

Please follow the steps in the file **"LegacyManuallyAddingTheFrameworkd.md"** otherwise you might get the error the below. 

```swift
error project: Failed to resolve dependencies 
```



<span style="color:green; font-size:18px">
Install Swift Package for Xcode 14.3 or newer (available on MacOS Ventura)
</span>
 
1. Open your Xcode project.
2. Go to File > Swift Packages > Add Package Dependency.
3. In the "Add Package Dependency" dialog box, paste the URL: https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution
4. Click "Next". Xcode will validate the package and its dependencies.
5. In the next dialog box, you'll be asked to specify the version or branch you want to use. You can choose main for the latest version or specify a specific version or branch.
6. After you've made your selection, click "Next".
7. You'll then be prompted to select the targets in your project that should include the package. Check the boxes for the targets you want to include.
8. Click "Finish" to add the package to your project.
9. Xcode will download and add the PassioNutritionAISDK to your project. You can now import and start using the PassioNutritionAISDK.

### Edit your Info.plist

* If opening from Xcode, right click and select 'open as source code'
* To allow camera usage add:

 ```XML
`<key>>NSCameraUsageDescription</key><string>For real-time food recognition</string>`.
```

***

### Initialize and configure the SDK

1) At the top of your view controller import the PassioNutritionAISDK and AVFoundation

```swift
import PassioNutritionAISDK
import AVFoundation
```

2) Add the following properties to your view controller. 

```swift
let passioSDK = PassioNutritionAI.shared
var videoLayer: AVCaptureVideoPreviewLayer?
```

3) In viewDidLoad configure the SDK with the Key you obtained by signing up at https://www.passio.ai/nutrition-ai. 

```swift 
override func viewDidLoad() {
        super.viewDidLoad()
        let key = "Your_PassioSDK_Key"
        //* To obtain a key please sign up at https://www.passio.ai/nutrition-ai 
        let passioConfig = PassioConfiguration(key: key)
        passioSDK.configure(passioConfiguration: passioConfig) { (status) in
            print("Mode = \(status.mode)\nmissingfiles = \(String(describing: status.missingFiles))" )
        }
    }
```

4) You will receive the PassioStatus back from the SDK.

```Swift
public struct PassioStatus {
    public internal(set) var mode: PassioSDK.PassioMode { get }
    public internal(set) var missingFiles: [PassioSDK.FileName]? { get }
    public internal(set) var debugMessage: String? { get }
    public internal(set) var activeModels: Int? { get }
}

public enum PassioMode {
    case notReady
    case isBeingConfigured
    case isDownloadingModels
    case isReadyForDetection
    case failedToConfigure
}
```

5) In `viewWillAppear` request authorization to use the camera and start the recognition:

```swift
override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            startFoodDetection()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.startFoodDetection()
                    }
                } else {
                    print("The user didn't grant access to use camera")
                }
            }
        }
    }

  ```

6) Add the method `startFoodDetection()`  

```swift
  func startFoodDetection() {
        setupPreviewLayer()
        DispatchQueue.global(qos: .userInitiated).async {
            self.passioSDK.startFoodDetection(foodRecognitionDelegate: self) { (ready) in
                if !ready {
                    print("SDK was not configured correctly")
                }
            }
        }
    }
```


7) Add the method `setupPreviewLayer`:

```swift
 // MARK: PassioSDK: setup PreviewLayer
    func setupPreviewLayer() {
        guard videoLayer == nil else { return }
        if let videoLayer = passioSDK.getPreviewLayer() {
            self.videoLayer = videoLayer
            videoLayer.frame = view.bounds
            view.layer.insertSublayer(videoLayer, at: 0)
        }
    }
```

8) Stop Food Detection in `viewWillDisappear`:

  ```swift
 override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        passioSDK.stopFoodDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
    }
  ```

9) Implement the delegate `FoodRecognitionDelegate`:

  ```swift
extension FoodRecognitionViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {

   // Barcode scanning
   if let time = lastBarcodeDetection,
           Date().timeIntervalSince(time) < timeToDisplayBarCodeResults {
            return
        } else if let barcode = candidates?.barcodeCandidates?.first {
            lastBarcodeDetection = Date()

            passioSDK.fetchFoodItemFor(productCode: barcode.value) { [weak self] (passioFoodItem) in
                guard let self else { return }
                if let foodItem = passioFoodItem {
                    self.barcodeAttributes = foodItem
                    DispatchQueue.main.async {
                        self.animateFoodEditorMicroView(show: true, foodItem: foodItem)
                    }
                } else if let list = self.foodEditorMicroView?.listOfFailedBarcodes,
                          !list.contains(barcode.value) {
                    DispatchQueue.main.async {
                        self.foodEditorMicroView?.listOfFailedBarcodes.insert(barcode.value)
                    }
                }
            }
        } else {
            lastBarcodeDetection = nil
            barcodeAttributes = nil
        }
```
- The fetchFoodItemFor(productCode: String) API is used to fetch the PassioFoodItem for the Barcode
- If the Barcode is valid then it will return the PassioFoodItem data in the response

```swift
        // Visual Food scanning
        var foodRecord: FoodRecordV3?
        if let firstCandidate = candidates?.detectedCandidates.first,
           firstCandidate.passioID != "BKG0001" {
            passioSDK.fetchFoodItemFor(passioID: firstCandidate.passioID, completion: { [weak self] (passioFoodItem) in
                
                guard let foodItem = passioFoodItem else {
                    return
                }
                
                var estimatedWeight: Double?
                
                if let quality = firstCandidate.amountEstimate?.estimationQuality,
                   quality == .good {
                    estimatedWeight = firstCandidate.amountEstimate?.weightEstimate
                }
                
                foodRecord = FoodRecordV3(foodItem: foodItem,
                                          scannedWeight: estimatedWeight,
                                          confidence: firstCandidate.confidence,
                                          alternatives: firstCandidate.alternatives.map({Alternatives(passioID: $0.passioID, name: $0.name)}))
                self?.detectedFoodRecord = foodRecord
            })
        }

        if foodRecord == nil,
           let detectedFoodRecord = detectedFoodRecord,
           detectedFoodRecord.createdAt.timeIntervalSinceNow > -2 {
            foodRecord = detectedFoodRecord
        }

        DispatchQueue.main.async {
            if foodRecord == nil {
                self.scanneWeightToDisplay = nil
            }
            self.animateFoodEditorMicroView(show: true,
                                            foodRecord: foodRecord,
                                            firstCandidate: candidates?.detectedCandidates.first)
        }
    }

}
```
- The fetchFoodItemFor(passioID: String) API is used to fetch the PassioFoodItem for the visual scanning
- When you point at a visual food or food image then it will call this API and return the PassioFoodItem in the response

10) Implement this search API to get the search text results in AdvanceTextSearchView
```swift
PassioNutritionAI.shared.searchForFood(byText: searchText) { [weak self] (passioAlternateSearchNames) in

                    guard let self else { return }

                    alternateSearches = passioAlternateSearchNames
                    if (alternateSearches?.alternateNames.count ?? 0) < 1,
                       (alternateSearches?.results.count ?? 0) < 1,
                       searchText.count >= 3 {
                        alternateSearches = getIconNameWhileTyping(text: searchText + self.noFood)
                    }

                    DispatchQueue.main.async {
                        self.searchTableView.reloadWithAnimations(withDuration: 0.21)
                    }
                }
```
- This API is used to fetch the searched text food result in the AdvanceTextSearchView
- If the searched text food is available then it will return the list of search results and alternatives of searched text in the completion

## To fetch the data of food item we have new Data models

1. **PassioFoodItem**
The PassioFoodItem model will return the recognised FoodItem data with below properties:
```swift
let id: String
let scannedId: PassioID
let shortName: String
let verboseName: String
let iconId: String
let licenseCopy: String
let amount: PassioFoodAmount
let ingredients: [PassioIngredient]

var name: String {
   shortName == "" ? verboseName : shortName
}
```

Method to get the PassioFoodItem:
```swift
static func fromSearchResponse(item: ResponseFoodItem, passioID: String = "") -> PassioFoodItem {

        let iconId = item.iconId
        let ingredients = item.ingredients.map { PassioIngredient.fromResponse(result: $0,
                                                                               topLevelIcon: iconId) }
        let amount: PassioFoodAmount
        if item.ingredients.count == 1 {
            amount = PassioFoodAmount.fromSearchResult(portions: item.ingredients.first?.portions)
        } else {
            let ingredientsWeight = ingredients.map { $0.weight() }.reduce(Measurement<UnitMass>(value: 0,
                                                                                                 unit: .grams),
                                                                           { $0 + $1 }).value
            amount = PassioFoodAmount.fromSearchResult(portions: item.portions,
                                                       ingredientWeight: ingredientsWeight)
        }

        return PassioFoodItem(id: item.internalId,
                              scannedId: passioID,
                              shortName: item.internalName ?? "",
                              verboseName: item.displayName,
                              iconId: iconId,
                              licenseCopy: "",
                              amount: amount,
                              ingredients: ingredients)
    }
```
2. **PassioIngredient**
This PassioIngredient model returns the ingredients of foodItem with below properties:
```swift
let id: String
let name: String
let iconId: String
let amount: PassioFoodAmount
let referenceNutrients: PassioNutrients
let metadata: PassioFoodMetadata
```

Method to get the PassioIngredients:
```swift
  static func fromResponse(result: ResponseIngredient, topLevelIcon: String) -> PassioIngredient {

        let nutrients = PassioNutrients(weight: Measurement<UnitMass>(value: 100, unit: .grams),
                                        responseNutrients: result.nutrients ?? [])
        let amount = PassioFoodAmount.fromSearchResult(portions: result.portions)
        let metadata = PassioFoodMetadata.fromSearchResult(result: result)
        let iconId = result.iconId != nil ? result.iconId : topLevelIcon

        return PassioIngredient(id: result.id,
                                name: result.name,
                                iconId: iconId ?? "",
                                amount: amount,
                                referenceNutrients: nutrients,
                                metadata: metadata)
    }
```
3. **PassioNutrients**
The PassioNutrients model will calculate the nutrition data and returns the nutrition data for Single food, Recipe food and UPC/Barcode food.
```swift
let weight: Measurement<UnitMass>
    var referenceWeight = Measurement<UnitMass>(value: 100.0, unit: .grams)

    private var _fat: Measurement<UnitMass>? = nil
    private var _satFat: Measurement<UnitMass>? = nil
    private var _monounsaturatedFat: Measurement<UnitMass>? = nil
    private var _polyunsaturatedFat: Measurement<UnitMass>? = nil
    private var _proteins: Measurement<UnitMass>? = nil
    private var _carbs: Measurement<UnitMass>? = nil
    private var _calories: Measurement<UnitEnergy>? = nil
    private var _cholesterol: Measurement<UnitMass>? = nil
    private var _sodium: Measurement<UnitMass>? = nil
    private var _fibers: Measurement<UnitMass>? = nil
    private var _transFat: Measurement<UnitMass>? = nil
    private var _sugars: Measurement<UnitMass>? = nil
    private var _sugarsAdded: Measurement<UnitMass>? = nil
    private var _alcohol: Measurement<UnitMass>? = nil
    private var _iron: Measurement<UnitMass>? = nil
    private var _vitaminC: Measurement<UnitMass>? = nil
    private var _vitaminA: Double? = nil
    private var _vitaminD: Measurement<UnitMass>? = nil
    private var _vitaminB6: Measurement<UnitMass>? = nil
    private var _vitaminB12: Measurement<UnitMass>? = nil
    private var _vitaminB12Added: Measurement<UnitMass>? = nil
    private var _vitaminE: Measurement<UnitMass>? = nil
    private var _vitaminEAdded: Measurement<UnitMass>? = nil
    private var _iodine: Measurement<UnitMass>? = nil
    private var _calcium: Measurement<UnitMass>? = nil
    private var _potassium: Measurement<UnitMass>? = nil
    private var _magnesium: Measurement<UnitMass>? = nil
    private var _phosphorus: Measurement<UnitMass>? = nil
    private var _sugarAlcohol: Measurement<UnitMass>? = nil

    private lazy var unitMap: [String: Measurement<UnitMass>] = [

        "fat": Measurement(value: _fat?.value ?? 0.0, unit: .grams),
        "satFat": Measurement(value: _satFat?.value ?? 0.0, unit: .grams),
        "transFat": Measurement(value: _transFat?.value ?? 0.0, unit: .grams),
        "monounsaturatedFat": Measurement(value: _monounsaturatedFat?.value ?? 0.0, unit: .grams),
        "polyunsaturatedFat": Measurement(value: _polyunsaturatedFat?.value ?? 0.0, unit: .grams),
        "cholesterol": Measurement(value: _cholesterol?.value ?? 0.0, unit: .milligrams),
        "sodium": Measurement(value: _sodium?.value ?? 0.0, unit: .milligrams),

        "carbs": Measurement(value: _carbs?.value ?? 0.0, unit: .grams),
        "fibers": Measurement(value: _fibers?.value ?? 0.0, unit: .grams),
        "sugars": Measurement(value: _sugars?.value ?? 0.0, unit: .grams),
        "sugarsAdded": Measurement(value: _sugarsAdded?.value ?? 0.0, unit: .grams),
        "proteins": Measurement(value: _proteins?.value ?? 0.0, unit: .grams),
        "vitaminD": Measurement(value: _vitaminD?.value ?? 0.0, unit: .micrograms),
        "calcium": Measurement(value: _calcium?.value ?? 0.0, unit: .milligrams),

        "iron": Measurement(value: _iron?.value ?? 0.0, unit: .milligrams),
        "potassium": Measurement(value: _potassium?.value ?? 0.0, unit: .milligrams),
        "vitaminC": Measurement(value: _vitaminC?.value ?? 0.0, unit: .milligrams),
        "sugarAlcohol": Measurement(value: _sugarAlcohol?.value ?? 0.0, unit: .grams),
        "vitaminB12Added": Measurement(value: _vitaminB12Added?.value ?? 0.0, unit: .micrograms),
        "vitaminB12": Measurement(value: _vitaminB12?.value ?? 0.0, unit: .micrograms),
        "vitaminB6": Measurement(value: _vitaminB6?.value ?? 0.0, unit: .milligrams),

        "vitaminE": Measurement(value: _vitaminE?.value ?? 0.0, unit: .milligrams),
        "vitaminEAdded": Measurement(value: _vitaminEAdded?.value ?? 0.0, unit: .milligrams),
        "magnesium": Measurement(value: _magnesium?.value ?? 0.0, unit: .milligrams),
        "phosphorus": Measurement(value: _phosphorus?.value ?? 0.0, unit: .milligrams),
        "iodine": Measurement(value: _iodine?.value ?? 0.0, unit: .micrograms),
        "alcohol": Measurement(value: _alcohol?.value ?? 0.0, unit: .grams)
    ]
```

Methods to calculate nutrition data:
1. For single food 
```swift
internal init(referenceNutrients: PassioNutrients,
                  weight: Measurement<UnitMass> = Measurement<UnitMass>(value: 100.0, unit: .grams)) {

        self.init(weight: weight)

        _fat = referenceNutrients._fat
        _satFat = referenceNutrients._satFat
        _monounsaturatedFat = referenceNutrients._monounsaturatedFat
        _polyunsaturatedFat = referenceNutrients._polyunsaturatedFat
        _proteins = referenceNutrients._proteins
        _carbs = referenceNutrients._carbs
        _calories = referenceNutrients._calories
        _cholesterol = referenceNutrients._cholesterol
        _sodium = referenceNutrients._sodium
        _fibers = referenceNutrients._fibers
        _transFat = referenceNutrients._transFat
        _sugars = referenceNutrients._sugars
        _sugarsAdded = referenceNutrients._sugarsAdded
        _alcohol = referenceNutrients._alcohol
        _iron = referenceNutrients._iron
        _vitaminC = referenceNutrients._vitaminC
        _vitaminD = referenceNutrients._vitaminD
        _vitaminB6 = referenceNutrients._vitaminB6
        _vitaminB12 = referenceNutrients._vitaminB12
        _vitaminB12Added = referenceNutrients._vitaminB12Added
        _vitaminE = referenceNutrients._vitaminE
        _vitaminEAdded = referenceNutrients._vitaminEAdded
        _iodine = referenceNutrients._iodine
        _calcium = referenceNutrients._calcium
        _potassium = referenceNutrients._potassium
        _magnesium = referenceNutrients._magnesium
        _phosphorus = referenceNutrients._phosphorus
        _sugarAlcohol = referenceNutrients._sugarAlcohol
        _vitaminA = referenceNutrients._vitaminA
    }
```
2. For Recipe food 
```swift
init(ingredientsData: [(PassioNutrients, Double)], weight: Measurement<UnitMass>) {

        self.init(weight: weight)

        _fat = ingredientsData.map { $0.0._fat?.times(mult: $0.1) }.reduce(_fat) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _satFat = ingredientsData.map { $0.0._satFat?.times(mult: $0.1) }.reduce(_satFat) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _monounsaturatedFat = ingredientsData.map { $0.0._monounsaturatedFat?.times(mult: $0.1) }.reduce(_monounsaturatedFat) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _polyunsaturatedFat = ingredientsData.map { $0.0._polyunsaturatedFat?.times(mult: $0.1) }.reduce(_polyunsaturatedFat) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _proteins = ingredientsData.map { $0.0._proteins?.times(mult: $0.1) }.reduce(_proteins) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _carbs = ingredientsData.map { $0.0._carbs?.times(mult: $0.1) }.reduce(_carbs) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _cholesterol = ingredientsData.map { $0.0._cholesterol?.times(mult: $0.1) }.reduce(_fat) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _sodium = ingredientsData.map { $0.0._sodium?.times(mult: $0.1) }.reduce(_cholesterol) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _fibers = ingredientsData.map { $0.0._fibers?.times(mult: $0.1) }.reduce(_sodium) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _transFat = ingredientsData.map { $0.0._transFat?.times(mult: $0.1) }.reduce(_transFat) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _sugars = ingredientsData.map { $0.0._sugars?.times(mult: $0.1) }.reduce(_sugars) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _sugarsAdded = ingredientsData.map { $0.0._sugarsAdded?.times(mult: $0.1) }.reduce(_sugarsAdded) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _alcohol = ingredientsData.map { $0.0._alcohol?.times(mult: $0.1) }.reduce(_alcohol) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _iron = ingredientsData.map { $0.0._iron?.times(mult: $0.1) }.reduce(_iron) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _vitaminC = ingredientsData.map { $0.0._vitaminC?.times(mult: $0.1) }.reduce(_vitaminC) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _vitaminD = ingredientsData.map { $0.0._vitaminD?.times(mult: $0.1) }.reduce(_vitaminD) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _vitaminB6 = ingredientsData.map { $0.0._vitaminB6?.times(mult: $0.1) }.reduce(_vitaminB6) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _vitaminB12 = ingredientsData.map { $0.0._vitaminB12?.times(mult: $0.1) }.reduce(_vitaminB12) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _vitaminB12Added = ingredientsData.map { $0.0._vitaminB12Added?.times(mult: $0.1) }.reduce(_vitaminB12Added) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _vitaminE = ingredientsData.map { $0.0._vitaminE?.times(mult: $0.1) }.reduce(_vitaminE) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _vitaminEAdded = ingredientsData.map { $0.0._vitaminEAdded?.times(mult: $0.1) }.reduce(_vitaminEAdded) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _iodine = ingredientsData.map { $0.0._iodine?.times(mult: $0.1) }.reduce(_iodine) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _calcium = ingredientsData.map { $0.0._calcium?.times(mult: $0.1) }.reduce(_calcium) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _potassium = ingredientsData.map { $0.0._potassium?.times(mult: $0.1) }.reduce(_potassium) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _magnesium = ingredientsData.map { $0.0._magnesium?.times(mult: $0.1) }.reduce(_magnesium) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _phosphorus = ingredientsData.map { $0.0._phosphorus?.times(mult: $0.1) }.reduce(_phosphorus) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _sugarAlcohol = ingredientsData.map { $0.0._sugarAlcohol?.times(mult: $0.1) }.reduce(_sugarAlcohol) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _calories = ingredientsData.map { $0.0._calories?.times(mult: $0.1) }.reduce(_calories) { $0?.plus($1) == nil ? $1 : $0?.plus($1) }
        _vitaminA = ingredientsData.map { $0.0._vitaminA?.times(mult: $0.1) }.reduce(_vitaminA) { $0?.plus(val: $1) == nil ? $1 : $0?.plus(val: $1) }
    }
```
3. For UPC/Barcode Food
```swift
internal init(weight: Measurement<UnitMass> = Measurement<UnitMass>(value: 100.0, unit: .grams),
                  responseNutrients: [ResponseIngredient.NutrientUPC]) {

        self.init(weight: weight)

        responseNutrients.forEach { upcNutrient in

            switch upcNutrient.id {
            case 1603211196544:
                var refValue = _proteins
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "proteins")
                _proteins = refValue
            case 1603211196545:
                var refValue = _fat
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "fat")
                _fat = refValue
            case 1603211196546:
                var refValue = _carbs
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "carbs")
                _carbs = refValue
            case 1603211196548:
                var refValue = _calories
                refValue = upcNutrient.amount.toKcal()
                _calories = refValue
            case 1603211196571:
                var refValue = _fibers
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "fibers")
                _fibers = refValue
            case 1603211196679:
                var refValue = _satFat
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "satFat")
                _satFat = refValue
            case 1603211196678:
                var refValue = _transFat
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "transFat")
                _transFat = refValue
            case 1603211196677:
                var refValue = _cholesterol
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "cholesterol")
                _transFat = _cholesterol
            case 1603211196583:
                var refValue = _sodium
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "sodium")
                _sodium = refValue
            case 1603211196751:
                var refValue = _sugars
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "sugars")
                _sugars = refValue
            case 1603211196577:
                var refValue = _calcium
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "calcium")
                _calcium = refValue
            case 1603211196579:
                var refValue = _iron
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "iron")
                _iron = refValue
            case 1603211196582:
                var refValue = _potassium
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "potassium")
                _potassium = refValue
            case 1603211196594:
                var refValue = _vitaminA
                refValue = upcNutrient.amount
                _vitaminA = refValue
            case 1603211196626:
                var refValue = _vitaminC
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminC")
                _vitaminC = refValue
            case 1603211196604:
                var refValue = _vitaminD
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminD")
                _vitaminD = refValue
            case 1603211196631:
                var refValue = _vitaminB6
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminB6")
                _vitaminB6 = refValue
            case 1603211196634:
                var refValue = _vitaminB12
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminB12")
                _vitaminB12 = refValue
            case 1603211196580:
                var refValue = _magnesium
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "magnesium")
                _magnesium = refValue
            case 1603211196581:
                var refValue = _phosphorus
                toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "phosphorus")
                _phosphorus = refValue
            default:
                switch upcNutrient.nutrient?.shortName {
                case "protein":
                    var refValue = _proteins
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "proteins")
                    _proteins = refValue
                case "fat":
                    var refValue = _fat
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "fat")
                    _fat = refValue
                case "carbs":
                    var refValue = _carbs
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "carbs")
                    _carbs = refValue
                case "calories":
                    var refValue = _calories
                    refValue = upcNutrient.amount.toKcal()
                    _calories = refValue
                case "fibers":
                    var refValue = _fibers
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "fibers")
                    _fibers = refValue
                case "satFat":
                    var refValue = _satFat
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "satFat")
                    _satFat = refValue
                case "transFat":
                    var refValue = _transFat
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "transFat")
                    _transFat = refValue
                case "cholesterol":
                    var refValue = _cholesterol
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "cholesterol")
                    _transFat = _cholesterol
                case "sodium":
                    var refValue = _sodium
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "sodium")
                    _sodium = refValue
                case "sugarTotal":
                    var refValue = _sugars
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "sugars")
                    _sugars = refValue
                case "alcohol":
                    var refValue = _alcohol
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "alcohol")
                    _alcohol = refValue
                case "monounsaturatedFat":
                    var refValue = _monounsaturatedFat
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "monounsaturatedFat")
                    _monounsaturatedFat = refValue
                case "polyunsaturatedFat":
                    var refValue = _polyunsaturatedFat
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "polyunsaturatedFat")
                    _polyunsaturatedFat = refValue
                case "calcium":
                    var refValue = _calcium
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "calcium")
                    _calcium = refValue
                case "iron":
                    var refValue = _iron
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "iron")
                    _iron = refValue
                case "potassium":
                    var refValue = _potassium
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "potassium")
                    _potassium = refValue
                case "vitaminA":
                    var refValue = _vitaminA
                    refValue = upcNutrient.amount
                    _vitaminA = refValue
                case "vitaminC":
                    var refValue = _vitaminC
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminC")
                    _vitaminC = refValue
                case "sugarAlcohol":
                    var refValue = _sugarAlcohol
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "sugarAlcohol")
                    _sugarAlcohol = refValue
                case "vitaminD":
                    var refValue = _vitaminD
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminD")
                    _vitaminD = refValue
                case "sugarsAdded":
                    var refValue = _sugarsAdded
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "sugarsAdded")
                    _sugarsAdded = refValue
                case "vitaminB6":
                    var refValue = _vitaminB6
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminB6")
                    _vitaminB6 = refValue
                case "vitaminB12":
                    var refValue = _vitaminB12
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminB12")
                    _vitaminB12 = refValue
                case "magnesium":
                    var refValue = _magnesium
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "magnesium")
                    _magnesium = refValue
                case "phosphorus":
                    var refValue = _phosphorus
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "phosphorus")
                    _phosphorus = refValue
                case "vitaminB12Added":
                    var refValue = _vitaminB12Added
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminB12Added")
                    _vitaminB12Added = refValue
                case "vitaminE":
                    var refValue = _vitaminE
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminE")
                    _vitaminE = refValue
                case "vitaminEAdded":
                    var refValue = _vitaminEAdded
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "vitaminEAdded")
                    _vitaminEAdded = refValue
                case "iodine":
                    var refValue = _iodine
                    toUnitMassAndSet(field: &refValue, value: upcNutrient.amount, nutrient: "iodine")
                    _iodine = refValue
                default: break
                }
            }
        }
    }
```

4. **PassioFoodMetadata**
This model will return the metadata with below properties:
```swift
var foodOrigins: [PassioFoodOrigin]?
    var barcode: Barcode?
    var ingredientsDescription: String?
    var tags: [String]?
```

Method to get PassioMetadata:
```swift
static func fromSearchResult(result: ResponseIngredient?) -> PassioFoodMetadata {

        var metadata = PassioFoodMetadata()

        guard let result = result else {
            return metadata
        }

        if let origin = result.origin {
            var originsTemp = [PassioFoodOrigin]()
            for item in origin {
                originsTemp.append(PassioFoodOrigin(id: item.id ?? "", source: item.source ?? "", licenseCopy: result.licenseCopy))
            }
            metadata.foodOrigins = originsTemp
        }

        metadata.barcode = result.branded?.productCode
        metadata.ingredientsDescription = result.branded?.ingredients
        metadata.tags = result.tags

        return metadata
    }
```

5. **PassioFoodAmount**
The PassioFoodAmount model will calculate the food amount and will return data with below properties:
```swift
    let servingSizes: [PassioServingSize]
    let servingUnits: [PassioServingUnit]
    let selectedUnit: String
    let selectedQuantity: Double

    private static let SERVING_UNIT_NAME = "serving"

    init(servingSizes: [PassioServingSize], servingUnits: [PassioServingUnit]) {

        self.servingSizes = servingSizes
        self.servingUnits = servingUnits
        self.selectedUnit = servingSizes.first?.unitName ?? ""
        self.selectedQuantity = servingSizes.first?.quantity ?? 0.0
    }
```

Method to get the PassioFoodAmount data
```swift
static func fromSearchResult(portions: [ResponseIngredient.Portion]?,
                                 ingredientWeight: Double? = nil) -> PassioFoodAmount {

        if portions == nil {
            return PassioFoodAmount(servingSizes: [PassioServingSize(quantity: 1.0,
                                                                     unitName: "gram")],
                                    servingUnits: [PassioServingUnit(unitName: "gram",
                                                                     weight: Measurement<UnitMass>(value: 100.0,
                                                                                                   unit: .grams))])
        }

        var servingSizes = [PassioServingSize]()
        var servingUnits = [PassioServingUnit]()

        portions?.forEach { portion in
            if let servingSizesAndUnit = getServingSizeAndUnit(portion: portion) {
                servingSizes.append(contentsOf: servingSizesAndUnit.0)
                servingUnits.append(servingSizesAndUnit.1)
            }
        }

        if servingSizes.isEmpty, let ingredientWeight = ingredientWeight {
            servingUnits.append(PassioServingUnit(unitName: SERVING_UNIT_NAME,
                                                  weight: Measurement<UnitMass>(value: ingredientWeight, unit: .grams)))
            servingSizes.append(PassioServingSize(quantity: 1.0, unitName: SERVING_UNIT_NAME))
        }
        
        let conversionUnits = getConversionUnits(currentUnits: servingUnits)

        if !conversionUnits.isEmpty {
            servingUnits += conversionUnits
        }

        if servingUnits.first(where: { $0.unitName == "gram" }) == nil {
            servingUnits.append(PassioServingUnit(unitName: "gram",
                                                  weight: Measurement<UnitMass>(value: 1.0, unit: .grams)))
        }

        servingSizes.append(PassioServingSize(quantity: 100.0, unitName: "gram"))
        return PassioFoodAmount(servingSizes: servingSizes, servingUnits: servingUnits)
    }
```

## To see all the capabilities of the SDK run the PassioSDKFullDemo

Start by adding your key to the PassioExternalConnector class
```swift
class PassioExternalConnector 

var passioKeyForSDK: String {
        "YourPassioSDKKey"
    }

```

Review the  RotationViewController super class is contains all the elements for adding the PassioNutritionAISDK to a view controller.

Note: If you use the SDK only in one view you could move all the code from viewDidAppear to viewWillAppear. 

It is also containing the code to support device rotations. 

```swift
import UIKit
import AVFoundation
import PassioNutritionAISDK

class RotationViewController: UIViewController {

    let passioSDK = PassioNutritionAI.shared
    var volumeDetectionMode = VolumeDetectionMode.auto
    var videoLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            backgroundImage?.fadeOut(seconds: 0.3)
            // backgroundImage?.isHidden = videoLayer == nil ? false : true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized { // already authorized
            setupVideoLayer()
            startDetection()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // access to video granted
                    DispatchQueue.main.async {
                        self.setupVideoLayer()
                        self.startDetection()
                    }
                } else {
                    print("The user didn't grant access to use camera")
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundImage.fadeIn(seconds: 0.2)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
        stopDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
        passioSDK.removevideoLayer()
    }

    func startDetection() {

    }

    func stopDetection() {

    }

    func setupVideoLayer() {
        guard videoLayer == nil else { return }
        print("setupVideoLayer volumeDetectionMode  == \(volumeDetectionMode)" )
        if let vLayer = passioSDK.getPreviewLayerWithGravity(volumeDetectionMode: volumeDetectionMode,
        videoGravity: .resizeAspectFill) {
            videoLayer = vLayer
            vLayer.frame = view.bounds
            view.layer.insertSublayer(vLayer, at: 0)
        }
    }

}

```

### Using the full demo app point at parts of the image below to test recognition
* Food (non packaged)
* Barcode
* Packaged food
* Nutrition facts 

![Use this image to test recognition](./READMEIMAGES/passio_recognition_test.jpg)

<sup>Copyright 2023 Passio Inc</sup>
