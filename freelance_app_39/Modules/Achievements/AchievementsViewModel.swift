import Foundation

protocol AchievementsViewModelDelegate: AnyObject {
  func dataSourceDidChange()
  func modelDidChange(at indexPath: IndexPath, with newModel: AchievementModel)
  
  
  func updateAchievementLevel(according type: AchievementType)
  func updateAchievementsSum(to value: Int)
}
final class AchievementsViewModel {
  private let service = HealthKitService.shared
  private weak var delegate: AchievementsViewModelDelegate?
  
  private let modelTypes = AchievementType.allCases
  private(set) var dataSource = [AchievementModel]()
  private var stepsForToday: Int = .zero
  
  init(delegate: AchievementsViewModelDelegate?) {
    self.delegate = delegate
    self.stepsForToday = service.stepCountForToday
    
    service.attach(observer: self)
  }
  func viewDidLoad() {
    fillDataSource()
    updateAchievementSumAndImage()
  }
  deinit {
    service.deattach(observer: self)
  }
  func deinitWasCalled() {
    service.deattach(observer: self)
  }
}
//MARK: - Helpers
private extension AchievementsViewModel {
  func indexForItem(at indexPath: IndexPath) -> Int {
    indexPath.row
  }
  func indexPathForItem(at index: Int) -> IndexPath {
    IndexPath(row: index, section: 0)
  }
  func isModelExist(at index: Int) -> Bool {
    dataSource.indices.contains(index)
  }
  
  func createDataSource() -> [AchievementModel] {
    modelTypes.map {
      AchievementModel(type: $0, maxStepsPerDay: UserDefaults.standard.maxStepsPerDay)
    }
  }
  
  func fillDataSource() {
    dataSource = createDataSource()
    delegate?.dataSourceDidChange()
  }
  func updateAchievementModel() {
    let oldDataSource = dataSource
    let newDataSource = createDataSource()
    
    var isChangesExist = false
    for (index, oldModel) in oldDataSource.enumerated() {
      guard newDataSource.indices.contains(index) else { continue }
      let newModel = newDataSource[index]
      if newModel.goalMultiplier != oldModel.goalMultiplier {
        let indexPath = indexPathForItem(at: index)
        delegate?.modelDidChange(at: indexPath, with: newModel)
        
        isChangesExist = true
      }
    }
    
    dataSource = newDataSource
    
    if isChangesExist {
      updateAchievementSumAndImage()
    }
  }
  
  func updateAchievementSumAndImage() {
    let doneAchievements = dataSource.filter { $0.isGoalDone }
    let achievementsSum = doneAchievements.map { $0.type.stepsGoal }.reduce(0, +)
    
    let additionalSteps: Int
    if stepsForToday > achievementsSum {
      additionalSteps = stepsForToday - achievementsSum
    } else {
      additionalSteps = .zero
    }
    
    delegate?.updateAchievementsSum(to: achievementsSum + additionalSteps)
    
    let openedAchievements = dataSource.filter { !$0.isClosed }.sorted { $0.type.rawValue < $1.type.rawValue }
    if let lastModel = openedAchievements.last {
      delegate?.updateAchievementLevel(according: lastModel.type)
    }
  }
}
//MARK: - API
extension AchievementsViewModel {
  func getAchievementModel(for indexPath: IndexPath) -> AchievementModel? {
    let index = indexForItem(at: indexPath)
    guard isModelExist(at: index) else { return nil }
    return dataSource[index]
  }
}
//MARK: - HealthKitServiceChanges
extension AchievementsViewModel: HealthKitServiceChanges {
  func stepCountForTodayDidChange(to value: Int) {
    stepsForToday = value
    
    updateAchievementModel()
  }
}
