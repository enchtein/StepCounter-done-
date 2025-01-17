import HealthKit

enum HealthKitBodyTypes: Int, CaseIterable {
  case gender
  case height
  case stepLenght
  case weight
  
  var objType: HKObjectType {
    switch self {
    case .gender:
      HKSampleType.characteristicType(forIdentifier: .biologicalSex)!
    case .height:
      HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    case .stepLenght:
      HKSampleType.quantityType(forIdentifier: .walkingStepLength)!
    case .weight:
      HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    }
  }
  
  var hkUnit: HKUnit {
    switch self {
    case .gender: HKUnit.kilocalorie() // not used
    case .height: HKUnit.meterUnit(with: .centi)
    case .stepLenght: HKUnit.meterUnit(with: .centi)
    case .weight: HKUnit.gramUnit(with: .kilo)
    }
  }
  
  var isGetByQuery: Bool { self != .gender }
}
