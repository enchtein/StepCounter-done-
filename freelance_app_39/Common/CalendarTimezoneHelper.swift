import Foundation

struct CalendarTimezoneHelper {
  private let zeroTimezone = TimeZone(secondsFromGMT: 0)!
  var zeroTimezoneCalendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = zeroTimezone
    return calendar
  }
  
  private let currentTimezone = TimeZone.current
  var currentCalendar: Calendar {
    var calendar = zeroTimezoneCalendar
    calendar.timeZone = currentTimezone
    return calendar
  }
}
//MARK: - Date Processing
extension CalendarTimezoneHelper {
  func getStartOfDay(date: Date) -> Date {
    zeroTimezoneCalendar.startOfDay(for: date)
  }
  func getEndOfDay(date: Date) -> Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    
    let startOfDay = getStartOfDay(date: date)
    return zeroTimezoneCalendar.date(byAdding: components, to: startOfDay)!
  }
  
  func getStartOfWeek(for date: Date) -> Date {
    let weekDayName = weekDay(from: date)
    let leftOffset = weekDayName?.leftOffset ?? .zero // offset to monday (first week day)
    
    let startOfDay = getStartOfDay(date: date)
    return zeroTimezoneCalendar.date(byAdding: .day, value: -leftOffset, to: startOfDay)!
  }
  func getEndOfWeek(for date: Date) -> Date {
    let startOfWeek = getStartOfWeek(for: date)
    let sunday = zeroTimezoneCalendar.date(byAdding: .day, value: 6, to: startOfWeek)! // last week day
    return getEndOfDay(date: sunday) // saturday
  }
  
  func getStartOfMonth(from date: Date) -> Date {
    let startOfDay = getStartOfDay(date: date)
    return zeroTimezoneCalendar.date(from: zeroTimezoneCalendar.dateComponents([.year, .month], from: startOfDay))!
  }
  func getEndOfMonth(from date: Date) -> Date {
    let startOfMonth = getStartOfMonth(from: date)
    let lastMonthDay = zeroTimezoneCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    return getEndOfDay(date: lastMonthDay)
  }
  
  func weekDay(from date: Date) -> CalendarWeekDays? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE"
    dateFormatter.locale = Locale(identifier: "en")
    dateFormatter.timeZone = zeroTimezone
    let dayInWeek = dateFormatter.string(from: date)
    
    return CalendarWeekDays.init(dayName: dayInWeek)
  }
  func date(byAdding component: Calendar.Component, value: Int, to date: Date) -> Date? {
    zeroTimezoneCalendar.date(byAdding: component, value: value, to: date)
  }
  
  func isSameDay(_ date: Date, with secondDate: Date) -> Bool {
    let leftDate = zeroTimezoneCalendar.dateComponents([.year, .month, .day], from: date)
    let rightDate = zeroTimezoneCalendar.dateComponents([.year, .month, .day], from: secondDate)
    return leftDate.day == rightDate.day && leftDate.month == rightDate.month && leftDate.year == rightDate.year
  }
  func isSameMonth(_ date: Date, with secondDate: Date) -> Bool {
    let leftDate = zeroTimezoneCalendar.dateComponents([.year, .month], from: date)
    let rightDate = zeroTimezoneCalendar.dateComponents([.year, .month], from: secondDate)
    return leftDate.month == rightDate.month && leftDate.year == rightDate.year
  }
  
  func removeOneHour(from date: Date) -> Date {
    zeroTimezoneCalendar.date(byAdding: .hour, value: -1, to: date) ?? date
  }
  
  func getDateRangeAccording(startDate: Date, endDate: Date) -> [Date] {
    var dates: [Date] = []
    var date = startDate
    while date <= endDate {
      dates.append(date)
      guard let newDate = self.date(byAdding: .day, value: 1, to: date) else { break }
      date = newDate
    }
    return dates
  }
  func filterUniqueDates(from filteredArray: [Date], according compairedArray: [Date]) -> [Date] {
    return filteredArray.filter { date in
      !compairedArray.contains{$0 == date}
    }
  }
}
//MARK: - User time zone
extension CalendarTimezoneHelper {
  func convertToUserTimezone(date: Date) -> Date {
    let timezoneOffset = TimeZone.current.secondsFromGMT()
    
    let userTimezoneDate = zeroTimezoneCalendar.date(byAdding: .second, value: timezoneOffset, to: date)
    return userTimezoneDate ?? date
  }
  func convertToZeroTimezone(date: Date) -> Date {
    let timezoneOffset = TimeZone.current.secondsFromGMT()
    
    let userTimezoneDate = zeroTimezoneCalendar.date(byAdding: .second, value: -timezoneOffset, to: date)
    return userTimezoneDate ?? date
  }
}
