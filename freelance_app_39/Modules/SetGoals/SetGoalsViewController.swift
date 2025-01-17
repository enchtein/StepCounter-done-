import UIKit
import Lottie

final class SetGoalsViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var topBackgroundView: UIView!
  
  @IBOutlet weak var topViewContainer: UIView!
  @IBOutlet weak var topViewContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var topContainer: UIView!
  @IBOutlet weak var animationView: LottieAnimationView!
  @IBOutlet weak var animationViewTop: NSLayoutConstraint!
  @IBOutlet weak var animationViewLeading: NSLayoutConstraint!
  @IBOutlet weak var setGoalsTitle: UILabel!
  @IBOutlet weak var setGoalsHelperTitle: UILabel!
  
  
  @IBOutlet weak var middleContainer: UIView!
  
  @IBOutlet weak var stepContainer: UIView!
  @IBOutlet weak var stepContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var stepImageView: UIImageView!
  @IBOutlet weak var stepImageViewWidth: NSLayoutConstraint!
  @IBOutlet weak var stepLabel: UILabel!
  @IBOutlet weak var stepTitle: UILabel!
  
  @IBOutlet weak var stepButtonsContainer: UIView!
  @IBOutlet weak var stepButtonsContainerTop: NSLayoutConstraint!
  @IBOutlet weak var stepDecreaseButton: UIButton!
  @IBOutlet weak var stepSeparatorTop: NSLayoutConstraint!
  @IBOutlet weak var stepSeparator: UIView!
  @IBOutlet weak var stepIncreaseButton: UIButton!
  
  @IBOutlet weak var kCalContainer: UIView!
  @IBOutlet weak var kCalContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var kCalImageView: UIImageView!
  @IBOutlet weak var kCalImageViewWidth: NSLayoutConstraint!
  @IBOutlet weak var kCalLabel: UILabel!
  @IBOutlet weak var kCalTitle: UILabel!
  
  @IBOutlet weak var kCalButtonsContainer: UIView!
  @IBOutlet weak var kCalButtonsContainerTop: NSLayoutConstraint!
  @IBOutlet weak var kCalDecreaseButton: UIButton!
  @IBOutlet weak var kCalSeparatorTop: NSLayoutConstraint!
  @IBOutlet weak var kCalSeparator: UIView!
  @IBOutlet weak var kCalIncreaseButton: UIButton!
  
  
  @IBOutlet weak var bottomContainer: UIView!
  @IBOutlet weak var divider: UIView!
  @IBOutlet weak var saveButton: CommonButton!
  
  private var buttonTimer: Timer?
  private lazy var viewModel = SetGoalsViewModel(isFromSettings: isFromSetting, delegate: self)
  
  private lazy var navPanel = CommonNavPanel(type: .goals, delegate: self)
  private var isFromSetting: Bool {
    AppCoordinator.shared.child(before: self) is SettingsViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    viewModel.viewDidLoad()
  }
  
  override func addUIComponents() {
    topViewContainer.addSubview(navPanel)
    navPanel.fillToSuperview()
  }
  override func setupColorTheme() {
    [topBackgroundView, topViewContainer].forEach {
      $0?.backgroundColor = AppColor.accentOne
    }
    
    [topContainer, middleContainer, bottomContainer].forEach {
      $0?.backgroundColor = view.backgroundColor
    }
    
    animationView.backgroundColor = .clear
    
    [setGoalsTitle, stepLabel, kCalLabel].forEach {
      $0?.textColor = Constants.mainTextColor
    }
    [setGoalsHelperTitle, stepTitle, kCalTitle].forEach {
      $0?.textColor = Constants.additionalTextColor
    }
    
    [stepContainer, kCalContainer].forEach {
      $0?.backgroundColor = AppColor.layerTwo
      $0?.layer.borderColor = AppColor.layerThree.cgColor
      $0?.layer.borderWidth = 1.0
    }
    [stepButtonsContainer, kCalButtonsContainer].forEach {
      $0?.backgroundColor = AppColor.layerThree
    }
    
    [stepDecreaseButton, stepIncreaseButton, kCalDecreaseButton, kCalIncreaseButton].forEach {
      $0?.setTitleColor(AppColor.layerOne, for: .normal)
    }
    
    [stepSeparator, kCalSeparator].forEach {
      $0?.backgroundColor = AppColor.layerFour
    }
    
    divider.backgroundColor = AppColor.layerThree
  }
  override func setupFontTheme() {
    setGoalsTitle.font = Constants.titleFont
    
    [stepLabel, kCalLabel].forEach {
      $0?.font = Constants.mainTextFont
    }
    [setGoalsHelperTitle, stepTitle, kCalTitle].forEach {
      $0?.font = Constants.additionalTextFont
    }
  }
  override func setupLocalizeTitles() {
    setGoalsTitle.text = SetGoalsTitles.setGoals.localized
    setGoalsHelperTitle.text = SetGoalsTitles.setGoalsMsg.localized
    
    [stepDecreaseButton, stepIncreaseButton, kCalDecreaseButton, kCalIncreaseButton].forEach {
      $0?.setTitle("", for: .normal)
    }
    
    stepTitle.text = SetGoalsTitles.steps.localized
    kCalTitle.text = SetGoalsTitles.kCal.localized
    
    saveButton.setupTitle(with: CommonAppTitles.save.localized)
  }
  override func setupIcons() {
    [stepDecreaseButton, kCalDecreaseButton].forEach {
      $0?.setImage(AppImage.SetGoals.decrement, for: .normal)
    }
    [stepIncreaseButton, kCalIncreaseButton].forEach {
      $0?.setImage(AppImage.SetGoals.increment, for: .normal)
    }
    
    stepImageView.image = AppImage.SetGoals.step
    kCalImageView.image = AppImage.SetGoals.kCal
  }
  
  override func setupConstraintsConstants() {
    animationViewTop.constant = isFromSetting ? .zero : Constants.animationViewTop
    animationViewLeading.constant = Constants.animationViewLeading
    
    [stepSeparatorTop, kCalSeparatorTop].forEach {
      $0?.constant = Constants.separatorTopConstant
    }
    
    [stepContainerHeight, kCalContainerHeight].forEach {
      $0?.constant = Constants.containerHeight
    }
    
    [stepImageViewWidth, kCalImageViewWidth].forEach {
      $0?.constant = Constants.imageViewWidth
    }
    
    [stepButtonsContainerTop, kCalButtonsContainerTop].forEach {
      $0?.constant = Constants.buttonsContainerTop
    }
  }
  override func additionalUISettings() {
    [topBackgroundView, topViewContainer].forEach {
      $0?.isHidden = !isFromSetting
    }
    
    [stepContainer, kCalContainer].forEach {
      $0?.cornerRadius = Constants.containerRadius
    }
    [stepButtonsContainer, kCalButtonsContainer].forEach {
      $0?.cornerRadius = Constants.buttonsContainerRadius
    }
    
    stepDecreaseButton.tag = Self.SetGoalsButtonType.decreaseStep.rawValue
    stepIncreaseButton.tag = Self.SetGoalsButtonType.increaseStep.rawValue
    
    kCalDecreaseButton.tag = Self.SetGoalsButtonType.decreaseKCal.rawValue
    kCalIncreaseButton.tag = Self.SetGoalsButtonType.increaseKCal.rawValue
    
    animationView.loopMode = .loop
    animationView.play()
  }
  
  //MARK: - Button Actions
  @IBAction func touchDownButtonAction(_ sender: UIButton) {
    let userInfo = ["senderTag": sender.tag]
    buttonTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(executeChangeValue), userInfo: userInfo, repeats: true)
  }
  @IBAction func touchDragEnterButtonAction(_ sender: UIButton) {
    let userInfo = ["senderTag": sender.tag]
    buttonTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(executeChangeValue), userInfo: userInfo, repeats: true)
  }
  @IBAction func touchDragExitButtonAction(_ sender: UIButton) {
    buttonTimer?.invalidate()
  }
  @IBAction func touchUpInsideButtonAction(_ sender: UIButton) {
    executeChangeValue()
    
    buttonTimer?.invalidate()
  }
  
  @objc private func executeChangeValue() {
    let userInfo = buttonTimer?.userInfo as? [String: Any]
    let senderButtonTag = userInfo?["senderTag"] as? Int
    
    let buttonType = Self.SetGoalsButtonType(rawValue: senderButtonTag)
    viewModel.executeChange(for: buttonType)
  }
  @IBAction func saveButtonAction(_ sender: CommonButton) {
    UserDefaults.standard.isWelcomeAlreadyAppeadred = true
    UserDefaults.standard.stepGoal = viewModel.currentStepsCount
    UserDefaults.standard.kCalGoal = viewModel.currentKCalCount
    
    if isFromSetting {
      AppCoordinator.shared.mainVC?.goalsDidChange()
      popVC()
    } else {
      AppCoordinator.shared.activateRoot()
    }
  }
}
extension SetGoalsViewController: SetGoalsDelegate {
  func stepsDidChange(to value: Int) {
    stepLabel.text = String(value)
  }
  
