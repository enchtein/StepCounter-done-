import UIKit

enum SettingSectionType: Int, CaseIterable {
  case app = 0
  case healthKit
  case documentation
  case appPopularing
  case appVer
  
  var sectionSettings: [SettingType] {
    switch self {
    case .app: [.goals, .profileSettings, .notifications]
    case .healthKit: [.importFromAppleHealth]
    case .documentation: [.privacyPolicy, .termsOfUse]
    case .appPopularing: [.rateUs, .shareApp]
    case .appVer: [.appVer]
    }
  }
}

enum SettingType: Int {
  case goals
  case profileSettings
  case notifications
  
  case importFromAppleHealth
  
  case privacyPolicy
  case termsOfUse
  
  case rateUs
  case shareApp
  
  case appVer
  
  var title: String {
    switch self {
    case .goals: SettingsTitles.goals.localized
    case .profileSettings: SettingsTitles.profileSettings.localized
    case .notifications: SettingsTitles.notifications.localized
    case .importFromAppleHealth: SettingsTitles.importFromAppleHealth.localized
    case .privacyPolicy: SettingsTitles.privacyPolicy.localized
    case .termsOfUse: SettingsTitles.termsOfUse.localized
    case .rateUs: SettingsTitles.rateUs.localized
    case .shareApp: SettingsTitles.shareApp.localized
    case .appVer: String(format: SettingsTitles.appVer.localized, appVer)
    }
  }
  var description: String? {
    switch self {
    case .goals: SettingsTitles.goalsDescription.localized
    case .profileSettings: SettingsTitles.profileSettingsDescription.localized
    case .notifications: LocalNotificationsProvider.shared.isAuthorized ? String(format: SettingsTitles.notificationsDescription.localized, LocalNotificationsProvider.shared.notificationDateStr) : SettingsTitles.notificationsDescriptionDisabled.localized
    default: nil
    }
  }
  
  var isDescriprionExist: Bool {
    description != nil
  }
  
  var icon: UIImage? {
    switch self {
    case .goals: AppImage.Settings.goals
    case .profileSettings: AppImage.Settings.profileSettings
    case .notifications: AppImage.Settings.notifications
    case .importFromAppleHealth: AppImage.Settings.importFromAppleHealth
    case .privacyPolicy: AppImage.Settings.privacyPolicy
    case .termsOfUse: AppImage.Settings.termsOfUse
    case .rateUs: AppImage.Settings.rateUs
    case .shareApp: AppImage.Settings.shareApp
    case .appVer: nil
    }
  }
  
  var link: URL? {
    switch self {
    case .goals: nil
    case .profileSettings: nil
    case .notifications:
      if #available(iOS 16.0, *) {
        URL(string: UIApplication.openNotificationSettingsURLString)
      } else {
        URL(string: UIApplication.openSettingsURLString)
      }
    case .importFromAppleHealth: nil
    case .privacyPolicy: URL(string: "https://www.google.com/")
    case .termsOfUse: URL(string: "https://www.google.com/")
    case .rateUs: nil
    case .shareApp: URL(string: "https://www.google.com/")
    case .appVer: nil
    }
  }
}

private extension SettingType {
  var appVer: String {
    if let bundleVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      return bundleVer
    } else {
      return "1.0.0"
    }
  }
}
