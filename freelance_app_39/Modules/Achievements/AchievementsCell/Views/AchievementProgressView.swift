import UIKit

final class AchievementProgressView: UIView {
  private lazy var stepsCountLabel = createStepsCountLabel()
  
  private lazy var progressBackgroundView = createProgressBackgroundView()
  private lazy var progressView = createProgressView()
  private lazy var circleUnderProgressView = createCircleUnderProgressView()
  
  private lazy var percentageLabel = createPercentageLabel()
  
  private lazy var progressViewWidth = createProgressViewWidth()
  
  private var model: AchievementModel
  private var goalMultiplier: Float { model.goalMultiplier }
  private var widthIndent: CGFloat {
    guard !model.isClosed else { return frame.width }
    return frame.width - (frame.width * CGFloat(goalMultiplier))
  }
  
  init(model: AchievementModel) {
    self.model = model
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    
    progressViewWidth.constant = -widthIndent
  }
  
  private func setupUI() {
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.spacing = 6.0
    
    vStack.addArrangedSubview(stepsCountLabel)
    
    let vSubStack = UIStackView()
    vSubStack.axis = .vertical
    vSubStack.spacing = .zero
    
    progressBackgroundView.addSubview(progressView)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.topAnchor.constraint(equalTo: progressBackgroundView.topAnchor).isActive = true
    progressView.leadingAnchor.constraint(equalTo: progressBackgroundView.leadingAnchor).isActive = true
    progressViewWidth.isActive = true
    progressView.bottomAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor).isActive = true
    
    progressBackgroundView.addSubview(circleUnderProgressView)
    circleUnderProgressView.topAnchor.constraint(equalTo: progressBackgroundView.topAnchor).isActive = true
    circleUnderProgressView.leadingAnchor.constraint(equalTo: progressBackgroundView.leadingAnchor).isActive = true
    circleUnderProgressView.bottomAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor).isActive = true
    
    vSubStack.addArrangedSubview(progressBackgroundView)
    vSubStack.addArrangedSubview(percentageLabel)
    
    vStack.addArrangedSubview(vSubStack)
    
    addSubview(vStack)
    vStack.fillToSuperview()
    
    [progressBackgroundView, progressView, circleUnderProgressView].forEach {
      $0.cornerRadius = Constants.progressLineRadius
    }
    setupPrecentageLabelText()
  }
  
  func updateProgress(with newModel: AchievementModel, isAnimated: Bool) {
    guard goalMultiplier != newModel.goalMultiplier else { return }
    guard !model.isClosed || model.isClosed && !newModel.isClosed else { return }
    
    model = newModel
    
    setupPrecentageLabelText()
    UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .curveEaseInOut) {
      self.progressViewWidth.constant = -self.widthIndent
      self.progressBackgroundView.layoutIfNeeded()
    }
  }
}
//MARK: - Helpers
private extension AchievementProgressView {
  func setupPrecentageLabelText() {
    percentageLabel.text = model.isClosed ? "0%" : "\(model.goalPercentage)%"
  }
}
//MARK: - UI elements creating
private extension AchievementProgressView {
  func createProgressBackgroundView() -> UIView {
    let view = UIView()
    view.backgroundColor = AppColor.accentOne.withAlphaComponent(0.2)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.heightAnchor.constraint(equalToConstant: Constants.progressLineHeight).isActive = true
    
    return view
  }
  func createProgressView() -> UIView {
    let view = UIView()
    view.backgroundColor = AppColor.accentOne
    
    return view
  }
  func createCircleUnderProgressView() -> UIView {
    let view = createProgressView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.widthAnchor.constraint(equalToConstant: Constants.progressLineHeight).isActive = true
    view.heightAnchor.constraint(equalToConstant: Constants.progressLineHeight).isActive = true
    
    return view
  }
  
  func createStepsCountLabel() -> UILabel {
    let label = UILabel()
    label.font = Constants.stepsCountLabelFont
    label.textColor = AppColor.accentOne
    
    label.text = String(model.type.stepsGoal) + " " + MainTitles.steps.localized
    label.textAlignment = .left
    
    return label
  }
  func createPercentageLabel() -> UILabel {
    let label = UILabel()
    label.font = Constants.percentageLabelFont
    label.textColor = AppColor.accentOne
    label.text = "\(model.goalPercentage)%"
    label.textAlignment = .right
    
    return label
  }
  
  func createProgressViewWidth() -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: progressBackgroundView, attribute: .width, multiplier: 1.0, constant: 0)
    constraint.priority = UILayoutPriority(999)
    
    return constraint
  }
}

//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var stepsCountLabelFont: UIFont {
    let fontSize = 16.0
    return AppFont.font(type: .semiBold, size: fontSize.sizeProportion)
  }
  static var percentageLabelFont: UIFont {
    let fontSize = 14.0
    return AppFont.font(type: .regular, size: fontSize.sizeProportion)
  }
  
  static let progressLineHeight: CGFloat = 10.0
  static var progressLineRadius: CGFloat {
    progressLineHeight / 2
  }
}
