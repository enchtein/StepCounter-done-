import UIKit

protocol StoryboardInitializable {
  static var storyboardName: String { get }
  static var storyboardBundle: Bundle? { get }
  
  static func createFromStoryboard() -> Self
}

extension StoryboardInitializable where Self : UIViewController {
  static var storyboardName: String {
    return "LaunchScreen"
  }
  
  static var storyboardBundle: Bundle? {
    return nil
  }
  
  static var storyboardIdentifier: String {
    return String(describing: self)
  }
  
  static func createFromStoryboard() -> Self {
    let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
    return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
  }
}

extension StoryboardInitializable where Self : SplashScreenViewController {
  static var storyboardName: String {
    return "SplashScreen"
  }
}

extension StoryboardInitializable where Self : OnBoardingViewController {
  static var storyboardName: String {
    return "OnBoarding"
  }
}
extension StoryboardInitializable where Self : OnBoardingPageViewController {
  static var storyboardName: String {
    return "OnBoardingPageView"
  }
}
extension StoryboardInitializable where Self : OnBoardingPageContentViewController {
  static var storyboardName: String {
    return "OnBoardingPageContent"
  }
}

extension StoryboardInitializable where Self : SetGoalsViewController {
  static var storyboardName: String {
    return "SetGoals"
  }
}

extension StoryboardInitializable where Self : MainViewController {
  static var storyboardName: String {
    return "Main"
  }
}

extension StoryboardInitializable where Self : LastSevenDaysViewController {
  static var storyboardName: String {
    return "LastSevenDays"
  }
}
extension StoryboardInitializable where Self : CalendarViewController {
  static var storyboardName: String {
    return "Calendar"
  }
}

extension StoryboardInitializable where Self : AchievementsViewController {
  static var storyboardName: String {
    return "Achievements"
  }
}

extension StoryboardInitializable where Self : SettingsViewController {
  static var storyboardName: String {
    return "Settings"
  }
}

extension StoryboardInitializable where Self : ProfileSettingsViewController {
  static var storyboardName: String {
    return "ProfileSettings"
  }
}
