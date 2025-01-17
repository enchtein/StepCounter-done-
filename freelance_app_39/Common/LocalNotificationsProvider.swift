import UserNotifications
import UIKit

final class LocalNotificationsProvider {
  static let shared = LocalNotificationsProvider()
  private(set) var isAuthorized = false
  
  private init() {}
  
  func requestNotificationPermission(successCompletion: (() -> Void)? = nil) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] didAllow, error in
      guard let self else { return }
      
      if didAllow {
        successCompletion?()
      } else {
#if DEBUG
        print("Permission for push notifications denied.")
#endif
      }
      
      updateAuthorizationStatus()
      scheduleRepeatebleNotification()
    }
  }
  
  private let notificationHour = 21
  private let notificationMinutes = 00
  
  private var notificationDate: Date? {
    var currentDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: Date())
    currentDateComponents.hour = notificationHour
    currentDateComponents.minute = notificationMinutes
    
    let timezoneHelper = CalendarTimezoneHelper()
    return timezoneHelper.zeroTimezoneCalendar.date(from: currentDateComponents)
  }
  var notificationDateStr: String {
    guard let notificationDate else { return "Missing date" }
    return notificationDate.toString(withFormat: .hoursMinutes24)
  }
}
//MARK: - Helpers
private extension LocalNotificationsProvider {
  private func updateAuthorizationStatus() {
    UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
      self?.isAuthorized = settings.authorizationStatus == .authorized
    }
  }
  
  private func scheduleRepeatebleNotification() {
    removeAllNotifications()
    
    let dailyNotificationKey = "Daily notification category"
    
    let content = UNMutableNotificationContent()
    
    content.title = Bundle.applicationName
    content.body = CommonAppTitles.notificationMsg.localized
    content.categoryIdentifier = dailyNotificationKey
    content.sound = UNNotificationSound.default
    content.badge = 1
    
    var dateComponents = DateComponents()
    dateComponents.timeZone = Calendar.current.timeZone
    dateComponents.hour = notificationHour
    dateComponents.minute = notificationMinutes
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: dailyNotificationKey, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
#if DEBUG
        print("❌ Daily Local Push Notification added failure: \(error.localizedDescription)")
#endif
      } else {
#if DEBUG
        print("✅ Daily Local Push Notification successfully added.")
#endif
      }
    }
  }
  
  private func removeAllNotifications() {
    updateBadgeCountToZero()
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
}
//MARK: - API
extension LocalNotificationsProvider {
  func updateBadgeCountToZero() {
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0)
    } else {
      // Fallback on earlier versions
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
  }
}
