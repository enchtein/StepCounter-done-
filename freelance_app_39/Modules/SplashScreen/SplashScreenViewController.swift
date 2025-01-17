import UIKit
import Lottie

final class SplashScreenViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var rectangleView: UIView!
  @IBOutlet weak var leadingRactangleView: NSLayoutConstraint!
  
  @IBOutlet weak var animationView: LottieAnimationView!
  @IBOutlet weak var animationViewHeight: NSLayoutConstraint!
  @IBOutlet weak var animationViewBottom: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func setupColorTheme() {
    rectangleView.backgroundColor = AppColor.accentOne
    animationView.backgroundColor = .clear
  }
  override func setupConstraintsConstants() {
    leadingRactangleView.constant = Constants.logoViewLeading
    
    animationViewHeight.constant = Constants.animationViewHeight
    animationViewBottom.constant = Constants.animationViewBottom
  }
  override func additionalUISettings() {
    rectangleView.cornerRadius = Constants.logoViewRadius
    
    animationView.loopMode = .loop
    animationView.play()
  }
}

fileprivate struct Constants {
  static var logoViewLeading: CGFloat {
    let maxLeading = 135.0
    return maxLeading
  }
  static var logoViewRadius: CGFloat {
    let maxRadius = 30.0
    return maxRadius.sizeProportion
  }
  
  static var animationViewHeight: CGFloat {
    let maxHeight = 100.0
    return maxHeight.sizeProportion
  }
  static var animationViewBottom: CGFloat { animationViewHeight }
}
