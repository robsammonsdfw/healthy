
This is the full code of the PrismSDK.
Example app: https://github.com/prismlabs-tech/prismsdk-example-ios

/*
import ARKit
import AVFoundation
import Combine
import CommonCrypto
import Compression
import CoreFoundation
import CoreImage
import CoreMedia
import CoreMotion
import DeveloperToolsSupport
import Foundation
import MediaPlayer
import PrismSDK.Swift
import QuartzCore
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import VideoToolbox
import Vision
import _Concurrency
import _StringProcessing
import _SwiftConcurrencyShims
import zlib

//! Project version number for PrismSDK.
public var PrismSDKVersionNumber: Double

//! Project version string for PrismSDK.
public let PrismSDKVersionString: <<error type>>

/// The base API Client utilized by domain clients, e.g. ScanClient, UserClient, etc.
final public class ApiClient : ObservableObject, Sendable {

    /// Create a new `ApiClient` object.
    ///
    /// This will generate a new ``ApiClient`` class that can facilitate the
    /// base parameter construction needed for communication to the Prism API.
    /// OR via providing the PrismSDK-Info.plist file when no values are passed
    /// - Parameters:
    ///   - baseURL: The URL of the Prism BodyMap API
    ///   - clientCredentials: The API credentials to communicate with the Prism BodyMap API
    public init(baseURL: URL? = nil, clientCredentials: PrismSDK.ApiClientBearerToken? = nil)

    /// The type of publisher that emits before the object has changed.
    public typealias ObjectWillChangePublisher = ObservableObjectPublisher
}

/// Type representing the Bearer Token for the API Client
public typealias ApiClientBearerToken = String

/// Api Client Error
public enum ApiClientError : Error {

    /// Invalid URL
    case invalidURL

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PrismSDK.ApiClientError, b: PrismSDK.ApiClientError) -> Bool

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

extension ApiClientError : Equatable {
}

extension ApiClientError : Hashable {
}

/// Asset model
public struct Asset : Codable, Sendable {

    /// The state the asset is in
    public let state: PrismSDK.Asset.State

    /// The last updated at date for the asset
    public let updatedAt: Date

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

extension Asset : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PrismSDK.Asset, rhs: PrismSDK.Asset) -> Bool
}

extension Asset : Hashable {

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

extension Asset {

    /// The state of the Scan Assets
    public enum State : String, Codable, CaseIterable, Identifiable, Sendable {

        /// Started calculating
        case started

        /// Finished calculating
        case succeeded

        /// Failed calculating
        case failed

        /// The stable identity of the entity associated with this instance.
        public var id: PrismSDK.Asset.State { get }

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
        public typealias AllCases = [PrismSDK.Asset.State]

        /// A type representing the stable identity of the entity associated with
        /// an instance.
        public typealias ID = PrismSDK.Asset.State

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = String

        /// A collection of all values of this type.
        public static var allCases: [PrismSDK.Asset.State] { get }

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
}

extension Asset.State : Equatable {
}

extension Asset.State : Hashable {
}

extension Asset.State : RawRepresentable {
}

/// AssetConfigId contains the supported scan asset bundles
public enum AssetConfigId : String, Codable, CaseIterable, Identifiable, Sendable {

    /// singlePlyOnly bundle contains a single .ply file and a preview .png
    case singlePlyOnly

    /// objTextureBased bundle contains a .obj file, texture .png, material .mtl and a preview .png
    case objTextureBased

    /// The stable identity of the entity associated with this instance.
    public var id: PrismSDK.AssetConfigId { get }

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
    public typealias AllCases = [PrismSDK.AssetConfigId]

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = PrismSDK.AssetConfigId

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PrismSDK.AssetConfigId] { get }

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

extension AssetConfigId : Equatable {
}

extension AssetConfigId : Hashable {
}

extension AssetConfigId : RawRepresentable {
}

/// Asset URL's contains the three files that can be downloaded for a scan
public struct AssetUrls : Codable, Sendable {

    /// Scan Canonical 3D Model
    ///
    /// Returns the URL of the canonical 3D model generated from the scan
    public let canonicalModel: String?

    /// Scan 3D Model Material
    ///
    /// Returns the URL of the texture generated from the scan
    public let material: String?

    /// Scan 3D Model
    ///
    /// Returns the URL of the 3D model generated from the scan
    public let model: String?

    /// Scan Preview Image
    ///
    /// Returns the URL of a snapshot of the 3D model for previewing
    public let previewImage: String?

    /// Scan 3D Stripes
    ///
    /// The returns the URL of the model that contains the stripes/rings where the
    /// measurements were taken on the body.
    public let stripes: String?

    /// Scan 3D Model Texture
    ///
    /// Returns the URL of the texture generated from the scan
    public let texture: String?

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

extension AssetUrls {

    /// Asset URL Option Type
    public enum Option : String, Codable, CaseIterable, Identifiable, Sendable {

        /// Canonical 3D Model
        case canonicalModel

        /// 3D Model Material
        case material

        /// 3D Model
        case model

        /// Preview Image
        case previewImage

        /// 3D Stripes Model
        case stripes

        /// 3D Model Texture
        case texture

        /// The stable identity of the entity associated with this instance.
        public var id: PrismSDK.AssetUrls.Option { get }

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
        public typealias AllCases = [PrismSDK.AssetUrls.Option]

        /// A type representing the stable identity of the entity associated with
        /// an instance.
        public typealias ID = PrismSDK.AssetUrls.Option

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = String

        /// A collection of all values of this type.
        public static var allCases: [PrismSDK.AssetUrls.Option] { get }

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
}

extension AssetUrls.Option : Equatable {
}

extension AssetUrls.Option : Hashable {
}

extension AssetUrls.Option : RawRepresentable {
}

/// Body shape prediction response object
public struct BodyShapePrediction : Codable, Sendable {

    public let id: String

    public let status: String

    public let scanId: String

    public let predictionType: String

    public let targetWeight: Int?

    public let targetBodyfat: Int?

    public let createdAt: String

    public let updatedAt: String

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

/// Asset URL that contains all files generated by the body shape prediction
public struct BodyShapePredictionAssetUrl : Codable, Sendable {

    /// Body shape prediction archive
    public let bodyShapePrediction: String?

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

extension BodyShapePredictionAssetUrl {

    /// Asset URL Option Type
    public enum Option : String, Codable, CaseIterable, Identifiable, Sendable {

        /// Body shape prediction archive
        case bodyShapePrediction

        /// The stable identity of the entity associated with this instance.
        public var id: PrismSDK.BodyShapePredictionAssetUrl.Option { get }

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
        public typealias AllCases = [PrismSDK.BodyShapePredictionAssetUrl.Option]

        /// A type representing the stable identity of the entity associated with
        /// an instance.
        public typealias ID = PrismSDK.BodyShapePredictionAssetUrl.Option

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = String

        /// A collection of all values of this type.
        public static var allCases: [PrismSDK.BodyShapePredictionAssetUrl.Option] { get }

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
}

extension BodyShapePredictionAssetUrl.Option : Equatable {
}

extension BodyShapePredictionAssetUrl.Option : Hashable {
}

extension BodyShapePredictionAssetUrl.Option : RawRepresentable {
}

/// Body shape prediction post request payload
public struct BodyShapePredictionPayload : Codable, Sendable {

    public let scanId: String

    public let predictionType: String

    public let targetWeight: Float?

    public let targetBodyfat: Float?

    /// Create a BodyShapePredictionPayload object
    ///
    /// This returns a new body shape prediction object that is used for creating a
    /// new body shape prediction using the API.
    ///
    /// - Parameters:
    ///   - scanId: Unique scanId for which the body shape prediction will be created
    ///   - predictionType: Type of the prediction used for the calculation
    ///   - targetWeight: The target weight for the prediction
    ///   - targetBodyfat: The target bodyfat percentage for the prediction
    public init(scanId: String, predictionType: String, targetWeight: Float? = nil, targetBodyfat: Float? = nil)

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

/// BodyFat returns the scan details around Body Fat and Lean Mass
public struct Bodyfat : Codable, Sendable {

    /// The response Bodyfat Method. Currently supported:
    /// - adam
    /// - coco
    /// - extended_navy_thinboost
    /// - tina_fit
    public let bodyfatMethod: String?

    /// Body Fat Percentage returns in a range of 0.0 to 1.0
    public let bodyfatPercentage: Double?

    /// The Fat Mass amount
    public let fatMass: Double?

    /// The Lean Mass amount
    public let leanMass: Double?

    /// Lean Mass Percentage returns in a range of 0.0 to 1.0
    public let leanMassPercentage: Double?

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

extension Bodyfat : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PrismSDK.Bodyfat, rhs: PrismSDK.Bodyfat) -> Bool
}

extension Bodyfat : Hashable {

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

public enum BodyfatMethod : String, Codable, CaseIterable, Identifiable, Sendable {

    case adam

    case army

    case army_athlete

    case coco

    case coco_legacy

    case coco_bri

    case extended_navy_thinboost

    case tina_fit

    /// The stable identity of the entity associated with this instance.
    public var id: PrismSDK.BodyfatMethod { get }

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
    public typealias AllCases = [PrismSDK.BodyfatMethod]

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = PrismSDK.BodyfatMethod

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PrismSDK.BodyfatMethod] { get }

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

extension BodyfatMethod : Equatable {
}

extension BodyfatMethod : Hashable {
}

extension BodyfatMethod : RawRepresentable {
}

/// Returns the full Camera Bummer
///
/// This will return both the raw CMSampleBuffer and the converted CGImage
/// This will allow you to process the raw feed further up in the chain allowing you to
/// access things like the EXIF data on a per-frame basses.
public struct CameraBuffer {

    /// A reference to a CMSampleBuffer
    ///
    /// A CF object containing zero or more compressed (or uncompressed)
    /// samples of a particular media type (audio, video, muxed, etc).
    public let buffer: CMSampleBuffer

    /// A reference to a CGImage
    ///
    /// A CG Object of an image that can be used to display a preview
    /// of the camera feed.
    public let frame: CGImage

    /// AVCaptureSessions Calibration Data
    ///
    /// AVCameraCalibrationData is a model object describing a camera's
    /// calibration information.
    public let calibrationData: AVCameraCalibrationData
}

extension CameraBuffer {

    public var exifData: [AnyHashable : Any]? { get }
}

/// The camera Permission Status
@frozen public enum CameraPermissionStatus : Int, CaseIterable, Identifiable {

    /// Undetermined permission status
    case notDetermined

    /// Restricted (Either by the user or by some parental controls)
    case restricted

    /// The user denied access to the Camera
    case denied

    /// The user granted permission to the camera
    case authorized

    /// The stable identity of the entity associated with this instance.
    public var id: PrismSDK.CameraPermissionStatus { get }

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
    public init?(rawValue: Int)

    /// A type that can represent a collection of all values of this type.
    public typealias AllCases = [PrismSDK.CameraPermissionStatus]

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = PrismSDK.CameraPermissionStatus

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = Int

    /// A collection of all values of this type.
    public static var allCases: [PrismSDK.CameraPermissionStatus] { get }

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
    public var rawValue: Int { get }
}

extension CameraPermissionStatus : Equatable {
}

extension CameraPermissionStatus : Hashable {
}

extension CameraPermissionStatus : RawRepresentable {
}

extension CameraPermissionStatus : Sendable {
}

/// The Camera Session used to record and determine
/// poses from the user.
///
/// Examples:
/// SwiftUI
/// ```swift
/// @StateObject var session: CameraSession = CameraSession()
/// ```
///
/// > Warning: This requires you to add the `Privacy - Camera Usage Description`
/// > key to your Info.plist file. Apple requires a description in detail of why
/// > you need access to the camera, and what you are doing with it.
///
@objc public class CameraSession : NSObject, ObservableObject {

    /// Enable or Disable the Camera Session
    public var isEnabled: Bool

    /// Enable or Disable Vision Detection.
    /// See ``visionDetection`` for more information
    public var visionDetection: PrismSDK.VisionDetectionState

    /// The Camera to use. We only support front facing right now, but the
    /// rear camera can also be used.
    public var cameraPosition: AVCaptureDevice.Position

    /// The Device orientation (landscape or portrait)
    public var orientation: AVCaptureVideoOrientation

    /// The permission status for the camera
    @Published public var status: PrismSDK.CameraPermissionStatus

    public var $status: Published<PrismSDK.CameraPermissionStatus>.Publisher

    /// The full camera buffer data
    @Published public var cameraBuffer: PrismSDK.CameraBuffer? { get }

    public var $cameraBuffer: Published<PrismSDK.CameraBuffer?>.Publisher { get }

    /// The raw frame from the camera without any post processing
    @Published public var rawFrame: CGImage? { get }

    public var $rawFrame: Published<CGImage?>.Publisher { get }

    /// The processed frame with any drawing on top
    @Published public var processedFrame: CGImage? { get }

    public var $processedFrame: Published<CGImage?>.Publisher { get }

    /// An indicator of position acceptability
    @Published public var positionFeedback: PrismSDK.DetectionFeedback? { get }

    public var $positionFeedback: Published<PrismSDK.DetectionFeedback?>.Publisher { get }

    /// An indicator of pose acceptability
    @Published public var poseFeedback: PrismSDK.DetectionFeedback? { get }

    public var $poseFeedback: Published<PrismSDK.DetectionFeedback?>.Publisher { get }

    /// A convience initializer to instantiate the camera and initialize the feed
    public init(poseTheme: PrismSDK.PoseTheme)

    public func updateDeviceOrientation()

    /// The type of publisher that emits before the object has changed.
    public typealias ObjectWillChangePublisher = ObservableObjectPublisher
}

extension CameraSession : AVCaptureDataOutputSynchronizerDelegate {

    dynamic public func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection)
}

/// Capture Errors
@frozen public enum CaptureError : Error {

    /// Unsupported Device
    case unsupportedDevice

    /// Invalid Documents Directory
    case invalidDocumentDirectory

    /// Invalid Recording
    case invalidRecording

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PrismSDK.CaptureError, b: PrismSDK.CaptureError) -> Bool

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

extension CaptureError : Equatable {
}

extension CaptureError : Hashable {
}

/// Capture Session
///
/// Handles and controls the entire capture flow. This returns all of
/// the raw values and data that can be used to build your own custom UI.
public class CaptureSession : ObservableObject {

    public var configuration: PrismSDK.CaptureSessionConfiguration

    /// Camera Buffer
    ///
    /// Returns the entire camera buffer
    @Published public var cameraBuffer: PrismSDK.CameraBuffer?

    public var $cameraBuffer: Published<PrismSDK.CameraBuffer?>.Publisher

    /// The raw camera frame
    @Published public var rawFrame: CGImage?

    public var $rawFrame: Published<CGImage?>.Publisher

    /// The preview frame to return upstream to the app
    /// This returns the processed frame containing the Pose Drawing
    @Published public var previewFrame: CGImage?

    public var $previewFrame: Published<CGImage?>.Publisher

    /// This returns the current state the scanner is in
    @Published public var state: PrismSDK.CaptureSessionState

    public var $state: Published<PrismSDK.CaptureSessionState>.Publisher

    /// This returns the current state the scanner is in
    @Published public var states: [PrismSDK.CaptureSessionState]

    public var $states: Published<[PrismSDK.CaptureSessionState]>.Publisher

    /// This returns the current camera permissions
    @Published public var permissions: PrismSDK.CameraPermissionStatus

    public var $permissions: Published<PrismSDK.CameraPermissionStatus>.Publisher

    /// Recording Manager
    @Published public var recordingUrl: URL?

    public var $recordingUrl: Published<URL?>.Publisher

    /// Level Manager
    @Published public var levelState: PrismSDK.PrismState

    public var $levelState: Published<PrismSDK.PrismState>.Publisher

    @Published public var levelResult: PrismSDK.MotionDetector.Level

    public var $levelResult: Published<PrismSDK.MotionDetector.Level>.Publisher

    /// The vertical change with tilting the phone.
    @Published public var verticalRotation: Double

    public var $verticalRotation: Published<Double>.Publisher

    /// Position Result
    @Published public var positioningResult: PrismSDK.DetectionFeedback?

    public var $positioningResult: Published<PrismSDK.DetectionFeedback?>.Publisher

    /// Position Manager
    @Published public var positioningState: PrismSDK.PrismState

    public var $positioningState: Published<PrismSDK.PrismState>.Publisher

    /// Posing Result
    @Published public var posingResult: PrismSDK.DetectionFeedback?

    public var $posingResult: Published<PrismSDK.DetectionFeedback?>.Publisher

    /// Position Manager
    @Published public var posingState: PrismSDK.PrismState

    public var $posingState: Published<PrismSDK.PrismState>.Publisher

    /// Recording Manager
    @Published public var recordingState: PrismSDK.PrismState

    public var $recordingState: Published<PrismSDK.PrismState>.Publisher

    /// The count down from the recording
    @Published public var recordingCountDown: Int

    public var $recordingCountDown: Published<Int>.Publisher

    /// Device Supported Check
    ///
    /// This returns true or false if the device is supported.
    /// A device with a True Depth Camera is required.
    public static var isSupported: Bool { get }

    /// Initializes a new ``CaptureSession``
    public init(configuration: PrismSDK.CaptureSessionConfiguration = .init())

    /// The type of publisher that emits before the object has changed.
    public typealias ObjectWillChangePublisher = ObservableObjectPublisher
}

extension CaptureSession {

    /// Starts the scanner
    /// This begins the entire capture flow.
    public func start() async throws

    /// Continue
    /// This tells the session its ready to continue to the next step.
    /// We have to call this step once the audio phrases have finished speaking.
    public func `continue`(from currentState: PrismSDK.CaptureSessionState, shouldStart: Bool = true)

    /// Checks the completion of the manager before it continues
    public func checkAndContinue(from currentState: PrismSDK.CaptureSessionState, start: Bool = true)

    /// Will start the manager for the next step
    public func startStep()

    /// Stops the scanner
    /// This will stop recording to disk, and will then trigger the archiver
    /// to zip up the files and return the URL so it can be used paert of the
    /// next step in the chain.
    @discardableResult
    public func stop() async throws -> URL

    /// Cancel the entire scanning operation.
    public func cancel() async throws
}

/// Configurable properties for the Capture Session
///
/// This allows you to specify configuration options for the Capture session.
public struct CaptureSessionConfiguration {

    /// The theme used for drawing the skeleton on screen
    ///
    /// View the ``PoseTheme`` for all available configuration options
    public var poseTheme: PrismSDK.PoseTheme

    /// Initialize the `CaptureSessionConfiguration`
    ///
    /// - Parameters:
    ///     - PoseTheme: The theme configuration to use during the capture session
    public init(poseTheme: PrismSDK.PoseTheme? = nil)
}

/// The states of the ``CaptureSession``
@frozen public enum CaptureSessionState : String, CaseIterable, Identifiable {

    /// Idle (Waiting)
    case idle

    /// Leveling the device (This uses the Gyroscope)
    case leveling

    /// Volume
    ///
    /// This is the state of the session when the user is
    /// on the volume setup page
    case volume

    /// Human Positioning
    ///
    /// This uses the Vision framework to help the user get
    /// into the middle of the screen and a certain distance away from the device.
    case positioning

    /// Human Posing
    ///
    /// This step helps the user position their body into what's called an "A Pose"
    case posing

    /// Recording
    ///
    /// When a user is recording their body scan
    case recording

    /// Processing the Data
    ///
    /// After a recording is complete, the Session then archives the images and prepares
    /// them for uploading.
    case processing

    /// To indicate the entire scanning process is complete.
    case finished

    /// The stable identity of the entity associated with this instance.
    public var id: PrismSDK.CaptureSessionState { get }

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
    public typealias AllCases = [PrismSDK.CaptureSessionState]

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = PrismSDK.CaptureSessionState

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PrismSDK.CaptureSessionState] { get }

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

extension CaptureSessionState : Equatable {
}

extension CaptureSessionState : Hashable {
}

extension CaptureSessionState : RawRepresentable {
}

extension CaptureSessionState : Sendable {
}

/// Detection Failures for positioning and posing
///
/// This contains all of the Detection Failures that are possible throughout the entire capture flow.
@frozen public enum DetectionFailure : String {

    /// Difference between your shoulders and ankles. If that is less than a certain
    /// percentage of the screen, it marks you as too far.
    case tooFar

    /// Difference between your shoulders and ankles. If that is greater than a
    /// certain percentage of the screen, it marks you as too far. Or, when some
    /// limb joints are missing.
    case tooClose

    /// At least one foot is blocked from view
    case occludedFeet

    /// Left shoulder too far from center
    case tooFarLeft

    /// Right shoulder too far from center
    case tooFarRight

    /// No nose detected
    case backward

    /// Waist is too far below the center of screen
    case cameraTooHigh

    /// Waist is too far above the center of screen
    case cameraTooLow

    /// Head below top 33% of screen height
    case emptySpaceTop

    /// Ankles above bottom 22% of screen height
    case emptySpaceBottom

    /// Youre not positioned upright
    case notUpright

    /// Legs are missaligned
    case badLegPose

    /// Arms are missaligned
    case badArmPose

    /// Right arm raised too high
    case rightArmRaised

    /// Left arm raised too high
    case leftArmRaised

    /// Right arm is too high
    case rightArmTooHigh

    /// Left arm is too high
    case leftArmTooHigh

    /// Right arm is too low
    case rightArmTooLow

    /// Left arm is too low
    case leftArmTooLow

    /// Arms are missaligned
    case badArmAlignment

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

extension DetectionFailure : Equatable {
}

extension DetectionFailure : Hashable {
}

extension DetectionFailure : RawRepresentable {
}

extension DetectionFailure : Sendable {
}

/// DetectionFeedback returns the high level results
@frozen public enum DetectionFeedback : Equatable {

    /// A sucessful detection
    case approved

    /// No person detected
    case emptyFrame

    /// Can't detect all required body parts
    case incompleteData

    /// More than one person in the frame
    case multiplePeople

    /// Returns a reason for the failure
    case failed(reason: PrismSDK.DetectionFailure)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PrismSDK.DetectionFeedback, b: PrismSDK.DetectionFeedback) -> Bool
}

extension DetectionFeedback : Sendable {
}

/// Used for modifying an existing user in the Prism API
public struct ExistingUser : Codable, Sendable {

    /// The token for the user
    public let token: String

    /// The email of the user
    public let email: String?

    /// The ``Sex`` of the user
    public let sex: PrismSDK.Sex?

    /// The region the user resides in
    public let region: String?

    /// The US state the user resides in
    public let usaResidence: String?

    /// The birthdate of the user
    public let birthDate: Date?

    /// The weight of the suer
    public let weight: PrismSDK.Weight?

    /// The height of the user
    public let height: PrismSDK.Height?

    /// Research Consent for the user. This is used to enroll or unenroll the user in using the
    /// uploaded body scans for training purposes.
    public let researchConsent: Bool?

    /// Creates a new ``ExistingUser`` model
    ///
    /// An Existing user **must** already exist in the database. Please refer to ``NewUser``
    /// for creating a new user in the Prism API.
    ///
    /// - Parameters:
    ///   - token: The token of the user
    ///   - email: A valid email address of the user
    ///   - sex: The users Sex preference
    ///   - region: The region the user resides in
    ///   - usaResidence: The US state the user resides in
    ///   - birthDate: The date of birth of the user
    ///   - weight: The weight of the user
    ///   - height: The height of the user
    ///   - researchConsent: Enable or Disabling the research consent option
    public init(token: String, email: String? = nil, sex: PrismSDK.Sex? = nil, region: String? = nil, usaResidence: String? = nil, birthDate: Date? = nil, weight: PrismSDK.Weight? = nil, height: PrismSDK.Height? = nil, researchConsent: Bool? = nil)

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

/// File Uploader handles uploading the Scan
@objc final public class FileUploader : NSObject, ObservableObject {

    @Published final public var isUploading: Bool

    final public var $isUploading: Published<Bool>.Publisher

    @Published final public var progress: Double

    final public var $progress: Published<Double>.Publisher

    @Published final public var uploadedFile: Bool

    final public var $uploadedFile: Published<Bool>.Publisher

    override dynamic public init()

    /// Setups the uploader for use
    /// This will also resume any suspended tasks and continue running them as needed.
    ///
    /// This handles retrieving any processing uploads and can then be used in keeping track of the current upload.
    final public func setup()

    /// Upload a File to a Generated URL
    ///
    /// This will upload a file to the given URL.
    /// The progress variable can be observed for progress.
    ///
    /// - Parameters
    ///     - file: The file to upload (this must be stored on the system)
    ///     - to: The URL the file is being uploaded to.
    final public func upload(file: URL, to url: URL)

    /// The type of publisher that emits before the object has changed.
    public typealias ObjectWillChangePublisher = ObservableObjectPublisher
}

extension FileUploader : URLSessionDelegate {

    final public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?)

    final public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)

    final public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?)
}

extension FileUploader : URLSessionTaskDelegate {

    final public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
}

/// Height information for the scan
public struct Height : Codable, Sendable {

    /// The height value of the user
    public let value: Double

    /// The unit used to format the value
    public let unit: PrismSDK.Height.Unit

    /// Create a new ``Height`` object
    /// - Parameters:
    ///   - value: The measurment in height for the user
    ///   - unit: The units of format used
    public init(value: Double, unit: PrismSDK.Height.Unit)

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

extension Height {

    /// The unit of measurment
    public enum Unit : String, Codable, CaseIterable, Identifiable, Sendable {

        /// Imperial (Inches)
        case inches

        /// Metric (Meters)
        case meters

        /// The stable identity of the entity associated with this instance.
        public var id: PrismSDK.Height.Unit { get }

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
        public typealias AllCases = [PrismSDK.Height.Unit]

        /// A type representing the stable identity of the entity associated with
        /// an instance.
        public typealias ID = PrismSDK.Height.Unit

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = String

        /// A collection of all values of this type.
        public static var allCases: [PrismSDK.Height.Unit] { get }

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
}

extension Height.Unit : Equatable {
}

extension Height.Unit : Hashable {
}

extension Height.Unit : RawRepresentable {
}

/// The Measurements results from a scan
public struct Measurements : Codable, Sendable {

    public let neckFit: Double

    public let shoulderFit: Double

    public let upperChestFit: Double

    public let chestFit: Double

    public let lowerChestFit: Double

    public let waistFit: Double

    public let waistNavyFit: Double

    public let stomachFit: Double

    public let hipsFit: Double

    public let upperThighLeftFit: Double

    public let upperThighRightFit: Double

    public let thighLeftFit: Double

    public let thighRightFit: Double

    public let lowerThighLeftFit: Double

    public let lowerThighRightFit: Double

    public let calfLeftFit: Double

    public let calfRightFit: Double

    public let ankleLeftFit: Double

    public let ankleRightFit: Double

    public let midArmRightFit: Double

    public let midArmLeftFit: Double

    public let lowerArmRightFit: Double

    public let lowerArmLeftFit: Double

    public let waistToHipRatio: Double

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

extension Measurements : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PrismSDK.Measurements, rhs: PrismSDK.Measurements) -> Bool
}

extension Measurements : Hashable {

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

/// Helps monitor Device Rotation.
///
/// The MotionDetector hands calculating Device Rotation both vertically and horizontally.
///
/// Examples:
/// SwiftUI
/// ```swift
/// @StateObject var detector: MotionDetector = MotionDetector()
/// ```
/// ...
/// ```swift
/// print(self.detector.horizontalRotation) // Left and right rotation
/// print(self.detector.verticalRotation) // Forward and backward rotation
/// print(self.detector.level) // Level state
/// ```
///
public class MotionDetector : ObservableObject {

    @frozen public enum Level : String, CaseIterable, Identifiable {

        /// If the device is leaning backwards
        case backwards

        /// If the device is leaning forwards
        case forwards

        /// If the device is veritcally level
        case level

        /// The stable identity of the entity associated with this instance.
        public var id: PrismSDK.MotionDetector.Level { get }

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
        public typealias AllCases = [PrismSDK.MotionDetector.Level]

        /// A type representing the stable identity of the entity associated with
        /// an instance.
        public typealias ID = PrismSDK.MotionDetector.Level

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = String

        /// A collection of all values of this type.
        public static var allCases: [PrismSDK.MotionDetector.Level] { get }

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

    /// The horizontal rotation angle
    @Published public var horizontalRotation: Double { get }

    public var $horizontalRotation: Published<Double>.Publisher { get }

    /// The vertical rotation angle
    @Published public var verticalRotation: Double { get }

    public var $verticalRotation: Published<Double>.Publisher { get }

    /// The level state. See `Level` for all available values
    @Published public var level: PrismSDK.MotionDetector.Level { get }

    public var $level: Published<PrismSDK.MotionDetector.Level>.Publisher { get }

    /// Returns a true or false value if the device has motion data available
    public var isDeviceMotionAvailable: Bool { get }

    /// Creates a MotionDetector with a given update interval.
    ///
    /// ```swift
    /// MotionDetector(maximumTiltDegrees: 3.0)
    /// ```
    ///
    /// - Parameters:
    ///     - maximumTiltDegrees: The maximum degrees to allow the device  to talk backwards
    ///
    /// - Returns: A `MotionDetector`.
    public init(maximumTiltDegrees: Double)

    /// Starts updating motion events for the device.
    public func start()

    /// Stops updating motion events for the device.
    public func stop()

    /// The type of publisher that emits before the object has changed.
    public typealias ObjectWillChangePublisher = ObservableObjectPublisher
}

extension MotionDetector.Level : Equatable {
}

extension MotionDetector.Level : Hashable {
}

extension MotionDetector.Level : RawRepresentable {
}

extension MotionDetector.Level : Sendable {
}

/// Networking error's
public enum NetworkingError : Error {

    /// Encoding Failure. This can be returned when encoding bad data
    case jsonEncodeFailure(any Error)

    /// Decoding Failure. This can be returned when decoding bad data
    case jsonDecodeFailure(any Error)

    /// Something went wrong making the network request
    case requestFailure

    /// Error with the expected Response
    case responseFailure(PrismSDK.PrismError)

    /// Server returned a non HTTP Response
    case notAnHttpResponse

    /// Invalid URL
    case invalidURL
}

extension NetworkingError : CustomStringConvertible {

    /// A textual representation of this instance.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(describing:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `description` property for types that conform to
    /// `CustomStringConvertible`:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    public var description: String { get }
}

/// Create a new scan
public struct NewScan : Codable, Sendable {

    public let deviceConfigName: String

    public let userToken: String

    public let bodyfatMethod: PrismSDK.BodyfatMethod?

    public let assetConfigId: PrismSDK.AssetConfigId?

    /// Create a NewScan model
    ///
    /// This returns a new scan object that is used for creating a new scan in the API
    ///
    /// - Parameters:
    ///   - deviceConfigName: The device name to use (Configured outside of the SDK)
    ///   - userToken: The User's token
    ///   - bodyfatMethod: The bodyfat method to use. Defaults to tina_fit
    ///   - assetConfigId: The ID of the group of assets returned by the API
    public init(deviceConfigName: String, userToken: String, bodyfatMethod: PrismSDK.BodyfatMethod? = nil, assetConfigId: PrismSDK.AssetConfigId? = nil)

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

public struct NewUser : Codable, Sendable {

    /// The token for the user
    public let token: String

    /// The email of the user
    public let email: String?

    /// The ``Sex`` of the user
    public let sex: PrismSDK.Sex

    /// The region the user resides in
    public let region: String

    /// The US state the user resides in
    public let usaResidence: String?

    /// The birthdate of the user
    public let birthDate: Date

    /// The weight of the suer
    public let weight: PrismSDK.Weight

    /// The height of the user
    public let height: PrismSDK.Height

    /// Research Consent for the user. This is used to enroll or unenroll the user in using the
    /// uploaded body scans for training purposes.
    public let researchConsent: Bool

    /// The Terms of Service
    public let termsOfService: PrismSDK.TermsOfService

    /// Create a new user in the Prism API
    ///
    /// All fields are required for the NewUser.
    ///
    /// - Parameters:
    ///   - token: The token of the user
    ///   - email: A valid email address of the user
    ///   - sex: The users Sex preference
    ///   - region: The region the user resides in
    ///   - usaResidence: The US state the user resides in
    ///   - birthDate: The date of birth of the user
    ///   - weight: The weight of the user
    ///   - height: The height of the user
    ///   - researchConsent: Enable or Disabling the research consent option
    ///   - termsOfService: Terms of Service acceptability
    public init(token: String, email: String? = nil, sex: PrismSDK.Sex, region: String = "north_america", usaResidence: String?, birthDate: Date, weight: PrismSDK.Weight, height: PrismSDK.Height, researchConsent: Bool = false, termsOfService: PrismSDK.TermsOfService)

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

/// Returns all metadata about the page the data is returned from
public struct PageInfo : Codable, Sendable {

    /// The cursor of the next set of data
    public let cursor: String?

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

/// The Paginated response containing the results and pate info
public struct Paginated<Element> : Codable, Sendable where Element : Decodable, Element : Encodable, Element : Sendable {

    /// The array or elements returned
    public let results: [Element]

    /// ``PageInfo`` for the response
    public let pageInfo: PrismSDK.PageInfo

    /// Create a new Paginated object
    /// - Parameters:
    ///   - results: An array or Codable objects
    ///   - pageInfo: Page information
    public init(results: [Element], pageInfo: PrismSDK.PageInfo)

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

/// All avaialble Pose Problems
///
/// This contains the full list of PosePorblems that can be returned when posing
@frozen public enum PoseProblem : String {

    /// Both wrists are above elbows
    case armsRaised

    /// Right wrist above right elbow or right shoulder
    case rightArmRaised

    /// Left wrist above left elbow or left shoulder
    case leftArmRaised

    /// Right arms raised too far away from the body
    case rightArmTooHigh

    /// Right arm to close to body
    case rightArmNotSpread

    /// Left arms raised too far away from the body
    case leftArmTooHigh

    /// Left arm to close to body
    case leftArmNotSpread

    /// Legs are not spread
    case legsNotSpread

    /// Right leg angle from vertical is too small
    case rightLegNotSpread

    /// Right leg angle from vertical is too big
    case rightLegTooWide

    /// Left leg angle from vertical is too small
    case leftLegNotSpread

    /// Left leg angle from vertical is too big
    case leftLegTooWide

    /// Feet are not perpemdicular
    case feetNotPerpendicular

    /// Main axis is too big an angle from vertical
    case leaning

    /// Shoulder axis too high an angle from horizontal
    case unevenShoulders

    /// Elbow axis too high an angle from horizontal
    case unevenElbows

    /// Wrist axis too high an angle from horizontal
    case unevenWrists

    /// Knee axis too high an angle from horizontal
    case unevenKnees

    /// Ankle axis too high an angle from horizontal
    case unevenAnkles

    /// One or both shoulders too far from center
    case offCenterShoulders

    /// One or both elbows too far from center
    case offCenterElbows

    /// One or both wrists too far from center
    case offCenterWrists

    /// One or both knees too far from center
    case offCenterKnees

    /// One or both ankles too far from center
    case offCenterAnkles

    /// Elbow closer to center than shoulder
    case elbowsNotSpread

    /// Wrist closer to center than elbow
    case wristsNotSpread

    /// The neck is lower than the waist
    case upsideDown

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

extension PoseProblem : Equatable {
}

extension PoseProblem : Hashable {
}

extension PoseProblem : RawRepresentable {
}

extension PoseProblem : Sendable {
}

/// PoseResult returns the high level results
@frozen public enum PoseResult : Equatable {

    /// A sucessful detection
    case approved

    /// No person detected
    case emptyFrame

    /// Can't detect all required body parts
    case incompleteData

    /// More than one person in the frame
    case multiplePoses

    /// Returns a reason for the failure
    case failed(reasons: Set<PrismSDK.PoseProblem>)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PrismSDK.PoseResult, b: PrismSDK.PoseResult) -> Bool
}

extension PoseResult : Sendable {
}

/// Defines all of the available properties for themeing the Pose Drawing
///
/// Colors, Gradients & Sizing
public struct PoseTheme {

    /// Line Acceptable Gradient
    public var acceptableGradient: CGGradient

    /// Line Unacceptable Gradient
    public var unacceptableGradient: CGGradient

    /// Line Width
    public var lineWidth: CGFloat

    /// The minimum `VNRecognizedPoint` confidence for a valid `Landmark`.
    public var pointThreshold: Float

    /// The drawing radius of a point on the skeleton.
    public var pointRadius: CGFloat

    /// The fill color of the point drawn on the skeleton
    public var pointFillColor: UIColor

    /// The stroke color of the point drawn on the skeleton
    public var pointStrokeColor: UIColor

    /// Create a new PoseTheme object
    ///
    /// - Parameters:
    ///     - acceptableGradient: The acceptable gradient for when a person meets the criteria to continue
    ///     - unacceptableGradient: The unacceptable gradient for when a person does not meet the criteria to continue
    ///     - lineWidth: The line width of the skeleton to draw
    ///     - pointThreshold: The minimum `VNRecognizedPoint` confidence for a valid `Landmark`.
    ///     - pointRadius: The drawing radius of a point on the skeleton.
    ///     - pointFillColor: The fill color of the point drawn on the skeleton
    ///     - pointStrokeColor: The stroke color of the point drawn on the skeleton
    public init(acceptableGradient: CGGradient? = nil, unacceptableGradient: CGGradient? = nil, lineWidth: CGFloat? = nil, pointThreshold: Float? = nil, pointRadius: CGFloat? = nil, pointFillColor: UIColor? = nil, pointStrokeColor: UIColor? = nil)
}

/// Positioning Problems
@frozen public enum PositioningProblem : Equatable {

    /// Difference between your shoulders and ankles. If that is less than a certain
    /// percentage of the screen, it marks you as too far.
    case tooFar

    /// Difference between your shoulders and ankles. If that is greater than a
    /// certain percentage of the screen, it marks you as too far. Or, when some
    /// limb joints are missing.
    case tooClose

    /// At least one foot is blocked from view
    case occludedFeet

    /// Left shoulder too far from center
    case tooFarLeft

    /// Right shoulder too far from center
    case tooFarRight

    /// No nose detected
    case backward

    /// Waist is too far below the center of screen
    case cameraTooHigh

    /// Waist is too far above the center of screen
    case cameraTooLow

    /// Head below top 32% of screen height
    case emptySpaceTop

    /// Ankles above bottom 22% of screen height
    case emptySpaceBottom

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PrismSDK.PositioningProblem, rhs: PrismSDK.PositioningProblem) -> Bool

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

extension PositioningProblem : Hashable {
}

extension PositioningProblem : Sendable {
}

/// PositioningResult returns the high level results
@frozen public enum PositioningResult : Equatable {

    /// A sucessful detection
    case approved

    /// No person detected
    case emptyFrame

    /// Can't detect all required body parts
    case incompleteData

    /// More than one person in the frame
    case multiplePoses

    /// Returns a reason for the failure
    case failed(reason: PrismSDK.PositioningProblem)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PrismSDK.PositioningResult, rhs: PrismSDK.PositioningResult) -> Bool
}

extension PositioningResult : Sendable {
}

/// Used as the Primary Action button for all CTA style buttons
public struct PrimaryActionButtonStyle : ButtonStyle {

    public init()

    /// Creates a view that represents the body of a button.
    ///
    /// The system calls this method for each ``Button`` instance in a view
    /// hierarchy where this style is the current button style.
    ///
    /// - Parameter configuration : The properties of the button.
    public func makeBody(configuration: PrismSDK.PrimaryActionButtonStyle.Configuration) -> some View


    /// A view that represents the body of a button.
    public typealias Body = some View
}

/// Prism Capture Session
///
/// This creates a singleton to handle rapid updates from CaptureSession
public class PrismCaptureSession : ObservableObject {

    final public let session: PrismSDK.CaptureSession

    public init(configuration: PrismSDK.CaptureSessionConfiguration = .init())

    /// The type of publisher that emits before the object has changed.
    public typealias ObjectWillChangePublisher = ObservableObjectPublisher
}

/// The PrismError contains the decoded messages from the Prism API
public struct PrismError : Codable, Sendable {

    /// The returned status code
    public let statusCode: Int

    /// The message returned from the Server
    public let messages: [String]

    /// The Network Status returned
    public let error: String?

    /// Initialize from decoder
    public init(from decoder: any Decoder) throws

    /// Encode to Data
    public func encode(to encoder: any Encoder) throws
}

extension PrismError : CustomStringConvertible {

    /// A textual representation of this instance.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(describing:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `description` property for types that conform to
    /// `CustomStringConvertible`:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    public var description: String { get }
}

/// The entire Capture Session Flow
///
/// This creates the entire capture complete, complete with leveling,
/// positioning, posing, and recording.
@MainActor public struct PrismSessionView : View {

    /// Instantiates a new ``PrismSessionView``
    ///
    /// This will create a new view that can be presented or displayed.
    /// - Parameters:
    ///   - receivedArchive: Returns the URL containing the file path to the recording zip
    ///   - onStatus: Returns the state of the capture session. This is useful for analytic tracking
    ///   - onDismiss: Called when the ``PrismSessionView`` is dismissed
    @MainActor public init(receivedArchive: @escaping (URL) -> Void, onStatus: @escaping (PrismSDK.CaptureSessionState) -> Void, onDismiss: @escaping () -> Void)

    /// The content and behavior of the view.
    ///
    /// When you implement a custom view, you must implement a computed
    /// `body` property to provide the content for your view. Return a view
    /// that's composed of built-in views that SwiftUI provides, plus other
    /// composite views that you've already defined:
    ///
    ///     struct MyView: View {
    ///         var body: some View {
    ///             Text("Hello, World!")
    ///         }
    ///     }
    ///
    /// For more information about composing views and a view hierarchy,
    /// see <doc:Declaring-a-Custom-View>.
    @MainActor public var body: some View { get }

    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required ``View/body-swift.property`` property.
    public typealias Body = some View
}

/// PrismSessionViewController functions as the one-stop Capture View.
/// The PrismSessionViewController handles all of the capturing, recording,
/// and posing of the person. This is to help simplify the entire process.
///
/// Examples:
/// UIKit
/// ```swift
/// let captureViewController = PrismSessionViewController(theme: .default, delegate: self)
/// self.present(captureViewController, animated: true)
/// ```
/// The Delegate is optional, but is required to do anything meaningful with the capture.
/// UIKit
/// ```swift
/// func prismSession(_ controller: PrismSessionViewController, didRecieveArchive archive: URL) {
///    print("Recording File URL: \(archive)")
/// }
///
/// func prismSession(willDismiss controller: PrismSessionViewController) {
///    controller.dismiss(animated: true)
/// }
/// ```
///
/// > Warning: This requires you to add the `Privacy - Camera Usage Description`
/// > key to your Info.plist file. Apple requires a description in detail of why
/// > you need access to the camera, and what you are doing with it.
///
@MainActor @objc public class PrismSessionViewController : UIViewController {

    /// Creates a ``PrismSessionViewController`` to faciliate the recording of a body scan.
    ///
    /// UIKit
    /// ```swift
    /// let captureViewController = PrismSessionViewController(theme: .default, delegate: self)
    /// ```
    ///
    /// - Parameters:
    ///     - theme: The theme configuration to apply to the session (Refer to ``PrismThemeConfiguration`` for options)
    ///     - delegate: An optional delegate to return capture information
    ///
    /// - Returns: A ``PrismSessionViewController``.
    @MainActor public init(theme: PrismSDK.PrismThemeConfiguration = .default, delegate: (any PrismSDK.PrismSessionViewControllerDelegate)? = nil)

    @MainActor override dynamic public func viewDidLoad()
}

/// The delegate callbacks for the ``PrismSessionViewController``
public protocol PrismSessionViewControllerDelegate : AnyObject {

    /// When a capture and an archive completes
    ///
    /// When a capture and archive completes, this delegate method is called to allow the
    /// parent ViewController to handle what to do with the archive.
    ///
    /// - Parameters:
    ///   - controller: The ``PrismSessionViewController`` returning the archive
    ///   - archive: The File path of the Archive stored on the system
    func prismSession(_ controller: PrismSDK.PrismSessionViewController, didRecieveArchive archive: URL)

    /// When the capture state changes
    ///
    /// This is called everytime a state changes within the capture flow.
    /// This can be used for analytic events.
    ///
    /// - Parameters:
    ///   - controller: The ``PrismSessionViewController`` returning the archive
    ///   - status: The status of the CaptureSession
    func prismSession(_ controller: PrismSDK.PrismSessionViewController, didChangeStatus status: PrismSDK.CaptureSessionState)

    /// The ``PrismSessionViewController`` that will dimiss
    ///
    /// This `willDimiss` method allows you to perform any actions you need before calling the
    /// `controller.dismiss(animated: true)` method. This is required to dismiss the presented view controller.
    ///
    /// - Parameter controller: The ``PrismSessionViewController`` that you wish to dismiss
    func prismSession(willDismiss controller: PrismSDK.PrismSessionViewController)
}

/// The state of the State Manager
@frozen public enum PrismState : String, Equatable, CaseIterable, Identifiable {

    /// Idle / Waiting. This is the default state
    case idle

    /// When the state manager is performing it's action
    case running

    /// State manager finished
    case finished

    /// The id
    public var id: PrismSDK.PrismState { get }

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
    public typealias AllCases = [PrismSDK.PrismState]

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = PrismSDK.PrismState

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PrismSDK.PrismState] { get }

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

extension PrismState : Hashable {
}

extension PrismState : RawRepresentable {
}

extension PrismState : Sendable {
}

/// Prism State Manager
///
/// Handles the state of each manager within the flow
public protocol PrismStateManager : ObservableObject {

    /// THe wait time before the step can be marked as finished
    var waitTime: TimeInterval { get }

    /// The current state of the manager
    var state: PrismSDK.PrismState { get }

    /// Start the manager
    func start()

    /// Stop the manager
    func stop()
}

/// Defines all of the available properties for theming the PrismSession
///
/// Colors, Fonts, and Corner Radius'
public struct PrismThemeConfiguration {

    /// The current theme applied
    public static var current: PrismSDK.PrismThemeConfiguration

    /// Primary Color
    public var primaryColor: Color

    /// Secondary Color
    public var secondaryColor: Color

    /// tertiary Color
    public var tertiaryColor: Color

    /// Disabled Color
    public var disabledColor: Color

    /// Shadow Color
    public var shadowColor: Color

    /// Border Color
    public var borderColor: Color

    /// Success color for anything that is successful
    public var successColor: Color

    /// Error color for anything that is an error
    public var errorColor: Color

    /// Primary Icon colors
    public var primaryIconColor: Color

    /// Secondary Icon colors
    public var secondaryIconColor: Color

    /// tertiary Icon colors
    public var tertiaryIconColor: Color

    /// Icon background colors
    public var iconBackgroundColor: Color

    /// Overlay Color used for separating the Alerts or Camera Feed
    public var overlayColor: Color

    /// The Background colors for the elements
    public var backgroundColor: Color

    /// The Secondary Background Color
    public var secondaryBackgroundColor: Color

    /// Outline Gradient
    public var outlineGradient: LinearGradient

    /// The title text color used across the entire capture session
    public var titleTextColor: Color

    /// The general text color used across the entire capture session
    public var textColor: Color

    /// The Disabled Text Color (Currently used for buttons only)
    public var disabledTextColor: Color

    /// Text color for primary button styles
    public var buttonTextColor: Color

    /// Large Title font style
    public var largeTitleFont: Font

    /// Title font style
    public var titleFont: Font

    /// Title 2 font style
    public var secondaryTitleFont: Font

    /// Title 3 font style
    public var tertiaryTitleFont: Font

    /// Body font style
    public var bodyFont: Font

    /// Button Corner Radius
    public var primaryButtonCornerRadius: CGFloat

    /// Small Button Corner Radius
    public var smallButtonCornerRadius: CGFloat

    /// Card Corner Radius (Alerts and Banners)
    public var cardCornerRadius: CGFloat

    /// Popup Sheet Corner Radius
    public var sheetCornerRadius: CGFloat

    /// Arrow Down Icon
    public var arrowDownIcon: Image

    /// Arrow Left Icon
    public var arrowLeftIcon: Image

    /// Arrow Right Icon
    public var arrowRightIcon: Image

    /// Arrow Up Icon
    public var arrowUpIcon: Image

    /// Chevron Down Icon
    public var chevronDownIcon: Image

    /// Chevron Left Icon
    public var chevronLeftIcon: Image

    /// Chevron Right Icon
    public var chevronRightIcon: Image

    /// Chevron Up Icon
    public var chevronUpIcon: Image

    /// Alert Icon
    public var alertIcon: Image

    /// Body Icon
    public var bodyIcon: Image

    /// Body Scan Icon
    public var bodyScanIcon: Image

    /// Large Body Scan Icon
    public var bodyScanLargeIcon: Image

    /// Body Overlay Icon
    public var bodyOverlayIcon: Image

    /// Book Icon
    public var bookIcon: Image

    /// Check Icon
    public var checkIcon: Image

    /// Checkbox Checked Icon
    public var checkboxCheckedIcon: Image

    /// Checkbox Unchecked Icon
    public var checkboxUncheckedIcon: Image

    /// Close Icon
    public var closeIcon: Image

    /// Help Icon
    public var helpIcon: Image

    /// Help Icon
    public var infoIcon: Image

    /// Loading Icon
    public var loadingIcon: Image

    /// Minus Icon
    public var minusIcon: Image

    /// Phone Icon
    public var phoneIcon: Image

    /// Play Icon
    public var playIcon: Image

    /// Plus Icon
    public var plusIcon: Image

    /// Rotate Icon
    public var rotateIcon: Image

    /// Ruler Icon
    public var rulerIcon: Image

    /// Spin Icon
    public var spinIcon: Image

    /// User Icon
    public var userIcon: Image

    /// Volume Low Icon
    public var volumeLowIcon: Image

    /// Volume Medium Icon
    public var volumeMediumIcon: Image

    /// Volume High Icon
    public var volumeHighIcon: Image

    /// Volume Mute Icon
    public var volumeMuteIcon: Image

    /// Move Camera Up Icon
    public var moveCameraUpIcon: Image

    /// Move Camera Down Icon
    public var moveCameraDownIcon: Image

    /// Phone Position Icon
    public var phonePositionIcon: Image
}

extension PrismThemeConfiguration {

    /// Creates a new theme object
    ///
    /// This allows you to specify any of the given properties in a theme.
    /// If any are not defined or are nil, the defaults will be used.
    public init(primaryColor: Color? = nil, secondaryColor: Color? = nil, tertiaryColor: Color? = nil, disabledColor: Color? = nil, shadowColor: Color? = nil, borderColor: Color? = nil, successColor: Color? = nil, errorColor: Color? = nil, primaryIconColor: Color? = nil, secondaryIconColor: Color? = nil, tertiaryIconColor: Color? = nil, iconBackgroundColor: Color? = nil, overlayColor: Color? = nil, backgroundColor: Color? = nil, secondaryBackgroundColor: Color? = nil, outlineGradient: LinearGradient? = nil, titleTextColorL: Color? = nil, titleTextColor: Color? = nil, textColor: Color? = nil, buttonTextColor: Color? = nil, disabledTextColor: Color? = nil, largeTitleFont: Font? = nil, titleFont: Font? = nil, secondaryTitleFont: Font? = nil, tertiaryTitleFont: Font? = nil, bodyFont: Font? = nil, primaryButtonCornerRadius: CGFloat? = nil, smallButtonCornerRadius: CGFloat? = nil, cardCornerRadius: CGFloat? = nil, sheetCornerRadius: CGFloat? = nil, arrowDownIcon: Image? = nil, arrowLeftIcon: Image? = nil, arrowRightIcon: Image? = nil, arrowUpIcon: Image? = nil, chevronDownIcon: Image? = nil, chevronLeftIcon: Image? = nil, chevronRightIcon: Image? = nil, chevronUpIcon: Image? = nil, alertIcon: Image? = nil, bodyIcon: Image? = nil, bodyScanIcon: Image? = nil, bodyScanLargeIcon: Image? = nil, bodyOverlayIcon: Image? = nil, bookIcon: Image? = nil, checkIcon: Image? = nil, checkboxCheckedIcon: Image? = nil, checkboxUncheckedIcon: Image? = nil, closeIcon: Image? = nil, helpIcon: Image? = nil, infoIcon: Image? = nil, loadingIcon: Image? = nil, minusIcon: Image? = nil, phoneIcon: Image? = nil, playIcon: Image? = nil, plusIcon: Image? = nil, rotateIcon: Image? = nil, rulerIcon: Image? = nil, spinIcon: Image? = nil, userIcon: Image? = nil, volumeLowIcon: Image? = nil, volumeMediumIcon: Image? = nil, volumeHighIcon: Image? = nil, volumeMuteIcon: Image? = nil, moveCameraUpIcon: Image? = nil, moveCameraDownIcon: Image? = nil, phonePositionIcon: Image? = nil)
}

extension PrismThemeConfiguration {

    /// Default "Prism" UI Theme.
    public static let `default`: PrismSDK.PrismThemeConfiguration
}

extension PrismThemeConfiguration : EnvironmentKey {

    /// The default value for the environment key.
    public static let defaultValue: PrismSDK.PrismThemeConfiguration

    /// The associated type representing the type of the environment key's
    /// value.
    public typealias Value = PrismSDK.PrismThemeConfiguration
}

/// Returned Scan Object
public struct Scan : Codable, Sendable {

    /// Scan ID
    public let id: String

    /// The id of the User who created the scan
    public let userId: String

    /// The token of the User who created the scan
    public let userToken: String

    /// The `Status` of the Scan
    public let status: PrismSDK.Scan.Status

    /// The device configuration used for the scan
    public let deviceConfigName: String

    /// Scan assets config id
    public let assetConfigId: String

    /// The weight of the user
    public let weight: PrismSDK.Weight

    /// The height of the user
    public let height: PrismSDK.Height

    /// The measurements information for the scan
    public let measurements: PrismSDK.Measurements?

    /// The body fat information for the scan
    public let bodyfat: PrismSDK.Bodyfat?

    /// Scan asset information
    public let scanAssets: PrismSDK.ScanAsset?

    /// Created at
    public let createdAt: Date

    /// Updated at
    public let updatedAt: Date

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

extension Scan : Identifiable {

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = String
}

extension Scan : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PrismSDK.Scan, rhs: PrismSDK.Scan) -> Bool
}

extension Scan : Hashable {

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

extension Scan {

    public static let createdPreview: PrismSDK.Scan

    public static let processingPreview: PrismSDK.Scan

    public static let failedPreview: PrismSDK.Scan

    public static let readyPreview: PrismSDK.Scan
}

extension Scan {

    /// Scan state
    ///
    /// This returns the state the scan is in.
    public enum Status : String, Codable, CaseIterable, Identifiable, Sendable {

        /// Scan was just created
        case created

        /// Scan is in the middle of processing the upload
        case processing

        /// Scan is complete without an error
        case ready

        /// Scan returned an error and failed
        case failed

        /// The stable identity of the entity associated with this instance.
        public var id: PrismSDK.Scan.Status { get }

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
        public typealias AllCases = [PrismSDK.Scan.Status]

        /// A type representing the stable identity of the entity associated with
        /// an instance.
        public typealias ID = PrismSDK.Scan.Status

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = String

        /// A collection of all values of this type.
        public static var allCases: [PrismSDK.Scan.Status] { get }

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
}

extension Scan.Status : Equatable {
}

extension Scan.Status : Hashable {
}

extension Scan.Status : RawRepresentable {
}

/// The scan asset information
public struct ScanAsset : Codable, Sendable {

    /// The id of the scan asset model
    public let id: String

    /// The id of the scan
    public let scanId: String

    /// Capture asset state information
    public let captureAsset: PrismSDK.Asset?

    /// Body asset state information
    public let bodyAsset: PrismSDK.Asset?

    /// Fitted asset state information
    public let fittedBodyAsset: PrismSDK.Asset?

    /// Measurment asset state information
    public let measurementAsset: PrismSDK.Asset?

    /// Created at date
    public let createdAt: Date

    /// Updated at date
    public let updatedAt: Date

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

extension ScanAsset : Identifiable {

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = String
}

extension ScanAsset : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: PrismSDK.ScanAsset, rhs: PrismSDK.ScanAsset) -> Bool
}

extension ScanAsset : Hashable {

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

/// ScanClient contains all of the API calls for creating,
/// fetching, and uploading scan information. This includes
/// generting the Upload URL.
public struct ScanClient : Sendable {

    /// Initialize the ScanClient
    ///
    /// - Parameters
    ///     - client: The ApiClient to be injected.
    public init(client: PrismSDK.ApiClient)

    /// Create a new scan
    /// Create a new scan that can be used for uploading the recording to.
    ///
    /// - Parameters:
    ///     - newScan: The New Scan Payload. See ``NewScan`` for more information
    /// - Returns: A ``Scan`` object
    public func createScan(_ newScan: PrismSDK.NewScan) async throws -> PrismSDK.Scan

    /// Get Scan
    /// Fetches an existing scan
    ///
    /// - Parameters:
    ///     - id: The ID of the scan to fetch
    /// - Returns: A ``Scan`` object
    public func getScan(forScan id: String) async throws -> PrismSDK.Scan

    /// Get Paginated Scans
    /// Fetches existing scans for a user in paginated form
    ///
    /// - Parameters:
    ///     - token: The token of the user to fetch all scans for
    ///     - limit: The amount to return on each page
    ///     - cursor: The cursor the fetch scans from
    ///     - order: The order to return the scans in
    ///
    /// - Returns: A ``Paginated`` object containing the scans and cursor information
    public func getScans(forUser token: String, limit: Int = 25, cursor: String? = nil, order: PrismSDK.Sort = .descending) async throws -> PrismSDK.Paginated<PrismSDK.Scan>

    /// Delete Scan
    /// Deletes an existing scan
    ///
    /// - Parameters:
    ///     - id: The ID of the scan to delete
    /// - Returns: A ``Scan`` object
    public func deleteScan(_ id: String) async throws -> PrismSDK.Scan

    /// Upload URL
    /// Generate a new upload URL for the scan. This used to upload the
    /// body recording.
    ///
    /// - Parameters:
    ///     - id: The ID of the scan to generate an URL for.
    /// - Returns: An ``UploadUrl`` object
    public func uploadUrl(forScan id: String) async throws -> PrismSDK.UploadUrl

    /// Asset URLs
    /// Fetches all the asset urls for a given scan
    ///
    /// - Parameters:
    ///     - id: The ID of the scan to fetch the asset urls for
    /// - Returns: An ``AssetUrls`` object
    public func assetUrls(forScan id: String) async throws -> PrismSDK.AssetUrls

    /// Asset URL
    /// Fetches a single url for a given scan
    ///
    /// - Parameters:
    ///     - id: The ID of the scan to fetch the asset url for
    /// - Returns: A ``String`` object
    public func assetUrl(forScan id: String, option: PrismSDK.AssetUrls.Option) async throws -> String

    /// Measurements
    /// Fetches the body measurement information
    ///
    /// - Parameters:
    ///     - id: The ID of the scan to fetch the measurements for
    /// - Returns: A ``Measurements`` object
    public func measurements(forScan id: String) async throws -> PrismSDK.Measurements

    /// Create new body shape prediction
    /// Start a new new body shape prediction for a specific scanId provided in
    /// the request body
    ///
    /// - Parameters:
    ///     - payload: Data required for the body shape prediction creation
    /// - Returns: A ``BodyShapePrediction`` object
    public func createBodyShapePrediction(_ payload: PrismSDK.BodyShapePredictionPayload) async throws -> PrismSDK.BodyShapePrediction

    /// Get body shape prediction status
    ///
    /// - Parameters:
    ///     - id: Unique body prediction id that was previously created
    /// - Returns: A ``BodyShapePrediction`` object
    public func getBodyShapePrediction(forBodyShapePrediction id: String) async throws -> PrismSDK.BodyShapePrediction

    /// Get body shape prediction asset download url
    ///
    /// - Parameters:
    ///     - id: Unique body prediction id that was previously created
    /// - Returns: A ``BodyShapePredictionAssetUrl`` object
    public func getBodyShapePredictionAsset(forBodyShapePrediction id: String) async throws -> PrismSDK.BodyShapePredictionAssetUrl
}

/// Used as the Primary Action button for all CTA style buttons
public struct SecondaryActionButtonStyle : ButtonStyle {

    public init()

    /// Creates a view that represents the body of a button.
    ///
    /// The system calls this method for each ``Button`` instance in a view
    /// hierarchy where this style is the current button style.
    ///
    /// - Parameter configuration : The properties of the button.
    public func makeBody(configuration: PrismSDK.SecondaryActionButtonStyle.Configuration) -> some View


    /// A view that represents the body of a button.
    public typealias Body = some View
}

/// The sex for the user
public enum Sex : String, Codable, CaseIterable, Identifiable, Sendable {

    /// Male
    case male

    /// Female
    case female

    /// Neurtral
    case neutral

    /// The stable identity of the entity associated with this instance.
    public var id: PrismSDK.Sex { get }

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
    public typealias AllCases = [PrismSDK.Sex]

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = PrismSDK.Sex

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PrismSDK.Sex] { get }

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

extension Sex : Equatable {
}

extension Sex : Hashable {
}

extension Sex : RawRepresentable {
}

/// Sorting values
public enum Sort : String, CaseIterable, Identifiable, Sendable {

    /// Ascending order
    case ascending

    /// Descending order
    case descending

    /// The stable identity of the entity associated with this instance.
    public var id: PrismSDK.Sort { get }

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
    public typealias AllCases = [PrismSDK.Sort]

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = PrismSDK.Sort

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    ///
    /// Every distinct value of the conforming type has a corresponding unique
    /// value of the `RawValue` type, but there may be values of the `RawValue`
    /// type that don't have a corresponding value of the conforming type.
    public typealias RawValue = String

    /// A collection of all values of this type.
    public static var allCases: [PrismSDK.Sort] { get }

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

extension Sort : Equatable {
}

extension Sort : Hashable {
}

extension Sort : RawRepresentable {
}

public struct TermsOfService : Codable, Sendable {

    /// Whether a user accepted the terms
    public let accepted: Bool

    /// Optional terms version identifier
    public let version: String?

    /// Create a new `TermsOfService` object
    ///
    /// Contains two parameters. The accepted is required
    /// and the version is optional
    ///
    /// - Parameters:
    ///   - accepted: The value of whether the user accepted the terms or not
    ///   - version: The version of the terms accepted
    public init(accepted: Bool, version: String?)

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

/// Upload URL object
public struct UploadUrl : Codable, Sendable {

    /// The signed URL for uploading a scan
    public let url: String

    /// The expiration date the URL expires
    public let expirationTime: Date

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

/// A User Model returned from the Prism API to describe the active person.
///
/// This contains all of the available fields on the user model.
public struct User : Codable, Sendable {

    /// The internal id of the user model
    public let id: String

    /// The token for the user
    public let token: String

    /// The email of the user
    public let email: String?

    /// The ``Sex`` of the user
    public let sex: PrismSDK.Sex

    /// The region the user resides in
    public let region: String

    /// The US state the user resides in
    public let usaResidence: String?

    /// The birthdate of the user
    public let birthDate: Date

    /// The weight of the suer
    public let weight: PrismSDK.Weight

    /// The height of the user
    public let height: PrismSDK.Height

    /// Research Consent for the user. This is used to enroll or unenroll the user in using the
    /// uploaded body scans for training purposes.
    public let researchConsent: Bool

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

/// The UserClient contains all of the API calls for
/// managing users.
public struct UserClient : Sendable {

    /// Initialize the UserClient
    ///
    /// - Parameters
    ///     - client: The ApiClient to be injected.
    public init(client: PrismSDK.ApiClient)

    /// Create a new user. This method is an upsert, meaning if the user does
    /// not exist a new user is created otherwise the existing user is updated.
    ///
    /// - Parameters
    ///     - newUser: A new user that will be created or an existing user that will be updated.
    /// - Returns: A ``User`` object
    public func create(user newUser: PrismSDK.NewUser) async throws -> PrismSDK.User

    /// Update an existing user. The user must exist before this method is called,
    /// otherwise it will throw a 404 user not found error.
    ///
    /// - Parameters
    ///     - user: Existing user that will be updated.
    /// - Returns: A ``User`` object
    public func update(user: PrismSDK.ExistingUser) async throws -> PrismSDK.User

    /// Fetch an existing user
    ///
    /// - Parameters
    ///     - token: The user's token
    /// - Returns: A ``User`` object
    public func fetchUser(for token: String) async throws -> PrismSDK.User
}

public struct Version {

    public static var current: PrismSDK.Version { get }

    public let major: UInt

    public let minor: UInt

    public let patch: UInt

    public let build: UInt

    public var semanticVersionNumber: String { get }

    public var buildNumber: String { get }
}

extension Version : CustomStringConvertible {

    /// A textual representation of this instance.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(describing:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `description` property for types that conform to
    /// `CustomStringConvertible`:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    public var description: String { get }
}

/// Vision Detection State
///
/// THe states used for telling the drawing system what type of drawing we want to occur
@frozen public enum VisionDetectionState {

    /// Idle
    ///
    /// No drawing will occur ing this step
    case idle

    /// Pose Detection
    ///
    /// The Pose Dectection Drawing state. This will draw the Skeleton ouline on the body
    case pose

    /// Positiong Detection
    ///
    /// This does not perform any drawing on the Camera frame
    case position

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: PrismSDK.VisionDetectionState, b: PrismSDK.VisionDetectionState) -> Bool

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

extension VisionDetectionState : Equatable {
}

extension VisionDetectionState : Hashable {
}

extension VisionDetectionState : Sendable {
}

/// Weight information for the scan
public struct Weight : Codable, Sendable {

    /// The weight value of the user
    public let value: Double

    /// The unit used to format the value
    public let unit: PrismSDK.Weight.Unit

    /// Create a new ``Weight`` object
    /// - Parameters:
    ///   - value: The measurment in weight for the user
    ///   - unit: The units of format used
    public init(value: Double, unit: PrismSDK.Weight.Unit)

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

extension Weight {

    /// The unit of measurment
    public enum Unit : String, Codable, CaseIterable, Identifiable, Sendable {

        /// Imperial (Pounds)
        case pounds

        /// Metric (Kilograms)
        case kilograms

        /// The stable identity of the entity associated with this instance.
        public var id: PrismSDK.Weight.Unit { get }

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
        public typealias AllCases = [PrismSDK.Weight.Unit]

        /// A type representing the stable identity of the entity associated with
        /// an instance.
        public typealias ID = PrismSDK.Weight.Unit

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = String

        /// A collection of all values of this type.
        public static var allCases: [PrismSDK.Weight.Unit] { get }

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
}

extension Weight.Unit : Equatable {
}

extension Weight.Unit : Hashable {
}

extension Weight.Unit : RawRepresentable {
}

extension LinearGradient {

    public static let prismGradient: LinearGradient

    public static let prismErrorGradient: LinearGradient
}

extension Bundle {

    public static let prism: Bundle
}

extension Color {

    public static let prismBase50: Color

    public static let prismBase40: Color

    public static let prismBase30: Color

    public static let prismBase20: Color

    public static let prismBase15: Color

    public static let prismBase10: Color

    public static let prismBase5: Color

    public static let prismBase2: Color
}

extension EnvironmentValues {

    public var prismThemeConfiguration: PrismSDK.PrismThemeConfiguration
}

extension View {

    /// Apply a specific theme property to the view
    ///
    /// This uses KeyPath's to apply a property and value.
    @MainActor public func theme<T>(_ keyPath: WritableKeyPath<PrismSDK.PrismThemeConfiguration, T>, _ value: T) -> some View


    /// Applies a ``PrismThemeConfiguration`` object
    @MainActor public func applyTheme(_ theme: PrismSDK.PrismThemeConfiguration) -> some View

}

extension Image {

    public static let arrowDown: Image

    public static let arrowLeft: Image

    public static let arrowRight: Image

    public static let arrowUp: Image

    public static let chevronDown: Image

    public static let chevronLeft: Image

    public static let chevronRight: Image

    public static let chevronUp: Image

    public static let alert: Image

    public static let body: Image

    public static let bodyScan: Image

    public static let bodyScanLarge: Image

    public static let bodyOverlay: Image

    public static let book: Image

    public static let check: Image

    public static let checkboxChecked: Image

    public static let checkboxUnchecked: Image

    public static let close: Image

    public static let help: Image

    public static let info: Image

    public static let loading: Image

    public static let minus: Image

    public static let phone: Image

    public static let play: Image

    public static let plus: Image

    public static let rotate: Image

    public static let ruler: Image

    public static let spin: Image

    public static let user: Image

    public static let volumeLow: Image

    public static let volumeMedium: Image

    public static let volumeHigh: Image

    public static let volumeMute: Image

    public static let moveCameraUp: Image

    public static let moveCameraDown: Image

    public static let phonePosition: Image
}


*/
