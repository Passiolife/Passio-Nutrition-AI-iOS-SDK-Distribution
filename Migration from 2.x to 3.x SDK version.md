## Camera recognition

* ```lookupNameFor```, ```lookupPassioAttributesForName``` and ```lookupAllDescendantsFor``` have been removed since these function were querying the local database

* ```lookupPassioAttributesFor``` has been replaced with ```fetchFoodItemForPassioID``` and now returns a ```PassioFoodItem``` result

* ```fetchPassioIDAttributesForBarcode``` and ```fetchPassioIDAttributesForPackagedFood``` have been replaced with ```fetchFoodItemForProductCode``` than now returns a ```PassioFoodItem``` result

* Alternative results in the form of parents, siblings and children have been replaced with two types of alternatives: **a)** Every detected candidate will have a list of ```alternatives: [DetectedCandidate]```. These alternatives represent contextually similar foods. Example: If the DetectadeCandidate would be "milk", than the list of alternatives would include items like "soy milk", "almond milk", etc. **b)** Also, the protocol ```FoodRecognitionDelegate``` might return multiple detected candidates, ordered by confidence. These multiple candidates represent the top result that our recognition system is predicting, but also other results that are visually similar to the top result. Example: If the first result in the list of ```detectedCandidates``` is "coffee", there might be more results in the list that are visually simillar to coffee like "coke", "black tea", "chocolate milk", etc.

* ```lookupIconFor``` has been deprecated, the correct function to use is ```lookupIconsFor```

## Search

* ```searchForFood``` now returns ```SearchResponse```. In ```SearchResponse``` you will get array of [PassioSearchResult] and array of [String] which is search options. The ```PassioSearchResult``` represent a specific food item associated with the search term

```swift
public struct PassioSearchResult {

    public let type: String

    public let displayName: String

    public let shortName: String

    public let score: Double

    public let brandName: String

    public let iconId: PassioNutritionAISDK.PassioID

    public let labelId: String

    public let synonymId: String

    public let scoredName: String

    public let recipeId: String

    public let referenceId: String

    public let resultId: String

    public let nutritionPreview: PassioNutritionAISDK.NutritionPreviewResult

    public var nutrition: PassioNutritionAISDK.PassioSearchNutritionPreview { get }
}

public struct PassioSearchNutritionPreview : Codable {

    public var calories: Int

    public var servingUnit: String

    public varservingQuantity: Double

    public var servingWeight: String
}
```

* To Fetch a food item for a specific search result use ```fetchSearchResult```

## Data models

************PassioIDAttributes************ as a top level representation of a food item has been replaced with ```PassioFoodItem```. **PassioFoodItemData** and **PassioFoodRecipe** have also been deprecated.

