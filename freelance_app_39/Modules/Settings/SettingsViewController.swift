import UIKit
import StoreKit

final class SettingsViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var topBackgroundView: UIView!
  
  @IBOutlet weak var topViewContainer: UIView!
  @IBOutlet weak var topViewContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var settingsTableView: UITableView!
  
  private lazy var navPanel = CommonNavPanel(type: .settings, delegate: self)
  private lazy var viewModel = SettingsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    settingsTableView.register(UINib(nibName: SettingsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsTableViewCell.identifier)
    settingsTableView.register(UINib(nibName: SettingsAppVersionCellTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsAppVersionCellTableViewCell.identifier)
    
    settingsTableView.dataSource = self
    settingsTableView.delegate = self
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
    
    settingsTableView.backgroundColor = AppColor.backgroundOne
  }
  override func additionalUISettings() {
    settingsTableView.contentInset = Constants.settingsTableViewInsents
  }
}

//MARK: - CommonNavPanelDelegate
extension SettingsViewController: CommonNavPanelDelegate {
  func backButtonAction() {
    popVC()
  }
}

//MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    viewModel.numberOfSections()
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfItems(in: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = viewModel.getSetting(for: indexPath)
    let isLastSectionCell = viewModel.isLastSectionCell(at: indexPath)
    
    if let setting {
      if setting == .appVer {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SettingsAppVersionCellTableViewCell.identifier, for: indexPath) as? SettingsAppVersionCellTableViewCell {
          cell.setupCell()
          
          return cell
        } else {
          return UITableViewCell()
        }
      } else {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell {
          cell.setupCell(with: setting, delegate: self, isLastSectionCell: isLastSectionCell)
          
          return cell
        } else {
          return UITableViewCell()
        }
      }
    } else {
      return UITableViewCell()
    }
  }
}
//MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}
//MARK: - SettingsTableViewCellDelegate
extension SettingsViewController: SettingsTableViewCellDelegate {
  func didSelect(cell: SettingsTableViewCell) {
    guard let indexPath = settingsTableView.indexPath(for: cell) else { return }
    guard let setting = viewModel.getSetting(for: indexPath) else { return }
    switch setting {
    case .goals:
      AppCoordinator.shared.push(.setGoals)
    case .profileSettings:
      AppCoordinator.shared.push(.profileSettings)
    case .importFromAppleHealth:
      let vc = ImportDataViewController.createFromNibHelper()
      vc.modalPresentationStyle = .custom
      vc.transitioningDelegate = self
      
      present(vc, animated: true)
    case .rateUs:
      if let windowScene = UIApplication.shared.appWindow?.windowScene {
        SKStoreReviewController.requestReview(in: windowScene)
      }
    case .notifications, .privacyPolicy, .termsOfUse, .shareApp:
      if let link = setting.link, UIApplication.shared.canOpenURL(link) {
        UIApplication.shared.open(link)
      } else {
        debugPrint("unknown item")
      }
    case .appVer: break
    }
  }
}
//MARK: - UIViewControllerTransitioningDelegate
extension SettingsViewController: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    if presented is ImportDataViewController {
      ImportDataPresentationController(presentedViewController: presented, presenting: presenting)
    } else if presented is ImportDataProcessViewController {
      ImportDataProcessPresentationController(presentedViewController: presented, presenting: presenting)
    } else {
      nil
    }
  }
}
//MARK: - API
extension SettingsViewController {
  func importHealthKitData() {
    let vc = ImportDataProcessViewController.createFromNibHelper()
    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = self
    
    present(vc, animated: true)
  }
}
//MARK: - Constants
fileprivate struct Constants {
  static var settingsTableViewInsents: UIEdgeInsets {
    let vIndent = 20.0
    return UIEdgeInsets(top: vIndent.sizeProportion, left: 0, bottom: vIndent.sizeProportion, right: 0)
  }
}
