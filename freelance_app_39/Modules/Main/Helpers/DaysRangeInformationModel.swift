import Foundation

struct DaysRangeInformationModel {
  let dayModels: [DayInformationModel]
  private var modelType: HealthKitActivityTypes {
    availableDayModels.map { $0.type }.first ?? .step
  }
  var averageValue: Float {
    return sumValue / Float(availableDayModels.count)
  }
  var formattedAvarageValue: String {
    switch modelType {
    case .step, .energy: String(Int(averageValue)) + " " + modelType.name
    case .distance, .exerciseTime:
      if averageValue == .zero {
        "0 " + modelType.name
      } else {
        String(Double(averageValue).withTwoDigits) + " " + modelType.name
      }
    }
  }
  
  var sumValue: Float {
    availableDayModels.map { $0.value }.reduce(0, +)
  }
  
  var dateFrom: Date {
    availableDayModels.map { $0.date }.min() ?? Date()
  }
  var dateTo: Date {
    availableDayModels.map { $0.date }.max() ?? Date()
  }
  
  private var availableDayModels: [DayInformationModel] {
    dayModels.filter { $0.isActiveDate }
  }
  
  init(dayModels: [DayInformationModel]) {
    self.dayModels = dayModels
  }
}

extension DaysRangeInformationModel {
  static let empty = Self.init(dayModels: [])
  
  static func createEmpty(dateFrom: Date, dateTo: Date, for type: HealthKitActivityTypes, isForMonth: Bool) -> Self {
    let timezoneHelper = CalendarTimezoneHelper()
    
    var daysInRange = timezoneHelper.getDateRangeAccording(startDate: dateFrom, endDate: dateTo)
    
    if isForMonth {
      // only if first date in array not monday!
      if let firstMonthDay = daysInRange.first, let weekDay = timezoneHelper.weekDay(from: firstMonthDay) {
        if !weekDay.isStartOfWeek {
          if let firstWeekDayDate = timezoneHelper.date(byAdding: .day, value: -weekDay.leftOffset, to: firstMonthDay) {
            let dateRange = timezoneHelper.getDateRangeAccording(startDate: firstWeekDayDate, endDate: firstMonthDay)
            let additionalCalendarDays = timezoneHelper.filterUniqueDates(from: dateRange, according: daysInRange)
            daysInRange.insert(contentsOf: additionalCalendarDays, at: 0)
          }
        }
      }
      
      // only if last date in array not sunday!
      if let lastMonthDay = daysInRange.last, let weekDay = timezoneHelper.weekDay(from: lastMonthDay) {
        if !weekDay.isEndOfWeek {
          if let lastWeekDayDate = timezoneHelper.date(byAdding: .day, value: weekDay.rightOffset, to: lastMonthDay) {
            let dateRange = timezoneHelper.getDateRangeAccording(startDate: lastMonthDay, endDate: lastWeekDayDate)
            let additionalCalendarDays = timezoneHelper.filterUniqueDates(from: dateRange, according: daysInRange)
            daysInRange.insert(contentsOf: additionalCalendarDays, at: daysInRange.count)
          }
        }
      }
      //additional 7 days if needed
      let weekDaysCount = CalendarWeekDays.weekDaysCount
      if (daysInRange.count / weekDaysCount) == 5, let lastMonthDay = daysInRange.last {
        if let lastWeekDayDate = timezoneHelper.date(byAdding: .day, value: weekDaysCount, to: lastMonthDay) {
          let dateRange = timezoneHelper.getDateRangeAccording(startDate: lastMonthDay, endDate: lastWeekDayDate)
          let additionalCalendarDays = timezoneHelper.filterUniqueDates(from: dateRange, according: daysInRange)
          daysInRange.insert(contentsOf: additionalCalendarDays, at: daysInRange.count)
        }
      }
    }
    
    let emptyDayInformationModels = daysInRange.map {
      let startOfDay = timezoneHelper.getStartOfDay(date: $0)
      
      let weekDay = timezoneHelper.weekDay(from: startOfDay)
      
      let userTimezoneTodayDate = timezoneHelper.convertToUserTimezone(date: Date())
      let startOfTodayDay = timezoneHelper.getStartOfDay(date: userTimezoneTodayDate)
      let isToday = timezoneHelper.isSameDay(startOfDay, with: startOfTodayDay)
      let isActiveDate = isForMonth ? timezoneHelper.isSameMonth(startOfDay, with: dateFrom) : true //always active for LastSeventDaysInformationView
      return DayInformationModel(day: weekDay ?? .monday, date: startOfDay, isToday: isToday, isActiveDate: isActiveDate, type: type, value: 0, maxValueAtRange: 0)
    }
    
    return Self(dayModels: emptyDayInformationModels)
  }
}
