import UIKit

final class DayInformationView: UIView {
  private(set) var model: DayInformationModel
  
  private lazy var countLabel = createCountLabel()
  private lazy var progressView = createProgressView(with: model)
  private lazy var nameLabel = createNameLabel()
  
  init(model: DayInformationModel) {
    self.model = model
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    addSubview(countLabel)
    countLabel.translatesAutoresizingMaskIntoConstraints = false
    countLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
    countLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    countLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    
    addSubview(progressView)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 2.0).isActive = true
    progressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    progressView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    
    addSubview(nameLabel)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4.0).isActive = true
    nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
  
  func updateValues(according model: DayInformationModel) {
    self.model = model
    
    countLabel.text = model.formattedValue
    progressView.updateValues(according: model)
    nameLabel.text = model.day.dayName
  }
}
//MARK: - UI elements creating
private extension DayInformationView {
  func createCountLabel() -> UILabel {
    let label = UILabel()
    label.font = Constants.countLabelFont
    label.textColor = Constants.countLabelColor
    label.textAlignment = .center
    
    label.text = model.formattedValue
    
    return label
  }
  func createProgressView(with model: DayInformationModel) -> DayProgress {
    DayProgress(model: model)
  }
  func createNameLabel() -> UILabel {
    let label = UILabel()
    label.font = Constants.nameLabelFont
    label.textColor = model.isToday ? AppColor.accentOne : Constants.nameLabelColor
    label.textAlignment = .center
    
    label.text = model.day.rawValue
    
    return label
  }
}

//MARK: - DayProgress
fileprivate final class DayProgress: UIView {
  private lazy var backgroundView = createBackgroundView()
  
  private lazy var progressView = createProgressView()
  private lazy var progressViewTop = createProgressViewTop()
  
  private lazy var crownImageView = createCrownImageView()
  
  private var model: DayInformationModel
  
  private(set) var multiplier: Float = .zero {
    didSet {
      updateProgressView()
    }
  }
  
  init(model: DayInformationModel) {
    self.model = model
    multiplier = model.multiplier
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    updateProgressView()
    
    backgroundView.setRounded()
    progressView.setRounded()
  }
  
  private func setupUI() {
    addSubview(backgroundView)
    backgroundView.fillToSuperview()
    
    backgroundView.addSubview(progressView)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressViewTop.isActive = true
    progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
    progressView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
    progressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
    
    addSubview(crownImageView)
    crownImageView.translatesAutoresizingMaskIntoConstraints = false
    crownImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DayProgressConstants.crownSideIndent).isActive = true
    crownImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DayProgressConstants.crownSideIndent).isActive = true
    crownImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DayProgressConstants.crownBottomIndent).isActive = true
    crownImageView.heightAnchor.constraint(equalTo: crownImageView.widthAnchor, multiplier: 1.0).isActive = true
    crownImageView.isHidden = true
  }
  
  private func updateProgressView() {
    progressViewTop.constant = frame.height - (frame.height * CGFloat(multiplier))
    
    if isBaseVCAppeared {
      if model.isGoalDone {
        crownImageView.fadeIn()
      } else {
        crownImageView.fadeOut()
      }
    } else {
      crownImageView.isHidden = !model.isGoalDone
    }
    
    let animationDuration = isBaseVCAppeared ? Constants.animationDuration : .zero
    UIView.animate(withDuration: animationDuration) {
      self.layoutIfNeeded()
    }
  }
  
  private func setup(progress: Float) {
    guard multiplier != progress else { return }
    multiplier = progress
  }
  
  func updateValues(according model: DayInformationModel) {
    self.model = model
    
    setup(progress: model.multiplier)
  }
}
//MARK: - UI elements creating
private extension DayProgress {
  func createBackgroundView() -> UIView {
    let view = UIView()
    view.backgroundColor = AppColor.accentOne.withAlphaComponent(0.2)
    view.layer.borderColor = AppColor.accentOne.cgColor
    view.layer.borderWidth = model.isToday ? 1.0 : .zero
    
    return view
  }
  func createProgressView() -> UIView {
    let view = UIView()
    view.backgroundColor = AppColor.accentOne
    
    return view
  }
  func createProgressViewTop() -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(item: progressView, attribute: .top, relatedBy: .equal,
                                        toItem: backgroundView, attribute: .top,
                                        multiplier: 1.0, constant: frame.height * CGFloat(multiplier))
    constraint.priority = .defaultLow
    return constraint
  }
  
  func createCrownImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = AppImage.Main.crown
    
    return imageView
  }
  
  struct DayProgressConstants {
    static var crownSideIndent: CGFloat {
      let maxIndent = 10.0
      let sizeProportion = maxIndent.sizeProportion
      return sizeProportion > maxIndent ? maxIndent : sizeProportion
    }
    static var crownBottomIndent: CGFloat {
      let maxIndent = 12.0
      let sizeProportion = maxIndent.sizeProportion
      return sizeProportion > maxIndent ? maxIndent : sizeProportion
    }
  }
}

//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var countLabelFont: UIFont {
    let minFontSize = 9.0
    let fontSize = 11.0
    let sizeProportion = fontSize.sizeProportion
    
    let totalFontSize = sizeProportion < minFontSize ? minFontSize : sizeProportion
    
    return AppFont.font(type: .regular, size: totalFontSize)
  }
  static let countLabelColor = AppColor.layerFive
  
  static var nameLabelFont: UIFont {
    let minFontSize = 9.0
    let fontSize = 11.0
    let sizeProportion = fontSize.sizeProportion
    
    let totalFontSize = sizeProportion < minFontSize ? minFontSize : sizeProportion
    
    return AppFont.font(type: .semiBold, size: totalFontSize)
  }
  static let nameLabelColor = AppColor.layerFour
}
