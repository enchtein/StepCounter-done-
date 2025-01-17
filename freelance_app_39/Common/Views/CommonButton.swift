import UIKit

final class CommonButton: UIButton {
  private(set) var enabledBgColor: UIColor = AppColor.accentOne
  private(set) var enabledTitleColor: UIColor = AppColor.layerOne
  
  override var isEnabled: Bool {
    didSet {
      guard oldValue != isEnabled else { return }
      enabledStateDidChange()
    }
  }
  
  init() {
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setupUI()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    
    cornerRadius = Constants.cornerRadius
  }
  
  private final func setupUI() {
    heightAnchor.constraint(equalToConstant: Constants.height).isActive = true
    
    backgroundColor = enabledBgColor
    
    setTitle("temp title", for: .normal)
    setTitleColor(enabledTitleColor, for: .normal)
    titleLabel?.font = Constants.font
    
    addTarget(self, action: #selector(setOpaqueButton), for: .touchDown)
    addTarget(self, action: #selector(setNonOpaquesButton), for: .touchDragExit)
    addTarget(self, action: #selector(setOpaqueButton), for: .touchDragEnter)
    addTarget(self, action: #selector(setNonOpaquesButton), for: .touchUpInside)
  }
}

//MARK: - CommonButton Actions
extension CommonButton {
  @objc private final func setOpaqueButton() {
    updateButtonOpacity(true)
  }
  @objc private final func setNonOpaquesButton() {
    updateButtonOpacity(false)
  }
  private final func updateButtonOpacity(_ isOpaque: Bool) {
    guard isEnabled else { return }
    layer.opacity = isOpaque ? Constants.actionsOpacity.highlighted : Constants.actionsOpacity.base
  }
  
  private final func enabledStateDidChange() {
    UIView.animate(withDuration: Constants.animationDuration) {
      self.backgroundColor = self.isEnabled ? self.enabledBgColor: AppColor.layerFour
    }
  }
}
//MARK: - API
extension CommonButton {
  final func setupTitle(with text: String) {
    setTitle(text, for: .normal)
  }
  final func setupEnabledBgColor(to color: UIColor) {
    enabledBgColor = color
    backgroundColor = color
  }
  func setupEnabledTitleColor(to color: UIColor) {
    enabledTitleColor = color
    setTitleColor(color, for: .normal)
  }
}
//MARK: - CommonButton Constants
fileprivate struct Constants: CommonSettings {
  static var height: CGFloat {
    let maxHeight = 54.0
    return maxHeight.sizeProportion
  }
  
  static var cornerRadius: CGFloat {
    let max = 27.0
    return max.sizeProportion
  }
  
  static let actionsOpacity = TargetActionsOpacity()
  
  static var font: UIFont {
    let maxFontSize = 16.0
    return AppFont.font(type: .semiBold, size: maxFontSize.sizeProportion)
  }
}
