import UIKit
import HealthKit

@objc protocol HealthKitServiceChanges: AnyObject {
  @objc optional func activeEnergyBurnedForTodayDidChange(to value: Int)
  @objc optional func stepCountForTodayDidChange(to value: Int)
  @objc optional func distanceWalkingRunningForTodayDidChange(to value: Double)
  @objc optional func exerciseTimeForTodayDidChange(to value: Double)
}

final class HealthKitService {
  static let shared = HealthKitService()
  private lazy var timezoneHelper = CalendarTimezoneHelper()
  
  private init() { }
  
  private let healthStore = HKHealthStore()
  private let activityTypes = HealthKitActivityTypes.allCases
  private let bodyTypes = HealthKitBodyTypes.allCases
  
  private var observers = [HealthKitServiceChanges]()
  
  //---> today variables (start)
  private(set) var activeEnergyBurnedForToday = 0
  private(set) var stepCountForToday = 0
  private(set) var distanceWalkingRunningForToday: Double = 0
  private(set) var exerciseTimeForToday: Double = 0
  //<--- today variables (end)
  
  var isActivityTypesAvailable: Bool {
    let isAllZero = [Double(activeEnergyBurnedForToday),
                     Double(stepCountForToday),
                     distanceWalkingRunningForToday,
                     exerciseTimeForToday].allSatisfy { $0 == .zero }
    
    return !isAllZero
  }
  
  func checkStatusAndRequestIfNeeded(denyAlertAction: (() -> Void)? = nil, allowAction: @escaping () -> Void) {
    if checkIsAccessAllowed() {
      runFetchingHealthKitServiceParameters()
      allowAction()
    } else {
      requestAccessToHealthKit(denyAlertAction: denyAlertAction, allowAction: allowAction)
    }
  }
  private func checkIsAccessAllowed() -> Bool {
    let authorizationStatuses = activityTypes.map {
      healthStore.authorizationStatus(for: $0.sampleType)
    }
    let authorizationBodyStatuses = bodyTypes.map {
      healthStore.authorizationStatus(for: $0.objType)
    }
    
    let allStatuses = authorizationStatuses + authorizationBodyStatuses
    
    let isDenyAccess = allStatuses.contains(.notDetermined) || allStatuses.contains(.sharingDenied)
    return !isDenyAccess
  }
  
  private func requestAccessToHealthKit(denyAlertAction: (() -> Void)?, allowAction: @escaping () -> Void) {
    let activityTypesSet: Set<HKObjectType> = Set(activityTypes.map{ $0.sampleType })
    let parameterTypesSet = Set(bodyTypes.map{ $0.objType })
    let all = activityTypesSet.union(parameterTypesSet)
    
    healthStore.requestAuthorization(toShare: nil, read: all) { [weak self] (success, error) in
      if let error {
        DispatchQueue.main.async {
          UIAlertController.alert(message: error.localizedDescription)
        }
        
      } else {
        if success {
          DispatchQueue.main.async {
            if self?.checkIsAccessAllowed() ?? false {
              self?.setUpBackgroundDeliveryForDataTypes()
              allowAction()
            } else {
              if let topVC = UIApplication.shared.appWindow?.topViewController(), topVC is BaseViewController {
                self?.showDenyAlert(okAlertAction: denyAlertAction)
              } else {
                denyAlertAction?()
              }
            }
          }
        } else {
          denyAlertAction?()
        }
      }
    }
  }
  
  private func showDenyAlert(okAlertAction: (() -> Void)?) {
    let okAction = UIAlertAction(title: OnBoardingTitles.denyAlertOk.localized, style: .cancel) { _ in
      okAlertAction?()
    }
    
    UIAlertController.alert(with: OnBoardingTitles.denyAlertTitle.localized, message: OnBoardingTitles.denyAlertMsg.localized, actions: [okAction])
  }
}
//MARK: - Observing changes
private extension HealthKitService {
  func setUpBackgroundDeliveryForDataTypes() {
    for activityType in activityTypes {
      let query = HKObserverQuery(sampleType: activityType.sampleType, predicate: nil) { [weak self] query, completionHandler, error in
        guard let self else { return }
        queryForUpdatesNotifying(activityType)
      }
      
      healthStore.execute(query)
      healthStore.enableBackgroundDelivery(for: activityType.sampleType, frequency: .immediate) { isSuccess, error in
        debugPrint("enableBackgroundDeliveryForType handler called for \(activityType) - success: \(isSuccess), error: \(error)")
      }
    }
  }
  
  func getBodyParams() {
    for bodyType in bodyTypes {
      switch bodyType {
      case .gender:
        Task {
          do {
            let sex = try healthStore.biologicalSex()
            UserDefaults.standard.gender = GenderType(biologicalSex: sex.biologicalSex)?.title
          }
        }
      default:
        guard let sampleType = bodyType.objType as? HKSampleType else { continue }
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: nil) { [weak self] (query, results, error) in
          if let result = results?.first as? HKQuantitySample {
            if bodyType.isGetByQuery {
              let totalValue = result.quantity.doubleValue(for: bodyType.hkUnit)
              self?.updateUserDefaults(with: totalValue, for: bodyType)
            }
          } else {
            debugPrint("OOPS didnt get \nResults => \(results), error => \(error)")
          }
        }
        
        healthStore.execute(query)
      }
    }
  }
}
//MARK: - Observers processing
extension HealthKitService {
  func attach(observer: HealthKitServiceChanges) {
    let existObserver = observers.first { $0 === observer }
    
    guard existObserver == nil else { return }
    observers.append(observer)
#if DEBUG
    print("⚠️ observer attached")
#endif
    
    
  }
  func deattach(observer: HealthKitServiceChanges) {
    observers.removeAll { $0 === observer }
#if DEBUG
    print("⚠️ observer deattached")
#endif
  }
  
