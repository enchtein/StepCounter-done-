import HealthKit

enum HealthKitActivityTypes: Int, CaseIterable {
  case energy = 0
  case step
  case distance
  case exerciseTime
  
  var sampleType: HKSampleType {
    switch self {
    case .energy: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    case .step: HKObjectType.quantityType(forIdentifier: .stepCount)!
    case .distance: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
    case .exerciseTime: HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
    }
  }
  
  var hkUnit: HKUnit {
    switch self {
    case .energy: HKUnit.kilocalorie()
    case .step: HKUnit.count()
    case .distance: HKUnit.mile()
    case .exerciseTime: HKUnit.hour()
    }
  }
  
  var name: String {
    switch self {
    case .step: MainTitles.steps.localized
    case .energy: MainTitles.kCal.localized
    case .distance: MainTitles.km.localized
    case .exerciseTime: MainTitles.hour.localized
    }
  }
}
