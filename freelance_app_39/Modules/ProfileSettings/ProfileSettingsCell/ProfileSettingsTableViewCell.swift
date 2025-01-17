import UIKit

protocol ProfileSettingsTableViewCellDelegate: AnyObject {
  func didSelect(cell: ProfileSettingsTableViewCell)
}
final class ProfileSettingsTableViewCell: UITableViewCell {
  @IBOutlet weak var contentContainer: UIView!
  @IBOutlet weak var contentContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var profileSettingTitle: UILabel!
  @IBOutlet weak var profileSettingLabel: UILabel!
  
  @IBOutlet weak var arrowImageView: UIImageView!
  
  private weak var delegate: ProfileSettingsTableViewCellDelegate?
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
    guard selected else { return }
    contentContainer.springAnimation { [weak self] in
      guard let self else { return }
      delegate?.didSelect(cell: self)
    }
  }
  
  func setupCell(setting: ProfileSettingsType, profileSettingValue: String, delegate: ProfileSettingsTableViewCellDelegate) {
    self.delegate = delegate
    
    setupColorTheme()
    setupFontTheme()
    setupLocalizeTitles(for: setting, with: profileSettingValue)
    setupIcons(for: setting)
    setupConstraintsConstants()
    additionalUISettings()
  }
  
}
//MARK: - UI Helpers
private extension ProfileSettingsTableViewCell {
  func setupColorTheme() {
    backgroundColor = AppColor.backgroundOne
    contentContainer.backgroundColor = AppColor.layerTwo
    contentContainer.layer.borderColor = AppColor.layerThree.cgColor
    
    profileSettingTitle.textColor = AppColor.layerOne
    profileSettingLabel.textColor = AppColor.layerFour
  }
  func setupFontTheme() {
    profileSettingTitle.font = Constants.profileSettingTitleFont
    profileSettingLabel.font = Constants.profileSettingLabelFont
  }
  func setupLocalizeTitles(for setting: ProfileSettingsType, with profileSettingValue: String) {
    profileSettingTitle.text = setting.title
    profileSettingLabel.text = profileSettingValue
  }
  func setupIcons(for setting: ProfileSettingsType) {
    arrowImageView.image = AppImage.Settings.rightArrow
  }
  
  func setupConstraintsConstants() {
    contentContainerHeight.constant = Constants.contentContainerHeight
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
  
  static var profileSettingTitleFont: UIFont {
    let maxFontSize = 16.0
    let sizeProportion = maxFontSize.sizeProportion
    let fontSize = sizeProportion > maxFontSize ? maxFontSize : sizeProportion
    
    return AppFont.font(type: .semiBold, size: fontSize)
  }
    static var profileSettingLabelFont: UIFont {
      let maxFontSize = 14.0
      let sizeProportion = maxFontSize.sizeProportion
      let fontSize = sizeProportion > maxFontSize ? maxFontSize : sizeProportion
      
      return AppFont.font(type: .semiBold, size: fontSize)
    }
}