```swift
public struct PassioFoodItem {

    public let id: String

    public let scannedId: PassioNutritionAISDK.PassioID

    public let name: String

    public let details: String

    public let iconId: String

    public let licenseCopy: String

    public let amount: PassioNutritionAISDK.PassioFoodAmount

    public let ingredients: [PassioNutritionAISDK.PassioIngredient]

    public var foodItemName: String { get }

    public func nutrients(weight: Measurement<UnitMass>) -> PassioNutritionAISDK.PassioNutrients

    public func nutrientsSelectedSize() -> PassioNutritionAISDK.PassioNutrients

    public func nutrientsReference() -> PassioNutritionAISDK.PassioNutrients

    public func weight() -> Measurement<UnitMass>

}

public struct PassioIngredient {

    public let id: String

    public let name: String

    public let iconId: String

    public let amount: PassioNutritionAISDK.PassioFoodAmount

    public let referenceNutrients: PassioNutritionAISDK.PassioNutrients

    public let metadata: PassioNutritionAISDK.PassioFoodMetadata

    public init(id: String, name: String, iconId: String, amount: PassioNutritionAISDK.PassioFoodAmount, referenceNutrients: PassioNutritionAISDK.PassioNutrients, metadata: PassioNutritionAISDK.PassioFoodMetadata)

    public func nutrients(weight: Measurement<UnitMass>) -> PassioNutritionAISDK.PassioNutrients

    public func weight() -> Measurement<UnitMass>

}

public struct PassioFoodAmount {

    public let servingSizes: [PassioNutritionAISDK.PassioServingSize]

    public let servingUnits: [PassioNutritionAISDK.PassioServingUnit]

    public let selectedUnit: String

    public let selectedQuantity: Double

    public init(servingSizes: [PassioNutritionAISDK.PassioServingSize], servingUnits: [PassioNutritionAISDK.PassioServingUnit])
    
    public func weight() -> Measurement<UnitMass>

    public func weightGrams() -> Double

}

public struct PassioNutrients {

    public let weight: Measurement<UnitMass>

    public var referenceWeight: Measurement<UnitMass>

    public init(weight: Measurement<UnitMass>)

    public init(fat: Measurement<UnitMass>? = nil, satFat: Measurement<UnitMass>? = nil, monounsaturatedFat: Measurement<UnitMass>? = nil, polyunsaturatedFat: Measurement<UnitMass>? = nil, proteins: Measurement<UnitMass>? = nil, carbs: Measurement<UnitMass>? = nil, calories: Measurement<UnitEnergy>? = nil, cholesterol: Measurement<UnitMass>? = nil, sodium: Measurement<UnitMass>? = nil, fibers: Measurement<UnitMass>? = nil, transFat: Measurement<UnitMass>? = nil, sugars: Measurement<UnitMass>? = nil, sugarsAdded: Measurement<UnitMass>? = nil, alcohol: Measurement<UnitMass>? = nil, iron: Measurement<UnitMass>? = nil, vitaminC: Measurement<UnitMass>? = nil, vitaminA: Double? = nil, vitaminD: Measurement<UnitMass>? = nil, vitaminB6: Measurement<UnitMass>? = nil, vitaminB12: Measurement<UnitMass>? = nil, vitaminB12Added: Measurement<UnitMass>? = nil, vitaminE: Measurement<UnitMass>? = nil, vitaminEAdded: Measurement<UnitMass>? = nil, iodine: Measurement<UnitMass>? = nil, calcium: Measurement<UnitMass>? = nil, potassium: Measurement<UnitMass>? = nil, magnesium: Measurement<UnitMass>? = nil, phosphorus: Measurement<UnitMass>? = nil, sugarAlcohol: Measurement<UnitMass>? = nil, weight: Measurement<UnitMass> = Measurement<UnitMass>(value: 100.0, unit: .grams))

    public init(referenceNutrients: PassioNutritionAISDK.PassioNutrients, weight: Measurement<UnitMass> = Measurement<UnitMass>(value: 100.0, unit: .grams))

    public init(ingredientsData: [(PassioNutritionAISDK.PassioNutrients, Double)], weight: Measurement<UnitMass>)

    public func fat() -> Measurement<UnitMass>?

    public func calories() -> Measurement<UnitEnergy>?

    public func protein() -> Measurement<UnitMass>?

    public func carbs() -> Measurement<UnitMass>?

    public func satFat() -> Measurement<UnitMass>?

    public func monounsaturatedFat() -> Measurement<UnitMass>?

    public func polyunsaturatedFat() -> Measurement<UnitMass>?

    public func cholesterol() -> Measurement<UnitMass>?

    public func sodium() -> Measurement<UnitMass>?

    public func fibers() -> Measurement<UnitMass>?

    public func transFat() -> Measurement<UnitMass>?

    public func sugars() -> Measurement<UnitMass>?

    public func sugarsAdded() -> Measurement<UnitMass>?

    public func alcohol() -> Measurement<UnitMass>?

    public func iron() -> Measurement<UnitMass>?

    public func vitaminC() -> Measurement<UnitMass>?

    public func vitaminA() -> Double?

    public func vitaminD() -> Measurement<UnitMass>?

    public func vitaminB6() -> Measurement<UnitMass>?

    public func vitaminB12() -> Measurement<UnitMass>?

    public func vitaminB12Added() -> Measurement<UnitMass>?

    public func vitaminE() -> Measurement<UnitMass>?

    public func vitaminEAdded() -> Measurement<UnitMass>?

    public func iodine() -> Measurement<UnitMass>?

    public func calcium() -> Measurement<UnitMass>?

    public func potassium() -> Measurement<UnitMass>?

    public func magnesium() -> Measurement<UnitMass>?

    public func phosphorus() -> Measurement<UnitMass>?

    public func sugarAlcohol() -> Measurement<UnitMass>?

}

```

