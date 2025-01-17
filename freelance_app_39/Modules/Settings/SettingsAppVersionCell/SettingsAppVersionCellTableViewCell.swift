import UIKit

final class SettingsAppVersionCellTableViewCell: UITableViewCell {
  @IBOutlet weak var appVerLabel: UILabel!
  
  func setupCell() {
    setupColorTheme()
    setupFontTheme()
    
    appVerLabel.text = SettingType.appVer.title
  }
  
  func setupColorTheme() {
    backgroundColor = AppColor.backgroundOne
    
    appVerLabel.textColor = AppColor.layerFour
  }
  func setupFontTheme() {
    appVerLabel.font = AppFont.font(type: .regular, size: 14.0.sizeProportion)
  }
}
