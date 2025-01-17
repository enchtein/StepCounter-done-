import UIKit

protocol StepsScoreViewDelegate: AnyObject {
  func layoutDidChangeHeight(to value: CGFloat, for view: StepsScoreView)
  func shareButtonAction()
}
final class StepsScoreView: UIView {
  let type: ActivityType
  private weak var delegate: StepsScoreViewDelegate?
  
  private lazy var stepsLabelsVStack = createStepsLabelsContainer()
  private lazy var stepsTitle = createStepsTitle()
  private lazy var stepsCounterLabel = createStepsCounterLabel()
  private lazy var stepsGoalLabel = createStepsGoalLabel()
  
  private(set) lazy var progressStepsCircleView = ProgressStepsCircleView()
  private(set) lazy var progressStepsCircleViewContainer = UIView()
  
  private lazy var shareButton = createShareButton()
  
  private lazy var snapshotImageView = UIImageView()
  
  init(type: ActivityType, delegate: StepsScoreViewDelegate) {
    self.type = type
    self.delegate = delegate
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private(set) var defaultHeight: CGFloat = .zero
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if defaultHeight == .zero {
      defaultHeight = frame.height
    }
    
    delegate?.layoutDidChangeHeight(to: defaultHeight, for: self)
  }
  
  private func setupUI() {
    switch type {
    case .today:
      progressStepsCircleViewContainer.backgroundColor = AppColor.accentOne
      addSubview(progressStepsCircleViewContainer)
      
      progressStepsCircleViewContainer.fillToSuperview(horizontalIndents: Constants.halfCircleViewSideIndent)
      let progressStepsCircleViewContainerHeight = NSLayoutConstraint(item: progressStepsCircleViewContainer, attribute: .height, relatedBy: .equal, toItem: progressStepsCircleViewContainer, attribute: .width, multiplier: 0.5, constant: .zero)
      progressStepsCircleViewContainerHeight.priority = UILayoutPriority(999)
      progressStepsCircleViewContainerHeight.isActive = true
      
      progressStepsCircleViewContainer.addSubview(progressStepsCircleView)
      
      progressStepsCircleView.translatesAutoresizingMaskIntoConstraints = false
      progressStepsCircleView.topAnchor.constraint(equalTo: progressStepsCircleViewContainer.topAnchor).isActive = true
      progressStepsCircleView.centerXAnchor.constraint(equalTo: progressStepsCircleViewContainer.centerXAnchor).isActive = true
      progressStepsCircleView.centerYAnchor.constraint(equalTo: progressStepsCircleViewContainer.bottomAnchor).isActive = true
      progressStepsCircleView.widthAnchor.constraint(equalTo: progressStepsCircleView.heightAnchor).isActive = true
      
      
      progressStepsCircleViewContainer.addSubview(stepsLabelsVStack)
      stepsLabelsVStack.translatesAutoresizingMaskIntoConstraints = false
      stepsLabelsVStack.centerXAnchor.constraint(equalTo: progressStepsCircleViewContainer.centerXAnchor).isActive = true
      stepsLabelsVStack.bottomAnchor.constraint(equalTo: progressStepsCircleViewContainer.bottomAnchor).isActive = true
      let stepsLabelsVStackHAnchor = NSLayoutConstraint(item: stepsLabelsVStack, attribute: .height, relatedBy: .lessThanOrEqual, toItem: progressStepsCircleViewContainer, attribute: .height, multiplier: 0.42, constant: .zero)
      stepsLabelsVStackHAnchor.priority = UILayoutPriority(998)
      stepsLabelsVStackHAnchor.isActive = true
      
      addSubview(shareButton)
      shareButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.shareButtonTop).isActive = true
      shareButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.shareButtonTrailing).isActive = true
    case .month:
      addSubview(stepsLabelsVStack)
      stepsLabelsVStack.fillToSuperview()
    }
    
    clipsToBounds = true
  }
  
  func layoutLabelsIfNeeded(isHide: Bool) {
    let scaleFactor: CGFloat = isHide ? 0.5 : 1.0
    
    UIView.animate(withDuration: Constants.animationDuration) {
      self.stepsTitle.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
      self.stepsCounterLabel.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
      self.layoutIfNeeded()
    } completion: { [weak self] _ in
      if !isHide {
        self?.removeSnapshot()
      }
    }
  }
  
  func setupSnapshot() {
    let snapshot = self.createSnapshot()
    snapshotImageView.contentMode = .scaleAspectFit
    
    self.snapshotImageView.image = snapshot
    
    addSubview(snapshotImageView)
    snapshotImageView.fillToSuperview()
    layoutIfNeeded()
    
    progressStepsCircleView.isHidden = true
    shareButton.isHidden = true
  }
  private func removeSnapshot() {
    snapshotImageView.image = nil
    snapshotImageView.removeFromSuperview()
    
    progressStepsCircleView.isHidden = false
    shareButton.isHidden = false
  }
}
//MARK: - UI elements creating
private extension StepsScoreView {
  func createStepsScoreHStack() -> UIStackView {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.spacing = 1.0
    hStack.alignment = .center
    
    hStack.addArrangedSubview(stepsCounterLabel)
    if type == .today {
      hStack.addArrangedSubview(stepsGoalLabel)
    }
    
    return hStack
  }
  func createStepsLabelsContainer() -> UIStackView {
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.spacing = .zero
    vStack.alignment = .center
    
    vStack.addArrangedSubview(stepsTitle)
    vStack.addArrangedSubview(createStepsScoreHStack())
    
    return vStack
  }
  func createStepsTitle() -> UILabel {
    let label = UILabel()
    label.text = MainTitles.steps.localized
    label.textColor = AppColor.layerOne
    label.font = Constants.stepsTitleFont
    
    return label
  }
  func createStepsCounterLabel() -> UILabel {
    let label = UILabel()
    label.text = "0"
    label.textColor = AppColor.layerOne
    label.font = Constants.stepsCounterLabelFont
    
    return label
  }
  func createStepsGoalLabel() -> UILabel {
    let label = UILabel()
    label.text = "/\(UserDefaults.standard.stepGoal)"
    label.textColor = AppColor.layerOne
    label.font = Constants.stepsCounterLabelGoalFont
    
    return label
  }
  