  private func queryForUpdatesNotifying(_ activityType: HealthKitActivityTypes) {
#if DEBUG
    print("\(activityType) value did change")
#endif
    fetchInfoForToday(for: activityType)
  }
}
//MARK: - Helpers
private extension HealthKitService {
  func fetchInfoForToday(for type: HealthKitActivityTypes) {
    let startDate = Calendar.current.startOfDay(for: Date())
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
    
    let query = HKSampleQuery(sampleType: type.sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { [weak self] (query, results, error) in
      guard let samples = results as? [HKQuantitySample] else { return }
      
      let totalValue = samples.reduce(0, {$0 + $1.quantity.doubleValue(for: type.hkUnit)})
      let roundedTotalValue = totalValue.withTwoDigits
      
      DispatchQueue.main.async {
        switch type {
        case .energy:
          self?.activeEnergyBurnedForToday = Int(roundedTotalValue)
          self?.observers.forEach {
            $0.activeEnergyBurnedForTodayDidChange?(to: Int(roundedTotalValue))
          }
        case .step:
          self?.stepCountForToday = Int(roundedTotalValue)
          self?.updateMaxStepsPerDayIfNeeded(with: Int(roundedTotalValue))
          
          self?.observers.forEach {
            $0.stepCountForTodayDidChange?(to: Int(roundedTotalValue))
          }
        case .distance:
          let totalDistanceKm = Measurement(value: totalValue, unit: UnitLength.miles).converted(to: .kilometers).value.withTwoDigits
          self?.distanceWalkingRunningForToday = totalDistanceKm
          self?.observers.forEach {
            $0.distanceWalkingRunningForTodayDidChange?(to: totalDistanceKm)
          }
        case .exerciseTime:
          self?.exerciseTimeForToday = roundedTotalValue
          self?.observers.forEach {
            $0.exerciseTimeForTodayDidChange?(to: roundedTotalValue)
          }
        }
      }
    }
    healthStore.execute(query)
  }
  
  func updateMaxStepsPerDayIfNeeded(with value: Int) {
    guard UserDefaults.standard.maxStepsPerDay < value else { return }
    UserDefaults.standard.maxStepsPerDay = value
  }
  
  func updateUserDefaults(with value: Double, for type: HealthKitBodyTypes) {
    let resValue = Int(value)
#if DEBUG
    print("type of \(type) was set to value = \(resValue)")
#endif
    
    DispatchQueue.main.async {
      switch type {
      case .gender: break
      case .height:
        UserDefaults.standard.heightCM = resValue
      case .stepLenght:
        UserDefaults.standard.stepLenghtCM = resValue
      case .weight:
        UserDefaults.standard.weightKG = resValue
      }
    }
  }
}

//MARK: - API
extension HealthKitService {
  func runFetchingHealthKitServiceParameters() {
    setUpBackgroundDeliveryForDataTypes()
    getBodyParams()
  }
  func resetBoduParams() {
    UserDefaults.standard.gender = nil
    UserDefaults.standard.heightCM = nil
    UserDefaults.standard.stepLenghtCM = nil
    UserDefaults.standard.weightKG = nil
    
    getBodyParams()
  }
  func getInformationAccording(type: HealthKitActivityTypes, dateFrom: Date, dateTo: Date, isForMonth: Bool, completion: @escaping (DaysRangeInformationModel) -> Void) {
    let emptyModel = DaysRangeInformationModel.createEmpty(dateFrom: dateFrom, dateTo: dateTo, for: type, isForMonth: isForMonth)
    
    let dateFromAtZeroTimezone = timezoneHelper.convertToZeroTimezone(date: dateFrom)
    let dateToAtZeroTimezone = timezoneHelper.convertToZeroTimezone(date: dateTo)
    
    let predicate = HKQuery.predicateForSamples(withStart: dateFromAtZeroTimezone, end: dateToAtZeroTimezone, options: .strictStartDate)
    
    let query = HKSampleQuery(sampleType: type.sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { [weak self] (query, results, error) in
      guard let self else { completion(emptyModel); return }
      guard let samples = results as? [HKQuantitySample] else { completion(emptyModel); return }
      
      let dayModels = emptyModel.dayModels.map { dayModel in
        let daySamples = samples.filter {
          let startDateAtUserTimezone = self.timezoneHelper.convertToUserTimezone(date: $0.startDate)
          return self.timezoneHelper.isSameDay(startDateAtUserTimezone, with:  dayModel.date)
        }
        let daySum = daySamples.reduce(0, { $0 + $1.quantity.doubleValue(for: type.hkUnit) })
        
        return DayInformationModel(value: Float(daySum), maxValueAtRange: 0, basedOn: dayModel)
      }
      
      let maxValueAtRange = dayModels.map { $0.value }.max() ?? 0
      let totalDayModels = dayModels.map { DayInformationModel(maxValueAtRange: maxValueAtRange, basedOn: $0) }
      
      let res = DaysRangeInformationModel(dayModels: totalDayModels)
      DispatchQueue.main.async {
        completion(res)
      }
    }
    healthStore.execute(query)
  }
}
