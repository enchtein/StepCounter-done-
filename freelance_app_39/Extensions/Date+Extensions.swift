import Foundation

extension Date {
  func toString(withFormat format: DateFormat, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) -> String {
    let dateFormatter = CommonDateFormatter.localized(with: format)
    dateFormatter.dateFormat = format.rawValue
    dateFormatter.amSymbol = "AM"
    dateFormatter.pmSymbol = "PM"
    dateFormatter.timeZone = timeZone
    return dateFormatter.string(from: self)
  }
  
  private var timeIntervalSince1970inMilliseconds: TimeInterval {
    return self.timeIntervalSince1970 * 1000
  }
  var milisecondsSince1970: Int {
    return Int(timeIntervalSince1970inMilliseconds)
  }
  
  init(milisecondsSince1970: Int) {
    self = Date(timeIntervalSince1970: Double(milisecondsSince1970) / 1000)
  }
}

enum DateFormat: String {
  case day = "d"
  case monthYear = "MMMM yyyy"
  case dayNameAndDayMonth = "EEEE, d MMMM"
  case hoursMinutes24 = "HH:mm"
  case dayMonthYear = "dd MMM yyyy"
}
