import Foundation

/// Represents the health report response from Prism's API
@objcMembers public class HealthReport: NSObject, Codable {
    public let scan: ScanInfo
    public let user: UserInfo
    public let bodyFatPercentageReport: BodyFatReport
    public let leanMassReport: LeanMassReport
    public let fatMassReport: FatMassReport
    public let waistCircumferenceReport: WaistReport
    public let waistToHipRatioReport: WaistToHipReport
    public let waistToHeightRatioReport: WaistToHeightReport
    public let metabolismReport: MetabolismReport
    
    // MARK: - Nested Types
    
    public struct ScanInfo: Codable {
        public let id: String
        public let createdAt: Date
    }
    
    public struct UserInfo: Codable {
        public let id: String
        public let token: String
        public let weight: Double
        public let height: Double
        public let age: Int
        public let sex: String
    }
    
    public struct Range: Codable {
        public let low: Double?
        public let high: Double?
    }
    
    public struct HealthLabelGroup: Codable {
        public let range: Range
        public let value: String
    }
    
    public struct HealthLabel: Codable {
        public let healthLabelGroups: [HealthLabelGroup]
        public let userHealthLabel: UserHealthLabel
    }
    
    public struct UserHealthLabel: Codable {
        public let range: Range
        public let value: String
    }
    
    public struct PercentileGroup: Codable {
        public let range: Range
        public let value: Int
    }
    
    public struct UserPercentile: Codable {
        public let range: Range
        public let value: Int
    }
    
    public struct AgeRange: Codable {
        public let low: Int
        public let high: Int
    }
    
    public struct Percentile: Codable {
        public let percentileGroups: [PercentileGroup]
        public let userPercentile: UserPercentile
        public let userAgeRange: AgeRange
    }
    
    public struct BodyFatReport: Codable {
        public let bodyFatPercentage: Double
        public let healthLabel: HealthLabel
        public let percentile: Percentile
    }
    
    public struct LeanMassReport: Codable {
        public let leanMass: Double
        public let healthLabel: HealthLabel
        public let percentile: Percentile
    }
    
    public struct FatMassReport: Codable {
        public let fatMass: Double
        public let healthLabel: HealthLabel
        public let percentile: Percentile
    }
    
    public struct WaistReport: Codable {
        public let waistCircumference: Double
        public let healthLabel: HealthLabel
        public let percentile: Percentile
    }
    
    public struct WaistToHipReport: Codable {
        public let waistToHipRatio: Double
        public let healthLabel: HealthLabel
        public let percentile: Percentile
    }
    
    public struct WaistToHeightReport: Codable {
        public let waistToHeightRatio: Double
        public let healthLabel: HealthLabel
        public let percentile: Percentile
    }
    
    public struct EnergyExpenditure: Codable {
        public let maintainTdee: Double
        public let cutTdee: TdeeRange
        public let buildTdee: TdeeRange
    }
    
    public struct TdeeRange: Codable {
        public let minimum: Double
        public let maximum: Double
    }
    
    public struct MetabolismReport: Codable {
        public let basalMetabolicRate: Double
        public let energyExpenditures: EnergyExpenditures
        public let recommendations: Recommendations
    }
    
    public struct EnergyExpenditures: Codable {
        public let sedentary: EnergyExpenditure
    }
    
    public struct Recommendations: Codable {
        public let cut: String
        public let build: String
    }
} 