  func createShareButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.heightAnchor.constraint(equalToConstant: Constants.shareButtonSideSize).isActive = true
    button.widthAnchor.constraint(equalToConstant: Constants.shareButtonSideSize).isActive = true
    
    button.setImage(AppImage.Main.share, for: .normal)
    button.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
    
    return button
  }
}

//MARK: - API
extension StepsScoreView {
  func updateValue(to value: Int) {
    stepsCounterLabel.text = "\(value)"
    
    guard type == .today else { return }
    let maxMultiplier = 1.0
    let multiplier = Double(value) / Double(UserDefaults.standard.stepGoal)
    let totalMultiplier = multiplier > maxMultiplier ? maxMultiplier : multiplier
    
    progressStepsCircleView.setProgress(totalMultiplier, animated: true)
  }
}
//MARK: - Actions
private extension StepsScoreView {
  @objc func shareButtonAction() {
    delegate?.shareButtonAction()
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static let halfCircleViewSideIndent: CGFloat = 38.0
  
  static let shareButtonTop: CGFloat = 6.0
  static let shareButtonTrailing: CGFloat = 18.0
  static let shareButtonSideSize: CGFloat = 32.0
  
  static var stepsTitleFont: UIFont {
    let maxFontSize = 16.0
    let proportionFontSize = maxFontSize.sizeProportion
    let fontSize = maxFontSize < proportionFontSize ? maxFontSize : proportionFontSize
    
    return AppFont.font(type: .regular, size: fontSize)
  }
  static var stepsCounterLabelFont: UIFont {
    let maxFontSize = 32.0
    let proportionFontSize = maxFontSize.sizeProportion
    let fontSize = maxFontSize < proportionFontSize ? maxFontSize : proportionFontSize
    
    return AppFont.font(type: .semiBold, size: fontSize)
  }
  static var stepsCounterLabelGoalFont: UIFont {
    let maxFontSize = 14.0
    let proportionFontSize = maxFontSize.sizeProportion
    let fontSize = maxFontSize < proportionFontSize ? maxFontSize : proportionFontSize
    
    return AppFont.font(type: .regular, size: fontSize)
  }
}
