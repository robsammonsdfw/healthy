import Foundation

/// Represents a complete health report from Prism's API
/// https://prism-labs.notion.site/Health-Assessment-Endpoint-03f086089b104c259127ee15cc3eae7f#bfd2116de60c4d088bf2374207187600
@objcMembers public class HealthReport: NSObject, Codable {
    public let scan: ScanInfo
    public let user: UserInfo
    public let bodyFatPercentageReport: MetricReport
    public let leanMassReport: MetricReport
    public let fatMassReport: MetricReport
    public let waistCircumferenceReport: MetricReport
    public let metabolismReport: MetabolismReport
}

/// Basic scan information
@objcMembers public class ScanInfo: NSObject, Codable {
    public let id: String
    public let createdAt: Date
}

/// Basic user information
@objcMembers public class UserInfo: NSObject, Codable {
    public let id: String
    public let token: String
    public let weight: Double
    public let age: Int
    public let sex: String
}

/// Represents a health metric report with labels and percentiles
@objcMembers public class MetricReport: NSObject, Codable {
    // Each report type has its own value field name
    private enum CodingKeys: String, CodingKey {
        case healthLabel
        case percentile
        // Value fields
        case bodyFatPercentage
        case leanMass
        case fatMass
        case waistCircumference
        case waistToHipRatio
        case waistToHeightRatio
    }
    
    public let value: Double
    public let healthLabel: HealthLabel
    public let percentile: Percentile
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try each possible value field name
        if let bodyFatPercentage = try container.decodeIfPresent(Double.self, forKey: .bodyFatPercentage) {
            value = bodyFatPercentage
        } else if let leanMass = try container.decodeIfPresent(Double.self, forKey: .leanMass) {
            value = leanMass
        } else if let fatMass = try container.decodeIfPresent(Double.self, forKey: .fatMass) {
            value = fatMass
        } else if let waistCircumference = try container.decodeIfPresent(Double.self, forKey: .waistCircumference) {
            value = waistCircumference
        } else if let waistToHipRatio = try container.decodeIfPresent(Double.self, forKey: .waistToHipRatio) {
            value = waistToHipRatio
        } else if let waistToHeightRatio = try container.decodeIfPresent(Double.self, forKey: .waistToHeightRatio) {
            value = waistToHeightRatio
        } else {
            throw DecodingError.keyNotFound(CodingKeys.bodyFatPercentage, 
                DecodingError.Context(codingPath: container.codingPath,
                                    debugDescription: "No value field found in metric report"))
        }
        
        healthLabel = try container.decode(HealthLabel.self, forKey: .healthLabel)
        percentile = try container.decode(Percentile.self, forKey: .percentile)
        
        super.init()
    }
    
    public func encode(to encoder: Encoder) throws {
        // We don't need encoding for now, but implement if needed
        throw EncodingError.invalidValue(self, EncodingError.Context(
            codingPath: encoder.codingPath,
            debugDescription: "Encoding not implemented"
        ))
    }
}

/// Health label information
@objcMembers public class HealthLabel: NSObject, Codable {
    public let healthLabelGroups: [HealthLabelGroup]
    public let userHealthLabel: UserHealthLabel
}

/// Represents a health label range and value
@objcMembers public class HealthLabelGroup: NSObject, Codable {
    public let range: Range
    public let value: String
}

/// User's specific health label
@objcMembers public class UserHealthLabel: NSObject, Codable {
    public let range: Range
    public let value: String
}

/// Percentile information
@objcMembers public class Percentile: NSObject, Codable {
    public let percentileGroups: [PercentileGroup]
    public let userPercentile: UserPercentile
    public let userAgeRange: AgeRange
}

/// Represents a percentile range and value
@objcMembers public class PercentileGroup: NSObject, Codable {
    public let range: Range
    public let value: Int
}

/// User's specific percentile
@objcMembers public class UserPercentile: NSObject, Codable {
    public let range: Range
    public let value: Int
}

/// Age range information
@objcMembers public class AgeRange: NSObject, Codable {
    public let low: Int
    public let high: Int
}

/// Range with optional low/high values
@objcMembers public class Range: NSObject, Codable {
    public let low: Double?
    public let high: Double?
}

/// Metabolism report information
@objcMembers public class MetabolismReport: NSObject, Codable {
    public let basalMetabolicRate: Int
    public let energyExpenditures: EnergyExpenditures
    public let recommendations: Recommendations
}

/// Energy expenditure calculations
@objcMembers public class EnergyExpenditures: NSObject, Codable {
    public let sedentary: SedentaryExpenditures
}

/// Sedentary energy expenditure details
@objcMembers public class SedentaryExpenditures: NSObject, Codable {
    public let maintainTdee: Int
    public let cutTdee: TdeeRange
    public let buildTdee: TdeeRange
}

/// TDEE (Total Daily Energy Expenditure) range
@objcMembers public class TdeeRange: NSObject, Codable {
    public let minimum: Int
    public let maximum: Int
}

/// Training recommendations
@objcMembers public class Recommendations: NSObject, Codable {
    public let cut: String
    public let build: String
} 
