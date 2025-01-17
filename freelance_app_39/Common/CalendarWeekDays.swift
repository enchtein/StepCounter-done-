import Foundation

enum CalendarWeekDays: CaseIterable {
  case monday
  case tuesday
  case wednesday
  case thurthday
  case friday
  case saturday
  case sunday
  
  var dayName: String {
    switch self {
    case .monday: MainTitles.mon.localized
    case .tuesday: MainTitles.tue.localized
    case .wednesday: MainTitles.wed.localized
    case .thurthday: MainTitles.thu.localized
    case .friday: MainTitles.fri.localized
    case .saturday: MainTitles.sat.localized
    case .sunday: MainTitles.sun.localized
    }
  }
  
  static var weekDaysCount: Int {
    CalendarWeekDays.allCases.count
  }
  
  var dayNumber: Int {
    switch self {
    case .monday: 1
    case .tuesday: 2
    case .wednesday: 3
    case .thurthday: 4
    case .friday: 5
    case .saturday: 6
    case .sunday: 7
    }
  }
  
  var leftOffset: Int {
    self.dayNumber - 1
  }
  var rightOffset: Int {
    CalendarWeekDays.weekDaysCount - dayNumber
  }
  
  var isStartOfWeek: Bool {
    self.leftOffset == .zero
  }
  var isEndOfWeek: Bool {
    rightOffset == .zero
  }
  
  init?(dayName: String) {
    switch dayName {
    case Self.monday.rawValue: self = .monday
    case Self.tuesday.rawValue: self = .tuesday
    case Self.wednesday.rawValue: self = .wednesday
    case Self.thurthday.rawValue: self = .thurthday
    case Self.friday.rawValue: self = .friday
    case Self.saturday.rawValue: self = .saturday
    case Self.sunday.rawValue: self = .sunday
      
    default: return nil
    }
  }
  var rawValue: String {
    switch self {
    case .monday: "Mon"
    case .tuesday: "Tue"
    case .wednesday: "Wed"
    case .thurthday: "Thu"
    case .friday: "Fri"
    case .saturday: "Sat"
    case .sunday: "Sun"
    }
  }
}
