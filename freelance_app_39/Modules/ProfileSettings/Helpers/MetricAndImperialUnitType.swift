import Foundation

enum MetricAndImperialUnitType: String, CaseIterable {
  case poundAndft
  case kgAndcm
  
  var title: String {
    switch self {
    case .poundAndft: ProfileSettingsTitles.poundAndft.localized
    case .kgAndcm: ProfileSettingsTitles.kgAndcm.localized
    }
  }
  
  init?(rawValue: String) {
    switch rawValue {
    case ProfileSettingsTitles.poundAndft.localized: self = .poundAndft
    case ProfileSettingsTitles.kgAndcm.localized: self = .kgAndcm
    default: return nil
    }
  }
}
