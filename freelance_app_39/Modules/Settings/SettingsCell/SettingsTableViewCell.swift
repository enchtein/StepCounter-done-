import UIKit

protocol SettingsTableViewCellDelegate: AnyObject {
  func didSelect(cell: SettingsTableViewCell)
}

final class SettingsTableViewCell: UITableViewCell {
  @IBOutlet weak var contentContainer: UIView!
  @IBOutlet weak var contentContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var contentContainerBottom: NSLayoutConstraint!
  
  @IBOutlet weak var settingImageView: UIImageView!
  
  @IBOutlet weak var settingTitle: UILabel!
  @IBOutlet weak var settingDescription: UILabel!
  
  @IBOutlet weak var arrowImageView: UIImageView!
  
  private weak var delegate: SettingsTableViewCellDelegate?
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
    guard selected else { return }
    contentContainer.springAnimation { [weak self] in
      guard let self else { return }
      delegate?.didSelect(cell: self)
    }
  }
  
  func setupCell(with setting: SettingType, delegate: SettingsTableViewCellDelegate, isLastSectionCell: Bool) {
    self.delegate = delegate
    
    setupColorTheme()
    setupFontTheme()
    setupLocalizeTitles(for: setting)
    setupIcons(for: setting)
    setupConstraintsConstants(isLastSectionCell: isLastSectionCell)
    additionalUISettings()
    
    settingDescription.isHidden = !setting.isDescriprionExist
  }
}
//MARK: - UI Helpers
private extension SettingsTableViewCell {
  func setupColorTheme() {
    backgroundColor = AppColor.backgroundOne
    contentContainer.backgroundColor = AppColor.layerTwo
    contentContainer.layer.borderColor = AppColor.layerThree.cgColor
    
    settingTitle.textColor = AppColor.layerOne
    settingDescription.textColor = AppColor.layerFour
  }
  func setupFontTheme() {
    settingTitle.font = Constants.settingTitleFont
    settingDescription.font = Constants.settingDescriptionFont
  }
  func setupLocalizeTitles(for setting: SettingType) {
    settingTitle.text = setting.title
    settingDescription.text = setting.description
  }
  func setupIcons(for setting: SettingType) {
    settingImageView.image = setting.icon
    arrowImageView.image = AppImage.Settings.rightArrow
  }
  
  func setupConstraintsConstants(isLastSectionCell: Bool) {
    contentContainerHeight.constant = Constants.contentContainerHeight
    
    contentContainerBottom.constant = isLastSectionCell ? Constants.contentContainerBottom : 4.0
  }
  func additionalUISettings() {
    contentContainer.cornerRadius = Constants.cornerRadius
    contentContainer.layer.borderWidth = 1.0
  }
}
//MARK: - Constants
fileprivate struct Constants {
  static var contentContainerHeight: CGFloat {
    let maxHeight = 60.0
    let sizeProportion = maxHeight.sizeProportion
    
    return sizeProportion > maxHeight ? maxHeight : sizeProportion
  }
  static var cornerRadius: CGFloat {
    let maxRadius = 10.0
    let sizeProportion = maxRadius.sizeProportion
    
    return sizeProportion > maxRadius ? maxRadius : sizeProportion
  }
  
  static var settingTitleFont: UIFont {
    let maxFontSize = 16.0
    let sizeProportion = maxFontSize.sizeProportion
    let fontSize = sizeProportion > maxFontSize ? maxFontSize : sizeProportion
    
    return AppFont.font(type: .semiBold, size: fontSize)
  }
  static var settingDescriptionFont: UIFont {
    let maxFontSize = 14.0
    let sizeProportion = maxFontSize.sizeProportion
    let fontSize = sizeProportion > maxFontSize ? maxFontSize : sizeProportion
    
    return AppFont.font(type: .regular, size: fontSize)
  }
  
  static var contentContainerBottom: CGFloat {
    let maxHeight = 20.0
    let sizeProportion = maxHeight.sizeProportion
    
    return sizeProportion > maxHeight ? maxHeight : sizeProportion
  }
}
