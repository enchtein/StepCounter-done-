import Foundation

protocol MainViewModelDelegate: AnyObject {
  func activeEnergyBurnedForTodayDidChange(to value: Int)
  func stepCountForTodayDidChange(to value: Int)
  func distanceWalkingRunningForTodayDidChange(to value: Double)
  func exerciseTimeForTodayDidChange(to value: Double)
  
  func calendarWillAppear()
}
final class MainViewModel {
  let service = HealthKitService.shared
  private weak var delegate: MainViewModelDelegate?
  
  private(set) var stepsForToday: Int = .zero
  private(set) var kCalForToday: Int = .zero
  private(set) var distanceForToday: Double = .zero
  private(set) var exerciseTimeForToday: Double = .zero
  
  private(set) var activityType: ActivityType = .today
  
  init(delegate: MainViewModelDelegate) {
    self.delegate = delegate
    service.attach(observer: self)
  }
  func viewDidLoad() {
    stepsForToday = service.stepCountForToday
    kCalForToday = service.activeEnergyBurnedForToday
    distanceForToday = service.distanceWalkingRunningForToday
    exerciseTimeForToday = service.exerciseTimeForToday
    
    delegate?.stepCountForTodayDidChange(to: stepsForToday)
    delegate?.activeEnergyBurnedForTodayDidChange(to: kCalForToday)
    delegate?.distanceWalkingRunningForTodayDidChange(to: distanceForToday)
    delegate?.exerciseTimeForTodayDidChange(to: exerciseTimeForToday)
  }
  deinit {
    service.deattach(observer: self)
  }
}
//MARK: - API
extension MainViewModel {
  func updateActivityType(to value: ActivityType) {
    activityType = value
    
    switch value {
    case .today:
      delegate?.activeEnergyBurnedForTodayDidChange(to: kCalForToday)
      delegate?.distanceWalkingRunningForTodayDidChange(to: distanceForToday)
      delegate?.exerciseTimeForTodayDidChange(to: exerciseTimeForToday)
    case .month:
      delegate?.calendarWillAppear()
    }
  }
}
//MARK: - HealthKitServiceChanges
extension MainViewModel: HealthKitServiceChanges {
  func activeEnergyBurnedForTodayDidChange(to value: Int) {
    kCalForToday = value
    
    guard activityType == .today else { return }
    delegate?.activeEnergyBurnedForTodayDidChange(to: value)
  }
  
  func stepCountForTodayDidChange(to value: Int) {
    stepsForToday = value
    
    delegate?.stepCountForTodayDidChange(to: value)
  }
  
  func distanceWalkingRunningForTodayDidChange(to value: Double) {
    distanceForToday = value
    
    guard activityType == .today else { return }
    delegate?.distanceWalkingRunningForTodayDidChange(to: value)
  }
  
  func exerciseTimeForTodayDidChange(to value: Double) {
    exerciseTimeForToday = value
    
    guard activityType == .today else { return }
    delegate?.exerciseTimeForTodayDidChange(to: value)
  }
}
