import UIKit

final class DetailedStatisticsViewController: CommonBasedOnPresentationViewController {
  @IBOutlet weak var contentVStack: UIStackView!
  @IBOutlet weak var contentVStackTop: NSLayoutConstraint!
  @IBOutlet weak var contentVStackBottom: NSLayoutConstraint!
  
  @IBOutlet weak var titleContainer: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var closeButtonTop: NSLayoutConstraint!
  @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var closeButtonBottom: NSLayoutConstraint!
  
  @IBOutlet weak var indicatorsContainer: UIView!
  @IBOutlet weak var indicatorsContainerHeight: NSLayoutConstraint!
  
  private var type: HealthKitActivityTypes = .step
  private var expectedHeight: CGFloat = .zero
  private var bottomIndent: CGFloat = .zero
  
  private lazy var lastSevenDaysVC = LastSevenDaysViewController.createFromStoryboardHelper(for: type)
  
  static func createFromNib(type: HealthKitActivityTypes, height: CGFloat, bottomIndent: CGFloat, presentDirection: TransitionDirection = .bottom) -> Self {
    let vc = Self.createFromNibHelper(presentDirection: presentDirection)
    vc.type = type
    vc.expectedHeight = height
    vc.bottomIndent = bottomIndent
    
    return vc
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    contentVStackBottom.constant = bottomIndent
    
    addChild(lastSevenDaysVC)
    indicatorsContainer.addSubview(lastSevenDaysVC.view)
    lastSevenDaysVC.view.fillToSuperview()
    lastSevenDaysVC.didMove(toParent: self)
    
    indicatorsContainerHeight.constant = expectedHeight
    view.layoutIfNeeded()
  }
  deinit {
    lastSevenDaysVC.deinitWasCalled()
  }
  
  override func setupColorTheme() {
    [view, titleContainer, lastSevenDaysVC.view].forEach {
      $0?.backgroundColor = AppColor.layerTwo
    }
    titleLabel.textColor = AppColor.layerOne
  }
  override func setupFontTheme() {
    titleLabel.font = AppFont.font(type: .bold, size: 24.sizeProportion)
  }
  override func setupLocalizeTitles() {
    titleLabel.text = MainTitles.detailedStatistics.localized
  }
  override func setupIcons() {
    closeButton.setTitle("", for: .normal)
    closeButton.setImage(AppImage.Main.close, for: .normal)
  }
  @IBAction func closeButtonAction(_ sender: UIButton) {
    dismiss(animated: true)
  }
}
