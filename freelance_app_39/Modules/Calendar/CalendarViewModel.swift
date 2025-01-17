import Foundation

protocol CalendarViewModelDelegate: AnyObject {
  func monthInformationDidChange()
  func monthDidChange(to text: String)
  
  func dayModelInformationDidChange(at indexPath: IndexPath)
  
  func updateRightDateSwitchButton(to isEnabled: Bool)
  
  func monthAverageStepsDidChange(to value: Int)
  func monthSumDidChange(to value: Float, for type: HealthKitActivityTypes)
}
final class CalendarViewModel {
  let service = HealthKitService.shared
  private weak var delegate: CalendarViewModelDelegate?
  
  private let helper = CalendarTimezoneHelper()
  private(set) var leftDate: Date = Date()
  private(set) var isLeftSwitcherActive = true
  
  private(set) var monthInformationModel: DaysRangeInformationModel = .empty
  
  private(set) var monthKCalModel: DaysRangeInformationModel = .empty
  private(set) var monthDistanceModel: DaysRangeInformationModel = .empty
  private(set) var monthHourModel: DaysRangeInformationModel = .empty
  
  
  private(set) var rightDate: Date = Date()
  private(set) var isRightSwitcherActive = true
  
  init(delegate: CalendarViewModelDelegate) {
    self.delegate = delegate
    service.attach(observer: self)
    
    processedCalendar(according: Date())
  }
  func viewDidLoad() {
    retriveHealthKitInfo()
  }
  deinit {
    service.deattach(observer: self)
  }
}

//MARK: - Helpers
private extension CalendarViewModel {
  func retriveHealthKitInfo() {
    retriveMonthDaysInformation(for: .energy)
    retriveMonthDaysInformation(for: .step)
    retriveMonthDaysInformation(for: .distance)
    retriveMonthDaysInformation(for: .exerciseTime)
  }
  
  func fillMonthDaysStepInformation() {
    monthInformationModel = DaysRangeInformationModel.createEmpty(dateFrom: leftDate, dateTo: rightDate, for: .step, isForMonth: true)
    delegate?.monthInformationDidChange()
    delegate?.monthAverageStepsDidChange(to: Int(monthInformationModel.averageValue))
    delegate?.monthSumDidChange(to: monthInformationModel.sumValue, for: .step)
    
    monthKCalModel = DaysRangeInformationModel.createEmpty(dateFrom: leftDate, dateTo: rightDate, for: .energy, isForMonth: true)
    delegate?.monthSumDidChange(to: monthKCalModel.sumValue, for: .energy)
    
    monthDistanceModel = DaysRangeInformationModel.createEmpty(dateFrom: leftDate, dateTo: rightDate, for: .distance, isForMonth: true)
    delegate?.monthSumDidChange(to: monthDistanceModel.sumValue, for: .distance)
    
    monthHourModel = DaysRangeInformationModel.createEmpty(dateFrom: leftDate, dateTo: rightDate, for: .exerciseTime, isForMonth: true)
    delegate?.monthSumDidChange(to: monthHourModel.sumValue, for: .exerciseTime)
  }
  
