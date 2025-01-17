import Foundation

protocol SetGoalsDelegate: AnyObject {
  func stepsDidChange(to value: Int)
  func kCalDidChange(to value: Int)
  
  func buttonAvailability(for type: SetGoalsViewController.SetGoalsButtonType, isActive: Bool)
  func saveButtonAvailability(isActive: Bool)
}
extension SetGoalsViewController {
  final class SetGoalsViewModel {
    private let isFromSettings: Bool
    private weak var delegate: SetGoalsDelegate?
    
    private let orgStepsCount: Int
    private let orgKCalCount: Int
    private(set) var currentStepsCount: Int = SetGoalsType.steps.defaultValue
    private(set) var currentKCalCount: Int = SetGoalsType.kCal.defaultValue
    
    init(isFromSettings: Bool, delegate: SetGoalsDelegate) {
      self.isFromSettings = isFromSettings
      self.delegate = delegate
      
      if UserDefaults.standard.stepGoal == .zero {
        currentStepsCount = SetGoalsType.steps.defaultValue
      } else {
        currentStepsCount = UserDefaults.standard.stepGoal
      }
      if UserDefaults.standard.kCalGoal == .zero {
        currentKCalCount = SetGoalsType.kCal.defaultValue
      } else {
        currentKCalCount = UserDefaults.standard.kCalGoal
      }
      
      orgStepsCount = currentStepsCount
      orgKCalCount = currentKCalCount
    }
    
    func viewDidLoad() {
      delegate?.stepsDidChange(to: currentStepsCount)
      delegate?.kCalDidChange(to: currentKCalCount)
      updateSaveButtonAvailabilityIfNeeded()
    }
  }
}
//MARK: - Helpers
private extension SetGoalsViewController.SetGoalsViewModel {
  func increase(type: SetGoalsViewController.SetGoalsType) {
    let newValue: Int
    
    switch type {
    case .steps:
      newValue = currentStepsCount + type.stepSizeValue
    case .kCal:
      newValue = currentKCalCount + type.stepSizeValue
    }
    
    updateIfNeeded(type: type, to: newValue)
  }
  func decrease(type: SetGoalsViewController.SetGoalsType) {
    let newValue: Int
    
    switch type {
    case .steps:
      newValue = currentStepsCount - type.stepSizeValue
    case .kCal:
      newValue = currentKCalCount - type.stepSizeValue
    }
    
    updateIfNeeded(type: type, to: newValue)
  }
  
  func isCouldUpdate(type: SetGoalsViewController.SetGoalsType, by newValue: Int) -> Bool {
    return newValue >= type.minValue && newValue <= type.maxValue
  }
  func updateButtonAvailability(for type: SetGoalsViewController.SetGoalsType) {
    let minValue = type.minValue
    let maxValue = type.maxValue
    
    switch type {
    case .steps:
      delegate?.buttonAvailability(for: .decreaseStep, isActive: currentStepsCount > minValue)
      delegate?.buttonAvailability(for: .increaseStep, isActive: currentStepsCount < maxValue)
    case .kCal:
      delegate?.buttonAvailability(for: .decreaseKCal, isActive: currentKCalCount > minValue)
      delegate?.buttonAvailability(for: .increaseKCal, isActive: currentKCalCount < maxValue)
    }
  }
  func updateIfNeeded(type: SetGoalsViewController.SetGoalsType, to value: Int) {
    if isCouldUpdate(type: type, by: value) {
      switch type {
      case .steps:
        currentStepsCount = value
        delegate?.stepsDidChange(to: value)
      case .kCal:
        currentKCalCount = value
        delegate?.kCalDidChange(to: value)
      }
    }
    
    updateButtonAvailability(for: type)
    updateSaveButtonAvailabilityIfNeeded()
  }
  
  func updateSaveButtonAvailabilityIfNeeded() {
    guard isFromSettings else { return }
    
    let isEqualStepsCount = orgStepsCount == currentStepsCount
    let isEqualKCalCount = orgKCalCount == currentKCalCount
    
    delegate?.saveButtonAvailability(isActive: !isEqualStepsCount || !isEqualKCalCount)
  }
}
//MARK: - API
extension SetGoalsViewController.SetGoalsViewModel {
  func executeChange(for type: SetGoalsViewController.SetGoalsButtonType?) {
    guard let type else { return }
    
    switch type {
    case .decreaseStep:
      decrease(type: .steps)
    case .increaseStep:
      increase(type: .steps)
    case .decreaseKCal:
      decrease(type: .kCal)
    case .increaseKCal:
      increase(type: .kCal)
    }
  }
}

extension SetGoalsViewController {
  enum SetGoalsType {
    case steps
    case kCal
    
    var defaultValue: Int {
      switch self {
      case .steps: 6000
      case .kCal: 200
      }
    }
    
    var minValue: Int {
      switch self {
      case .steps: 500
      case .kCal: 25
      }
    }
    var maxValue: Int {
      switch self {
      case .steps: 40000
      case .kCal: 3000
      }
    }
    
    var stepSizeValue: Int {
      switch self {
      case .steps: 100
      case .kCal: 25
      }
    }
  }
}
extension SetGoalsViewController {
  enum SetGoalsButtonType: Int {
    case decreaseStep = 0
    case increaseStep
    
    case decreaseKCal
    case increaseKCal
    
    init?(rawValue: Int?) {
      switch rawValue {
      case Self.decreaseStep.rawValue: self = .decreaseStep
      case Self.increaseStep.rawValue: self = .increaseStep
        
      case Self.decreaseKCal.rawValue: self = .decreaseKCal
      case Self.increaseKCal.rawValue: self = .increaseKCal
      default: return nil
      }
    }
  }
}