  func kCalDidChange(to value: Int) {
    kCalLabel.text = String(value)
  }
  
  func buttonAvailability(for type: SetGoalsButtonType, isActive: Bool) {
    let processedButton: UIButton
    switch type {
    case .decreaseStep:
      processedButton = stepDecreaseButton
    case .increaseStep:
      processedButton = stepIncreaseButton
    case .decreaseKCal:
      processedButton = kCalDecreaseButton
    case .increaseKCal:
      processedButton = kCalIncreaseButton
    }
    
    guard processedButton.isEnabled != isActive else { return }
    
    processedButton.isEnabled = isActive
    let opacity = isActive ? Constants.actionsOpacity.base : Constants.actionsOpacity.highlighted
    
    UIView.animate(withDuration: Constants.animationDuration) {
      processedButton.layer.opacity = opacity
    }
  }
  func saveButtonAvailability(isActive: Bool) {
    saveButton.isEnabled = isActive
  }
}
//MARK: - CommonNavPanelDelegate
extension SetGoalsViewController: CommonNavPanelDelegate {
  func backButtonAction() {
    popVC()
  }
}
//MARK: - CommonButton Constants
fileprivate struct Constants: CommonSettings {
  static let actionsOpacity = TargetActionsOpacity()
  
  static let mainTextColor = AppColor.layerOne
  static let additionalTextColor = AppColor.layerFour
  
  static let titleFont = AppFont.font(type: .semiBold, size: 32.0.sizeProportion)
  
  static let mainTextFont = AppFont.font(type: .semiBold, size: 16.0.sizeProportion)
  static let additionalTextFont = AppFont.font(type: .regular, size: 14.0.sizeProportion)
  
  static let containerRadius = 10.0.sizeProportion
  static let buttonsContainerRadius = 8.0.sizeProportion
  
  static var animationViewLeading: CGFloat {
    let minValue = 76.5
    let proportionValue = minValue.invertedSizeProportion
    return proportionValue < minValue ? minValue : proportionValue
  }
  static var animationViewTop: CGFloat {
    let maxValue = 28.0
    let proportionValue = maxValue.sizeProportion
    return proportionValue > maxValue ? maxValue : proportionValue
  }
  
  static var separatorTopConstant: CGFloat {
    let maxValue = 7.0
    let proportionValue = maxValue.sizeProportion
    return proportionValue > maxValue ? maxValue : proportionValue
  }
  static var buttonsContainerTop: CGFloat {
    let maxValue = 14.0
    let proportionValue = maxValue.sizeProportion
    return proportionValue > maxValue ? maxValue : proportionValue
  }
  static var containerHeight: CGFloat {
    return 60.0.sizeProportion
  }
  static var imageViewWidth: CGFloat {
    return 50.sizeProportion
  }
}
