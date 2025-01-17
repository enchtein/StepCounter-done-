import UIKit

final class AchievementsViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var topBackgroundView: UIView!
  @IBOutlet weak var topBackgroundViewBottom: NSLayoutConstraint!
  
  @IBOutlet weak var topViewContainer: UIView!
  @IBOutlet weak var topViewContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var currentAchievementImageView: UIImageView!
  @IBOutlet weak var currentAchievementImageViewHeight: NSLayoutConstraint!
  @IBOutlet weak var levelTitle: UILabel!
  @IBOutlet weak var levelDescription: UILabel!
  
  @IBOutlet weak var achievementsTableView: UITableView!
  
  private lazy var navPanel = CommonNavPanel(type: .achievements, delegate: self)
  private lazy var viewModel = AchievementsViewModel(delegate: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    achievementsTableView.register(UINib(nibName: AchievementsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AchievementsTableViewCell.identifier)
    achievementsTableView.dataSource = self
    achievementsTableView.delegate = self
    
    viewModel.viewDidLoad()
  }
  
  override func addUIComponents() {
    topViewContainerHeight.isActive = false
    topViewContainer.addSubview(navPanel)
    navPanel.fillToSuperview()
  }
  override func setupColorTheme() {
    [topBackgroundView, topViewContainer].forEach {
      $0?.backgroundColor = AppColor.accentOne
    }
    
    [levelTitle, levelDescription].forEach {
      $0?.textColor = AppColor.layerOne
    }
    
    achievementsTableView.backgroundColor = AppColor.backgroundOne
  }
  override func setupFontTheme() {
    levelTitle.font = Constants.levelTitleFont
    levelDescription.font = Constants.levelDescriptionFont
  }
  override func setupLocalizeTitles() {
    levelTitle.text = AchievementType.lvl1.title
    levelDescription.text = String(format: AchievementsTitles.youWalkedSteps.localized, 0)
  }
  override func setupIcons() {
    currentAchievementImageView.image = AchievementType.lvl1.icon
  }
  override func setupConstraintsConstants() {
    topBackgroundViewBottom.constant = Constants.topBackgroundViewBottom
    currentAchievementImageViewHeight.constant = Constants.currentAchievementImageViewHeight
  }
  override func additionalUISettings() {
    topBackgroundView.roundCorners([.bottomLeft, .bottomRight], radius: Constants.topBackgroundViewRadius)
    
    achievementsTableView.contentInset = UIEdgeInsets(top: Constants.headerViewHeight, left: 0, bottom: Constants.footerViewHeight, right: 0)
  }
}

//MARK: - UITableViewDataSource
extension AchievementsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = viewModel.getAchievementModel(for: indexPath)
    if let model, let cell = tableView.dequeueReusableCell(withIdentifier: AchievementsTableViewCell.identifier, for: indexPath) as? AchievementsTableViewCell {
      cell.setupCell(with: model)
      return cell
    }
    return UITableViewCell()
  }
  
  
}
//MARK: - UITableViewDelegate
extension AchievementsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

//MARK: - CommonNavPanelDelegate
extension AchievementsViewController: CommonNavPanelDelegate {
  func backButtonAction() {
    viewModel.deinitWasCalled()
    popVC()
  }
  func shareButtonAction() {
    self.getScreenshotAndShare()
  }
}
//MARK: - AchievementsViewModelDelegate
extension AchievementsViewController: AchievementsViewModelDelegate {
  func updateAchievementLevel(according type: AchievementType) {
    let animationDuration = isAppeared ? Constants.animationDuration : .zero
    
    UIView.transition(with: currentAchievementImageView, duration: animationDuration, options: .transitionFlipFromRight) {
      self.currentAchievementImageView.image = type.icon
    }
    UIView.transition(with: levelTitle, duration: animationDuration, options: .transitionCrossDissolve) {
      self.levelTitle.text = type.title
    }
  }
  
  func updateAchievementsSum(to value: Int) {
    let animationDuration = isAppeared ? Constants.animationDuration : .zero
    
    UIView.transition(with: levelDescription, duration: animationDuration, options: .transitionCrossDissolve) {
      self.levelDescription.text = String(format: AchievementsTitles.youWalkedSteps.localized, value)
    }
  }
  
  func dataSourceDidChange() {
    achievementsTableView.reloadData()
  }
  
  func modelDidChange(at indexPath: IndexPath, with newModel: AchievementModel) {
    guard let cell = achievementsTableView.cellForRow(at: indexPath) as? AchievementsTableViewCell else { return }
    cell.updateProgress(with: newModel)
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var topBackgroundViewBottom: CGFloat {
    let indent = 24.0
    return indent.sizeProportion
  }
  static var topBackgroundViewRadius: CGFloat {
    let maxRadius = 32.0
    let sizeProportion = maxRadius.sizeProportion
    return sizeProportion > maxRadius ? maxRadius : sizeProportion
  }
  
  static var currentAchievementImageViewHeight: CGFloat {
    let height = 140.0
    return height.sizeProportion
  }
  
  static var levelTitleFont: UIFont {
    let fontSize = 24.0
    return AppFont.font(type: .bold, size: fontSize.sizeProportion)
  }
  static var levelDescriptionFont: UIFont {
    let fontSize = 16.0
    return AppFont.font(type: .regular, size: fontSize.sizeProportion)
  }
  
  static var headerViewHeight: CGFloat {
    let maxHeight = 18.0
    let sizeProportion = maxHeight.sizeProportion
    return sizeProportion > maxHeight ? maxHeight : sizeProportion
  }
  static var footerViewHeight: CGFloat {
    let maxHeight = 15.0
    let sizeProportion = maxHeight.sizeProportion
    return sizeProportion > maxHeight ? maxHeight : sizeProportion
  }
}