  func retriveMonthDaysInformation(for type: HealthKitActivityTypes) {
    service.getInformationAccording(type: type, dateFrom: monthInformationModel.dateFrom, dateTo: monthInformationModel.dateTo, isForMonth: true) { [weak self] model in
      guard let self else { return }
      setup(model: model, for: type)
    }
  }
  func setup(model: DaysRangeInformationModel, for type: HealthKitActivityTypes) {
    switch type {
    case .energy:
      monthKCalModel = model
      
      delegate?.monthSumDidChange(to: model.sumValue, for: type)
    case .step:
      monthInformationModel = model
      delegate?.monthInformationDidChange()
      delegate?.monthAverageStepsDidChange(to: Int(model.averageValue))
      delegate?.monthSumDidChange(to: model.sumValue, for: .step)
    case .distance:
      monthDistanceModel = model
      
      delegate?.monthSumDidChange(to: model.sumValue, for: type)
    case .exerciseTime:
      monthHourModel = model
      
      delegate?.monthSumDidChange(to: model.sumValue, for: type)
    }
  }
  func updateTodayModelIfNeeded(for type: HealthKitActivityTypes, with value: Float) {
    let model: DaysRangeInformationModel
    
    switch type {
    case .energy:
      model = monthKCalModel
    case .step:
      model = monthInformationModel
    case .distance:
      model = monthDistanceModel
    case .exerciseTime:
      model = monthHourModel
    }
    
    let todayModel = model.dayModels.first { $0.isToday }
    guard let todayModel else { return }
    
    var dayModels = model.dayModels
    let updatedTodayModel = DayInformationModel(value: value, basedOn: todayModel)
    
    dayModels.removeAll { $0.isToday }
    dayModels.append(updatedTodayModel)
    dayModels.sort { $0.date.milisecondsSince1970 < $1.date.milisecondsSince1970 }
    
    let newModel = DaysRangeInformationModel(dayModels: dayModels)
    switch type {
    case .energy:
      monthKCalModel = newModel
    case .step:
      monthInformationModel = newModel
    case .distance:
      monthDistanceModel = newModel
    case .exerciseTime:
      monthHourModel = newModel
    }
    
    switch type {
    case .energy, .distance, .exerciseTime:
      delegate?.monthSumDidChange(to: newModel.sumValue, for: type)
    case .step:
      let indexWithUpdate = monthInformationModel.dayModels.firstIndex { $0.isToday }
      guard let indexWithUpdate else { return }
      //update Cell
      delegate?.dayModelInformationDidChange(at: getIndexPathForItem(at: indexWithUpdate))
      
      delegate?.monthAverageStepsDidChange(to: Int(monthInformationModel.averageValue))
      delegate?.monthSumDidChange(to: monthInformationModel.sumValue, for: .step)
    }
  }
    
  func getIndexForItem(at indexPath: IndexPath) -> Int {
    indexPath.row
  }
  func getIndexPathForItem(at index: Int) -> IndexPath {
    IndexPath(row: index, section: 0)
  }
  
  private func processedCalendar(according date: Date) {
    //need get startOfMonth and endOfMonth
    leftDate = helper.getStartOfMonth(from: date)
    rightDate = helper.getEndOfMonth(from: date)
    
    delegate?.monthDidChange(to: leftDate.toString(withFormat: .monthYear))
    
    let userTimezoneCurrentDate = helper.convertToUserTimezone(date: Date())
    let expectedIsActive = userTimezoneCurrentDate.milisecondsSince1970 > rightDate.milisecondsSince1970
    
    if isRightSwitcherActive != expectedIsActive {
      isRightSwitcherActive = expectedIsActive
      delegate?.updateRightDateSwitchButton(to: expectedIsActive)
    }
    
    fillMonthDaysStepInformation()
  }
}
//MARK: - API
extension CalendarViewModel {
  func getDayModel(for indexPath: IndexPath) -> DayInformationModel? {
    let index = getIndexForItem(at: indexPath)
    guard monthInformationModel.dayModels.indices.contains(index) else { return nil }
    
    return monthInformationModel.dayModels[index]
  }
  func switchDateRange(isToLeft: Bool) {
    let rangeValue = isToLeft ? -1 : 1 // if -1 -- left button tapped if 1 -- right button tapped
    let processedDate = isToLeft ? leftDate : rightDate
    
    let changebleDate = isToLeft ? helper.getStartOfMonth(from: processedDate) : helper.getEndOfMonth(from: processedDate)
    
    guard let changedDate = helper.date(byAdding: .month, value: rangeValue, to: changebleDate) else {
#if DEBUG
      print("❌ CalendarViewModel.switchDateRange(isToLeft: Bool): Calendar could not get next Date!")
#endif
      return
    }
    
    processedCalendar(according: changedDate)
    retriveHealthKitInfo()
  }
}

//MARK: - HealthKitServiceChanges
extension CalendarViewModel: HealthKitServiceChanges {
  func activeEnergyBurnedForTodayDidChange(to value: Int) {
    updateTodayModelIfNeeded(for: .energy, with: Float(value))
  }
  func stepCountForTodayDidChange(to value: Int) {
    updateTodayModelIfNeeded(for: .step, with: Float(value))
  }
  func distanceWalkingRunningForTodayDidChange(to value: Double) {
    updateTodayModelIfNeeded(for: .distance, with: Float(value))
  }
  func exerciseTimeForTodayDidChange(to value: Double) {
    updateTodayModelIfNeeded(for: .exerciseTime, with: Float(value))
  }
}
