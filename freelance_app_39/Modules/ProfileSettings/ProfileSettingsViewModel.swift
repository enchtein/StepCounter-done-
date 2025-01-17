import Foundation

final class ProfileSettingsViewModel {
  let dataSource = ProfileSettingsType.allCases
}
//MARK: - DataSource helpers
private extension ProfileSettingsViewModel {
  func getSettingIndex(from indexPath: IndexPath) -> Int {
    indexPath.row
  }
  
  func isSettingExist(at indexPath: IndexPath) -> Bool {
    let item = getSettingIndex(from: indexPath)
    
    return dataSource.indices.contains(item)
  }
  
  func defaultText() -> String {
    ProfileSettingsTitles.notSelected.localized
  }
  func convertAccordingMetricAndImperialUnit(valueCM: Int?) -> String {
    guard let valueCM, valueCM != .zero else { return defaultText() }
    
    let selectedUnit = MetricAndImperialUnitType(rawValue: UserDefaults.standard.metricAndImperialUnit) ?? .kgAndcm
    switch selectedUnit {
    case .kgAndcm:
      return String(valueCM) + " " + ProfileSettingsTitles.cm.localized
    case .poundAndft:
      let heightCM = Measurement(value: Double(valueCM), unit: UnitLength.centimeters)
      let heightFeet = heightCM.converted(to: UnitLength.feet)
      return String(heightFeet.value.withTwoDigits) + " " + ProfileSettingsTitles.ft.localized
    }
  }
  func convertAccordingMetricAndImperialUnit(valueKG: Int?) -> String {
    guard let valueKG, valueKG != .zero else { return defaultText() }
    
    let selectedUnit = MetricAndImperialUnitType(rawValue: UserDefaults.standard.metricAndImperialUnit) ?? .kgAndcm
    switch selectedUnit {
    case .kgAndcm:
      return String(valueKG) + " " + ProfileSettingsTitles.kg.localized
    case .poundAndft:
      let weightKG = Measurement(value: Double(valueKG), unit: UnitMass.kilograms)
      let weightPounds = weightKG.converted(to: .pounds)
      return String(weightPounds.value.withTwoDigits) + " " + ProfileSettingsTitles.pound.localized
    }
  }
}
//MARK: - API
extension ProfileSettingsViewModel {
  func indexPath(for type: ProfileSettingsType) -> IndexPath? {
    guard let index = dataSource.firstIndex(of: type) else { return nil }
    return IndexPath(item: index, section: 0)
  }
  
  func numberOfItems(in section: Int) -> Int {
    dataSource.count
  }
  func getSetting(for indexPath: IndexPath) -> ProfileSettingsType? {
    guard isSettingExist(at: indexPath) else { return nil }
    let item = getSettingIndex(from: indexPath)
    
    return dataSource[item]
  }
  func getSettingValue(for indexPath: IndexPath) -> String {
    let setting = getSetting(for: indexPath)
    
    let value: String
    switch setting {
    case .gender:
      value = GenderType(rawValue: UserDefaults.standard.gender)?.title ?? defaultText()
    case .height:
      value = convertAccordingMetricAndImperialUnit(valueCM: UserDefaults.standard.heightCM)
    case .stepLength:
      value = convertAccordingMetricAndImperialUnit(valueCM: UserDefaults.standard.stepLenghtCM)
    case .weight:
      value = convertAccordingMetricAndImperialUnit(valueKG: UserDefaults.standard.weightKG)
    case .metric:
      value = UserDefaults.standard.metricAndImperialUnit
    default: value = "unidentified"
    }
    
    return value
  }
}
