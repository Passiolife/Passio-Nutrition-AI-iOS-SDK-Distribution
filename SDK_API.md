# Passio PassioNutritionAISDK 

## Version 3.1.0
```Swift

import AVFoundation
import Accelerate
import CommonCrypto
import CoreML
import CoreMedia
import CoreMotion
import DeveloperToolsSupport
import Foundation
import MLCompute
import Metal
import MetalPerformanceShaders
import SQLite3
import SwiftUI
import UIKit
import VideoToolbox
import Vision
import _Concurrency
import _StringProcessing
import _SwiftConcurrencyShims
import simd

/// Returning all information of Amount estimation and directions how to move the device for better estimation
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

public struct ArchitectureStructure : Codable {

    public let modelName: String?

    public let modelId: String?

    public let datasetId: String?

    public let trainingRunId: String?

    public let filename: PassioNutritionAISDK.FileName?

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

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
    func barcodeResult(barcodes: [any PassioNutritionAISDK.BarcodeCandidate])
}

public struct Branded : Codable {

    public let owner: String?

    public let productCode: String?

    public let ingredients: String?

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws
}

public enum Bridge : String {

    case none

    case flutter

    case reactNative

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

extension Bridge : Equatable {
}

extension Bridge : Hashable {
}

extension Bridge : RawRepresentable {
}

public enum CapturingDeviceType : CaseIterable {

    case builtInWideAngleCamera

    case builtInTelephotoCamera

    case builtInUltraWideCamera

    case builtInDualCamera

    case builtInDualWideCamera

    case builtInTripleCamera

    public static func supportedDeviceTypes() -> [PassioNutritionAISDK.CapturingDeviceType]

    public static func defaultCapturing() -> PassioNutritionAISDK.CapturingDeviceType

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.CapturingDeviceType, b: PassioNutritionAISDK.CapturingDeviceType) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: In your implementation of `hash(into:)`,
    ///   don't call `finalize()` on the `hasher` instance provided,
    ///   or replace it with a different instance.
    ///   Doing so may become a compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher)

    /// A type that can represent a collection of all values of this type.
    public typealias AllCases = [PassioNutritionAISDK.CapturingDeviceType]

    /// A collection of all values of this type.
    public static var allCases: [PassioNutritionAISDK.CapturingDeviceType] { get }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }
}

extension CapturingDeviceType : Equatable {
}

extension CapturingDeviceType : Hashable {
}

public struct Child : Codable {

    public let labelname: String?

    public let displayName: String?

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

/// The ClassificationCandidate protocol returns the classification candidate result delegate.
public protocol ClassificationCandidate {

    var name: String { get }

    /// PassioID recognized by the MLModel
    var passioID: PassioNutritionAISDK.PassioID { get }

    /// Confidence (0.0 to 1.0) of the associated PassioID recognized by the MLModel
    var confidence: Double { get }

    var alternatives: [any PassioNutritionAISDK.DetectedCandidate] { get }

    /// Mapping ID is mapped ID for personalisation
    var mappingID: PassioNutritionAISDK.PassioID { get set }
}

/// The visual food candidates
public protocol DetectedCandidate {

    var name: String { get }

    /// PassioID recognized by the MLModel
    var passioID: PassioNutritionAISDK.PassioID { get }

    /// Confidence (0.0 to 1.0) of the associated PassioID recognized by the MLModel
    var confidence: Double { get }

    /// boundingBox CGRect representing the predicted bounding box in normalized coordinates.
    var boundingBox: CGRect { get }

    /// The image that the detection was preformed upon
    var croppedImage: UIImage? { get }

    /// Scanned AmountEstimate
    var amountEstimate: (any PassioNutritionAISDK.AmountEstimate)? { get }

    var alternatives: [any PassioNutritionAISDK.DetectedCandidate] { get }

    var mappingID: PassioNutritionAISDK.PassioID { get set }
}

public struct EnsembleArchitecture : Codable {

    public let name: String

    public let structure: [PassioNutritionAISDK.ArchitectureStructure]

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public enum EstimationQuality : String {

    case good

    case fair

    case poor

    case noEstimation

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

extension EstimationQuality : Equatable {
}

extension EstimationQuality : Hashable {
}

extension EstimationQuality : RawRepresentable {
}

public typealias FileLocalURL = URL

public typealias FileName = String

/// The FoodCandidates protocol returns all four potential candidates. If FoodDetectionConfiguration is not set only visual candidates will be returned.
public protocol FoodCandidates {

    /// The visual candidates returned from the recognition
    var detectedCandidates: [any PassioNutritionAISDK.DetectedCandidate] { get }

    /// The Barcode candidates if available
    var barcodeCandidates: [any PassioNutritionAISDK.BarcodeCandidate]? { get }

    /// The packaged food candidates if available
    var packagedFoodCandidates: [any PassioNutritionAISDK.PackagedFoodCandidate]? { get }

    /// Use stability larger than one, only relevant when using Volume. 
    var deviceStability: Double? { get }
}

/// The FoodCandidates protocol returns all four potential candidates. If FoodDetectionConfiguration is not set only visual candidates will be returned.
public protocol FoodCandidatesWithText : PassioNutritionAISDK.FoodCandidates {

    var observations: [VNRecognizedTextObservation]? { get }
}

/// FoodDetectionConfiguration is need to configure the food detection
public struct FoodDetectionConfiguration {

    /// Only set to false if you don't want to use the ML Models to detect food.
    public var detectVisual: Bool

    /// Select the right Volume Detection Mode
    public var volumeDetectionMode: PassioNutritionAISDK.VolumeDetectionMode

    /// Set to true for detecting barcodes
    public var detectBarcodes: Bool

    /// Set to true for detecting Packaged Food
    public var detectPackagedFood: Bool

    /// Change this if you would like to control the resolution of the image you get back in the delegate. Changing this value will not change the visual recognition results.
    public var sessionPreset: AVCaptureSession.Preset

    /// The frequency of sending images for the recognitions models. The default is set to two pre seconds. Increasing this value will require more resources from the device.
    public var framesPerSecond: PassioNutritionAISDK.PassioNutritionAI.FramesPerSecond

    public init(detectVisual: Bool = true, volumeDetectionMode: PassioNutritionAISDK.VolumeDetectionMode = .none, detectBarcodes: Bool = false, detectPackagedFood: Bool = false)
}

/// Implement the FoodRecognitionDelegate protocol to receive delegate method from the FoodRecognition
public protocol FoodRecognitionDelegate : AnyObject {

    /// Delegate function for food recognition
    /// - Parameters:
    ///   - candidates: Food candidates
    ///   - image: Image used for detection
    func recognitionResults(candidates: (any PassioNutritionAISDK.FoodCandidates)?, image: UIImage?)
}

public protocol FoodRecognitionWithTextObservations : AnyObject {

    func recognitionResults(candidates: (any PassioNutritionAISDK.FoodCandidates)?, image: UIImage?, nutritionFacts: PassioNutritionAISDK.PassioNutritionFacts?, observations: [VNRecognizedTextObservation])
}

public enum IconSize : String {

    case px90

    case px180

    case px360

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

extension IconSize : Equatable {
}

extension IconSize : Hashable {
}

extension IconSize : RawRepresentable {
}

/// InflammatoryEffectData for nutrients data
public struct InflammatoryEffectData : Codable {

    public let name: String

    public let amount: Double

    public let unit: String

    public let inflammatoryEffectScore: Double

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct LabelMetaData : Codable {

    public let displayName: String?

    public let synonyms: [String : [PassioNutritionAISDK.SynonymLang]]?

    public let models: [String]?

    public let labelId: String

    public let description: String?

    public var modelName: String? { get }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct LabelName : Codable {

    public let labelname: String?

    public let displayName: String?

    public let overrideName: String?

    public let children: [PassioNutritionAISDK.Child]?

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct MeasurementIU {

    public var value: Double

    public let unit: String
}

public enum MoveDirection : String {

    case away

    case ok

    case up

    case down

    case around

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

extension MoveDirection : Equatable {
}

extension MoveDirection : Hashable {
}

extension MoveDirection : RawRepresentable {
}

public struct NAMessage : Codable {

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public enum NetworkError : Error {

    case decode

    case invalidURL

    case noResponse

    case unauthorized

    case badRequest

    case unexpectedStatusCode

    case serverError

    case custom(String)
}

/// Passio SDK - Copyright © 2024 Passio Inc. All rights reserved.
public class NutritionAdvisor {

    /// Shared Instance
    public class var shared: PassioNutritionAISDK.NutritionAdvisor { get }

    /// Use this method to configure Nutrition Advisor
    /// - Parameters:
    ///   - licenceKey: Licence Key for configuration
    ///   - completion: NutritionAdvisorResult with sucess or error message
    public func configure(licenceKey: String, completion: @escaping PassioNutritionAISDK.NutritionAdvisorStatus)

    /// Initiate converstion with Nutrition Advisor
    /// - Parameters:
    ///   - completion: NutritionAdvisorResult with sucess or error message
    public func initConversation(completion: @escaping PassioNutritionAISDK.NutritionAdvisorStatus)

    /// Use this method to send message to Nutrition Advisor
    /// - Parameters:
    ///   - message: Message you want to send
    ///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive PassioAdvisorResponse containing food information.
    public func sendMessage(message: String, completion: @escaping PassioNutritionAISDK.NutritionAdvisorResponse)

    /// Use this method to send image to Nutrition Advisor
    /// - Parameters:
    ///   - image: UIImage you want to send
    ///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive PassioAdvisorResponse containing food information.
    public func sendImage(image: UIImage, completion: @escaping PassioNutritionAISDK.NutritionAdvisorResponse)

    /// Use this method to fetch ingredients
    /// - Parameters:
    ///   - advisorResponse: Pass PassioAdvisorResponse
    ///   - completion: NutritionAdvisor responds with a success or error response. If the response is successful, you will receive PassioAdvisorResponse containing food information.
    public func fetchIngridients(from advisorResponse: PassioNutritionAISDK.PassioAdvisorResponse, completion: @escaping PassioNutritionAISDK.NutritionAdvisorResponse)
}

public typealias NutritionAdvisorResponse = (Result<PassioNutritionAISDK.PassioAdvisorResponse, PassioNutritionAISDK.NetworkError>) -> Void

public typealias NutritionAdvisorStatus = (Result<Bool, PassioNutritionAISDK.NetworkError>) -> Void

/// Implement the NutritionFactsDelegate protocol to receive delegate method from the Nutrition Facts
public protocol NutritionFactsDelegate : AnyObject {

    /// Delegate function for nutrition facts
    /// - Parameters:
    ///   - nutritionFacts: Nutrition Facts
    ///   - text: OCR text
    func recognitionResults(nutritionFacts: PassioNutritionAISDK.PassioNutritionFacts?, text: String?)
}

public struct NutritionPreviewResult : Codable {

    public let portion: PassioNutritionAISDK.Portion?

    public let calories: Double?

    public let carbs: Double?

    public let fat: Double?

    public let protein: Double?

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws
}

/// The ObjectDetectionCandidate protocol returns the object detection result
public protocol ObjectDetectionCandidate : PassioNutritionAISDK.ClassificationCandidate {

    /// boundingBox CGRect representing the predicted bounding box in normalized coordinates.
    var boundingBox: CGRect { get }
}

public struct Origin : Codable {

    public let source: String

    public let id: String

    public let dataType: String?

    public let timestamp: String?

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws
}

public protocol PackagedFoodCandidate {

    var packagedFoodCode: PassioNutritionAISDK.PackagedFoodCode { get }

    var confidence: Double { get }
}

/// packagedFoodCode (typealias String) is the string representation of the PackagedFoodCode id
public typealias PackagedFoodCode = String

public struct PassioAdvisorFoodInfo : Codable {

    public let recogniseName: String

    public let portionSize: String

    public let weightGrams: Double

    public let foodDataInfo: PassioNutritionAISDK.PassioFoodDataInfo

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct PassioAdvisorResponse : Codable {

    public var messageId: String?

    public var markupContent: String?

    public var rawContent: String?

    public var tools: [String]?

    public var extractedIngridients: [PassioNutritionAISDK.PassioAdvisorFoodInfo]?

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

/// PassioAlternative is an alternative to a food from the Database
public struct PassioAlternative : Codable, Equatable, Hashable {

    public var passioID: PassioNutritionAISDK.PassioID

    public var name: String

    public var quantity: Double?

    public var unitName: String?

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
    /// - Important: In your implementation of `hash(into:)`,
    ///   don't call `finalize()` on the `hasher` instance provided,
    ///   or replace it with a different instance.
    ///   Doing so may become a compile-time error in the future.
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
    public func encode(to encoder: any Encoder) throws

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
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

    /// If you are bridging the SDK via ReactNative or Flutter, please set accordingly.
    public var bridge: PassioNutritionAISDK.Bridge

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

public struct PassioFoodAmount : Codable {

    public let servingSizes: [PassioNutritionAISDK.PassioServingSize]

    public let servingUnits: [PassioNutritionAISDK.PassioServingUnit]

    public let selectedUnit: String

    public let selectedQuantity: Double

    public static let SERVING_UNIT_NAME: String

    public init(servingSizes: [PassioNutritionAISDK.PassioServingSize], servingUnits: [PassioNutritionAISDK.PassioServingUnit])

    public func weight() -> Measurement<UnitMass>

    public func weightGrams() -> Double

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct PassioFoodDataInfo : Codable {

    public let brandName: String

    public let foodName: String

    public let iconID: PassioNutritionAISDK.PassioID

    public let labelId: String

    public let resultId: String

    public let score: Double

    public let scoredName: String

    public let type: String

    public let nutritionPreview: PassioNutritionAISDK.PassioSearchNutritionPreview?

    public let isShortName: Bool

    public init(foodName: String, brandName: String, iconID: PassioNutritionAISDK.PassioID, score: Double, scoredName: String, labelId: String, type: String, resultId: String, nutritionPreview: PassioNutritionAISDK.PassioSearchNutritionPreview?, isShortName: Bool)

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct PassioFoodItem : Codable {

    public let id: String

    public let scannedId: PassioNutritionAISDK.PassioID

    public let name: String

    public let details: String

    public let iconId: String

    public let licenseCopy: String

    public let amount: PassioNutritionAISDK.PassioFoodAmount

    public let ingredients: [PassioNutritionAISDK.PassioIngredient]

    public let refCode: String?

    public var foodItemName: String { get }

    public func nutrients(weight: Measurement<UnitMass>) -> PassioNutritionAISDK.PassioNutrients

    public func nutrientsSelectedSize() -> PassioNutritionAISDK.PassioNutrients

    public func nutrientsReference() -> PassioNutritionAISDK.PassioNutrients

    public func weight() -> Measurement<UnitMass>

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

/// PassioFoodItemData contains all the information for a Food Item Data.
public struct PassioFoodItemData : Equatable, Codable {

    public var passioID: PassioNutritionAISDK.PassioID { get }

    public var name: String

    public var tags: [String]? { get }

    public var selectedQuantity: Double { get }

    public var selectedUnit: String { get }

    public var entityType: PassioNutritionAISDK.PassioIDEntityType { get }

    public var servingUnits: [PassioNutritionAISDK.PassioServingUnit] { get }

    public var servingSizes: [PassioNutritionAISDK.PassioServingSize] { get }

    public var ingredientsDescription: String? { get }

    public var barcode: PassioNutritionAISDK.Barcode? { get }

    public var foodOrigins: [PassioNutritionAISDK.PassioFoodOrigin]? { get }

    public var isOpenFood: Bool { get }

    public var confusionAlternatives: [PassioNutritionAISDK.PassioID]? { get }

    public var invisibleIngredients: [PassioNutritionAISDK.PassioID]? { get }

    public var computedWeight: Measurement<UnitMass> { get }

    public var parents: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var parentsPassioID: [PassioNutritionAISDK.PassioID]? { get }

    public var children: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var childrenPassioID: [PassioNutritionAISDK.PassioID]? { get }

    public var siblings: [PassioNutritionAISDK.PassioAlternative]? { get }

    public var siblingsPassioID: [PassioNutritionAISDK.PassioID]? { get }

    public var totalCalories: Measurement<UnitEnergy>? { get }

    public var totalCarbs: Measurement<UnitMass>? { get }

    public var totalFat: Measurement<UnitMass>? { get }

    public var totalProteins: Measurement<UnitMass>? { get }

    public var totalSaturatedFat: Measurement<UnitMass>? { get }

    public var totalTransFat: Measurement<UnitMass>? { get }

    public var totalMonounsaturatedFat: Measurement<UnitMass>? { get }

    public var totalPolyunsaturatedFat: Measurement<UnitMass>? { get }

    public var totalCholesterol: Measurement<UnitMass>? { get }

    public var totalSodium: Measurement<UnitMass>? { get }

    public var totalFibers: Measurement<UnitMass>? { get }

    public var totalSugars: Measurement<UnitMass>? { get }

    public var totalSugarsAdded: Measurement<UnitMass>? { get }

    public var totalVitaminD: Measurement<UnitMass>? { get }

    public var totalCalcium: Measurement<UnitMass>? { get }

    public var totalIron: Measurement<UnitMass>? { get }

    public var totalPotassium: Measurement<UnitMass>? { get }

    public var totalVitaminA: PassioNutritionAISDK.MeasurementIU? { get }

    public var totalVitaminC: Measurement<UnitMass>? { get }

    public var totalAlcohol: Measurement<UnitMass>? { get }

    public var totalSugarAlcohol: Measurement<UnitMass>? { get }

    public var totalVitaminB12Added: Measurement<UnitMass>? { get }

    public var totalVitaminB12: Measurement<UnitMass>? { get }

    public var totalVitaminB6: Measurement<UnitMass>? { get }

    public var totalVitaminE: Measurement<UnitMass>? { get }

    public var totalVitaminEAdded: Measurement<UnitMass>? { get }

    public var totalMagnesium: Measurement<UnitMass>? { get }

    public var totalPhosphorus: Measurement<UnitMass>? { get }

    public var totalIodine: Measurement<UnitMass>? { get }

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
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public enum PassioFoodItemDataError : LocalizedError {

    case noValidPortion

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
    public static func == (a: PassioNutritionAISDK.PassioFoodItemDataError, b: PassioNutritionAISDK.PassioFoodItemDataError) -> Bool

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: In your implementation of `hash(into:)`,
    ///   don't call `finalize()` on the `hasher` instance provided,
    ///   or replace it with a different instance.
    ///   Doing so may become a compile-time error in the future.
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
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }
}

extension PassioFoodItemDataError : Equatable {
}

extension PassioFoodItemDataError : Hashable {
}

public struct PassioFoodMetadata : Codable {

    public var foodOrigins: [PassioNutritionAISDK.PassioFoodOrigin]?

    public var barcode: PassioNutritionAISDK.Barcode?

    public var ingredientsDescription: String?

    public var tags: [String]?

    public init(foodOrigins: [PassioNutritionAISDK.PassioFoodOrigin]? = nil, barcode: PassioNutritionAISDK.Barcode? = nil, ingredientsDescription: String? = nil, tags: [String]? = nil)

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct PassioFoodOrigin : Codable, Equatable {

    public let id: String

    public let source: String

    public var licenseCopy: String?

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
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

/// PassioFoodRecipe contains the list of ingredient and their amounts 
public struct PassioFoodRecipe : Equatable, Codable {

    public var passioID: PassioNutritionAISDK.PassioID { get }

    public var name: String { get }

    public var servingSizes: [PassioNutritionAISDK.PassioServingSize] { get }

    public var servingUnits: [PassioNutritionAISDK.PassioServingUnit] { get }

    public var selectedUnit: String { get }

    public var selectedQuantity: Double { get }

    public var isOpenFood: Bool { get }

    public var foodItems: [PassioNutritionAISDK.PassioFoodItemData] { get }

    public var computedWeight: Measurement<UnitMass> { get }

    public init(passioID: PassioNutritionAISDK.PassioID, name: String, foodItems: [PassioNutritionAISDK.PassioFoodItemData], selectedUnit: String, selectedQuantity: Double, servingSizes: [PassioNutritionAISDK.PassioServingSize], servingUnits: [PassioNutritionAISDK.PassioServingUnit])

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
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

/// PassioID (typealias String) is used throughout the SDK, food and other objects are identified by PassioID. All attributes (names, nutrition etc..) are referred by PassioID.
public typealias PassioID = String

public struct PassioIDAndName : Codable {

    public let passioID: PassioNutritionAISDK.PassioID

    public let name: String

    public init(passioID: PassioNutritionAISDK.PassioID, name: String)

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
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

    public var recipe: PassioNutritionAISDK.PassioFoodRecipe? { get }

    public var isOpenFood: Bool { get }

    public var confusionAlternatives: [PassioNutritionAISDK.PassioID]? { get }

    public var invisibleIngredients: [PassioNutritionAISDK.PassioID]? { get }

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
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
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

public struct PassioIngredient : Codable {

    public let id: String

    public let name: String

    public let iconId: String

    public let amount: PassioNutritionAISDK.PassioFoodAmount

    public let referenceNutrients: PassioNutritionAISDK.PassioNutrients

    public let metadata: PassioNutritionAISDK.PassioFoodMetadata

    public let refCode: String?

    public init(id: String, name: String, iconId: String, amount: PassioNutritionAISDK.PassioFoodAmount, referenceNutrients: PassioNutritionAISDK.PassioNutrients, metadata: PassioNutritionAISDK.PassioFoodMetadata, refCode: String?)

    public func nutrients(weight: Measurement<UnitMass>) -> PassioNutritionAISDK.PassioNutrients

    public func weight() -> Measurement<UnitMass>

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public enum PassioLogAction : String, Codable, CaseIterable {

    case add

    case remove

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

    /// A type that can represent a collection of all values of this type.
    public typealias AllCases = [PassioNutritionAISDK.PassioLogAction]

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PassioNutritionAISDK.PassioLogAction] { get }

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

extension PassioLogAction : Equatable {
}

extension PassioLogAction : Hashable {
}

extension PassioLogAction : RawRepresentable {
}

public struct PassioMealPlan : Codable, Equatable {

    public var mealPlanLabel: String?

    public var mealPlanTitle: String?

    public var carbsTarget: Int? { get }

    public var proteinTarget: Int? { get }

    public var fatTarget: Int? { get }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioMealPlan, b: PassioNutritionAISDK.PassioMealPlan) -> Bool

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct PassioMealPlanItem {

    public var dayNumber: Int?

    public var dayTitle: String?

    public var mealTime: PassioNutritionAISDK.PassioMealTime?

    public var meal: PassioNutritionAISDK.PassioFoodDataInfo?
}

public enum PassioMealTime : String, Codable {

    case breakfast

    case lunch

    case dinner

    case snack

    public static func currentMealTime() -> PassioNutritionAISDK.PassioMealTime

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

extension PassioMealTime : Equatable {
}

extension PassioMealTime : Hashable {
}

extension PassioMealTime : RawRepresentable {
}

public struct PassioMetadata : Codable {

    public var labelMetadata: [PassioNutritionAISDK.PassioID : PassioNutritionAISDK.LabelMetaData]? { get }

    public let architecture: PassioNutritionAISDK.EnsembleArchitecture?

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public class PassioMetadataService {

    public var passioMetadata: PassioNutritionAISDK.PassioMetadata? { get }

    public var getModelNames: [String]? { get }

    public var getlabelIcons: [PassioNutritionAISDK.PassioID : PassioNutritionAISDK.PassioID]? { get }

    public func getPassioIDs(byModelName: String) -> [PassioNutritionAISDK.PassioID]?

    public func getLabel(passioID: PassioNutritionAISDK.PassioID, languageCode: String = "en") -> String?

    public init(metatadataURL: URL? = nil)
}

/// PassioMode will report the mode the SDK is currently in.
public enum PassioMode : Codable {

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
    /// - Important: In your implementation of `hash(into:)`,
    ///   don't call `finalize()` on the `hasher` instance provided,
    ///   or replace it with a different instance.
    ///   Doing so may become a compile-time error in the future.
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
    public func encode(to encoder: any Encoder) throws

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

extension PassioMode : Equatable {
}

extension PassioMode : Hashable {
}

public struct PassioNutrients : Codable, Equatable {

    public let weight: Measurement<UnitMass>

    public var referenceWeight: Measurement<UnitMass>

    public init(weight: Measurement<UnitMass>)

    public init(fat: Measurement<UnitMass>? = nil, satFat: Measurement<UnitMass>? = nil, monounsaturatedFat: Measurement<UnitMass>? = nil, polyunsaturatedFat: Measurement<UnitMass>? = nil, proteins: Measurement<UnitMass>? = nil, carbs: Measurement<UnitMass>? = nil, calories: Measurement<UnitEnergy>? = nil, cholesterol: Measurement<UnitMass>? = nil, sodium: Measurement<UnitMass>? = nil, fibers: Measurement<UnitMass>? = nil, transFat: Measurement<UnitMass>? = nil, sugars: Measurement<UnitMass>? = nil, sugarsAdded: Measurement<UnitMass>? = nil, alcohol: Measurement<UnitMass>? = nil, iron: Measurement<UnitMass>? = nil, vitaminC: Measurement<UnitMass>? = nil, vitaminA: Double? = nil, vitaminD: Measurement<UnitMass>? = nil, vitaminB6: Measurement<UnitMass>? = nil, vitaminB12: Measurement<UnitMass>? = nil, vitaminB12Added: Measurement<UnitMass>? = nil, vitaminE: Measurement<UnitMass>? = nil, vitaminEAdded: Measurement<UnitMass>? = nil, iodine: Measurement<UnitMass>? = nil, calcium: Measurement<UnitMass>? = nil, potassium: Measurement<UnitMass>? = nil, magnesium: Measurement<UnitMass>? = nil, phosphorus: Measurement<UnitMass>? = nil, sugarAlcohol: Measurement<UnitMass>? = nil, zinc: Measurement<UnitMass>? = nil, selenium: Measurement<UnitMass>? = nil, folicAcid: Measurement<UnitMass>? = nil, chromium: Measurement<UnitMass>? = nil, vitaminKPhylloquinone: Measurement<UnitMass>? = nil, vitaminKMenaquinone4: Measurement<UnitMass>? = nil, vitaminKDihydrophylloquinone: Measurement<UnitMass>? = nil, weight: Measurement<UnitMass> = Measurement<UnitMass>(value: 100.0, unit: .grams))

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

    public func zinc() -> Measurement<UnitMass>?

    public func selenium() -> Measurement<UnitMass>?

    public func folicAcid() -> Measurement<UnitMass>?

    public func chromium() -> Measurement<UnitMass>?

    public func vitaminKPhylloquinone() -> Measurement<UnitMass>?

    public func vitaminKMenaquinone4() -> Measurement<UnitMass>?

    public func vitaminKDihydrophylloquinone() -> Measurement<UnitMass>?

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PassioNutritionAISDK.PassioNutrients, b: PassioNutritionAISDK.PassioNutrients) -> Bool

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

/// Passio SDK - Copyright © 2024 Passio Inc. All rights reserved.
public class PassioNutritionAI {

    final public let filesVersion: Int

    public var version: String { get }

    /// Shared Instance
    public class var shared: PassioNutritionAISDK.PassioNutritionAI { get }

    /// The SDK will request Compressed file the default is set to "true" (faster download/slower processing). If set to "false" the SDK will request none-compressed files (slower download/faster processing.
    public var requestCompressedFiles: Bool

    /// Get the PassioStatus directly or implement the PassioStatusDelegate for updates.
    public var status: PassioNutritionAISDK.PassioStatus { get }

    /// Delegate to track PassioStatus changes. You will get the same status via the configure function.
    weak public var statusDelegate: (any PassioNutritionAISDK.PassioStatusDelegate)?

    /// Available frames per seconds. The default set for two (2) fps.
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

    /// Call this API to configure the SDK
    /// - Parameters:
    ///   - PassioConfiguration: Your desired configuration, must include your developer key
    ///   - completion: Receive back the status of the SDK
    public func configure(passioConfiguration: PassioNutritionAISDK.PassioConfiguration, completion: @escaping (PassioNutritionAISDK.PassioStatus) -> Void)

    /// Shut down the Passio SDK and release all resources
    public func shutDownPassioSDK()

    /// Use this function to detect food via pointing the camera at Food, Barcode and Packaged Food
    /// - Parameters:
    ///   - detectionConfig: FoodDetectionConfiguration() object with the configuration
    ///   - foodRecognitionDelegate: Add self to implement the FoodRecognitionDelegate
    ///   - completion: success or failure of the startFoodDetection
    public func startFoodDetection(detectionConfig: PassioNutritionAISDK.FoodDetectionConfiguration = FoodDetectionConfiguration(), foodRecognitionDelegate: any PassioNutritionAISDK.FoodRecognitionDelegate, capturingDeviceType: PassioNutritionAISDK.CapturingDeviceType = .defaultCapturing(), completion: @escaping (Bool) -> Void)

    /// Use this function to detect Nutrition Facts via pointing the camera at Nutrition Facts
    /// - Parameters:
    ///   - nutritionfactsDelegate: Add self to implement the NutritionFactsDelegate
    ///   - completion: success or failure of the startNutritionFactsDetection
    public func startNutritionFactsDetection(nutritionfactsDelegate: (any PassioNutritionAISDK.NutritionFactsDelegate)?, capturingDeviceType: PassioNutritionAISDK.CapturingDeviceType = .defaultCapturing(), completion: @escaping (Bool) -> Void)

    /// Use this function to stop food detection.
    ///
    /// Use this method to remove camera completely
    ///
    ///     public func removeVideoLayer()
    public func stopFoodDetection()

    /// Detect food in a static image/photo
    /// - Parameters:
    ///   - image: Image for detection
    ///   - detectionConfig: FoodDetectionConfiguration
    ///   - slicingRects: Optional ability to divide the image to slices or regions.
    ///   - completion: optional FoodCandidates
    public func detectFoodIn(image: UIImage, detectionConfig: PassioNutritionAISDK.FoodDetectionConfiguration = FoodDetectionConfiguration(), slicingRects: [CGRect]? = nil, completion: @escaping ((any PassioNutritionAISDK.FoodCandidates)?) -> Void)

    /// Detect barcodes "BarcodeCandidate" in an image
    /// - Parameter image: Image for the detection
    /// - Parameter completion: Receives back Array of "BarcodeCandidate" for that image
    public func detectBarcodesIn(image: UIImage, completion: @escaping ([any PassioNutritionAISDK.BarcodeCandidate]) -> Void)

    /// List all food enabled for weight estimations
    /// - Returns: List of PassioIDs
    public func listFoodEnabledForAmountEstimation() -> [PassioNutritionAISDK.PassioID]

    public func isWeightEstimateAvailableFor(passioID: PassioNutritionAISDK.PassioID) -> Bool

    /// use getPreviewLayer if you don't plan to rotate the PreviewLayer.
    /// - Returns: AVCaptureVideoPreviewLayer
    public func getPreviewLayer() -> AVCaptureVideoPreviewLayer?

    /// use getPreviewLayerWithGravity if you plan to rotate the PreviewLayer.
    /// - Returns: AVCaptureVideoPreviewLayer
    public func getPreviewLayerWithGravity(sessionPreset: AVCaptureSession.Preset = .hd1920x1080, volumeDetectionMode: PassioNutritionAISDK.VolumeDetectionMode = .none, videoGravity: AVLayerVideoGravity = .resizeAspectFill, capturingDeviceType: PassioNutritionAISDK.CapturingDeviceType = .defaultCapturing()) -> AVCaptureVideoPreviewLayer?

    /// Use getPreviewLayer if you don't plan to rotate the PreviewLayer.
    /// - Returns: AVCaptureVideoPreviewLayer
    public func getPreviewLayerForFrontCamera() -> AVCaptureVideoPreviewLayer?

    /// Don't call this function if you need to use the Passio layer again. Only call this function to set the PassioSDK Preview layer to nil
    public func removeVideoLayer()

    /// Use this function if you want to change zoom level of SDK's camera
    ///  - Parameter level: Level of zoom
    public func setCamera(toVideoZoomFactor: CGFloat)

    /// Use this function if you want to allow user to change focus of SDK's camera manually
    /// - Parameter pointOfInterest: Focus point of interest
    public func setTapToFocus(pointOfInterest: CGPoint)

    /// Use this function to get the bounding box relative to the previewLayerBonds
    /// - Parameter boundingBox: The bounding box from the delegate
    /// - Parameter preview: The preview layer bounding box
    public func transformCGRectForm(boundingBox: CGRect, toRect: CGRect) -> CGRect

    /// Use this call to add personalizedAlternative to a Passio ID
    /// - Parameter personalizedAlternative:
    public func addToPersonalization(visualCadidate: any PassioNutritionAISDK.DetectedCandidate, alternative: any PassioNutritionAISDK.DetectedCandidate)

    /// Clean records for one PassioID
    /// - Parameter passioID: PassioID
    public func cleanPersonalizationForVisual(passioID: PassioNutritionAISDK.PassioID)

    /// Clean all records
    public func cleanAllPersonalization()

    /// Lookup fetchFoodItemFor from PassioID
    /// - Parameter passioID: PassioID
    /// - Returns: PassioFoodItem
    public func fetchFoodItemFor(passioID: PassioNutritionAISDK.PassioID, completion: @escaping (PassioNutritionAISDK.PassioFoodItem?) -> Void)

    /// Lookup fetchFoodItem from RefCode
    /// - Parameter RefCode: String
    /// - Returns: PassioFoodItem
    public func fetchFoodItemFor(refCode: String, completion: @escaping (PassioNutritionAISDK.PassioFoodItem?) -> Void)

    /// Advanced search for food will return a list of alternate search and search result
    /// - Parameters:
    ///   - byText: User typed in text
    ///   - completion: PassioAlternateSearchNames, which containts list of alternate search and its results
    public func searchForFood(byText: String, completion: @escaping (PassioNutritionAISDK.SearchResponse?) -> Void)

    /// Fetch search result will return a list of searched text results
    /// - Parameters:
    ///   - labelId: labelId of selected searched result
    ///   - type: type of selected searched result
    ///   - resultId: resultId of selected searched result
    ///   - completion: PassioAlternateSearchNames, which containts list of search results
    public func fetchFoodItemFor(foodItem: PassioNutritionAISDK.PassioFoodDataInfo, completion: @escaping (PassioNutritionAISDK.PassioFoodItem?) -> Void)

    /// Get suggestions for particular meal time.
    /// - Parameters:
    ///   - mealTime: meal time (.breakfast, .lunch, .dinner, .snack)
    ///   - completion: [PassioFoodDataInfo]
    public func fetchSuggestions(mealTime: PassioNutritionAISDK.PassioMealTime, completion: @escaping ([PassioNutritionAISDK.PassioFoodDataInfo]) -> Void)

    /// Get list of all meal plans.
    /// - Parameters:
    ///   - completion: [PassioMealPlan]
    public func fetchMealPlans(completion: @escaping ([PassioNutritionAISDK.PassioMealPlan]) -> Void)

    /// Fetch meal plan for the day
    /// - Parameters:
    ///   - mealPlanLabel: type of mealPlan
    ///   - day: for which day meal plan is needed
    ///   - completion: [PassioMealPlanItem]
    public func fetchMealPlanForDay(mealPlanLabel: String, day: Int, completion: @escaping ([PassioNutritionAISDK.PassioMealPlanItem]) -> Void)

    /// Fetch from Passio web-service the PassioFoodItem for a productCode
    /// - Parameter barcode: Product code
    /// - Parameter completion: PassioFoodItem?
    public func fetchFoodItemFor(productCode: String, completion: @escaping ((PassioNutritionAISDK.PassioFoodItem?) -> Void))

    /// Fetch PassioFoodItem for a v2 PassioID
    /// - Parameter passioID: PassioID
    /// - Parameter completion: Receive a closure with optional PassioFoodItem
    public func fetchFoodItemLegacy(from passioID: PassioNutritionAISDK.PassioID, completion: @escaping (PassioNutritionAISDK.PassioFoodItem?) -> Void)

    /// This function replaces 'lookupIconFor'. You will receive the placeHolderIcon and an optional icon.  If the icons is nil you can use the asynchronous function to "fetchIconFor" the icons from the web.
    /// - Parameters:
    ///   - passioID: PassioID
    ///   - size: IconSize (.px90, .px180 or .px360) where .px90 is the default
    ///   - entityType: PassioEntityType to return the right placeholder.
    /// - Returns: UIImage and a UIImage?  You will receive the placeHolderIcon and an optional icon.  If the icons is nil you can use the asynchronous function to "fetchIconFor" the icons from the web.
    public func lookupIconsFor(passioID: PassioNutritionAISDK.PassioID, size: PassioNutritionAISDK.IconSize = IconSize.px90, entityType: PassioNutritionAISDK.PassioIDEntityType = .item) -> (placeHolderIcon: UIImage, icon: UIImage?)

    /// Fetch icons from the web.
    /// - Parameters:
    ///   - passioID: PassioID
    ///   - size: IconSize (.px90, .px180 or .px360) where .px90 is the default
    ///   - entityType: PassioEntityType to return the right placeholder.
    ///   - completion: Optional Icon.
    public func fetchIconFor(passioID: PassioNutritionAISDK.PassioID, size: PassioNutritionAISDK.IconSize = IconSize.px90, completion: @escaping (UIImage?) -> Void)

    /// Get the icon URL
    /// - Parameters:
    ///   - passioID: passioID
    ///   - size: IconSize (.px90, .px180 or .px360) where .px90 is the default
    /// - Returns: Optional URL
    public func iconURLFor(passioID: PassioNutritionAISDK.PassioID, size: PassioNutritionAISDK.IconSize = IconSize.px90) -> URL?

    /// Beta API/Function
    /// - Parameters:
    ///   - passioID: passioID
    ///   - completion: tag as a list of strings.
    public func fetchTagsFor(passioID: PassioNutritionAISDK.PassioID, completion: @escaping ([String]?) -> Void)

    /// Returns fetchNutrientsFor
    /// - Parameters:
    ///   - passioID: passioID
    ///   - completion: tag as a list of strings.
    public func fetchInflammatoryEffectData(passioID: PassioNutritionAISDK.PassioID, completion: @escaping ([PassioNutritionAISDK.InflammatoryEffectData]?) -> Void)

    /// Return a sorted list of available Volume Detections mode.
    /// Recommended mode is .auto
    public var availableVolumeDetectionModes: [PassioNutritionAISDK.VolumeDetectionMode] { get }

    /// Return the best Volume detection Mode for this iPhone
    public var bestVolumeDetectionMode: PassioNutritionAISDK.VolumeDetectionMode { get }

    /// Beta feature: Passio recommends not to change this value. The default is .cpuAndGPU
    @available(iOS 15.0, *)
    public func setMLComputeUnits(units: MLComputeUnits)

    /// Use this method to fetch PassioSpeechRecognitionModel using speech
    /// - Parameters:
    ///   - text: Text for recognizing food logging actions
    ///   - completion: Actions with food data info
    public func recognizeSpeechRemote(from text: String, completion: @escaping ([PassioNutritionAISDK.PassioSpeechRecognitionModel]) -> Void)

    /// Use this method to fetch PassioAdvisorFoodInfo using Image
    /// - Parameters:
    ///   - image: UIImage for recognizing Food
    ///   - completion: Returns Array of PassioAdvisorFoodInfo if any or empty array if unable to recognize food in image
    public func recognizeImageRemote(image: UIImage, completion: @escaping ([PassioNutritionAISDK.PassioAdvisorFoodInfo]) -> Void)

    /// Detect food in a static image/photo
    /// - Parameters:
    ///   - image: Image for detection
    ///   - detectionConfig: FoodDetectionConfiguration
    ///   - slicingRects: Optional ability to divide the image to slices or regions.
    ///   - completion: optional FoodCandidates
    public func detectFoodWithText(image: UIImage, detectionConfig: PassioNutritionAISDK.FoodDetectionConfiguration = FoodDetectionConfiguration(), completion: @escaping ((any PassioNutritionAISDK.FoodCandidatesWithText)?) -> Void)
}

extension PassioNutritionAI : PassioNutritionAISDK.PassioStatusDelegate {

    public func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL])

    public func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int)

    public func downloadingError(message: String)

    public func passioStatusChanged(status: PassioNutritionAISDK.PassioStatus)

    public func passioProcessing(filesLeft: Int)
}

extension PassioNutritionAI {

    public func getSupportedDevice() -> [PassioNutritionAISDK.CapturingDeviceType]

    public func setCapturingDevice(capturingDevice: PassioNutritionAISDK.CapturingDeviceType)
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

        case mg

        case mcg

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

    final public let titleSaturatedFat: String

    final public let titleTransFat: String

    final public let titleCholesterol: String

    final public let titleSodium: String

    final public let titleTotalCarbs: String

    final public let titleProtein: String

    final public let titleDietaryFiber: String

    final public let titleTotalSugars: String

    final public let titleSugarAlcohol: String

    final public let titleIngredients: String

    public var titleAddedSugar: String

    public var titleVitaminD: String

    public var titleCalcium: String

    public var titleIron: String

    public var titlePotassium: String

    public var servingSizeQuantity: Double

    public var servingSizeUnitName: String?

    public var servingSizeGram: Double?

    public var servingSizeUnit: PassioNutritionAISDK.PassioNutritionFacts.ServingSizeUnit

    public var calories: Double?

    public var fat: Double?

    public var saturatedFat: Double?

    public var transFat: Double?

    public var cholesterol: Double?

    public var sodium: Double?

    public var carbs: Double?

    public var protein: Double?

    public var dietaryFiber: Double?

    public var sugars: Double?

    public var sugarAlcohol: Double?

    public var ingredients: String?

    public var totalSugars: Double?

    public var addedSugar: Double?

    public var vitaminD: Double?

    public var calcium: Double?

    public var iron: Double?

    public var potassium: Double?

    public var isManuallyEdited: Bool

    public var servingSizeText: String { get }

    public var caloriesText: String { get }

    public var fatText: String { get }

    public var saturatedFatText: String { get }

    public var transFatText: String { get }

    public var cholesterolText: String { get }

    public var sodiumText: String { get }

    public var carbsText: String { get }

    public var proteinText: String { get }

    public var dietaryFiberText: String { get }

    public var sugarsText: String { get }

    public var sugarAlcoholText: String { get }

    public var totalSugarsText: String { get }

    public var addedSugarText: String { get }

    public var vitaminDText: String { get }

    public var calciumText: String { get }

    public var ironText: String { get }

    public var potassiumText: String { get }

    public var isCompleted: Bool { get }

    public var description: String { get }

    public func clearAll()
}

extension PassioNutritionFacts {

    public func fromNutritionFacts(foodName: String, brand: String = "") -> PassioNutritionAISDK.PassioFoodItem
}

extension PassioNutritionFacts.ServingSizeUnit : Equatable {
}

extension PassioNutritionFacts.ServingSizeUnit : Hashable {
}

extension PassioNutritionFacts.ServingSizeUnit : RawRepresentable {
}

/// PassioSDKError will return the error with errorDescription if the configuration has failed.
public enum PassioSDKError : LocalizedError, Codable {

    case canNotRunOnSimulator

    case keyNotValid

    case licensedKeyHasExpired(String?)

    case modelsNotValid

    case modelsDownloadFailed

    case noModelsFilesFound

    case noInternetConnection

    case notLicensedForThisProject

    /// A localized message describing what error occurred.
    public var errorDescription: String? { get }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct PassioSearchNutritionPreview : Codable {

    public var calories: Int

    public let carbs: Double

    public let fat: Double

    public let protein: Double

    public var servingUnit: String

    public var servingQuantity: Double

    public var weightUnit: String

    public var weightQuantity: Double

    public init(result: PassioNutritionAISDK.NutritionPreviewResult)

    public init(calories: Int, carbs: Double, fat: Double, protein: Double, servingUnit: String, servingQuantity: Double, weightUnit: String, weightQuantity: Double)

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
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
    /// - Important: In your implementation of `hash(into:)`,
    ///   don't call `finalize()` on the `hasher` instance provided,
    ///   or replace it with a different instance.
    ///   Doing so may become a compile-time error in the future.
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
    public func encode(to encoder: any Encoder) throws

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    ///   The compiler provides an implementation for `hashValue` for you.
    public var hashValue: Int { get }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
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
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

public struct PassioSpeechRecognitionModel {

    public let action: PassioNutritionAISDK.PassioLogAction?

    public let meal: PassioNutritionAISDK.PassioMealTime?

    public let date: String!

    public let advisorFoodInfo: PassioNutritionAISDK.PassioAdvisorFoodInfo
}

/// PassioStatus is returned at the end of the configuration of the SDK.
public struct PassioStatus : Codable {

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

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

/// Implement the protocol to receive status updates
public protocol PassioStatusDelegate : AnyObject {

    func passioStatusChanged(status: PassioNutritionAISDK.PassioStatus)

    func passioProcessing(filesLeft: Int)

    func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL])

    func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int)

    func downloadingError(message: String)
}

public struct Portion : Codable {

    public let weight: PassioNutritionAISDK.Weight?

    public let name: String?

    public let quantity: Double?

    public let suggestedQuantity: [Double]?

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws
}

public struct ResponseAlternative : Codable {

    public let displayName: String

    public let iconId: String

    public let labelId: String

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws
}

/// PassioAlternateSearchNames contains alternate search names with search related data
public struct ResponseFood : Codable {

    public let alternatives: [PassioNutritionAISDK.ResponseAlternative]?

    public let results: [PassioNutritionAISDK.ResponseFoodItem]?

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws
}

public struct ResponseFoodItem : Codable {

    public let displayName: String

    public let internalName: String?

    public let brandName: String?

    public let iconId: PassioNutritionAISDK.PassioID

    public let type: String

    public let internalId: String

    public let portions: [PassioNutritionAISDK.ResponseIngredient.Portion]?

    public let ingredients: [PassioNutritionAISDK.ResponseIngredient]

    public let refCode: String?

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws
}

public struct ResponseIngredient : Codable {

    public let id: String

    public let name: String

    public let iconId: String?

    public let timestamp: String?

    public let nutrients: [PassioNutritionAISDK.ResponseIngredient.NutrientUPC]?

    public let portions: [PassioNutritionAISDK.ResponseIngredient.Portion]?

    public let branded: PassioNutritionAISDK.ResponseIngredient.Branded?

    public let origin: [PassioNutritionAISDK.ResponseIngredient.Origin]?

    public let licenseCopy: String?

    public let tags: [String]?

    public let refCode: String?

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    public struct NutrientUPC : Codable {

        public let id: Double?

        public let nutrient: PassioNutritionAISDK.ResponseIngredient.InternalNutrient?

        public let amount: Double?

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: any Encoder) throws
    }

    /// Component of ResponseIngredient decoding struct
    public struct InternalNutrient : Codable {

        public let name: String?

        public let unit: String?

        public let shortName: String?

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: any Encoder) throws
    }

    /// Component of ResponseIngredient decoding struct
    public struct Branded : Codable {

        public let owner: String?

        public let upc: String?

        public let productCode: String?

        public let ingredients: String?

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: any Encoder) throws
    }

    /// Component of ResponseIngredient decoding struct
    public struct Origin : Codable {

        public let source: String?

        public let id: String?

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: any Encoder) throws
    }

    /// Component of ResponseIngredient decoding struct
    public struct Portion : Codable {

        public let weight: PassioNutritionAISDK.ResponseIngredient.Weight?

        public let name: String?

        public let quantity: Double?

        public let suggestedQuantity: [Double]?

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: any Encoder) throws
    }

    /// Component of ResponseIngredient decoding struct
    public struct Weight : Codable {

        public let unit: String?

        public let value: Double?

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: any Encoder) throws
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
    public func encode(to encoder: any Encoder) throws
}

public enum SDKLanguage : String {

    case en

    case de

    case auto

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

extension SDKLanguage : Equatable {
}

extension SDKLanguage : Hashable {
}

extension SDKLanguage : RawRepresentable {
}

/// PassioAlternateSearchNames contains alternate search names with search related data
public struct SearchResponse {

    public let alternateNames: [String]

    public let results: [PassioNutritionAISDK.PassioFoodDataInfo]
}

public struct SynonymLang : Codable {

    public let synonym: String?

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
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

    public let tags: [String]?

    /// Component of UPC Product decoding struct
    public struct NutrientUPC : Codable {

        public let id: Double?

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
        public func encode(to encoder: any Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws
    }

    /// Component of UPC Product decoding struct
    public struct InternalNutrient : Codable {

        public let name: String?

        public let unit: String?

        public let shortName: String?

        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: any Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws
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
        public func encode(to encoder: any Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws
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
        public func encode(to encoder: any Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws
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
        public func encode(to encoder: any Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws
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
        public func encode(to encoder: any Encoder) throws

        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws
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
    public func encode(to encoder: any Encoder) throws

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws
}

/// VolumeDetectionMode for detection volume.
public enum VolumeDetectionMode : String, CaseIterable {

    /// Using best technology available in this order dualWideCamera, dualCamera or none if the device is not capable of detection volume.
    case auto

    /// If dualWideCamera is not available the mode will not fall back to dualCamera
    case dualWideCamera

    /// No volume detection
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

    /// A type that can represent a collection of all values of this type.
    public typealias AllCases = [PassioNutritionAISDK.VolumeDetectionMode]

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PassioNutritionAISDK.VolumeDetectionMode] { get }

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

public struct Weight : Codable {

    public let unit: String?

    public let value: Double

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws
}

extension Array {

    public subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element { get }

    public subscript(safeIndex index: Int) -> Element? { get }
}

extension UIImageView {

    @MainActor public func loadPassioIconBy(passioID: PassioNutritionAISDK.PassioID, entityType: PassioNutritionAISDK.PassioIDEntityType, size: PassioNutritionAISDK.IconSize = .px90, completion: @escaping (PassioNutritionAISDK.PassioID, UIImage) -> Void)
}

infix operator .+ : DefaultPrecedence

infix operator ./ : DefaultPrecedence

```
