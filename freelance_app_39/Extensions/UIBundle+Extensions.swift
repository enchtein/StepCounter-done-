import Foundation

extension Bundle {
  class var applicationName: String {
    if let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
      return displayName
    } else if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
      return name
    } else {
      return "nil"
    }
  }
}
