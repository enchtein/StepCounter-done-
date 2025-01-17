import UIKit

@objc protocol CommonNavPanelDelegate: AnyObject {
  @objc optional func achievementsButtonAction()
  @objc optional func settingsButtonAction()
  @objc optional func backButtonAction()
  @objc optional func shareButtonAction()
}
final class CommonNavPanel: UIView {
  private let type: CommonNavPanelType
  private weak var delegate: CommonNavPanelDelegate?
  
  private lazy var title = createTitle()
  private lazy var achievementsButton = createAchievementsButton()
  private lazy var settingsButton = createSettingsButton()
  
  private lazy var backButton = createBackButton()
  private lazy var shareButton = createShareButton()
  
  private lazy var emptyView = createEmptyView()
  
  init(type: CommonNavPanelType, delegate: CommonNavPanelDelegate?) {
    self.type = type
    self.delegate = delegate
    
    super.init(frame: .zero)
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    let hStack = UIStackView()
    hStack.spacing = Constants.spacing
    hStack.alignment = .center
    
    addSubview(hStack)
    hStack.translatesAutoresizingMaskIntoConstraints = false
    hStack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topIndent).isActive = true
    hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.sideIndent).isActive = true
    hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.sideIndent).isActive = true
    hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomIndent).isActive = true
    
    switch type {
    case .main:
      hStack.addArrangedSubview(title)
      hStack.addArrangedSubview(achievementsButton)
      hStack.addArrangedSubview(settingsButton)
    case .achievements:
      hStack.addArrangedSubview(backButton)
      hStack.addArrangedSubview(title)
      hStack.addArrangedSubview(shareButton)
    case .settings, .goals, .profileSettings:
      hStack.addArrangedSubview(backButton)
      hStack.addArrangedSubview(title)
      hStack.addArrangedSubview(emptyView)
    }
    
    additionalUISettings()
  }
  private func additionalUISettings() {
    switch type {
    case .main:
      title.textAlignment = .left
    case .achievements, .settings, .goals, .profileSettings:
      title.textAlignment = .center
    }
  }
}
//MARK: - Actions
private extension CommonNavPanel {
  @objc func achievementsButtonAction() {
    delegate?.achievementsButtonAction?()
  }
  @objc func settingsButtonAction() {
    delegate?.settingsButtonAction?()
  }
  @objc func backButtonAction() {
    delegate?.backButtonAction?()
  }
  @objc func shareButtonAction() {
    delegate?.shareButtonAction?()
  }
}
//MARK: - Create UI elements
private extension CommonNavPanel {
  func createTitle() -> UILabel {
    let label = UILabel()
    label.textColor = Constants.titleColor
    label.font = Constants.titleFont
    label.text = type.title
    
    return label
  }
  func createAchievementsButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.achievements, for: .normal)
    button.addTarget(self, action: #selector(achievementsButtonAction), for: .touchUpInside)
    
    return button
  }
  func createSettingsButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.settings, for: .normal)
    button.addTarget(self, action: #selector(settingsButtonAction), for: .touchUpInside)
    
    return button
  }
  func createBackButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.back, for: .normal)
    button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
    
    return button
  }
  func createShareButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.share, for: .normal)
    button.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
    
    return button
  }
  func createEmptyView() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    view.widthAnchor.constraint(equalToConstant: Constants.buttonSideSize).isActive = true
    view.heightAnchor.constraint(equalToConstant: Constants.buttonSideSize).isActive = true
    
    return view
  }
  
  func createCommonButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    button.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
    button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
    
    button.widthAnchor.constraint(equalToConstant: Constants.buttonSideSize).isActive = true
    button.heightAnchor.constraint(equalToConstant: Constants.buttonSideSize).isActive = true
    
    return button
  }
}
//MARK: - Constants
fileprivate struct Constants {
  static var titleFont: UIFont {
    let fontSize = 24.0
    return AppFont.font(type: .bold, size: fontSize.sizeProportion)
  }
  static let titleColor = AppColor.layerOne
  
  static var buttonSideSize: CGFloat {
    let sideSize = 44.0
    return sideSize.sizeProportion
  }
  
  static let topIndent: CGFloat = 8.0
  static let sideIndent: CGFloat = 16.0
  static let bottomIndent: CGFloat = 12.0
  
  static let spacing: CGFloat = 12.0
}
//MARK: - CommonNavPanelType
enum CommonNavPanelType {
  case main
  case achievements
  case settings
  case goals
  case profileSettings
  
  var title: String {
    switch self {
    case .main: MainTitles.title.localized
    case .achievements: AchievementsTitles.title.localized
    case .settings: SettingsTitles.title.localized
    case .goals: SettingsTitles.goals.localized
    case .profileSettings: ProfileSettingsTitles.title.localized
    }
  }
}
