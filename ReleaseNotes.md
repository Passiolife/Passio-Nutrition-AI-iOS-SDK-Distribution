# Passio SDK Release Notes

## V3.2.8

- Fixed incorrect packaging of v3.2.7, identical to v3.2.7 otherwise.

## V3.2.7
### New APIs:

- Added startBarcodeScanning
```swift
/// Use this function to detect barcodes by pointing the camera at a barcode
/// - Parameters:
///   - recognitionDelegate: ``BarcodeRecognitionDelegate``, Add self to implement the BarcodeRecognitionDelegate
///   - completion: If success, it will return array of `BarcodeCandidate` objects
public func startBarcodeScanning(recognitionDelegate: BarcodeRecognitionDelegate,
                                 completion: @escaping (Bool) -> Void) {
    coreSDK.startBarcodeScanning(recognitionDelegate: recognitionDelegate,
                                 completion: completion)
}
```

- Added stopBarcodeScanning
```swift
/// Use this function to stop barcode detection.
public func stopBarcodeScanning() {
    coreSDK.stopFoodDetection()
}
```

### Removed APIs:

- `startFoodDetection`
- `stopFoodDetection`

## V3.2.6
### New APIs:

- Added hierarchy grouping for voice results
```swift
/// This method groups a list of `PassioFoodItem` into recipes
    /// - Parameters:
    ///   - text: Text for recognizing food logging actions
    ///   - completion: ``PassioRecognitionResult`` with array of ``PassioRecognitionItem``
    public func recognizeSpeechRemoteWithGrouping(text: String,
                                                  completion: @escaping (Result<PassioRecognitionResult, Error>) -> Void) {
        coreSDK.recognizeSpeechRemoteWithGrouping(text: text,
                                                  completion: completion)
    }
```

- Added hierarchy grouping for image results
```swift
// This method groups a list of `PassioFoodItem` into recipes
    /// - Parameters:
    ///   - image: UIImage for recognizing Food, Barcodes or Nutrition Facts
    ///   - resolution: Image resoultion for detection. Default Image resoultion is 512, see ``PassioImageResolution`` for more options.
    ///   - completion: ``PassioRecognitionResult`` with array of ``PassioRecognitionItem``
    public func recognizeImageRemoteWithGrouping(image: UIImage,
                                                 resolution: PassioImageResolution = .res_512,
                                                 message: String? = nil,
                                                 completion: @escaping (Result<PassioRecognitionResult, Error>) -> Void) {
        coreSDK.recognizeImageRemoteWithGrouping(image: image,
                                                 resolution: resolution,
                                                 message: message,
                                                 completion: completion)
    }
```

- Added generateMealPlan API
```swift
/// Generates a meal plan for the user based on the provided input
    /// - Parameters:
    ///   - request: The food item or ingredient list to generate a meal plan for
    ///   - completion: ``PassioGeneratedMealPlan``
    public func generateMealPlan(request: String,
                                 completion: @escaping (Result<PassioGeneratedMealPlan, Error>) -> Void) {
        coreSDK.generateMealPlan(request: request,
                                 completion: completion)
    }
```

- Added generateMealPlanPreview API
```swift
/// Generates a meal plan preview for the user based on the provided input
    /// - Parameters:
    ///   - request: The food item or ingredient list to generate a meal plan preview for
    ///   - completion: ``PassioGeneratedMealPlan``
    public func generateMealPlanPreview(request: String,
                                        completion: @escaping (Result<PassioGeneratedMealPlan, Error>) -> Void) {
        coreSDK.generateMealPlanPreview(request: request,
                                        completion: completion)
    }
```

### Removed APIs:

- `detectFoodWithText`
- `startNutritionFactsDetection`

### Enhancements:

- `recognizeImageRemote` is able to also recognize barcode images, which means, this is a broader API which handles more cases

## V3.2.5
### What's new:

- Add concerns to `PassioFoodMetadata`
- Refactor `fetchFoodItemForDataInfo` method

### Deprecated APIs:

- `startFoodDetection`
- `stopFoodDetection`
- `detectFoodWithText`
- `startNutritionFactsDetection`

## V3.2.4
### What's new:

- Fixed issue: `fetchFoodItemForDataInfo` returning incorrect weight
- Added two properties inside `PassioConfiguration` to offer a layer of security, where clients can authenticate the SDK license and fetch the token on their backend.

