import UIKit

protocol IndicatorCardDelegate: AnyObject {
  func didSelectCard(with type: IndicatorCardType)
}
final class IndicatorCard: UIControl {
  let cardType: IndicatorCardType
  private weak var delegate: IndicatorCardDelegate?
  
  init(cardType: IndicatorCardType, delegate: IndicatorCardDelegate) {
    self.cardType = cardType
    self.delegate = delegate
    
    super.init(frame: .zero)
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var indicatorImageView = createIndicatorImageView()
  
  private lazy var indicatorTitle = createIndicatorTitle()
  
  private lazy var indicatorValueLabel = createIndicatorValueLabel()
  private lazy var indicatorGoalLabel = createIndicatorGoalLabel()
  
  private func setupUI() {
    addSubview(indicatorImageView)
    indicatorImageView.translatesAutoresizingMaskIntoConstraints = false
    indicatorImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.baseSideIndent).isActive = true
    indicatorImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.baseSideIndent).isActive = true
    
    
    addSubview(indicatorTitle)
    indicatorTitle.translatesAutoresizingMaskIntoConstraints = false
    indicatorTitle.topAnchor.constraint(equalTo: indicatorImageView.bottomAnchor, constant: Constants.spacing).isActive = true
    indicatorTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.baseSideIndent).isActive = true
    indicatorTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.baseSideIndent).isActive = true
    
    addSubview(indicatorValueLabel)
    indicatorValueLabel.translatesAutoresizingMaskIntoConstraints = false
    indicatorValueLabel.topAnchor.constraint(equalTo: indicatorTitle.bottomAnchor).isActive = true
    indicatorValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.baseSideIndent).isActive = true
    if cardType != .kCal {
      indicatorValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.baseSideIndent).isActive = true
    }
    indicatorValueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.baseSideIndent).isActive = true
    
    if cardType == .kCal {
      indicatorValueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      
      addSubview(indicatorGoalLabel)
      indicatorGoalLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      indicatorGoalLabel.translatesAutoresizingMaskIntoConstraints = false
      indicatorGoalLabel.topAnchor.constraint(equalTo: indicatorValueLabel.topAnchor).isActive = true
      indicatorGoalLabel.leadingAnchor.constraint(equalTo: indicatorValueLabel.trailingAnchor, constant: 1.0).isActive = true
      indicatorGoalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -Constants.baseSideIndent).isActive = true
      indicatorGoalLabel.bottomAnchor.constraint(equalTo: indicatorValueLabel.bottomAnchor).isActive = true
    }
    
    addActions()
    additionalUISettings()
  }
  
  private func addActions() {
    addTarget(self, action: #selector(setOpaqueButton), for: .touchDown)
    addTarget(self, action: #selector(setNonOpaquesButton), for: .touchDragExit)
    addTarget(self, action: #selector(setOpaqueButton), for: .touchDragEnter)
    addTarget(self, action: #selector(setNonOpaquesButton), for: .touchUpInside)
    
    addTarget(self, action: #selector(touchUpInsideAction), for: .touchUpInside)
  }
  
  private func additionalUISettings() {
    backgroundColor = AppColor.layerOne
    cornerRadius = Constants.baseCornerRadius
  }
}
//MARK: - Actions
private extension IndicatorCard {
  @objc func touchUpInsideAction() {
    delegate?.didSelectCard(with: cardType)
  }
  
  @objc func setOpaqueButton() {
    updateButtonOpacity(true)
  }
  @objc func setNonOpaquesButton() {
    updateButtonOpacity(false)
  }
  func updateButtonOpacity(_ isOpaque: Bool) {
    guard isEnabled else { return }
    backgroundColor = isOpaque ? AppColor.layerFive : AppColor.layerOne
  }
}
//MARK: - Create UI elements
private extension IndicatorCard {
  func createIndicatorImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = cardType.image
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height).isActive = true
    
    return imageView
  }
  func createIndicatorTitle() -> UILabel {
    let label = UILabel()
    label.font = Constants.titleFont
    label.textColor = Constants.titleColor
    label.text = cardType.title
    
    return label
  }
  func createIndicatorValueLabel() -> UILabel {
    let label = UILabel()
    label.font = Constants.currentValueFont
    label.textColor = Constants.currentValueColor
    label.text = "temp"
    
    return label
  }
  func createIndicatorGoalLabel() -> UILabel {
    let label = UILabel()
    label.font = Constants.goalValueFont
    label.textColor = Constants.goalValueColor
    label.text = "/\(UserDefaults.standard.kCalGoal)"
    
    return label
  }
}
//MARK: - API
extension IndicatorCard {
  func updateValue(to value: Int, for activityType: ActivityType) {
    indicatorGoalLabel.isHidden = activityType == .month
    indicatorValueLabel.text = "\(value)"
    layoutIfNeeded()
  }
  func updateValue(to value: Double, for activityType: ActivityType) {
    indicatorGoalLabel.isHidden = activityType == .month
    indicatorValueLabel.text = String(value.withTwoDigits)
    layoutIfNeeded()
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var spacing: CGFloat {
    let spacing = 8.0
    return spacing.sizeProportion
  }
  static var imageSize: CGSize {
    let sideSize = 38.0
    let proportionValue = sideSize.sizeProportion
    return CGSize(width: proportionValue, height: proportionValue)
  }
  
  static let titleColor = AppColor.layerTwo
  static let currentValueColor = AppColor.accentOne
  static let goalValueColor = AppColor.layerFour
  
  static var titleFont: UIFont {
    let fontSize = 14.0
    return AppFont.font(type: .regular, size: fontSize.sizeProportion)
  }
  static var currentValueFont: UIFont {
    let fontSize = 16.0
    return AppFont.font(type: .semiBold, size: fontSize.sizeProportion)
  }
  static var goalValueFont: UIFont {
    let fontSize = 11.0
    return AppFont.font(type: .semiBold, size: fontSize.sizeProportion)
  }
}

//MARK: - enum IndicatorCardType
enum IndicatorCardType: CaseIterable {
  case kCal
  case km
  case hour
  
  var title: String {
    hkType.name
  }
  var image: UIImage {
    switch self {
    case .kCal: AppImage.Main.kCal
    case .km: AppImage.Main.km
    case .hour: AppImage.Main.hour
    }
  }
  
  var hkType: HealthKitActivityTypes {
    switch self {
    case .kCal: .energy
    case .km: .distance
    case .hour: .exerciseTime
    }
  }
}
