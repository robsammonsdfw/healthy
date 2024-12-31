//
//  BodyScan.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 12/31/24.
//

import Foundation

/// Represents a scan result from the API
public struct ScanResult {
    public let id: String
    public let createdAt: Date
    public let status: String
    public let measurements: Measurements?
}

/// Represents measurement data from a scan
public struct Measurements {
    public let weight: Measurement?
    public let bodyFat: Measurement?
    public let muscleMass: Measurement?
    
    // Add new measurements from PrismSDK
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
    
    public init(weight: Measurement?, 
               bodyFat: Measurement?, 
               muscleMass: Measurement?,
               neckFit: Double = 0,
               shoulderFit: Double = 0,
               upperChestFit: Double = 0,
               chestFit: Double = 0,
               lowerChestFit: Double = 0,
               waistFit: Double = 0,
               waistNavyFit: Double = 0,
               stomachFit: Double = 0,
               hipsFit: Double = 0,
               upperThighLeftFit: Double = 0,
               upperThighRightFit: Double = 0,
               thighLeftFit: Double = 0,
               thighRightFit: Double = 0,
               lowerThighLeftFit: Double = 0,
               lowerThighRightFit: Double = 0,
               calfLeftFit: Double = 0,
               calfRightFit: Double = 0,
               ankleLeftFit: Double = 0,
               ankleRightFit: Double = 0,
               midArmRightFit: Double = 0,
               midArmLeftFit: Double = 0,
               lowerArmRightFit: Double = 0,
               lowerArmLeftFit: Double = 0,
               waistToHipRatio: Double = 0) {
        self.weight = weight
        self.bodyFat = bodyFat
        self.muscleMass = muscleMass
        self.neckFit = neckFit
        self.shoulderFit = shoulderFit
        self.upperChestFit = upperChestFit
        self.chestFit = chestFit
        self.lowerChestFit = lowerChestFit
        self.waistFit = waistFit
        self.waistNavyFit = waistNavyFit
        self.stomachFit = stomachFit
        self.hipsFit = hipsFit
        self.upperThighLeftFit = upperThighLeftFit
        self.upperThighRightFit = upperThighRightFit
        self.thighLeftFit = thighLeftFit
        self.thighRightFit = thighRightFit
        self.lowerThighLeftFit = lowerThighLeftFit
        self.lowerThighRightFit = lowerThighRightFit
        self.calfLeftFit = calfLeftFit
        self.calfRightFit = calfRightFit
        self.ankleLeftFit = ankleLeftFit
        self.ankleRightFit = ankleRightFit
        self.midArmRightFit = midArmRightFit
        self.midArmLeftFit = midArmLeftFit
        self.lowerArmRightFit = lowerArmRightFit
        self.lowerArmLeftFit = lowerArmLeftFit
        self.waistToHipRatio = waistToHipRatio
    }
}

/// Represents a single measurement with value and unit
public struct Measurement {
    public let value: Double
    public let unit: String
    
    public init(value: Double, unit: String) {
        self.value = value
        self.unit = unit
    }
    
    public var formatted: String {
        return String(format: "%.1f %@", value, unit)
    }
}
