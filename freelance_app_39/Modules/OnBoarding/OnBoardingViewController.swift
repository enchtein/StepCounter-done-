import UIKit

final class OnBoardingViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var containerView: UIView!
  
  @IBOutlet weak var divider: UIView!
  @IBOutlet weak var dividerTop: NSLayoutConstraint!
  @IBOutlet weak var dividerBottom: NSLayoutConstraint!
  
  @IBOutlet weak var buttonsHStack: UIStackView!
  @IBOutlet weak var skipButton: CommonButton!
  @IBOutlet weak var continueButton: CommonButton!
  
  private lazy var pageVC = OnBoardingPageViewController.createFromStoryboard()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    addChild(pageVC)
    containerView.addSubview(pageVC.view)
    pageVC.view.fillToSuperview()
    pageVC.didMove(toParent: self)
  }
  
  override func setupColorTheme() {
    divider.backgroundColor = AppColor.layerThree
    skipButton.setupEnabledBgColor(to: AppColor.accentOne.withAlphaComponent(0.2))
    skipButton.setupEnabledTitleColor(to: AppColor.accentOne)
  }
  override func setupLocalizeTitles() {
    skipButton.setupTitle(with: OnBoardingTitles.skip.localized)
    continueButton.setupTitle(with: OnBoardingTitles.continue.localized)
  }
  
  //MARK: - Actions
  @IBAction func skipButtonAction(_ sender: CommonButton) {
    goToSetGoals()
  }
  @IBAction func continueButtonAction(_ sender: CommonButton) {
    if pageVC.currentPageContentVCType == .month {
      goToSetGoals()
    } else {
      pageVC.forward()
    }
  }
}
//MARK: - API
extension OnBoardingViewController {
  func updateUIAccording(_ currentPageContentVCType: OnBoardingPageType) {
    switch currentPageContentVCType {
    case .day, .archivements: 
      continueButton.setupTitle(with: OnBoardingTitles.continue.localized)
      skipButton.showAnimated(in: buttonsHStack)
    case .month:
      continueButton.setupTitle(with: OnBoardingTitles.getStarted.localized)
      skipButton.hideAnimated(in: buttonsHStack)
    }
  }
}
//MARK: - Helpers
private extension OnBoardingViewController {
  func goToSetGoals() {
    HealthKitService.shared.checkStatusAndRequestIfNeeded {
#if DEBUG
      print("❌ Permission Denied, go to Set Goals")
#endif
      AppCoordinator.shared.push(.setGoals)
    } allowAction: {
#if DEBUG
      print("✅ Permission Allowed, go to Set Goals")
#endif
      AppCoordinator.shared.push(.setGoals)
    }
  }
}
