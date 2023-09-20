//
//  DayDataProvider.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/23/23.
//

import Foundation
import FMDB

/// Class that provides a Day's data from a local cache or
/// database.
@objc @objcMembers final class DayDataProvider: NSObject {
    private var database: FMDatabase?
    private let massFormatter = MassFormatter()
    private let numberFormatter = NumberFormatter()
    
    // Singleton, main access point.
    @objc static let sharedInstance = DayDataProvider()
    
    /// Current user. Nil if logged out.
    public var currentUser: DMUser? {
        return DMAuthManager.sharedInstance().loggedInUser()
    }
    
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
    
    /// Gets the day's calorie data for use in other public functions.
    /// Passing nil will use today's date.
    private func getCalorieData(date: Date?) -> (totalCalories: Double,
                                                fatCalories: Double,
                                                carbCalories: Double,
                                                proteinCalories: Double,
                                                sugarCalories: Double,
                                                sugarGrams: Double) {
        guard let database = database, database.open() == true else {
            return (0, 0, 0, 0, 0, 0)
        }
        let sourceDate = date ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: sourceDate)
        
        let query = String(format: "SELECT Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food_Log_Items.NumberOfServings, Food.FoodKey, Food.Name, Food.Calories, Food.Fat, Food.Carbohydrates, Food.Protein, Food.Sugars, FoodMeasure.GramWeight, Food.ServingSize FROM Food_Log INNER JOIN Food_Log_Items ON Food_Log.MealID = Food_Log_Items.MealID INNER JOIN Food ON Food.FoodKey = Food_Log_Items.FoodID INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey WHERE (Food_Log.MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) AND Food_Log_Items.MeasureID = FoodMeasure.MeasureID ORDER BY Food_Log_Items.MealCode ASC", dateString, dateString)
        
        var totalCalories = 0.0
        var fatCalories = 0.0
        var carbCalories = 0.0
        var proteinCalories = 0.0
        var sugarCalories = 0.0
        var gramSugars = 0.0
        
        do {
            let rs = try database.executeQuery(query, values: nil)
            while rs.next() {
                let numberOfServings = rs.double(forColumn: "NumberOfServings")
                let gramWeight = rs.double(forColumn: "GramWeight")
                let servingSize = rs.double(forColumn: "ServingSize")
                let calories = rs.double(forColumn: "Calories")
                let protein = rs.double(forColumn: "Protein")
                let carbs = rs.double(forColumn: "Carbohydrates")
                let sugar = rs.double(forColumn:"Sugars")
                let fat = rs.double(forColumn:"Fat")
                
                let sugarGrams = sugar * numberOfServings * (gramWeight / 100 / servingSize)
                sugarCalories += (sugarGrams * 3.8)
                gramSugars += sugarGrams
                
                let totalFatCalories = numberOfServings * ((fat * 9.0) * (gramWeight / 100) / servingSize)
                fatCalories += totalFatCalories
                
                let totalCarbCalories = numberOfServings * ((carbs * 4.0) * (gramWeight / 100) / servingSize)
                carbCalories += totalCarbCalories
                                
                let totalProteinCalories = numberOfServings * ((protein * 4.0) * (gramWeight / 100) / servingSize)
                proteinCalories += totalProteinCalories
                                
                totalCalories += numberOfServings * ((calories * (gramWeight / 100)) / servingSize)
            }
        } catch let error {
            debugPrint("Error: \(error.localizedDescription)")
            return (0, 0, 0, 0, 0, 0)
        }

