# Passio PassioNutritionAISDK 

## Version  2.1.1
```Swift
import ARKit
import AVFoundation
import Accelerate
import Combine
import CommonCrypto
import CoreML
import CoreMedia
import CoreMotion
import Foundation
import Metal
import MetalPerformanceShaders
import SQLite3
import SwiftUI
import UIKit
import VideoToolbox
import Vision
import _Concurrency
import simd

/// Barcode (typealias String) is the string representation of the barcode id
public typealias Barcode = String

/// The BarcodeCandidate protocol returns the barcode candidate.
public protocol BarcodeCandidate {

    /// Passio ID recognized by the model
    var value: String { get }

    /// boundingBox CGRect representing the predicted bounding box in normalized coordinates.
    var boundingBox: CGRect { get }
}

/// Implement the BarcodeDetectionDelegate protocol to receive delegate methods from the object detection. Barcode detection is optional and initiated when starting Object Detection or Classification.
public protocol BarcodeDetectionDelegate : AnyObject {

    /// Called when a barcode is detected.
    /// - Parameter barcodes: Array of BarcodeCandidate
    func barcodeResult(barcodes: [PassioNutritionAISDK.BarcodeCandidate])
}

/// The ClassificationCandidate protocol returns the classification candidate result delegate.
public protocol ClassificationCandidate {

    /// PassioID recognized by the MLModel
    var passioID: PassioNutritionAISDK.PassioID { get }

    /// Confidence (0.0 to 1.0) of the associated PassioID recognized by the MLModel
    var confidence: Double { get }
}

/// The visual food candidates
public protocol DetectedCandidate {

    /// PassioID recognized by the MLModel
    var passioID: PassioNutritionAISDK.PassioID { get }

    /// Confidence (0.0 to 1.0) of the associated PassioID recognized by the MLModel
    var confidence: Double { get }

    /// boundingBox CGRect representing the predicted bounding box in normalized coordinates.
    var boundingBox: CGRect { get }

    /// The image that the detection was preformed upon
    var croppedImage: UIImage? { get }

    /// Scanned Volume in milliliters
    var scannedVolume: Double? { get }

    /// Scanned Weight in grams
    var scannedWeight: Double? { get }
}

public struct DetectedCandidateImp : PassioNutritionAISDK.DetectedCandidate {

    /// PassioID recognized by the MLModel
    public var passioID: PassioNutritionAISDK.PassioID

    /// Confidence (0.0 to 1.0) of the associated PassioID recognized by the MLModel
    public var confidence: Double

    /// boundingBox CGRect representing the predicted bounding box in normalized coordinates.
    public var boundingBox: CGRect

    /// The image that the detection was preformed upon
    public var croppedImage: UIImage?

    /// Scanned Volume in milliliters
    public var scannedVolume: Double?

    /// Scanned Weight in grams
    public var scannedWeight: Double?
}

public typealias FileLocalURL = URL

public typealias FileName = String

/// The FoodCandidates protocol returns all four potential candidates. If FoodDetectionConfiguration is not set only visual candidates will be returned.
public protocol FoodCandidates {

    /// The visual candidates returned from the recognition
    var detectedCandidates: [PassioNutritionAISDK.DetectedCandidate] { get }

    var barcodeCandidates: [PassioNutritionAISDK.BarcodeCandidate]? { get }

    var packagedFoodCandidates: [PassioNutritionAISDK.PackagedFoodCandidate]? { get }
}

/// FoodDetectionConfiguration is need to configure the food detection
public struct FoodDetectionConfiguration {

    /// Only set to false if you don't want to use the ML Models to detect food.
    public var detectVisual: Bool

    /// Select the right Volume Detection Mode
    public var volumeDetectionMode: PassioNutritionAISDK.VolumeDetectionMode

    /// Set to true for detecting barcodes
    public var detectBarcodes: Bool

    ///
    public var detectPackagedFood: Bool

    /// Detect and decipher the Nutrition Facts label
    public var detectNutritionFacts: Bool

    /// Change this if you would like to control the resolution of the image you get back in the delegate. Changing this value will not change the visula recognition results.
    public var sessionPreset: AVCaptureSession.Preset

    /// The frequency of sending images for the recognitions models. The default is set to two pre seconds. Increasing this value will require more resources from the device.
    public var framesPerSecond: PassioNutritionAISDK.PassioNutritionAI.FramesPerSecond

    public init(detectVisual: Bool = true, volumeDetectionMode: PassioNutritionAISDK.VolumeDetectionMode = .none, detectBarcodes: Bool = false, detectPackagedFood: Bool = false, nutritionFacts: Bool = false)
}

/// Implement the FoodRecognitionDelegate protocol to receive delegate methods from the FoodRecognition
public protocol FoodRecognitionDelegate : AnyObject {

    /// Delegate function for food recognition
    /// - Parameters:
    ///   - candidates: Food candidates
    ///   - image: Image used for detection
    func recognitionResults(candidates: PassioNutritionAISDK.FoodCandidates?, image: UIImage?, nutritionFacts: PassioNutritionAISDK.PassioNutritionFacts?)
}

public enum LabelForNutrient {

    case calories

    case fat

    case satFat

    case transFat

    case monounsaturatedFat

    case polyunsaturatedFat

    case cholesterol

    case sodium

    case carbs

    case fiber

    case sugarTotal

    case sugarAdded

    case protein

    case vitaminD

    case calcium

    case iron

    case potassium

    case vitaminA

    case vitaminC

    case sugarAlcohol

    case vitaminB12Added

    case vitaminB12

    case vitaminB6

    case vitaminE

    case vitaminEAdded

    case magnesium

    case phosphorus

    case iodine

    public var label: String { get }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.LabelForNutrient, b: PassioNutritionAISDK.LabelForNutrient) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher)

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { get }
}

extension LabelForNutrient : Equatable {
}

extension LabelForNutrient : Hashable {
}

/// The ObjectDetectionCandidate protocol returns the object detection result
public protocol ObjectDetectionCandidate : PassioNutritionAISDK.ClassificationCandidate {

    /// boundingBox CGRect representing the predicted bounding box in normalized coordinates.
    var boundingBox: CGRect { get }
}

public protocol PackagedFoodCandidate {

    var packagedFoodCode: PassioNutritionAISDK.PackagedFoodCode { get }

    var confidence: Double { get }
}

/// packagedFoodCode (typealias String) is the string representation of the PackagedFoodCode id
public typealias PackagedFoodCode = String

/// PassioAlternative is an alternative to a food from the Database
public struct PassioAlternative : Codable, Equatable, Hashable {

    public let passioID: PassioNutritionAISDK.PassioID

    public var name: String { get }

    public let quantity: Double?

    public let unitName: String?

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioAlternative, b: PassioNutritionAISDK.PassioAlternative) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher)

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { get }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

/// PassioConfiguration is needed configure the SDK with the following options:
public struct PassioConfiguration : Equatable {

    /// This is the key you have received from Passio. A valid key must be used.
    public var key: String

    /// If you have chosen to remove the files from the SDK and provide the SDK different URLs for this files please use this variable.
    public var filesLocalURLs: [PassioNutritionAISDK.FileLocalURL]?

    /// If you set this option to true, the SDK will download the models relevant for this version from Passio's bucket.
    public var sdkDownloadsModels: Bool

    /// If you have problems configuring the SDK, set debugMode = 1 to get more debugging information.
    public var debugMode: Int

    /// If you set allowInternetConnection = false without working with Passio the SDK will not work. The SDK will not connect to the internet for key validations, barcode data and packaged food data.
    public var allowInternetConnection: Bool

    public init(key: String)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioConfiguration, b: PassioNutritionAISDK.PassioConfiguration) -> Bool
}

/// Implement the protocol if you are setting autoUpdate = true PassioConfiguration
public protocol PassioDownloadDelegate : AnyObject {

    func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL])

    func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int)

    func downloadingError(message: String)
}

/// PassioFoodItemData contains all the information for a Food Item Data.
public struct PassioFoodItemData : Equatable, Codable {

    public var passioID: PassioNutritionAISDK.PassioID { get }

    public var name: String { get }

    public var imageName: String { get }

    public var selectedQuantity: Double { get }

    public var selectedUnit: String { get }

    public var entityType: PassioNutritionAISDK.PassioIDEntityType { get }

    public var servingUnits: [PassioNutritionAISDK.PassioServingUnit] { get }

    public var servingSizes: [PassioNutritionAISDK.PassioServingSize] { get }

    public var ingredientsDescription: String? { get }

    public var barcode: PassioNutritionAISDK.Barcode? { get }

    public var foodOrigins: [PassioNutritionAISDK.PassioFoodOrigin]? { get }

    public var isOpenFood: Bool { get }

    public var image: UIImage? { get }

    public var computedWeight: Measurement<UnitMass> { get }

    public var parents: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var parentsPassioID: [PassioNutritionAISDK.PassioID]? { get }

    public var children: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var childrenPassioID: [PassioNutritionAISDK.PassioID]? { get }

    public var siblings: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var siblingsPassioID: [PassioNutritionAISDK.PassioID]? { get }

    public var totalCalories: Double? { get }

    public var totalCarbs: Double? { get }

    public var totalFat: Double? { get }

    public var totalProteins: Double? { get }

    public var totalSaturatedFat: Double? { get }

    public var totalTransFat: Double? { get }

    public var totalMonounsaturatedFat: Double? { get }

    public var totalPolyunsaturatedFat: Double? { get }

    public var totalCholesterol: Double? { get }

    public var totalSodium: Double? { get }

    public var totalFibers: Double? { get }

    public var totalSugars: Double? { get }

    public var totalSugarsAdded: Double? { get }

    public var totalVitaminD: Double? { get }

    public var totalCalcium: Double? { get }

    public var totalIron: Double? { get }

    public var totalPotassium: Double? { get }

    public var totalVitaminA: Double? { get }

    public var totalVitaminC: Double? { get }

    public var totalAlcohol: Double? { get }

    public var totalSugarAlcohol: Double? { get }

    public var totalVitaminB12Added: Double? { get }

    public var totalVitaminB12: Double? { get }

    public var totalVitaminB6: Double? { get }

    public var totalVitaminE: Double? { get }

    public var totalVitaminEAdded: Double? { get }

    public var totalMagnesium: Double? { get }

    public var totalPhosphorus: Double? { get }

    public var totalIodine: Double? { get }

    public var summary: String { get }

    public mutating func setFoodItemDataServingSize(unit: String, quantity: Double) -> Bool

    public mutating func setServingUnitKeepWeight(unitName: String) -> Bool

    public init(upcProduct: PassioNutritionAISDK.UPCProduct)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioFoodItemData, b: PassioNutritionAISDK.PassioFoodItemData) -> Bool

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

public struct PassioFoodOrigin : Codable, Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioFoodOrigin, b: PassioNutritionAISDK.PassioFoodOrigin) -> Bool

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

/// PassioFoodRecipe contains the list of ingredient and their amounts 
public struct PassioFoodRecipe : Equatable, Codable {

    public var passioID: PassioNutritionAISDK.PassioID { get }

    public var name: String { get }

    public var imageName: String { get }

    public var servingSizes: [PassioNutritionAISDK.PassioServingSize] { get }

    public var servingUnits: [PassioNutritionAISDK.PassioServingUnit] { get }

    public var selectedUnit: String { get }

    public var selectedQuantity: Double { get }

    public var isOpenFood: Bool { get }

    public var foodItems: [PassioNutritionAISDK.PassioFoodItemData] { get }

    public var image: UIImage? { get }

    public var computedWeight: Measurement<UnitMass> { get }

    public init(passioID: PassioNutritionAISDK.PassioID, name: String, fileNameIcon: String, foodItems: [PassioNutritionAISDK.PassioFoodItemData], selectedUnit: String, selectedQuantity: Double, servingSizes: [PassioNutritionAISDK.PassioServingSize], servingUnits: [PassioNutritionAISDK.PassioServingUnit])

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioFoodRecipe, b: PassioNutritionAISDK.PassioFoodRecipe) -> Bool

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

/// PassioID (typealias String) is used throughout the SDK, food and other objects are identified by PassioID. All attributes (names, nutrition etc..) are referred by PassioID.
public typealias PassioID = String

public struct PassioIDAndName {

    public let passioID: PassioNutritionAISDK.PassioID

    public let name: String

    public init(passioID: PassioNutritionAISDK.PassioID, name: String)
}

/// PassioIDAttributes contains all the attributes for a PassioID.
public struct PassioIDAttributes : Equatable, Codable {

    public var passioID: PassioNutritionAISDK.PassioID { get }

    public var name: String { get }

    public var entityType: PassioNutritionAISDK.PassioIDEntityType { get }

    public var parents: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var children: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var siblings: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var passioFoodItemData: PassioNutritionAISDK.PassioFoodItemData? { get }

    public var imageName: String { get }

    public var recipe: PassioNutritionAISDK.PassioFoodRecipe? { get }

    public var isOpenFood: Bool { get }

    public var image: UIImage? { get }

    public init(passioID: PassioNutritionAISDK.PassioID, name: String, foodItemDataForDefault: PassioNutritionAISDK.PassioFoodItemData?, entityType: PassioNutritionAISDK.PassioIDEntityType = .barcode)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioIDAttributes, b: PassioNutritionAISDK.PassioIDAttributes) -> Bool

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

/// PassioIDEntityType is The entity Type of the PassioID Attributes.
public enum PassioIDEntityType : String, CaseIterable, Codable {

    case group

    case item

    case recipe

    case barcode

    case packagedFoodCode

    case favorite

    case nutritionFacts

    /// Creates a new instance with the specified raw value.
    ///
    /// If there is no value of the type that corresponds with the specified raw
    /// value, this initializer returns `nil`. For example:
    ///
    ///     enum PaperSize: String {
    ///         case A4, A5, Letter, Legal
    ///     }
    ///
    ///     print(PaperSize(rawValue: "Legal"))
    ///     // Prints "Optional("PaperSize.Legal")"
    ///
    ///     print(PaperSize(rawValue: "Tabloid"))
    ///     // Prints "nil"
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    public init?(rawValue: String)

    /// A type that can represent a collection of all values of this type.
    public typealias AllCases = [PassioNutritionAISDK.PassioIDEntityType]

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PassioNutritionAISDK.PassioIDEntityType] { get }

    /// The corresponding value of the raw type.
    ///
    /// A new instance initialized with `rawValue` will be equivalent to this
    /// instance. For example:
    ///
    ///     enum PaperSize: String {
    ///         case A4, A5, Letter, Legal
    ///     }
    ///
    ///     let selectedSize = PaperSize.Letter
    ///     print(selectedSize.rawValue)
    ///     // Prints "Letter"
    ///
    ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
    ///     // Prints "true"
    public var rawValue: String { get }
}

extension PassioIDEntityType : Equatable {
}

extension PassioIDEntityType : Hashable {
}

extension PassioIDEntityType : RawRepresentable {
}

/// PassioMode will report the mode the SDK is currently in.
public enum PassioMode {

    case notReady

    case isBeingConfigured

    case isDownloadingModels

    case isReadyForDetection

    case failedToConfigure

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioMode, b: PassioNutritionAISDK.PassioMode) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher)

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { get }
}

extension PassioMode : Equatable {
}

extension PassioMode : Hashable {
}

/// Passio SDK - Copyright © 2022 Passio Inc. All rights reserved.
public class PassioNutritionAI {

    /// Shared Instance
    public class var shared: PassioNutritionAISDK.PassioNutritionAI { get }

    /// Defaulted to true. If set to false to the SDK will request none-compressed files.
    public var requestCompressedFiles: Bool

    /// Get the PassioStatus directly or implement the PassioStatusDelegate for updates.
    public var status: PassioNutritionAISDK.PassioStatus { get }

    /// Delegate to track PassioStatus changes. You will get the same status via the configure function.
    weak public var statusDelegate: PassioNutritionAISDK.PassioStatusDelegate?

    /// Available frames per seconds
    public enum FramesPerSecond : Int32 {

        case one

        case two

        case three

        case four

        /// Creates a new instance with the specified raw value.
        ///
        /// If there is no value of the type that corresponds with the specified raw
        /// value, this initializer returns `nil`. For example:
        ///
        ///     enum PaperSize: String {
        ///         case A4, A5, Letter, Legal
        ///     }
        ///
        ///     print(PaperSize(rawValue: "Legal"))
        ///     // Prints "Optional("PaperSize.Legal")"
        ///
        ///     print(PaperSize(rawValue: "Tabloid"))
        ///     // Prints "nil"
        ///
        /// - Parameter rawValue: The raw value to use for the new instance.
        public init?(rawValue: Int32)

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = Int32

        /// The corresponding value of the raw type.
        ///
        /// A new instance initialized with `rawValue` will be equivalent to this
        /// instance. For example:
        ///
        ///     enum PaperSize: String {
        ///         case A4, A5, Letter, Legal
        ///     }
        ///
        ///     let selectedSize = PaperSize.Letter
        ///     print(selectedSize.rawValue)
        ///     // Prints "Letter"
        ///
        ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
        ///     // Prints "true"
        public var rawValue: Int32 { get }
    }

    /// Delegate to track the internal downloading service. If the PassioConfiguration flag sdkDownloadsModels is set to true.
    weak public var downloadDelegate: PassioNutritionAISDK.PassioDownloadDelegate?

    /// Call this API to configure the SDK
    /// - Parameters:
    ///   - PassioConfiguration: Your desired configuration, must include your developer key
    ///   - completion: Receive back the status of the SDK
    @available(iOS 13.0, *)
    public func configure(passioConfiguration: PassioNutritionAISDK.PassioConfiguration, completion: @escaping (PassioNutritionAISDK.PassioStatus) -> Void)

    /// Shut down the Passio SDK and release all resources
    public func shutDownPassioSDK()

    /// Core functionality of the PassioSDK is to detect food via pointing the camera at food
    /// - Parameters:
    ///   - detectionConfig: send FoodDetectionConfiguration() object with the configuration
    ///   - foodRecognitionDelegate: add self to implement the FoodRecognitionDelegate
    ///   - packagedFoodDelegate: add self to implement packaged food detection PackagedFoodDelegate
    ///   - completion: Listen to success or failure of the startFoodDetection.
    @available(iOS 13.0, *)
    public func startFoodDetection(detectionConfig: PassioNutritionAISDK.FoodDetectionConfiguration = FoodDetectionConfiguration(), foodRecognitionDelegate: PassioNutritionAISDK.FoodRecognitionDelegate, completion: @escaping (Bool) -> Void)

    /// Stop Food Detection to remove camera completely use public func removeVidoeLayer()
    public func stopFoodDetection()

    @available(iOS 13.0, *)
    public func detectFoodIn(image: UIImage, detectionConfig: PassioNutritionAISDK.FoodDetectionConfiguration = FoodDetectionConfiguration(), completion: @escaping (PassioNutritionAISDK.FoodCandidates?) -> Void)

    /// Detect food in an image
    /// - Parameters:
    ///   - image: Image for detection
    ///   - slicingRects: Array of rectangulares for granular detection
    ///   - completion: Array of detection [DetectedCandidate]
    @available(iOS 13.0, *)
    public func detectFoodInSlicedRects(image: UIImage, slicingRects: [CGRect]? = nil, completion: @escaping ([PassioNutritionAISDK.DetectedCandidate]) -> Void)

    /// Detect barcodes "BarcodeCandidate" in an image
    /// - Parameter image: Image for the detection
    /// - Parameter completion: Receives back Array of "BarcodeCandidate" for that image
    public func detectBarcodesIn(image: UIImage, completion: @escaping ([PassioNutritionAISDK.BarcodeCandidate]) -> Void)

    /// List all food enabled for weight estimations
    /// - Returns: List of PassioIDs
    public func listFoodEnabledForWeightEstimation() -> [PassioNutritionAISDK.PassioID]

    /// use getPreviewLayer if you don't plan to rotate the PreviewLayer.
    /// - Returns: AVCaptureVideoPreviewLayer
    public func getPreviewLayer() -> AVCaptureVideoPreviewLayer?

    /// use getPreviewLayerWithGravity if you plan to rotate the PreviewLayer.
    /// - Returns: AVCaptureVideoPreviewLayer
    public func getPreviewLayerWithGravity(sessionPreset: AVCaptureSession.Preset = .hd1920x1080, volumeDetectionMode: PassioNutritionAISDK.VolumeDetectionMode = .none, videoGravity: AVLayerVideoGravity = .resizeAspectFill) -> AVCaptureVideoPreviewLayer?

    /// Don't call this function if you need to use the Passio layer again. Only call this function to set the PassioSDK Preview layer to nil
    public func removeVidoeLayer()

    /// Use this function to get the bounding box relative to the previewLayerBonds
    /// - Parameter boundingBox: The bounding box from the delegate
    /// - Parameter preview: The preview layer bounding box
    public func transformCGRectForm(boundingBox: CGRect, toPreviewLayerRect preview: CGRect) -> CGRect

    /// Use this call to add personalizedAlternative to a Passio ID
    /// - Parameter personalizedAlternative:
    public func addToPersonalization(personalizedAlternative: PassioNutritionAISDK.PersonalizedAlternative)

    /// Lookup Personalized Alternative For PassioID
    /// - Parameter passioID: PassioID
    /// - Returns: PersonalizedAlternative
    public func lookupPersonalizedAlternativeFor(passioID: PassioNutritionAISDK.PassioID) -> PassioNutritionAISDK.PersonalizedAlternative?

    /// Clean records for one PassioID
    /// - Parameter passioID: PassioID
    public func cleanPersonalizationForVisual(passioID: PassioNutritionAISDK.PassioID)

    /// Clean all records
    public func cleanAllPersonalization()

    /// Lookup PassioIDAttributes from PassioID
    /// - Parameter passioID: PassioID
    /// - Returns: PassioIDAttributes
    public func lookupPassioIDAttributesFor(passioID: PassioNutritionAISDK.PassioID) -> PassioNutritionAISDK.PassioIDAttributes?

    /// Lookup an icon by its name
    /// - Parameter imageName: the name of the image.
    public func lookupImageBy(imageName: String) -> UIImage?

    /// Lookup Name For PassioID
    /// - Parameter passioID: PassioID
    /// - Returns: Name : String?
    public func lookupNameForPassioID(passioID: PassioNutritionAISDK.PassioID) -> String?

    /// Search for food will return a list of potential food items ordered and optimized for user selection.
    /// - Parameter byText: User typed in key words
    /// - Returns: All potential PassioIDAndName.
    public func searchForFood(byText: String) -> [PassioNutritionAISDK.PassioIDAndName]

    /// Fetch from Passio web-service the PassioIDAttributes for a barcode by its number
    /// - Parameter barcode: Barcode number
    /// - Parameter completion: Receive a closure with optional PassioIDAttributes
    public func fetchPassioIDAttributesFor(barcode: PassioNutritionAISDK.Barcode, completion: @escaping ((PassioNutritionAISDK.PassioIDAttributes?) -> Void))

    /// Fetch from Passio web-service the PassioIDAttributes for a packagedFoodCode by its number
    /// - Parameters:
    ///   - packagedFoodCode: packagedFoodCode
    ///   - completion: Receive a closure with optional PassioIDAttributes
    public func fetchPassioIDAttributesFor(packagedFoodCode: PassioNutritionAISDK.PackagedFoodCode, completion: @escaping ((PassioNutritionAISDK.PassioIDAttributes?) -> Void))

    /// lookupAllDescendantsFor PassioID
    /// - Parameter passioID: PassioID
    /// - Returns: PassioID Array of all Descendants
    public func lookupAllDescendantsFor(passioID: PassioNutritionAISDK.PassioID) -> [PassioNutritionAISDK.PassioID]

    /// Return a sorted list of available Volume Detections mode.
    /// Recommended mode is .auto
    public var availableVolumeDetectionModes: [PassioNutritionAISDK.VolumeDetectionMode] { get }

    /// Return the best Volume detection Mode for this iPhone
    public var bestVolumeDetectionMode: PassioNutritionAISDK.VolumeDetectionMode { get }
}

extension PassioNutritionAI : PassioNutritionAISDK.PassioDownloadDelegate {

    public func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL])

    public func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int)

    public func downloadingError(message: String)
}

extension PassioNutritionAI : PassioNutritionAISDK.PassioStatusDelegate {

    public func passioSDKChanged(status: PassioNutritionAISDK.PassioStatus)
}

extension PassioNutritionAI.FramesPerSecond : Equatable {
}

extension PassioNutritionAI.FramesPerSecond : Hashable {
}

extension PassioNutritionAI.FramesPerSecond : RawRepresentable {
}

/// This object will decipher the Nutrition Facts table on packaged food
public class PassioNutritionFacts {

    public init()

    public enum ServingSizeUnit : String {

        case g

        case ml

        /// Creates a new instance with the specified raw value.
        ///
        /// If there is no value of the type that corresponds with the specified raw
        /// value, this initializer returns `nil`. For example:
        ///
        ///     enum PaperSize: String {
        ///         case A4, A5, Letter, Legal
        ///     }
        ///
        ///     print(PaperSize(rawValue: "Legal"))
        ///     // Prints "Optional("PaperSize.Legal")"
        ///
        ///     print(PaperSize(rawValue: "Tabloid"))
        ///     // Prints "nil"
        ///
        /// - Parameter rawValue: The raw value to use for the new instance.
        public init?(rawValue: String)

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = String

        /// The corresponding value of the raw type.
        ///
        /// A new instance initialized with `rawValue` will be equivalent to this
        /// instance. For example:
        ///
        ///     enum PaperSize: String {
        ///         case A4, A5, Letter, Legal
        ///     }
        ///
        ///     let selectedSize = PaperSize.Letter
        ///     print(selectedSize.rawValue)
        ///     // Prints "Letter"
        ///
        ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
        ///     // Prints "true"
        public var rawValue: String { get }
    }

    public var foundNutritionFactsLabel: Bool { get }

    final public let titleNutritionFacts: String

    final public let titleServingSize: String

    final public let titleCalories: String

    final public let titleTotalFat: String

    final public let titleTotalCarbs: String

    final public let titleProtein: String

    public var servingSizeQuantity: Int

    public var servingSizeUnitName: String?

    public var servingSizeGram: Double?

    public var servingSizeUnit: PassioNutritionAISDK.PassioNutritionFacts.ServingSizeUnit

    public var calories: Double?

    public var fat: Double?

    public var carbs: Double?

    public var protein: Double?

    public var isManuallyEdited: Bool

    public var servingSizeText: String { get }

    public var caloriesText: String { get }

    public var fatText: String { get }

    public var carbsText: String { get }

    public var proteinText: String { get }

    public var isCompleted: Bool { get }

    public var description: String { get }

    public func clearAll()
}

extension PassioNutritionFacts {

    public func createPassioIDAttributes(foodName: String) -> PassioNutritionAISDK.PassioIDAttributes
}

extension PassioNutritionFacts.ServingSizeUnit : Equatable {
}

extension PassioNutritionFacts.ServingSizeUnit : Hashable {
}

extension PassioNutritionFacts.ServingSizeUnit : RawRepresentable {
}

/// PassioSDKError will return the error with errorDescription if the configuration has failed. 
public enum PassioSDKError : LocalizedError {

    case canNotRunOnSimulator

    case keyNotValid

    case licensedKeyHasExpired

    case modelsNotValid

    case autoUpdateFailed

    case noModelsFilesFound

    case noInterenetConnection

    case notLicensedForThisProject

    /// A localized message describing what error occurred.
    public var errorDescription: String? { get }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioSDKError, b: PassioNutritionAISDK.PassioSDKError) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher)

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { get }
}

extension PassioSDKError : Equatable {
}

extension PassioSDKError : Hashable {
}

/// PassioServingSize for food Item Data
public struct PassioServingSize : Codable, Equatable, Hashable {

    public let quantity: Double

    public let unitName: String

    public init(quantity: Double, unitName: String)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioServingSize, b: PassioNutritionAISDK.PassioServingSize) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher)

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { get }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

/// PassioServingUnit for food Item Data
public struct PassioServingUnit : Equatable, Codable {

    public let unitName: String

    public let weight: Measurement<UnitMass>

    public init(unitName: String, weight: Measurement<UnitMass>)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioServingUnit, b: PassioNutritionAISDK.PassioServingUnit) -> Bool

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

/// PassioStatus is returned at the end of the configuration of the SDK.
public struct PassioStatus {

    /// The mode had several values . isReadyForDetection is full success
    public var mode: PassioNutritionAISDK.PassioMode { get }

    /// If the SDK is missing files or new files could be used. It will send the list of files needed for the update.
    public var missingFiles: [PassioNutritionAISDK.FileName]? { get }

    /// A string with more verbose information related to the configuration of the SDK
    public var debugMessage: String? { get }

    /// The error in case the SDK failed to configure
    public var error: PassioNutritionAISDK.PassioSDKError? { get }

    /// The version of the latest models that are now used by the SDK.
    public var activeModels: Int? { get }
}

/// Implement the protocol to receive status updates
public protocol PassioStatusDelegate : AnyObject {

    func passioSDKChanged(status: PassioNutritionAISDK.PassioStatus)
}

public struct PersonalizedAlternative : Codable, Equatable {

    public let visualPassioID: PassioNutritionAISDK.PassioID

    public let nutritionalPassioID: PassioNutritionAISDK.PassioID

    public var servingUnit: String?

    public var servingSize: Double?

    public init(visualPassioID: PassioNutritionAISDK.PassioID, nutritionalPassioID: PassioNutritionAISDK.PassioID, servingUnit: String?, servingSize: Double?)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PersonalizedAlternative, b: PassioNutritionAISDK.PersonalizedAlternative) -> Bool

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

/// UPC Product decoding struct
public struct UPCProduct : Codable {

    public let id: String

    public let name: String

    public let nutrients: [PassioNutritionAISDK.UPCProduct.NutrientUPC]?

    public let branded: PassioNutritionAISDK.UPCProduct.Branded?

    public let origin: [PassioNutritionAISDK.UPCProduct.Origin]?

    public let portions: [PassioNutritionAISDK.UPCProduct.Portion]?

    public let qualityScore: String?

    public let licenseCopy: String?

    /// Component of UPC Product decoding struct
    public struct NutrientUPC : Codable {

        public let nutrient: PassioNutritionAISDK.UPCProduct.InternalNutrient?

        public let amount: Double?

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws
    }

    /// Component of UPC Product decoding struct
    public struct InternalNutrient : Codable {

        public let id: Double?

        public let name: String?

        public let unit: String?

        public let shortName: String?

        public let value: String?

        public let origin: [PassioNutritionAISDK.UPCProduct.Origin]?

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws
    }

    /// Component of UPC Product decoding struct
    public struct Branded : Codable {

        public let owner: String?

        public let upc: String?

        public let productCode: String?

        public let ingredients: String?

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws
    }

    /// Component of UPC Product decoding struct
    public struct Origin : Codable {

        public let source: String?

        public let id: String?

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws
    }

    /// Component of UPC Product decoding struct
    public struct Portion : Codable {

        public let weight: PassioNutritionAISDK.UPCProduct.Weight?

        public let name: String?

        public let quantity: Double?

        public let suggestedQuantity: [Double]?

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws
    }

    /// Component of UPC Product decoding struct
    public struct Weight : Codable {

        public let unit: String?

        public let value: Double?

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws
    }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws
}

/// VolumeDetectionMode for detection volume.
public enum VolumeDetectionMode : String {

    /// Using best technology available in this order dualWideCamera, dualCamera or none if the device is not capable of detection volume.
    case auto

    /// If dualWideCamera is not available the mode will not fall back to dualCamera
    case dualWideCamera

    case none

    /// Creates a new instance with the specified raw value.
    ///
    /// If there is no value of the type that corresponds with the specified raw
    /// value, this initializer returns `nil`. For example:
    ///
    ///     enum PaperSize: String {
    ///         case A4, A5, Letter, Legal
    ///     }
    ///
    ///     print(PaperSize(rawValue: "Legal"))
    ///     // Prints "Optional("PaperSize.Legal")"
    ///
    ///     print(PaperSize(rawValue: "Tabloid"))
    ///     // Prints "nil"
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    public init?(rawValue: String)

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// The corresponding value of the raw type.
    ///
    /// A new instance initialized with `rawValue` will be equivalent to this
    /// instance. For example:
    ///
    ///     enum PaperSize: String {
    ///         case A4, A5, Letter, Legal
    ///     }
    ///
    ///     let selectedSize = PaperSize.Letter
    ///     print(selectedSize.rawValue)
    ///     // Prints "Letter"
    ///
    ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
    ///     // Prints "true"
    public var rawValue: String { get }
}

extension VolumeDetectionMode : Equatable {
}

extension VolumeDetectionMode : Hashable {
}

extension VolumeDetectionMode : RawRepresentable {
}

extension simd_float4x4 : ContiguousBytes {

    /// Calls the given closure with the contents of underlying storage.
    ///
    /// - note: Calling `withUnsafeBytes` multiple times does not guarantee that
    ///         the same buffer pointer will be passed in every time.
    /// - warning: The buffer argument to the body should not be stored or used
    ///            outside of the lifetime of the call to the closure.
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}



```
<sup>Copyright 2021 Passio Inc</sup>