```swift
/// Set the base URL of the target proxy endpoint
public var proxyUrl: String?
/// Set the needed headers to all of the requests
public var proxyHeaders: [String: String]?
```

## V3.2.3
### Updated APIs:

- Renamed `semanticSearchForFood` to `searchForFoodSemantic`
- Renamed `fetchNextPredictedIngredients` to `predictNextIngredients`

## V3.2.2
### New APIs:

- Added semantic search API
```swift
/// Semantic search for food will return a list of alternate search and search result
    /// - Parameters:
    ///   - byText: User typed text
    ///   - completion: ``SearchResponse``, which containts list of alternate search and its results
    public func semanticSearchForFood(searchTerm: String,
                                      completion: @escaping (PassioNutritionAISDK.SearchResponse?) -> Void)

```

- Added fetch next predicted ingredients API
```swift
/// Returns possible ingredients for a given food item
    /// - Parameters:
    ///   - ingredients: List of food ingredients name
    ///   - completion: ``PassioPredictedIngredients``, PassioPredictedIngredients responds with a success or error response. If the response is successful, you will receive an array of ``PassioAdvisorFoodInfo`` ingredients showing what might be contained in the given food.
    public func fetchNextPredictedIngredients(ingredients: [String], 
                                              completion: @escaping PassioNutritionAISDK.PassioPredictedIngredients)

```

### Updated APIs:

- Change fetchTagsFor API to accept the refCode
```swift
/// Fetch the tags from the ref code
    /// - Parameters:
    ///   - refCode: Reference code of food item
    ///   - completion: Tag as a list of strings
```

- Change fetchInflammatoryEffectData API to accept the refCode
```swift
/// Fetch the list of nutrients with their inflammatory score
    /// - Parameters:
    ///   - refCode: Reference code of food item
    ///   - completion: List of `InflammatoryEffectData` objects
```

## V3.2.1
### New APIs:

- Added report food API
```swift
/**
     Use this method to report incorrect food item
     
     - Parameters:
        - refCode: Reference code of food item
        - productCode: Product code
        - notes: Note if any (optional)
        - completion: You will receive ``PassioResult`` in completion.
     
     - Precondition: Either `refCode` or `productCode` must be present
     - Returns: It returns ``PassioResult`` that can be either an `errorMessage` or the `boolean` noting the success of the operation.
     public func reportFoodItem(refCode: String = "", 
                                productCode: String = "", 
                                notes: [String]? = nil, 
                                completion: @escaping PassioNutritionAISDK.PassioResult)

*/
```

- Submit User Created Food
```swift
/// Use this method to submit User Created Food. The method will return `true` if the uploading of user food is successfull.
    /// - Parameters:
    ///   - item: Pass ``PassioFoodItem`` to sumbit it to Passio
    ///   - completion: You will receive ``PassioResult`` in completion.
    public func submitUserCreatedFood(item: PassioNutritionAISDK.PassioFoodItem,
                                      completion: @escaping PassioNutritionAISDK.PassioResult)

```

## V3.2.0
### New APIs:

- Added remote recognition of nutrition facts
```swift
/// Use this method for scanning nutrients from Packaged Product. This method returns ``PassioFoodItem``.
    /// - Parameters:
    ///   - image: Image for detecting nutrients
    ///   - resolution: Image resoultion for detection. Default Image resoultion is `512`, see ``PassioImageResolution`` for more options.
    ///   - completion: If the response is successful, you will receive ``PassioFoodItem`` or else you will receive nil value.
    public func recognizeNutritionFactsRemote(image: UIImage,
                                              resolution: PassioImageResolution = .res_512,
                                              completion: @escaping (PassioFoodItem?) -> Void)
```

- Added support for localization
```swift
/// Use this method to retrieve localized food data. The method will return `true` if the language setting is applied successfully.
    /// - Parameters:
    ///   - languageCode: A two-character string representing the ISO 639-1 language code (e.g., 'en' for English, 'fr' for French, 'de' for German).
    public func updateLanguage(languageCode: String) -> Bool
```

### Updated APIs.

- Added `remoteOnly` property in `PassioConfiguration` struct
```swift
/// If you set this option to true, the SDK will not download the ML models and Visual and Packaged food detection won't work, only Barcode and NutritionFacts will work.
    public var remoteOnly = false
```

