//
//  DataProvider.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/23/23.
//

import Foundation
import FMDB

/// Class that provides data from a local cache or
/// database.
@objc @objcMembers final class DataProvider: NSObject {
    private var database: FMDatabase?
    
    // Singleton, main access point.
    @objc static let sharedInstance = DataProvider()
    
    /// Current user. Nil if logged out.
    public var currentUser: DMUser?

   
    private override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        database = FMDatabase(path: databasePath())
    }

    /// Gets the database path. Nil if not found.
    private func databasePath() -> String? {
        guard let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let filename = "DMGO_v3.9.2.sqlite"
        let fullURL = pathURL.appendingPathComponent(filename)
        let fileManager = FileManager.default
        let exists = fileManager.fileExists(atPath: fullURL.absoluteString)
        if !exists {
            let localURL = Bundle.main.bundleURL.appendingPathComponent(filename)
            try! fileManager.copyItem(atPath: localURL.absoluteString, toPath: fullURL.absoluteString)
        }
        return fullURL.absoluteString
    }
    
    /// Today's values. Defaults to zero.
    /// Previously was stored in UserDefaults "minutesExercised" key.
    @objc public func getMinutesExercisedToday() -> NSInteger {
        guard let database = database, database.open() == true else { return 0 }
        
        let combineTrackingCalories = UserDefaults.standard.bool(forKey: "CalorieTrackingDevice")
        
        let sourceDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: sourceDate)

        let query = String(format: "SELECT Exercise_Log.Exercise_Log_ID, Exercise_Log.ExerciseID, Exercise_Log.Exercise_Time_Minutes, Exercise_Log.Log_Date, Exercises.ActivityName, Exercises.CaloriesPerHour FROM Exercise_Log INNER JOIN Exercises ON Exercise_Log.ExerciseID = Exercises.ExerciseID WHERE (Exercise_Log.Log_Date BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) ORDER BY Log_Date", dateString, dateString)
        
        var totalCaloriesBurned = 0.0
        var totalCaloriesBurnedTracked = 0.0
        
        do {
            let rs = try database.executeQuery(query, values: nil)
            while rs.next() {
                let exerciseID = rs.object(forColumn: "ExerciseID") as? NSNumber
                let timeMinutes = rs.double(forColumn: "Exercise_Time_Minutes")
                let caloriesPerHour = rs.double(forColumn: "CaloriesPerHour")
                let currentWeight = 0.0
                var totalCaloriesBurned = (caloriesPerHour / 60) * currentWeight * timeMinutes;
                
                // If Apple watch is enabled, add it.
                // Apple watch 274 for step count. Apple watch (272) calories apple watch.
                // Note, timeMinutes is actually "calories burned" when a tracking device is used.
                if (exerciseID == 257 || exerciseID == 267 || exerciseID == 272 || exerciseID == 275) {
                    totalCaloriesBurnedTracked += timeMinutes // aka calories.
                    if (combineTrackingCalories) {
                        totalCaloriesBurned += timeMinutes // aka calories.
                    }
                } else {
                    totalCaloriesBurned += totalCaloriesBurned
                }
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return 0
        }
        return 0
    }
    
}
