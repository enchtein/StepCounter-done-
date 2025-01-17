import HealthKit

enum GenderType: String, CaseIterable {
  case man
  case woman
  case nonbinary
  
  var title: String {
    switch self {
    case .man: ProfileSettingsTitles.man.localized
    case .woman: ProfileSettingsTitles.woman.localized
    case .nonbinary: ProfileSettingsTitles.nonbinary.localized
    }
  }
  
  init?(rawValue: String?) {
    guard let rawValue else { return nil }
    switch rawValue {
    case ProfileSettingsTitles.man.localized: self = .man
    case ProfileSettingsTitles.woman.localized: self = .woman
    case ProfileSettingsTitles.nonbinary.localized: self = .nonbinary
    default: return nil
    }
  }
  
  init?(biologicalSex: HKBiologicalSex) {
    switch biologicalSex {
    case .male: self = .man
    case .female: self = .woman
    case .other: self = .nonbinary
    default: return nil
    }
  }
}
