import UIKit

final class AchievementsTableViewCell: UITableViewCell {
  @IBOutlet weak var contentContainer: UIView!
  
  @IBOutlet weak var achievementImageView: UIImageView!
  @IBOutlet weak var achievementImageViewHeight: NSLayoutConstraint!
  @IBOutlet weak var achievementProgressContainer: UIView!
  
  @IBOutlet weak var achievementDescription: UILabel!
  
  private var progressView: AchievementProgressView?
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
    guard selected else { return }
    contentContainer.springAnimation()
  }
  
  func setupCell(with model: AchievementModel) {
    addUIComponents(with: model)
    
    setupColorTheme(with: model)
    setupFontTheme()
    setupLocalizeTitles(with: model)
    setupIcons(model: model)
    setupConstraintsConstants()
    additionalUISettings()
  }
  func updateProgress(with model: AchievementModel) {
    progressView?.updateProgress(with: model, isAnimated: true)
    
    UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .curveEaseInOut) {
      self.setupColorTheme(with: model)
    }
    UIView.transition(with: achievementImageView, duration: Constants.animationDuration, options: .transitionCrossDissolve) {
      self.setupIcons(model: model)
    }
    UIView.transition(with: achievementDescription, duration: Constants.animationDuration, options: .transitionCrossDissolve) {
      self.setupLocalizeTitles(with: model)
    }
  }
}

//MARK: - Helpers
private extension AchievementsTableViewCell {
  func addUIComponents(with model: AchievementModel) {
    progressView?.removeFromSuperview()
    
    progressView = AchievementProgressView(model: model)
    guard let progressView else { return }
    achievementProgressContainer.addSubview(progressView)
    progressView.fillToSuperview()
  }
  
  func setupColorTheme(with model: AchievementModel) {
    let color = model.isClosed ? AppColor.layerTwo : AppColor.layerOne
    contentContainer.backgroundColor = color
    progressView?.backgroundColor = color
    
    contentView.backgroundColor = AppColor.backgroundOne
    
    achievementDescription.textColor = model.isClosed ? AppColor.layerFive : AppColor.layerFour
    
    contentContainer.layer.borderColor = model.isClosed ? AppColor.layerThree.cgColor : UIColor.clear.cgColor
    contentContainer.layer.borderWidth = 1.0
  }
  
  func setupFontTheme() {
    achievementDescription.font = Constants.achievementDescriptionFont
  }
  
  func setupLocalizeTitles(with model: AchievementModel) {
    if model.isClosed {
      achievementDescription.text = AchievementsTitles.closeAchievementDescr.localized
    } else {
      let atr1 = NSAttributedString(string: AchievementsTitles.openAchievementDescrPart1.localized, attributes: [NSAttributedString.Key.font: Constants.achievementDescriptionFont, NSAttributedString.Key.foregroundColor: AppColor.layerFour])
      let atr2 = NSAttributedString(string: String(model.type.stepsGoal), attributes: [NSAttributedString.Key.font: Constants.achievementDescriptionFont, NSAttributedString.Key.foregroundColor: AppColor.accentOne])
      let atr3 = NSAttributedString(string: AchievementsTitles.openAchievementDescrPart2.localized, attributes: [NSAttributedString.Key.font: Constants.achievementDescriptionFont, NSAttributedString.Key.foregroundColor: AppColor.layerFour])
      let mutableAttrStr = NSMutableAttributedString(attributedString: atr1)
      mutableAttrStr.append(atr2)
      mutableAttrStr.append(atr3)
      achievementDescription.attributedText = mutableAttrStr
    }
  }
  
  func setupIcons(model: AchievementModel) {
    achievementImageView.image = model.isClosed ? AppImage.Achievements.close : model.type.icon
  }
  
  func setupConstraintsConstants() {
    achievementImageViewHeight.constant = Constants.achievementImageViewHeight
  }
  
  func additionalUISettings() {
    contentContainer.cornerRadius = Constants.baseCornerRadius
  }
}

//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var achievementImageViewHeight: CGFloat {
    let height = 60.0
    return height.sizeProportion
  }
  static var achievementDescriptionFont: UIFont {
    let fontSize = 14.0
    return AppFont.font(type: .regular, size: fontSize.sizeProportion)
  }
}