- Added barcode and nutrition facts scanning to the recognizeImageRemote function.
```swift
/// Use this method to retrieve ``PassioAdvisorFoodInfo`` by providing an image. You can provide any image, including those of regular food, barcodes, or nutrition facts printed on a product, to obtain the corresponding ``PassioAdvisorFoodInfo``
    /// - Parameters:
    ///   - image: UIImage for recognizing Food, Barcodes or Nutrition Facts
    ///   - resolution: Image resoultion for detection. Default Image resoultion is 512, see ``PassioImageResolution`` for more options.
    ///   - completion: Returns Array of ``PassioAdvisorFoodInfo`` if any or empty array if unable to recognize food in image
    public func recognizeImageRemote(image: UIImage,
                                     resolution: PassioImageResolution = .res_512,
                                     message: String? = nil,
                                     completion: @escaping ([PassioAdvisorFoodInfo]) -> Void)
```

- Added new tags property in PassioFoodDataInfo
```swift
public let tags: [String]?
```

- Added new Vitamin A RAE with μ unit in PassioNutrients struct
```swift
public func vitaminA_RAE() ->  Measurement<UnitMass>?
```

- Added new apiName property in PassioTokenBudget struct
```swift
public let apiName: String
```

## V3.1.4

### New APIs.
- Added Token Usage API to track token usage.
```swift
/// Delegate to track account usage updates. Used to monitor total monthly
/// tokens, used tokens and how many tokens the last request used.
public weak var accountDelegate: PassioAccountDelegate?

/// Implement to receive account usage updates. Used to monitor total monthly
/// tokens, used tokens and how many tokens the last request used.
public protocol PassioAccountDelegate: AnyObject {
    func tokenBudgetUpdated(tokenBudget: PassioTokenBudget)
}

public struct PassioTokenBudget: Codable {
    public let budgetCap: Int
    public let periodUsage: Int
    public let requestUsage: Int
    public var usedPercent: Float { get }
    public func toString() -> String
    public func debugPrint()
}
```

- Added Flashlight API to turn Flashlight on/off.
```swift
/// Use this method to turn Flashlight on/off.
/// - Parameters:
///   - enabled: Pass true to turn flashlight on or pass false to turn in off.
///   - torchLevel: Sets the illumination level when in Flashlight mode. This value must be a floating-point number between 0.0 and 1.0.
public func enableFlashlight(enabled: Bool, level torchLevel: Float)
```

## V3.1.3
- Added missing suggarAdded nutrient in the `PassioNutrients`

## V3.1.1

### New APIs.
- Added `fetchHiddenIngredients`, `fetchVisualAlternatives` and `fetchPossibleIngredients` APIs.

```swift  
    /// Returns hidden ingredients for a given food item
    /// - Parameters:
    ///   - foodName: Food name to search for
    ///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive an array of ``PassioAdvisorFoodInfo`` hidden ingredients found in the searched for food item.
    public func fetchHiddenIngredients(
        foodName: String,
        completion: @escaping NutritionAdvisorIngredientsResponse
    )
```
```swift 
    /// Returns visual alternatives for a given food item
    /// - Parameters:
    ///   - foodName: Food name to search for
    ///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive an array of ``PassioAdvisorFoodInfo`` visual alternatives for the searched for food item.
    public func fetchVisualAlternatives(
        foodName: String,
        completion: @escaping NutritionAdvisorIngredientsResponse
    )
```
```swift 
    /// Returns possible ingredients for a given food item
    /// - Parameters:
    ///   - foodName: Food name to search for
    ///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive an array of ``PassioAdvisorFoodInfo`` ingredients showing what might be contained in the given food.
    public func fetchPossibleIngredients(
        foodName: String,
        completion: @escaping NutritionAdvisorIngredientsResponse
    )
```

### Updated APIs.
- Added new `PassioImageResolution` parameter to `recognizeImageRemote` API.

```Swift
public func recognizeImageRemote(
    image: UIImage,
    resolution: PassioImageResolution = .res_512,
    message: String? = nil,
    completion: @escaping ([PassioAdvisorFoodInfo]) -> Void
)
```

