import UIKit

enum AppImage {
  
  enum OnBoarding {
    static let day = UIImage(resource: .dayObIc)
    static let archivements = UIImage(resource: .archivementsObIc)
    static let month = UIImage(resource: .monthObIc)
  }
  enum SetGoals {
    static let increment = UIImage(resource: .incrementSGIm)
    static let decrement = UIImage(resource: .decrementSGIm)
    
    static let step = UIImage(resource: .stepSGIm)
    static let kCal = UIImage(resource: .kCalSGIm)
  }
  
  enum Main {
    static let share = UIImage(resource: .shareMIc)
    
    static let kCal = UIImage(resource: .kCalMIc)
    static let km = UIImage(resource: .kmMIc)
    static let hour = UIImage(resource: .hourMIc)
    
    static let crown = UIImage(resource: .crownMIc)
    
    static let leftDateSwitch = UIImage(resource: .leftDateSwitchMIc)
    static let rightDateSwitch = UIImage(resource: .rightDateSwitchMIc)
    
    static let close = UIImage(resource: .closeMIc)
    
    static let denyNotifyingStep = UIImage(resource: .denyNotifyingStepMIc)
  }
  
  enum CommonNavPanel {
    static let achievements = UIImage(resource: .achievementsCNPIc)
    static let settings = UIImage(resource: .settingsCNPIc)
    static let back = UIImage(resource: .backCNPIc)
    static let share = UIImage(resource: .shareCNPIc)
  }
  
  enum Achievements {
    static let close = UIImage(resource: .closeAIc)
    static let lvl1 = UIImage(resource: .lvl1AIc)
    static let lvl2 = UIImage(resource: .lvl2AIc)
    static let lvl3 = UIImage(resource: .lvl3AIc)
    static let lvl4 = UIImage(resource: .lvl4AIc)
    static let lvl5 = UIImage(resource: .lvl5AIc)
    static let lvl6 = UIImage(resource: .lvl6AIc)
    static let lvl7 = UIImage(resource: .lvl7AIc)
    static let lvl8 = UIImage(resource: .lvl8AIc)
    static let lvl9 = UIImage(resource: .lvl9AIc)
    static let lvl10 = UIImage(resource: .lvl10AIc)
  }
  
  enum Settings {
    static let rightArrow = UIImage(resource: .rightArrowSIm)
    
    static let goals = UIImage(resource: .goalsSIm)
    static let profileSettings = UIImage(resource: .profileSIm)
    static let notifications = UIImage(resource: .notificationsSIm)
    
    static let importFromAppleHealth = UIImage(resource: .importFromAppleHealthSIm)
    
    static let privacyPolicy = UIImage(resource: .privacyPolicySIm)
    static let termsOfUse = UIImage(resource: .termsOfUseSIm)
    
    static let rateUs = UIImage(resource: .rateUsSIm)
    static let shareApp = UIImage(resource: .shareAppSIm)
  }
}
