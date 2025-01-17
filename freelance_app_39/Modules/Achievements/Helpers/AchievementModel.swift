import Foundation

struct AchievementModel {
  let type: AchievementType
  private let maxStepsPerDay: Int
  
  private let maxMultiplier: Float = 1.0
  var goalMultiplier: Float {
    let multiplier = Float(maxStepsPerDay) / Float(type.stepsGoal)
    return multiplier < maxMultiplier ? multiplier : maxMultiplier
  }
  var goalPercentage: Int {
    Int(goalMultiplier * 100)
  }
  var isGoalDone: Bool {
    goalMultiplier == maxMultiplier
  }
  
  var isClosed: Bool {
    guard let prevType = AchievementType(rawValue: type.rawValue - 1) else { return false }
    return prevType.stepsGoal >= maxStepsPerDay
  }
  
  init(type: AchievementType, maxStepsPerDay: Int) {
    self.type = type
    self.maxStepsPerDay = maxStepsPerDay
  }
}