## V3.1.0
* Added Nutrition Advsior API
```swift
/// Use this method to configure Nutrition Advisor
/// - Parameters:
///   - licenceKey: Licence Key for configuration
///   - completion: NutritionAdvisorResult with sucess or error message
public func configure(licenceKey: String, completion: @escaping NutritionAdvisorStatus)

/// Initiate converstion with Nutrition Advisor
/// - Parameters:
///   - completion: NutritionAdvisorResult with sucess or error message
public func initConversation(completion: @escaping NutritionAdvisorStatus)

/// Use this method to send message to Nutrition Advisor
/// - Parameters:
///   - message: Message you want to send
///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive PassioAdvisorResponse containing food information.

public func sendMessage(message: String, completion: @escaping NutritionAdvisorResponse)
/// Use this method to send image to Nutrition Advisor
/// - Parameters:
///   - image: UIImage you want to send
///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive PassioAdvisorResponse containing food information.
public func sendImage(image: UIImage, completion: @escaping NutritionAdvisorResponse)

/// Use this method to fetch ingredients
/// - Parameters:
///   - advisorResponse: Pass PassioAdvisorResponse
///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive PassioAdvisorResponse containing food information.
public func fetchIngridients(from advisorResponse: PassioAdvisorResponse, completion: @escaping NutritionAdvisorResponse)
```

* Refactored Nutrition Facts API
```Swift
/// Use this function to detect Nutrition Facts via pointing the camera at Nutrition Facts
/// - Parameters:
///   - nutritionfactsDelegate: Add self to implement the NutritionFactsDelegate
///   - completion: success or failure of the startNutritionFactsDetection
func startNutritionFactsDetection(
    nutritionfactsDelegate: NutritionFactsDelegate?,
    capturingDeviceType: CapturingDeviceType = .defaultCapturing(),
    completion: @escaping (Bool) -> Void
)
```

* Added fetchFoodItemLegacy API
```Swift
/// Fetch PassioFoodItem for a v2 PassioID
/// - Parameter passioID: PassioID
/// - Parameter completion: Receive a closure with optional PassioFoodItem
public func fetchFoodItemLegacy(from passioID: PassioID, completion: @escaping (PassioFoodItem?) -> Void)
```

## V3.0.5
- Refactored PassioSearchNutritionPreview

```Swift
public struct PassioSearchNutritionPreview: Codable {
    public var calories: Int
    public let carbs: Double
    public let fat: Double
    public let protein: Double
    public var servingUnit: String
    public var servingQuantity: Double
    public var weightUnit: String
    public var weightQuantity: Double
}

```
- Added refCode as an attribute to the PassioFoodItem and PassioIngredient classes.
- Added method to fetch a food item using just the refCode attribute

```Swift
/// Lookup fetchFoodItem from RefCode
/// - Parameter RefCode: String
/// - Returns: PassioFoodItem
public func fetchFoodItemFor(refCode: String, completion: @escaping (PassioNutritionAISDK.PassioFoodItem?) -> Void)
```

## V3.0.3
* Added Meal Plan API
```swift
    public func fetchMealPlans(completion: @escaping ([PassioNutritionAISDK.PassioMealPlan]) -> Void)

    public func fetchMealPlanForDay(mealPlanLabel: String, day: Int, completion: @escaping ([PassioNutritionAISDK.PassioMealPlanItem]) -> Void)
```

## V3.0.2
* Added dynamic metadata loading in SDK inisialisations.
* Intigrated API to fetch quick suggestions
```swift 
        public func fetchSuggestions(mealTime: MealTime, completion: @escaping ([PassioSearchResult]) -> Void)
    ```
* MealTime enum added (Breakfast,lunch,dinner,snacks)
* Added following micronutrients: Zinc, Selenium, Folic acid, Chromium, Vitamin-K Phylloquinone,Vitamin-K Menaquinone4,Vitamin-K Dihydrophylloquinone

## V3.0.1
* Added alternatives in HNN Candidate to display while scanning the food 
* Added new Filters Kalman filter, Weiner filter, Smooth Bayes filter to detect top 3 candidate of scanned food item
* Updated PassioFoodItem data model

## V3.0.0
* Removed APIs starting with name lookUpFor
* Added new Data models PassioFoodItem, PassioNutrients, PassioIngredient, etc. to get the nutritional data of food item
* Added new Advance search API searchForFood which returns the search results and alternatives of searched term.

## V2.3.15
* Removed Language support

### Models
* Number of food items recognized via HNN: 4104
* Nutrition database version: passio_nutrition.4105.0.301
* Number of products recognized via OCR: 27756

### New included HNN foods
```
corn chowder
```

