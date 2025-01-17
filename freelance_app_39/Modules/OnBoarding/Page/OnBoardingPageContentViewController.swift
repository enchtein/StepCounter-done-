import UIKit

final class OnBoardingPageContentViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var contentVStack: UIStackView!
  @IBOutlet weak var imageContainer: UIView!
  
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var imageTop: NSLayoutConstraint!
  @IBOutlet weak var imageLeading: NSLayoutConstraint!
  
  @IBOutlet weak var leadingSpacer: UIView!
  @IBOutlet weak var helperTitlesVStack: UIStackView!
  @IBOutlet weak var helperTitle: UILabel!
  @IBOutlet weak var helperMsg: UILabel!
  @IBOutlet weak var trailingSpacer: UIView!
  
  private(set) var type: OnBoardingPageType = .day
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func setupColorTheme() {
    imageContainer.backgroundColor = AppColor.accentOne
    helperTitle.textColor = AppColor.layerOne
    helperMsg.textColor = AppColor.layerFour
    
    [leadingSpacer, trailingSpacer].forEach {
      $0?.backgroundColor = AppColor.backgroundOne
    }
  }
  override func setupFontTheme() {
    helperTitle.font = Constants.helperTitleFont
    helperMsg.font = Constants.helperMsgFont
  }
  override func setupLocalizeTitles() {
    helperTitle.text = type.helperTitle
    helperMsg.text = type.helperMsg
  }
  override func setupIcons() {
    image.image = type.image
  }
  override func setupConstraintsConstants() {
    imageContainer.roundCorners([.bottomLeft, .bottomRight], radius: Constants.imageContainerRadius)
    
    imageTop.constant = safeArea.top + Constants.imageTopIndent
    imageLeading.constant = Constants.imageLeadingIndent
  }
}
//MARK: - API
extension OnBoardingPageContentViewController {
  func updateUIAccording(_ pageType: OnBoardingPageType) {
    type = pageType
  }
}

enum OnBoardingPageType: Int, CaseIterable {
  case day = 0
  case archivements
  case month
  
  var helperTitle: String {
    switch self {
    case .day: OnBoardingTitles.dayTitle.localized
    case .archivements: OnBoardingTitles.archivementsTitle.localized
    case .month: OnBoardingTitles.monthTitle.localized
    }
  }
  var helperMsg: String {
    switch self {
    case .day: OnBoardingTitles.dayMsg.localized
    case .archivements: OnBoardingTitles.archivementsMsg.localized
    case .month: OnBoardingTitles.monthMsg.localized
    }
  }
  
  var image: UIImage {
    switch self {
    case .day: AppImage.OnBoarding.day
    case .archivements: AppImage.OnBoarding.archivements
    case .month: AppImage.OnBoarding.month
    }
  }
}

//MARK: - Constants
fileprivate struct Constants {
  static var imageContainerRadius: CGFloat {
    let radius = 44.0
    return radius.sizeProportion
  }
  static var imageTopIndent: CGFloat {
    let indent = 30.0
    return indent.sizeProportion
  }
  static var imageLeadingIndent: CGFloat {
    let indent = 55
    return indent.sizeProportion
  }
  static var helperTitleFont: UIFont {
    let size = 32.0
    return AppFont.font(type: .semiBold, size: size.sizeProportion)
  }
  static var helperMsgFont: UIFont {
    let size = 14.0
    return AppFont.font(type: .regular, size: size.sizeProportion)
  }
}
