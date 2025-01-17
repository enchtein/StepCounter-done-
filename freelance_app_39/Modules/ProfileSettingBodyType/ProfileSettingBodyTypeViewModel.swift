import Foundation

protocol ProfileSettingBodyTypeViewModelDelegate: AnyObject {
  func updateUI(according selectedItem: Int, in component: Int)
  func updateSaveButtonAvailability(to isEnabled: Bool)
}
final class ProfileSettingBodyTypeViewModel {
  private weak var delegate: ProfileSettingBodyTypeViewModelDelegate?
  private let bodyType: ProfileSettingsType
  
  private let originalSelectedDataSourceItem: Int?
  private(set) var selectedDataSourceItem: Int = .zero
  private let stepLenghtСoefficient = 0.4
  
  private let originalUnitDataSource: [Int]
  let dataSource: [String]
  
  let emptyComponentIndex = 0
  let dataSourceComponentIndex = 1
  let parameterComponentIndex = 2
  
  init(delegate: ProfileSettingBodyTypeViewModelDelegate?, bodyType: ProfileSettingsType) {
    self.delegate = delegate
    self.bodyType = bodyType
    
    originalUnitDataSource = Array(bodyType.minValue...bodyType.maxValue) //kg / cm
    var processedDataSource = [Double]()
    
    var currentValue: Double?
    switch bodyType {
    case .gender: break
    case .height:
      if let heightCM = UserDefaults.standard.heightCM {
        currentValue = Self.convertAccordingMetricAndImperialUnit(valueCM: heightCM)
      }
      processedDataSource = originalUnitDataSource.map {
        Self.convertAccordingMetricAndImperialUnit(valueCM: $0)
      }
    case .stepLength:
      if let stepLenghtCM = UserDefaults.standard.stepLenghtCM {
        currentValue = Self.convertAccordingMetricAndImperialUnit(valueCM: stepLenghtCM)
      }
      processedDataSource = originalUnitDataSource.map {
        Self.convertAccordingMetricAndImperialUnit(valueCM: $0)
      }
    case .weight:
      if let weightKG = UserDefaults.standard.weightKG {
        currentValue = Self.convertAccordingMetricAndImperialUnit(valueKG: weightKG)
      }
      processedDataSource = originalUnitDataSource.map {
        Self.convertAccordingMetricAndImperialUnit(valueKG: $0)
      }
    case .metric: break
    }
    
    if let searchValue = currentValue?.withTwoDigits, searchValue != .zero {
      selectedDataSourceItem = processedDataSource.firstIndex { $0 >= searchValue } ?? 0
      originalSelectedDataSourceItem = selectedDataSourceItem
    } else {
      originalSelectedDataSourceItem = nil
    }
    
    dataSource = processedDataSource.map { String($0.withTwoDigits) }
  }
  
  func viewDidLoad() {
    delegate?.updateUI(according: selectedDataSourceItem, in: dataSourceComponentIndex)
    updateSaveButtonAvailability()
  }
}
//MARK: - Helpers
private extension ProfileSettingBodyTypeViewModel {
  static func convertAccordingMetricAndImperialUnit(valueCM: Int) -> Double {
    let selectedUnit = MetricAndImperialUnitType(rawValue: UserDefaults.standard.metricAndImperialUnit) ?? .kgAndcm
    switch selectedUnit {
    case .kgAndcm:
      return Double(valueCM)
    case .poundAndft:
      let heightCM = Measurement(value: Double(valueCM), unit: UnitLength.centimeters)
      let heightFeet = heightCM.converted(to: UnitLength.feet)
      return heightFeet.value.withTwoDigits
    }
  }
  static func convertAccordingMetricAndImperialUnit(valueKG: Int) -> Double {
    let selectedUnit = MetricAndImperialUnitType(rawValue: UserDefaults.standard.metricAndImperialUnit) ?? .kgAndcm
    switch selectedUnit {
    case .kgAndcm:
      return Double(valueKG)
    case .poundAndft:
      let weightKG = Measurement(value: Double(valueKG), unit: UnitMass.kilograms)
      let weightPounds = weightKG.converted(to: .pounds)
      return weightPounds.value.withTwoDigits
    }
  }
  
  func updateSaveButtonAvailability() {
    delegate?.updateSaveButtonAvailability(to: selectedDataSourceItem != originalSelectedDataSourceItem)
  }
}
//MARK: - API
extension ProfileSettingBodyTypeViewModel {
  func getStepLenghtСoefficient() -> String {
    "\(stepLenghtСoefficient)"
  }
  func getCurrentHeight() -> String {
    guard let heightCM = UserDefaults.standard.heightCM, heightCM != .zero else { return "" }
    
    let selectedUnit = MetricAndImperialUnitType(rawValue: UserDefaults.standard.metricAndImperialUnit) ?? .kgAndcm
    switch selectedUnit {
    case .poundAndft:
      let value = Self.convertAccordingMetricAndImperialUnit(valueCM: heightCM)
      return "(" + String(value.withTwoDigits) + ProfileSettingsTitles.ft.localized + ")"
    case .kgAndcm:
      return "(" + String(heightCM) + ProfileSettingsTitles.cm.localized + ")"
    }
  }
  
  func updateSelectedItem(with row: Int) {
    selectedDataSourceItem = row
    updateSaveButtonAvailability()
  }
  func numberOfComponents() -> Int {
    [emptyComponentIndex, dataSourceComponentIndex, parameterComponentIndex].count
  }
  func numberOfRows(in component: Int) -> Int {
    switch component {
    case emptyComponentIndex: 1
    case dataSourceComponentIndex: dataSource.count
    case parameterComponentIndex: 1
    default: .zero
    }
  }
  
  func saveButtonAction() {
    guard originalUnitDataSource.indices.contains(selectedDataSourceItem) else { return }
    
    switch bodyType {
    case .gender: break
    case .height:
      UserDefaults.standard.heightCM = originalUnitDataSource[selectedDataSourceItem]
    case .stepLength:
      UserDefaults.standard.stepLenghtCM = originalUnitDataSource[selectedDataSourceItem]
    case .weight:
      UserDefaults.standard.weightKG = originalUnitDataSource[selectedDataSourceItem]
    case .metric: break
    }
  }
}