### Excluded HNN foods
```
coconut sandwich cookies
mollete
strawberry cream cheese bagel
```

## V2.3.13

* Requesting SDK Language
```swift 
public func requestLanguage(sdkLanguage: PassioNutritionAISDK.SDKLanguage, 
                              completion: @escaping (PassioNutritionAISDK.SDKLanguage?) -> Void)
```

* Available languages
```swift 
public enum SDKLanguage : String {
    case en, de, auto
}
```

### Models

* Number of food items recognized via HNN: 4106
* Nutrition database version: passio_nutrition.4107.0.301
* Number of products recognized via OCR: 27646

### New included HNN foods
```
black krim heirloom tomatoes
cooked japanese sweet potato
```

### Excluded HNN foods
```
clam chowder
gazpacho
tuna casserole
white pureed soups
```


## V2.3.11

### Minor Improvement and enhancements 
* This version has significant improvement in Object(Food) Detection. This upgrade is recommended for all previous versions. 

* PassioNutritionFacts was enhance to read Canadian Nutrition Facts Labels and to additionally read the following nutrients.  

```swift
    public var saturatedFat: Double?
    public var transFat: Double?
    public var cholesterol: Double?
    public var sodium: Double?
    public var dietaryFiber: Double?
    public var sugars: Double?
    public var sugarAlcohol: Double?
```


## V2.3.9

Added to the PassioIDAttributes and PassioFoodItemData.
```swift
    public var confusionAlternatives: [PassioNutritionAISDK.PassioID]? { get }

    public var invisibleIngredients: [PassioNutritionAISDK.PassioID]? { get }
```

## V2.3.8

### Minor Improvement and enhancements

The spelling of 
```swift
var observasions: [VNRecognizedTextObservation]? { get }
```
was corrected to 
```swift
var observations: [VNRecognizedTextObservation]? { get }
``````

tags was set optional

```swift
public var tags: [String]? { get }
```

## V2.3.7
### Improvement and enhancements

* New API **iconURLFor** get the icon URL and download the icons directly. 

```swift  
    /// Get the icon URL
    /// - Parameters:
    ///   - passioID: passioID
    ///   - size: IconSize (.px90, .px180 or .px360) where .px90 is the default
    /// - Returns: Optional URL
    public func iconURLFor(passioID: PassioNutritionAISDK.PassioID, size: PassioNutritionAISDK.IconSize = IconSize.px90) -> URL?
```

The function 'lookupIconFor' was deprecated. Use 'lookupIconsFor' instead.

```swift
/// This function replaces 'lookupIconFor'. You will receive the placeHolderIcon and an optional icon.  If the icon is nil you can use the asynchronous function to "fetchIconFor" the icons from the web.
    /// - Parameters:
    ///   - passioID: PassioID
    ///   - size: IconSize (.px90, .px180 or .px360) where .px90 is the default
    ///   - entityType: PassioEntityType to return the right placeholder.
    /// - Returns: UIImage and a UIImage?  You will receive the placeHolderIcon and an optional icon.  If the icons is nil you can use the asynchronous function to "fetchIconFor" the icons from the web.
    public func lookupIconsFor(passioID: PassioID,
                              size: IconSize = IconSize.px90,
                               entityType: PassioIDEntityType = .item) -> (placeHolderIcon: UIImage, icon: UIImage?) { // true = final icon.
        PassioCoreSDK.shared.lookupIconsFor(passioID: passioID,
                                           size: size,
                                           entityType: entityType)
    }

``````

#### tags   

1) For barcodes and packagedFoods PassioIDAttributes fetch calls there is new tags (optional) property.
```swift 
/// PassioIDAttributes contains all the attributes for a PassioID.
public struct PassioIDAttributes : Equatable, Codable {

    public let tags: [String]?
```

2) To find tags for local passioIDs there is a new API call.

    **Fetch tags** for PassioID, were tags is a list of strings

```swift
   /// Beta API/Function
    /// - Parameters:
    ///   - passioID: passioID
    ///   - completion: tag as a list of strings.
    public func fetchTagsFor(passioID: PassioID, completion: @escaping ([String]?) -> Void)
```




## V2.3.5
### Improvement and enhancements

* StartFoodRecognition was accelerated by sending the packageFood object to by initialized in the userInitiated queue.

## V2.3.3
### Models

