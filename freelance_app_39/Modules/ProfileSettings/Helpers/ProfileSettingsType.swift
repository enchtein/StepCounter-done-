import Foundation

enum ProfileSettingsType: Int, CaseIterable {
  case gender = 0
  case height
  case stepLength
  case weight
  case metric
  
  var title: String {
    switch self {
    case .gender: ProfileSettingsTitles.gender.localized
    case .height: ProfileSettingsTitles.height.localized
    case .stepLength: ProfileSettingsTitles.stepLength.localized
    case .weight: ProfileSettingsTitles.weight.localized
    case .metric: ProfileSettingsTitles.metric.localized
    }
  }
  
  var minValue: Int {
    switch self {
    case .gender: .zero
    case .height: 60
    case .stepLength: 10
    case .weight: 20
    case .metric: .zero
    }
  }
  var maxValue: Int {
    switch self {
    case .gender: .zero
    case .height: 300
    case .stepLength: 160
    case .weight: 300
    case .metric: .zero
    }
  }
}
