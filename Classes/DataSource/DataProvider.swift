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
        let exists = fileManager.fileExists(atPath: fullURL.path)
        if !exists {
            let localURL = Bundle.main.bundleURL.appendingPathComponent(filename)
            try! fileManager.copyItem(atPath: localURL.path, toPath: fullURL.path)
        }
        return fullURL.absoluteString
    }
    
    private func getExerciseData() -> (minutes: Double,
                                       calories: Double,
                                       trackerCalories: Double,
                                       steps: Double) {
        guard let database = database, database.open() == true else { return (0, 0, 0, 0) }
        // If the user desires to combine the calories from a tracking device or not.
        let combineTrackingCalories = UserDefaults.standard.bool(forKey: "CalorieTrackingDevice")
        
        let sourceDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: sourceDate)
        
        let query = String(format: "SELECT Exercise_Log.Exercise_Log_ID, Exercise_Log.ExerciseID, Exercise_Log.Exercise_Time_Minutes, Exercise_Log.Log_Date, Exercises.ActivityName, Exercises.CaloriesPerHour FROM Exercise_Log INNER JOIN Exercises ON Exercise_Log.ExerciseID = Exercises.ExerciseID WHERE (Exercise_Log.Log_Date BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) ORDER BY Log_Date", dateString, dateString)
        
        var totalCaloriesBurned = 0.0
        var totalCaloriesBurnedViaTracker = 0.0
        var minutesExercised = 0.0
        var stepsTaken = 0.0

        do {
            let rs = try database.executeQuery(query, values: nil)
            while rs.next() {
                let exerciseID = rs.object(forColumn: "ExerciseID") as? NSNumber
                let timeMinutes = rs.double(forColumn: "Exercise_Time_Minutes")
                let caloriesPerHour = rs.double(forColumn: "CaloriesPerHour")
                let currentWeight = 0.0
                totalCaloriesBurned = (caloriesPerHour / 60) * currentWeight * timeMinutes;
                
                // If a health tracking device is used, add those values.
                // Note, timeMinutes is actually "calories burned" or "steps" when
                // a tracking device is used.
                
                // Exercise IDs and their values:
                // 257 = Override Calories Burned
                // 267 = Fitbit Calories
                // 268 = Movband Moves
                // 272 = Apple Calories
                // 275 = Garmin Calories
                // Check if the exercise was a calorie override.
                if (exerciseID == 257 || exerciseID == 267 ||
                    exerciseID == 272 || exerciseID == 275) {
                    totalCaloriesBurnedViaTracker += timeMinutes
                    if (combineTrackingCalories) {
                        totalCaloriesBurned += timeMinutes
                    }
                // Handle step trackers.
                // 259 = Override Steps Taken
                // 269 = Movband Steps
                // 276 = Garmin Steps
                // 274 = Apple Steps
                } else if exerciseID == 259 || exerciseID == 269 ||
                            exerciseID == 276 || exerciseID == 274 {
                    stepsTaken += timeMinutes
                } else {
                    totalCaloriesBurned += totalCaloriesBurned
                    minutesExercised += timeMinutes
                }
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return (0, 0, 0, 0)
        }
        return (minutesExercised, totalCaloriesBurned,
                totalCaloriesBurnedViaTracker, stepsTaken)
    }
    
    /// Previously was stored in UserDefaults "minutesExercised" key.
    @objc public func getMinutesExercisedToday() -> Double {
        return self.getExerciseData().minutes
    }

    /// Today's values. Defaults to zero.
    @objc public func getCaloriesBurnedToday() -> Double {
        return self.getExerciseData().calories
    }

    /// Today's values. Defaults to zero.
    @objc public func getCaloriesBurnedTodayViaTracker() -> Double {
        return self.getExerciseData().trackerCalories
    }
    
    /// Today's values. Defaults to zero.
    @objc public func getStepsTakenToday() -> Double {
        return self.getExerciseData().steps
    }

}
