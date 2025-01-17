import Foundation

struct DayInformationModel {
  let day: CalendarWeekDays
  let date: Date
  let isToday: Bool
  let isActiveDate: Bool //while day in month range
  
  let type: HealthKitActivityTypes
  let value: Float
  private var goal: Int? {
    switch type {
    case .step: UserDefaults.standard.stepGoal
    case .energy: UserDefaults.standard.kCalGoal
    case .distance: nil
    case .exerciseTime: nil
    }
  }
  var formattedValue: String {
    switch type {
    case .step, .energy: String(Int(value))
    case .distance, .exerciseTime:
      if value == .zero {
        "0"
      } else {
        String(Double(value).withTwoDigits)
      }
    }
  }
  
  private let maxMultiplier: Float = 1.0
  private let maxValueAtRange: Float
  var multiplier: Float {
    if let goal {
      let calculation = value / Float(goal)
      return calculation > maxMultiplier ? maxMultiplier : calculation
    } else {
      guard value != .zero && maxValueAtRange != .zero else { return .zero }
      return value / maxValueAtRange
    }
  }
  var isGoalDone: Bool {
    guard goal != nil else { return false }
    return multiplier == maxMultiplier
  }
  
  init(day: CalendarWeekDays, date: Date, isToday: Bool, isActiveDate: Bool, type: HealthKitActivityTypes, value: Float, maxValueAtRange: Float) {
    self.day = day
    self.date = date
    self.isToday = isToday
    self.isActiveDate = isActiveDate
    self.type = type
    self.value = value
    self.maxValueAtRange = maxValueAtRange
  }
}

extension DayInformationModel {
  init(value: Float, basedOn model: Self) {
    self.init(day: model.day,
              date: model.date,
              isToday: model.isToday,
              isActiveDate: model.isActiveDate,
              type: model.type,
              
              value: value,
              
              maxValueAtRange: model.maxValueAtRange)
  }
  init(value: Float, maxValueAtRange: Float, basedOn model: Self) {
    self.init(day: model.day,
              date: model.date,
              isToday: model.isToday,
              isActiveDate: model.isActiveDate,
              type: model.type,
              
              value: value,
              maxValueAtRange: maxValueAtRange)
  }
  init(maxValueAtRange: Float, basedOn model: Self) {
    self.init(day: model.day,
              date: model.date,
              isToday: model.isToday,
              isActiveDate: model.isActiveDate,
              type: model.type,
              value: model.value,
              
              maxValueAtRange: maxValueAtRange)
  }
}
