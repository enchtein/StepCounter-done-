import Foundation

protocol LastSevenDaysViewModelDelegate: AnyObject {
  func informationDidChange(to model: DaysRangeInformationModel)
}
final class LastSevenDaysViewModel {
  let service = HealthKitService.shared
  
  private let type: HealthKitActivityTypes
  private weak var delegate: LastSevenDaysViewModelDelegate?
  
  private(set) var lastSevenDaysStepInformation: DaysRangeInformationModel = .empty
  private var valueForToday: Double = .zero
  
  init(type: HealthKitActivityTypes, delegate: LastSevenDaysViewModelDelegate?) {
    self.type = type
    self.delegate = delegate
    
    service.attach(observer: self)
    
    fillLastSevenDaysStepInformation()
  }
  func viewDidLoad() {
    getLastSevenDaysStepInformation()
  }
  deinit {
    service.deattach(observer: self)
  }
  func deinitWasCalled() {
    service.deattach(observer: self)
  }
}
//MARK: - Helpers
private extension LastSevenDaysViewModel {
  func getLastSeventRangeDays() -> (dateFrom: Date, dateTo: Date) {
    let helper = CalendarTimezoneHelper()
    let userTimezoneDate = helper.convertToUserTimezone(date: Date())
    let startOfDay = helper.getStartOfDay(date: userTimezoneDate)
    
    let dateFrom = helper.date(byAdding: .day, value: -6, to: startOfDay) ?? startOfDay
    let dateTo = helper.getEndOfDay(date: startOfDay)
    
    return (dateFrom, dateTo)
  }
  
  func fillLastSevenDaysStepInformation() { //call once on init
    switch type {
    case .energy: valueForToday = Double(service.activeEnergyBurnedForToday)
    case .step: valueForToday = Double(service.stepCountForToday)
    case .distance: valueForToday = service.distanceWalkingRunningForToday
    case .exerciseTime: valueForToday = service.exerciseTimeForToday
    }
    
    let rangeDays = getLastSeventRangeDays()
    
    lastSevenDaysStepInformation = DaysRangeInformationModel.createEmpty(dateFrom: rangeDays.dateFrom, dateTo: rangeDays.dateTo, for: type, isForMonth: false)
  }
  
  func updateLastSevenDaysStepInformation() {
    let todayModel = lastSevenDaysStepInformation.dayModels.first { $0.isToday }
    
    guard let todayModel else { return }
    
    var dayModels = lastSevenDaysStepInformation.dayModels
    let updatedTodayModel = DayInformationModel(value: Float(valueForToday), basedOn: todayModel)
    
    dayModels.removeAll { $0.isToday }
    dayModels.append(updatedTodayModel)
    dayModels.sort { $0.date.milisecondsSince1970 < $1.date.milisecondsSince1970 }
    
    lastSevenDaysStepInformation = DaysRangeInformationModel(dayModels: dayModels)
    delegate?.informationDidChange(to: lastSevenDaysStepInformation)
  }
}
//MARK: - get info from HealthKit
private extension LastSevenDaysViewModel {
  func getLastSevenDaysStepInformation() {
    let rangeDays = getLastSeventRangeDays()
    
    service.getInformationAccording(type: type, dateFrom: rangeDays.dateFrom, dateTo: rangeDays.dateTo, isForMonth: false) { [weak self] model in
      guard let self else { return }
      
      self.lastSevenDaysStepInformation = model
      self.updateLastSevenDaysStepInformation()
    }
  }
}
//MARK: - HealthKitServiceChanges
extension LastSevenDaysViewModel: HealthKitServiceChanges {
  func activeEnergyBurnedForTodayDidChange(to value: Int) {
    guard type == .energy else { return }
    
    valueForToday = Double(value)
    updateLastSevenDaysStepInformation()
  }
  func stepCountForTodayDidChange(to value: Int) {
    guard type == .step else { return }
    
    valueForToday = Double(value)
    updateLastSevenDaysStepInformation()
  }
  func distanceWalkingRunningForTodayDidChange(to value: Double) {
    guard type == .distance else { return }
    
    valueForToday = value
    updateLastSevenDaysStepInformation()
  }
  func exerciseTimeForTodayDidChange(to value: Double) {
    guard type == .exerciseTime else { return }
    
    valueForToday = value
    updateLastSevenDaysStepInformation()
  }
}