* Number of food items recognized via HNN: 4119
* Nutrition database version: passio_nutrition.4120.0.301
* Number of products recognized via OCR: 23863

### New included HNN foods
```
365 organic orange juice
bob evans liquid egg whites
cheerio muesli bowl
coffee tin
cream of tartar package
deli market mustard
garden salad with figs
instant coffee bottle
keurig coffee pods
natures heart granola package
pabst can
packaged apples
packaged bacon
packaged buns
packaged canadian bacon
packaged crimini mushrooms
packaged donuts
packaged frozen strawberries
packaged fruit cups
packaged muffins
packaged oyster mushrooms
packaged rosemary
packaged salads
packaged salmon
packaged shiitake mushrooms
packaged spinach
packaged spring mix
packaged turkey bacon
packaged white fish filet
packaged white mushrooms
packaged whole ham
```

### Excluded HNN foods
```
bitterballen
cinnamon roll cake
cooked cream of wheat
del monte red grapefruit cup
eat smart salad
folgers coffee package
fresh express salad
john morrell bacon
jones canadian bacon
kirkland frozen strawberries package
kirkland ham
kroger gala apple package
nescafe clasico instant coffee
nescafe tradicion instant coffee
oscar mayer turkey bacon package
packaged fortnum and mason royal blend
packaged great value tea
packaged greens
packaged herbs
packaged lipton teabags
packaged mushrooms
packaged twinings teabags
packaged yorkshire teabags
physicians choice collagen peptides
smithfield bacon
starbucks keurig pods
tastykake powdered sugar mini donuts
taylor farms salad
vital proteins collagen
```


## V2.3.1

### Improvement and enhancements
* Fix a rare issue where the SDK will not configure under unresponsive network.
* Limit the ```byText``` parameter below to 100 characters. 
```swift 
 public func searchForFood(byText: String, 
                            completion: @escaping ([PassioIDAndName]) 
 ```

### Models
* Same models as V2.2.23 

## V2.2.23

### Recognition
Additional improvement in recognizing multiple foods in the same frame. 

### Models

* Number of food items recognized via HNN: 4117
* Nutrition database version: passio_nutrition.4118.0.301
* Number of products recognized via OCR: 21423

### New included HNN foods
```
packaged pills and supplements
white tortillas
```

### Excluded HNN foods
```
arazo nutrition omega 3
benefiber bar
benefiber probiotic
emergen-c pouch
flour tortilla
goli gummies
jakoten
metamucil package
metamucil pouch
nordic naturals bottle
solaray bottle
vitafusion multivites bottle
webber naturals bottle
```


## V2.2.21

### Recognition
There is an improvement recognizing food a bit further away than before. Below the hood the bounding box of the object detections was improved. 

### Package Recognition and Barcode

The SDK will return alternatives (parents, siblings, children ) if available in the PassioIDAttributes of Package Recognition and Barcode
### Models
* Number of food items recognized via HNN: 4128
* Nutrition database version: passio_nutrition.4129.0.301
* Number of products recognized via OCR: 18225 


## V2.2.19
### Models
* Number of food items recognized via HNN: 4136
* Nutrition database version: passio_nutrition.4137.0.301
* Number of products recognized via OCR: 14288 

## V2.2.17
### Models 
* Number of food items recognized via HNN: 4154
* Nutrition database version: passio_nutrition.4155.0.301
* Number of products recognized via OCR: 9848 

## V2.2.15
### Models 
* Number of food items recognized via HNN: 4153
* Nutrition database version: passio_nutrition.4154.0.301
* Number of products recognized via OCR: 6401 

## V2.2.13
### Models 
* Number of food items recognized via HNN: 4175
* Nutrition database version: passio_nutrition.4176.0.301

### Additional API 
```swift
public struct PassioMetadataService {

    public var passioMetadata: PassioNutritionAISDK.PassioMetadata? { get }

    public var getModelNames: [String]? { get }

    public var getlabelIcons: [PassioNutritionAISDK.PassioID : PassioNutritionAISDK.PassioID]? { get }

    public func getPassioIDs(byModelName: String) -> [PassioNutritionAISDK.PassioID]?

    public func getLabel(passioID: PassioNutritionAISDK.PassioID, languageCode: String = "en") -> String?

    public init()
}
```

## V2.2.11

### No Breaking API changes
### Models 
* Number of food items recognized via HNN: 4175
* Nutrition database version: passio_nutrition.4176.0.301

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
