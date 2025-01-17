import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = window else {
      assertionFailure("Please, choose launch storyboard")
      return false
    }
    
    UNUserNotificationCenter.current().delegate = self
    
    AppCoordinator.shared.start(with: window)
    LocalNotificationsProvider.shared.requestNotificationPermission()
    
    return true
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.sound, .badge, .banner])
  }
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    LocalNotificationsProvider.shared.updateBadgeCountToZero()
  }
}
