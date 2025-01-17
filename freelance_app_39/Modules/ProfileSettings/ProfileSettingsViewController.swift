import UIKit

final class ProfileSettingsViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var topBackgroundView: UIView!
  
  @IBOutlet weak var topViewContainer: UIView!
  @IBOutlet weak var topViewContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var profileSettingsTableView: UITableView!
  
  private lazy var navPanel = CommonNavPanel(type: .profileSettings, delegate: self)
  private lazy var viewModel = ProfileSettingsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    profileSettingsTableView.register(UINib(nibName: ProfileSettingsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProfileSettingsTableViewCell.identifier)
    
    profileSettingsTableView.dataSource = self
    profileSettingsTableView.delegate = self
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
    
    profileSettingsTableView.backgroundColor = AppColor.backgroundOne
  }
  override func additionalUISettings() {
    profileSettingsTableView.contentInset = Constants.profileSettingsTableViewInsents
  }
}

extension ProfileSettingsViewController: CommonNavPanelDelegate {
  func backButtonAction() {
    popVC()
  }
}
//MARK: - UITableViewDataSource
extension ProfileSettingsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfItems(in: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = viewModel.getSetting(for: indexPath)
    let itemValue = viewModel.getSettingValue(for: indexPath)
    if let item, let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSettingsTableViewCell.identifier, for: indexPath) as? ProfileSettingsTableViewCell {
      cell.setupCell(setting: item, profileSettingValue: itemValue, delegate: self)
      
      return cell
    }
    return UITableViewCell()
  }
}
//MARK: - UITableViewDelegate
extension ProfileSettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}
//MARK: - ProfileSettingsTableViewCellDelegate
extension ProfileSettingsViewController: ProfileSettingsTableViewCellDelegate {
  func didSelect(cell: ProfileSettingsTableViewCell) {
    guard let indexPath = profileSettingsTableView.indexPath(for: cell) else { return }
    guard let setting = viewModel.getSetting(for: indexPath) else { return }
    
    switch setting {
    case .gender:
      var totalActions = GenderType.allCases.map { gendetType in
        UIAlertAction(title: gendetType.title, style: .default) { [weak self] _ in
          UserDefaults.standard.gender = gendetType.title
          
          self?.reloadCell(at: indexPath)
        }
      }
      
      let cancelAction = UIAlertAction(title: CommonAppTitles.cancel.localized, style: .cancel)
      totalActions.append(cancelAction)
      
      UIAlertController.alert(with: setting.title, message: ProfileSettingsTitles.genderAlertMsg.localized, actions: totalActions, alertStyle: .actionSheet)
    case .height, .stepLength, .weight:
      let vc = ProfileSettingBodyTypeViewController.createFromNib(type: setting)
      vc.modalPresentationStyle = .custom
      vc.transitioningDelegate = self
      
      present(vc, animated: true)
    case .metric:
      var totalActions = MetricAndImperialUnitType.allCases.map { unit in
        UIAlertAction(title: unit.title, style: .default) { [weak self] _ in
          UserDefaults.standard.metricAndImperialUnit = unit.title
          
          self?.reloadTableWithAnimation()
        }
      }
      
      let cancelAction = UIAlertAction(title: CommonAppTitles.cancel.localized, style: .cancel)
      totalActions.append(cancelAction)
      
      UIAlertController.alert(with: setting.title, message: ProfileSettingsTitles.metricAlertMsg.localized, actions: totalActions, alertStyle: .actionSheet)
    }
  }
  
  private func reloadCell(at indexPath: IndexPath) {
    profileSettingsTableView.reloadRows(at: [indexPath], with: .fade)
  }
  private func reloadTableWithAnimation() {
    let range = NSMakeRange(0, profileSettingsTableView.numberOfSections)
    let sections = NSIndexSet(indexesIn: range)
    profileSettingsTableView.reloadSections(sections as IndexSet, with: .automatic)
  }
}
//MARK: - UIViewControllerTransitioningDelegate
extension ProfileSettingsViewController: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    ProfileSettingBodyTypePresentationController(presentedViewController: presented, presenting: presenting)
  }
}
//MARK: - API
extension ProfileSettingsViewController {
  func reloadCell(for bodyType: ProfileSettingsType) {
    guard let indexPath = viewModel.indexPath(for: bodyType) else { return }
    reloadCell(at: indexPath)
  }
}

//MARK: - Constants
fileprivate struct Constants {
  static var profileSettingsTableViewInsents: UIEdgeInsets {
    let vIndent = 18.0
    return UIEdgeInsets(top: vIndent.sizeProportion, left: 0, bottom: vIndent.sizeProportion, right: 0)
  }
}