        return (totalCalories, fatCalories, carbCalories,
                proteinCalories, sugarCalories, gramSugars)
    }
    
    /// Gets the day's exercise data for use in other public functions.
    private func getExerciseData(date: Date?) -> (minutes: Double,
                                                  loggedCalories: Double,
                                                  exerciseCalories: Double,
                                                  trackerCalories: Double,
                                                  steps: Double) {
        guard let database = database, database.open() == true else { return (0, 0, 0, 0, 0) }
        guard let currentUser = currentUser else { return (0, 0, 0, 0, 0) }
        
        let sourceDate = date ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: sourceDate)
        
        let query = String(format: "SELECT Exercise_Log.Exercise_Log_ID, Exercise_Log.ExerciseID, Exercise_Log.Exercise_Time_Minutes, Exercise_Log.Log_Date, Exercises.ActivityName, Exercises.CaloriesPerHour FROM Exercise_Log INNER JOIN Exercises ON Exercise_Log.ExerciseID = Exercises.ExerciseID WHERE (Exercise_Log.Log_Date BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) ORDER BY Log_Date", dateString, dateString)
        
        // How many calories were burned that should be added into
        // the day's budget of calories. (E.g. eat 200 more calories since I burned them).
        var totalCaloriesBurned = 0.0
        // How many calories were burned during exercise.
        var totalExerciseCalories = 0.0
        // How many calories were burned using a tracking device.
        var totalCaloriesBurnedViaTracker = 0.0
        // How many minutes were exercised in total.
        var minutesExercised = 0.0
        // How many steps were taken.
        var stepsTaken = 0.0

        do {
            let rs = try database.executeQuery(query, values: nil)
            while rs.next() {
                let exerciseID = rs.object(forColumn: "ExerciseID") as? NSNumber
                let timeMinutes = rs.double(forColumn: "Exercise_Time_Minutes")
                let caloriesPerHour = rs.double(forColumn: "CaloriesPerHour")
                let currentWeight = getCurrentWeight().doubleValue
                let burnedCalories = (caloriesPerHour / 60) * currentWeight * timeMinutes;

                // If a health tracking device is used, add those values.
                // Note, timeMinutes is actually "calories burned" or "steps" when
                // a tracking device is used.
                
                // Exercise IDs and their values:
                // 257 = Override Calories Burned
                // 267 = Fitbit Calories
                // 268 = Movband Movesf
                // 272 = Apple Calories
                // 275 = Garmin Calories
                // Check if the exercise was a calorie override.
                if (exerciseID == 257) {
                    totalExerciseCalories += timeMinutes
                    if (currentUser.useBurnedCalories) {
                        totalCaloriesBurned += timeMinutes
                    }
                } else if (exerciseID == 267 ||
                    exerciseID == 272 || exerciseID == 275) {
                    totalCaloriesBurnedViaTracker += timeMinutes
                    totalExerciseCalories += timeMinutes
                // Handle step trackers.
                // 259 = Override Steps Taken
                // 269 = Movband Steps
                // 276 = Garmin Steps
                // 274 = Apple Steps
                } else if exerciseID == 259 || exerciseID == 269 ||
                            exerciseID == 276 || exerciseID == 274 {
                    stepsTaken += timeMinutes
                } else {
                    if (currentUser.useBurnedCalories) {
                        totalCaloriesBurned += burnedCalories
                    }
                    minutesExercised += timeMinutes
                    totalExerciseCalories += burnedCalories
                }
            }
        } catch let error {
            debugPrint("Error: \(error.localizedDescription)")
            return (0, 0, 0, 0, 0)
        }
        return (minutesExercised, totalCaloriesBurned, totalExerciseCalories, totalCaloriesBurnedViaTracker, stepsTaken)
    }
    
    /// Helper to output a number to a string with "g" appended.
    @objc public func numberToGramString(number: NSNumber) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = NSLocale.current
        formatter.maximumFractionDigits = 1
        guard let stringValue = formatter.string(from: number) else {
            return "0g"
        }
        return String(format: "%@g", stringValue)
    }

    // MARK: - Exercise and Burned Calories
    
    /// Gets the number of minutes exercised for the given day.
    @objc public func getMinutesExercised(date: Date?) -> Double {
        return getExerciseData(date: date).minutes
    }

    /// Selected day's values that should be included in a log.
    /// NOTE: Takes into account the option to use
    /// a health tracker, so those tracked calories are already reflected
    /// in the value if necessary. Defaults to zero if no exercise calories
    /// should be added to daily intake. This utilizes user settings to determine
    /// how much to return. See AppSettings.h.
    @objc public func getCaloriesBurnedForLog(date: Date?) -> Double {
        guard let currentUser = currentUser else { return 0.0  }
        // If wearable option is on, return that in addition to calculated value.
        if currentUser.useCalorieTrackingDevice {
            return getExerciseData(date: date).loggedCalories +
                        getExerciseData(date: date).trackerCalories
        }

        return getExerciseData(date: date).loggedCalories
    }

    /// Selected day's values. How many calories were burned overall in
    /// exercise. Includes any trackers.
    @objc public func getCaloriesBurnedViaExercise(date: Date?) -> Double {
        return getExerciseData(date: date).exerciseCalories
    }
    @objc public func getCaloriesBurnedViaExerciseString(date: Date?) -> String {
        let calories = getExerciseData(date: date).exerciseCalories
        return String(format: "%.f", calories)
    }

    /// Selected day's values. Defaults to zero. This only includes
    /// calories from a tracker.
    @objc public func getCaloriesBurnedViaTracker(date: Date?) -> Double {
        return getExerciseData(date: date).trackerCalories
    }
    
    /// Selected day's values. Defaults to zero.
    @objc public func getStepsTaken(date: Date?) -> Double {
        return getExerciseData(date: date).steps
    }
    
    // MARK: - Weight and Goals
    
    /// Gets the current weight of the user, or returns zero.
    @objc public func getCurrentWeight() -> NSNumber {
        let defaultValue = NSNumber(floatLiteral: 0.0)
        guard let database = database, database.open() == true else { return defaultValue }
        
        let query = "SELECT weight FROM weightlog WHERE logtime IN (SELECT MAX(logtime) FROM weightlog WHERE deleted = 1) AND deleted = 1"
        
        var currentWeight = 0.0

        do {
            let rs = try database.executeQuery(query, values: nil)
            while rs.next() {
                currentWeight = rs.double(forColumn: "weight")
            }
        } catch let error {
            debugPrint("Error: \(error.localizedDescription)")
            return defaultValue
        }
        return NSNumber(floatLiteral: currentWeight)
    }

    /// Returns the starting weight of the user for their goal.
    @objc public func getStartingWeight() -> NSNumber {
        let defaultValue = NSNumber(floatLiteral: 0.0)
        guard let database = database, database.open() == true else { return defaultValue }
        
        let query = "SELECT weight FROM weightlog WHERE logtime IN (SELECT MIN(logtime) FROM weightlog WHERE deleted = 1) AND deleted = 1"

        var startingWeight = 0.0

        do {
            let rs = try database.executeQuery(query, values: nil)
            while rs.next() {
                startingWeight = rs.double(forColumn: "weight")
            }
        } catch let error {
            debugPrint("Error: \(error.localizedDescription)")
            return defaultValue
        }
        return NSNumber(floatLiteral: startingWeight)
    }
    
    /// Returns the remaining weight a user needs to lose.
    @objc public func getRemainingWeight() -> NSNumber {
        let currentWeight = self.getCurrentWeight().doubleValue
        let weightGoal = currentUser?.weightGoal.doubleValue ?? 0.0
        
        let remainingWeight = NSNumber(floatLiteral: currentWeight - weightGoal)
        
        return remainingWeight
    }
    
    /// Returns the current body fat percentage of the user.
    @objc public func getCurrentBodyFatPercentage() -> NSNumber {
        let defaultValue = NSNumber(floatLiteral: 0.0)
        guard let database = database, database.open() == true else { return defaultValue }
        
        let query = "SELECT bodyfat FROM weightlog WHERE logtime IN (SELECT MAX(logtime) FROM weightlog WHERE deleted = 1 AND entry_type = 1)"
        
        var value = 0.0

        do {
            let rs = try database.executeQuery(query, values: nil)
            while rs.next() {
                value = rs.double(forColumn: "bodyfat")
            }
        } catch let error {
            debugPrint("Error: \(error.localizedDescription)")
            return defaultValue
        }
        return NSNumber(floatLiteral: value)
    }

    // MARK: - BMR / BMI
    
    /// Returns the current BMR of the user.
    @objc public func getCurrentBMR() -> NSNumber {
        return currentUser?.userBMR ?? NSNumber(integerLiteral: 0)
    }

    /// Returns the current BMI of the user.
    @objc public func getCurrentBMI() -> NSNumber {
        guard let currentUser = currentUser else {
            return NSNumber(integerLiteral: 0)
        }
        let bodyMassIndex = getCurrentWeight().doubleValue / (currentUser.height.doubleValue * currentUser.height.doubleValue) * 703
        return NSNumber(integerLiteral: Int(bodyMassIndex))
    }
    
    /// Returns the user's current BMR as a string.
    @objc public func getCurrentBMRString() -> String {
        let bmrValue = getCurrentBMR().intValue
        return String(format: "%i", bmrValue)
    }
    /// Grams based on a user's BMR and if consumed is provided, will return how many grams are left
    /// for the day. Example: If ratio of carbs is 10, 10% of BMR 1000 calories is 100 carb calories,
    /// thus the function will return 25.0g
    /// NOTE: If a date is provided, it will return remaining for the day provided.
    @objc public func getCarbGramsString(date: Date?) -> String {
        guard let currentUser = currentUser else { return "0g" }
        let bmrValue = getCurrentBMR().doubleValue
        let caloriesPerGram = 4.0;
        let carbGrams = (currentUser.carbRatio.doubleValue / 100.0) * bmrValue / caloriesPerGram;
        var consumedGrams = 0.0;
        if let date = date {
            consumedGrams = getTotalCarbCalories(date: date).doubleValue / caloriesPerGram;
        }
        return numberToGramString(number: NSNumber(floatLiteral: carbGrams - consumedGrams))
    }
    @objc public func getProteinGramsString(date: Date?) -> String {
        guard let currentUser = currentUser else { return "0g" }
        let bmrValue = getCurrentBMR().doubleValue
        let caloriesPerGram = 4.0;
        let proteinGrams = (currentUser.proteinRatio.doubleValue / 100.0) * bmrValue / caloriesPerGram;
        var consumedGrams = 0.0;
        if let date = date {
            consumedGrams = getTotalProteinCalories(date: date).doubleValue / caloriesPerGram;
        }
        return numberToGramString(number: NSNumber(floatLiteral: proteinGrams - consumedGrams))
    }
    @objc public func getFatGramsString(date: Date?) -> String {
        guard let currentUser = currentUser else { return "0g" }
        let bmrValue = getCurrentBMR().doubleValue
        let caloriesPerGram = 9.0;
        let fatGrams = (currentUser.fatRatio.doubleValue / 100.0) * bmrValue / caloriesPerGram;
        var consumedGrams = 0.0;
        if let date = date {
            consumedGrams = getTotalFatCalories(date: date).doubleValue / caloriesPerGram;
        }
        return numberToGramString(number: NSNumber(floatLiteral: fatGrams - consumedGrams))
    }

    // MARK: - Localized Output
        
    /// Goal the localized weight goal for the current user.
    @objc public func getLocalizedUserWeightGoalString() -> String {
        return currentUser?.weightGoalLocalizedString() ?? "0.0"
    }

    /// Returns the localized starting weight string, e.g. "100 lbs."
    @objc public func getLocalizedStartingWeightString() -> String {
        massFormatter.isForPersonMassUse = true
        var unit = MassFormatter.Unit.pound
        if (numberFormatter.locale.usesMetricSystem) {
            unit = MassFormatter.Unit.kilogram;
        }
        
        return massFormatter.string(fromValue: getStartingWeight().doubleValue, unit: unit)
    }
    
    /// Returns the localized current weight string, e.g. "100 lbs."
    @objc public func getLocalizedCurrentWeightString() -> String {
        massFormatter.isForPersonMassUse = true
        var unit = MassFormatter.Unit.pound
        if (numberFormatter.locale.usesMetricSystem) {
            unit = MassFormatter.Unit.kilogram;
        }
        
        return massFormatter.string(fromValue: getCurrentWeight().doubleValue, unit: unit)
    }
    
    /// Returns the localized remaining weight string, e.g. "100 lbs."
    @objc public func getLocalizedRemainingWeightString() -> String {
        massFormatter.isForPersonMassUse = true
        var unit = MassFormatter.Unit.pound
        if (numberFormatter.locale.usesMetricSystem) {
            unit = MassFormatter.Unit.kilogram;
        }
        
        return massFormatter.string(fromValue: getRemainingWeight().doubleValue, unit: unit)
    }
    
    // MARK: - Selected Day's Calories
    
    /// If date is nil, it will use the current day's date.
    @objc public func getTotalCaloriesConsumed(date: Date?) -> NSNumber {
        return NSNumber(floatLiteral: getCalorieData(date: date).totalCalories)
    }
    @objc public func getTotalCaloriesConsumedString(date: Date?) -> String {
        let consumed = getCalorieData(date: date).totalCalories
        return String(format: "%.f", consumed)
    }

    @objc public func getTotalCarbCalories(date: Date?) -> NSNumber {
        return NSNumber(floatLiteral: getCalorieData(date: date).carbCalories)
    }
    @objc public func getTotalFatCalories(date: Date?) -> NSNumber {
        return NSNumber(floatLiteral: getCalorieData(date: date).fatCalories)
    }
    @objc public func getTotalProteinCalories(date: Date?) -> NSNumber {
        return NSNumber(floatLiteral: getCalorieData(date: date).proteinCalories)
    }
    @objc public func getTotalSugarGrams(date: Date?) -> NSNumber {
        return NSNumber(floatLiteral: getCalorieData(date: date).sugarGrams)
    }
    @objc public func getTotalSugarCalories(date: Date?) -> NSNumber {
        return NSNumber(floatLiteral: getCalorieData(date: date).sugarCalories)
    }
    
    /// Gets the total calories remaining, which is "net calories".
    /// This takes into account if the user opted to include logged calories or not.
    /// If date is nil, it will use the current day's date.
    @objc public func getTotalCaloriesRemaining(date: Date?) -> NSNumber {
        let totalCaloriesBurnedViaExercise = getCaloriesBurnedForLog(date: date)
        let bmr = getCurrentBMR().doubleValue
        let totalCaloriesToday = getTotalCaloriesConsumed(date: date).doubleValue

        let caloriesRemainingToday = (bmr + totalCaloriesBurnedViaExercise) - totalCaloriesToday

        return NSNumber(floatLiteral: caloriesRemainingToday)
    }
    @objc public func getTotalCaloriesRemainingString(date: Date?) -> String {
        let caloriesRemaining = getTotalCaloriesRemaining(date: date).intValue
        return String(format: "%i", caloriesRemaining)
    }
}
