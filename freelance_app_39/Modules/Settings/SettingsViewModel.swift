import Foundation

final class SettingsViewModel {
  private let dataSource = SettingSectionType.allCases
}

//MARK: - DataSource helpers
private extension SettingsViewModel {
  func getSectionIndex(from indexPath: IndexPath) -> Int {
    indexPath.section
  }
  func getSettingIndex(from indexPath: IndexPath) -> Int {
    indexPath.row
  }
  
  func isSectionExist(at indexPath: IndexPath) -> Bool {
    let section = getSectionIndex(from: indexPath)
    return dataSource.indices.contains(section)
  }
  func getSection(for indexPath: IndexPath) -> SettingSectionType? {
    guard isSectionExist(at: indexPath) else { return nil }
    let sectionIndex = getSectionIndex(from: indexPath)
    return dataSource[sectionIndex]
  }
  
  func isSettingExist(at indexPath: IndexPath) -> Bool {
    guard isSectionExist(at: indexPath) else { return false }
    
    let section = getSectionIndex(from: indexPath)
    let item = getSettingIndex(from: indexPath)
    
    return dataSource[section].sectionSettings.indices.contains(item)
  }
}
//MARK: - API
extension SettingsViewModel {
  func numberOfSections() -> Int {
    dataSource.count
  }
  func isLastSectionCell(at indexPath: IndexPath) -> Bool {
    guard isSectionExist(at: indexPath) else { return false }
    
    let section = getSectionIndex(from: indexPath)
    let item = getSettingIndex(from: indexPath)
    
    return dataSource[section].sectionSettings.indices.last == item
  }
  
  func numberOfItems(in section: Int) -> Int {
    guard dataSource.indices.contains(section) else { return .zero }
    return dataSource[section].sectionSettings.count
  }
  func getSetting(for indexPath: IndexPath) -> SettingType? {
    guard isSettingExist(at: indexPath) else { return nil }
    
    let section = getSectionIndex(from: indexPath)
    let item = getSettingIndex(from: indexPath)
    
    return dataSource[section].sectionSettings[item]
  }
}