* To migrate from the old data structure to the new one this snippet of code will be

```swift
func attrsToFoodItem(attrs: PassioIDAttributes) -> PassioFoodItem {

    var ingredients = [PassioIngredient]()

    if let passioFoodItemData = attrs.passioFoodItemData {

        let ingredient = foodDataToIngredient(foodItemData: passioFoodItemData)

        ingredients.append(ingredient)

    } else if let passioFoodRecipe = attrs.recipe {

        let recipeIngredients = passioFoodRecipe.foodItems.map { foodDataToIngredient(foodItemData: $0) }

        ingredients.append(contentsOf: recipeIngredients)

    }

    let amount: PassioFoodAmount
    if let passioFoodItemData = attrs.passioFoodItemData {
        amount = PassioFoodAmount(servingSizes: passioFoodItemData.servingSizes,

                                  servingUnits: passioFoodItemData.servingUnits)

    } else if let passioFoodRecipe = attrs.recipe {

        amount = PassioFoodAmount(servingSizes: passioFoodRecipe.servingSizes,

                                  servingUnits: passioFoodRecipe.servingUnits)

    } else {

        fatalError("Neither passioFoodItemData nor passioFoodRecipe is present")

    }

    return PassioFoodItem(id: attrs.passioID,

                          scannedId: attrs.passioID,

                          name: attrs.name,

                          details: attrs.name,

                          iconId: attrs.passioID,

                          licenseCopy: "",

                          amount: amount,

                          ingredients: ingredients)

}

func foodDataToIngredient(foodItemData: PassioFoodItemData) -> PassioIngredient {

    let amount = PassioFoodAmount(

        servingSizes: foodItemData.servingSizes,

        servingUnits: foodItemData.servingUnits

    )

    let nutrients = PassioNutrients(

        fat: foodItemData.totalFat,

        satFat: foodItemData.totalSaturatedFat,

        monounsaturatedFat: foodItemData.totalMonounsaturatedFat,

        polyunsaturatedFat: foodItemData.totalPolyunsaturatedFat,

        proteins: foodItemData.totalProteins,

        carbs: foodItemData.totalCarbs,

        calories: foodItemData.totalCalories,

        cholesterol: foodItemData.totalCholesterol,

        sodium: foodItemData.totalSodium,

        fibers: foodItemData.totalFibers,

        transFat: foodItemData.totalTransFat,

        sugars: foodItemData.totalSugars,

        sugarsAdded: foodItemData.totalSugarsAdded,

        alcohol: foodItemData.totalAlcohol,

        iron: foodItemData.totalIron,

        vitaminC: foodItemData.totalVitaminC,

        vitaminA: foodItemData.totalVitaminA?.value,

        vitaminD: foodItemData.totalVitaminD,

        vitaminB6: foodItemData.totalVitaminB6,

        vitaminB12: foodItemData.totalVitaminB12,

        vitaminB12Added: foodItemData.totalVitaminB12Added,

        vitaminE: foodItemData.totalVitaminE,

        vitaminEAdded: foodItemData.totalVitaminEAdded,

        iodine: foodItemData.totalIodine,

        calcium: foodItemData.totalCalcium,

        potassium: foodItemData.totalPotassium,

        magnesium: foodItemData.totalMagnesium,

        phosphorus: foodItemData.totalPhosphorus,

        sugarAlcohol: foodItemData.totalSugarAlcohol

    )

    let metadata = PassioFoodMetadata(

        foodOrigins: foodItemData.foodOrigins,

        barcode: foodItemData.barcode,

        ingredientsDescription: foodItemData.ingredientsDescription,

        tags: foodItemData.tags

    )

    return PassioIngredient(id: foodItemData.passioID,
    
                            name: foodItemData.name,

                            iconId: foodItemData.passioID,

                            amount: amount,

                            referenceNutrients: nutrients,

                            metadata: metadata
                            
    )

}
```

Copyright 2024 Passio Inc
