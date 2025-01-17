import UIKit

protocol DenyHealthKitActivitiesNotifyingViewDelegate: AnyObject {
  func goToProfileAction()
}
final class DenyHealthKitActivitiesNotifyingView: UIView {
  private weak var delegate: DenyHealthKitActivitiesNotifyingViewDelegate?
  
  private lazy var imageView = createImageView()
  private lazy var helperLabel = createHelperLabel()
  private lazy var goToProfileButton = createGoToProfileButton()
  
  private(set) var isWasShowedInAppLifeCycle = false
  
  init(delegate: DenyHealthKitActivitiesNotifyingViewDelegate) {
    self.delegate = delegate
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    
    goToProfileButton.setRounded()
  }
  
  private func setupUI() {
    let hStackView = UIStackView()
    hStackView.spacing = 8.0
    hStackView.axis = .horizontal
    hStackView.distribution = .equalCentering
    
    hStackView.addArrangedSubview(imageView)
    hStackView.addArrangedSubview(helperLabel)
    
    addSubview(hStackView)
    hStackView.translatesAutoresizingMaskIntoConstraints = false
    hStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.baseSideIndent).isActive = true
    hStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.baseSideIndent).isActive = true
    hStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.baseSideIndent).isActive = true
    
    addSubview(goToProfileButton)
    goToProfileButton.translatesAutoresizingMaskIntoConstraints = false
    goToProfileButton.topAnchor.constraint(equalTo: hStackView.bottomAnchor, constant: 12.0).isActive = true
    goToProfileButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.baseSideIndent).isActive = true
    goToProfileButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.baseSideIndent).isActive = true
    
    
    backgroundColor = AppColor.layerThree
    layer.borderWidth = 1.0
    layer.borderColor = AppColor.layerOne.withAlphaComponent(0.28).cgColor
    cornerRadius = 16.0
  }
}
//MARK: - UI elements creating
private extension DenyHealthKitActivitiesNotifyingView {
  func createImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.widthAnchor.constraint(equalToConstant: Constants.imageSideSize).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: Constants.imageSideSize).isActive = true
    imageView.image = AppImage.Main.denyNotifyingStep
    
    return imageView
  }
  func createHelperLabel() -> UILabel {
    let label = UILabel()
    label.text = MainTitles.denyActivitiesNotifyingMsg.localized
    label.textAlignment = .left
    label.numberOfLines = .zero
    label.textColor = AppColor.layerOne
    label.font = Constants.helperLabelFont
    
    return label
  }
  
  func createGoToProfileButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight).isActive = true
    
    button.setTitle("    " + MainTitles.goProfile.localized + "    ", for: .normal)
    button.titleLabel?.font = Constants.buttonFont
    button.setTitleColor(AppColor.layerOne, for: .normal)
    button.backgroundColor = AppColor.accentOne
    
    button.addTarget(self, action: #selector(goToProfileButtonAction), for: .touchUpInside)
    
    return button
  }
}
//MARK: - Actions
private extension DenyHealthKitActivitiesNotifyingView {
  @objc func goToProfileButtonAction() {
    delegate?.goToProfileAction()
  }
}
//MARK: - API
extension DenyHealthKitActivitiesNotifyingView {
  func didDisappear() {
    guard !isWasShowedInAppLifeCycle else { return }
    isWasShowedInAppLifeCycle = true
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var imageSideSize: CGFloat {
    let maxSize = 48.0
    let sizeProportion = maxSize.sizeProportion
    
    return sizeProportion > maxSize ? maxSize : sizeProportion
  }
  private static var fontSize: CGFloat {
    let maxSize = 14.0
    let sizeProportion = maxSize.sizeProportion
    
    return sizeProportion > maxSize ? maxSize : sizeProportion
  }
  static var helperLabelFont: UIFont {
    AppFont.font(type: .regular, size: Self.fontSize)
  }
  static var buttonFont: UIFont {
    AppFont.font(type: .bold, size: Self.fontSize)
  }
  static var buttonHeight: CGFloat {
    let max = 38.0
    let sizeProportion = max.sizeProportion
    
    return sizeProportion > max ? max : sizeProportion
  }
}
