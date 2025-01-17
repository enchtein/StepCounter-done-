import UIKit

enum AchievementType: Int, CaseIterable {
  case lvl1 = 0
  case lvl2
  case lvl3
  case lvl4
  case lvl5
  case lvl6
  case lvl7
  case lvl8
  case lvl9
  case lvl10
  
  var stepsGoal: Int {
    switch self {
    case .lvl1: 3000
    case .lvl2: 7000
    case .lvl3: 10000
    case .lvl4: 15000
    case .lvl5: 20000
    case .lvl6: 40000
    case .lvl7: 45000
    case .lvl8: 60000
    case .lvl9: 65000
    case .lvl10: 70000
    }
  }
  
  var icon: UIImage {
    switch self {
    case .lvl1: AppImage.Achievements.lvl1
    case .lvl2: AppImage.Achievements.lvl2
    case .lvl3: AppImage.Achievements.lvl3
    case .lvl4: AppImage.Achievements.lvl4
    case .lvl5: AppImage.Achievements.lvl5
    case .lvl6: AppImage.Achievements.lvl6
    case .lvl7: AppImage.Achievements.lvl7
    case .lvl8: AppImage.Achievements.lvl8
    case .lvl9: AppImage.Achievements.lvl9
    case .lvl10: AppImage.Achievements.lvl10
    }
  }
  var title: String {
    String(format: AchievementsTitles.level.localized, self.rawValue + 1)
  }
}
