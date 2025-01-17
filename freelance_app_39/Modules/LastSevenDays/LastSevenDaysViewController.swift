import UIKit

final class LastSevenDaysViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var contentContainer: UIView!
  
  private lazy var lastSevenDaysInformationView = LastSevenDaysInformationView(model: viewModel.lastSevenDaysStepInformation)
  
  private var type: HealthKitActivityTypes = .step

  private lazy var viewModel = LastSevenDaysViewModel(type: type, delegate: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    viewModel.viewDidLoad()
  }
  override func addUIComponents() {
    contentContainer.addSubview(lastSevenDaysInformationView)
    lastSevenDaysInformationView.fillToSuperview()
  }
  override func setupColorTheme() {
    contentContainer.backgroundColor = AppColor.layerTwo
  }
  
  override func additionalUISettings() {
    contentContainer.cornerRadius = Constants.baseCornerRadius
    contentContainer.layer.borderColor = AppColor.layerThree.cgColor
    contentContainer.layer.borderWidth = 1.0
  }
  
  func deinitWasCalled() {
    viewModel.deinitWasCalled()
  }
}

//MARK: - LastSevenDaysViewModelDelegate
extension LastSevenDaysViewController: LastSevenDaysViewModelDelegate {
  func informationDidChange(to model: DaysRangeInformationModel) {
    lastSevenDaysInformationView.updateValues(according: model)
  }
}
//MARK: - createFromStoryboardHelper
extension LastSevenDaysViewController {
  static func createFromStoryboardHelper(for type: HealthKitActivityTypes) -> Self {
    let vc = Self.createFromStoryboard()
    vc.type = type
    
    return vc
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {}
