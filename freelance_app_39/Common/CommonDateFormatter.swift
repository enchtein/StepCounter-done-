import Foundation

final class CommonDateFormatter: NSObject {
  private enum TargetLang {
    case russian
    case ukrainian
    case english
    
    var identifier: String {
      switch self {
      case .russian: return "ru_RU"
      case .ukrainian: return "uk_UA"
      case .english: return "en_US"
      }
    }
    
    init(_ rawValue: String) {
      switch rawValue {
      case "ru": self = .russian
      case "uk": self = .ukrainian
      default: self = .english
      }
    }
  }
  
  private static let localizedFormatter = DateFormatter()

  //MARK: - Public
  static func localized(with format: DateFormat) -> DateFormatter {
    let localizedFormatter = localized
    localizedFormatter.dateFormat = format.rawValue
    localizedFormatter.amSymbol = "AM"
    localizedFormatter.pmSymbol = "PM"
    localizedFormatter.timeZone = TimeZone.current
    return localizedFormatter
  }
  
  //MARK: - Private
  private static var localized: DateFormatter {
    if let targetLang = UserDefaults.standard.object(forKey: "selectedLanguage") as? String {
      localizedFormatter.locale = Locale(identifier: TargetLang(targetLang).identifier)
    } else {
      localizedFormatter.locale = Locale(identifier: "en_US")
    }
    localizedFormatter.timeZone = TimeZone.current
    return localizedFormatter
  }

  static var enUSLocale: Locale {
    Locale(identifier: TargetLang.english.identifier)
  }
  static var uaLocale: Locale {
    Locale(identifier: TargetLang.ukrainian.identifier)
  }
}
