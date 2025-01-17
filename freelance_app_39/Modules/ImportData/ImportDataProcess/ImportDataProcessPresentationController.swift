import UIKit

final class ImportDataProcessPresentationController: CommonPresentationController {
  private var importDataProcessVC: ImportDataProcessViewController? {
    presentedViewController as? ImportDataProcessViewController
  }
  override var indent: CGFloat {
    (containerView!.frame.height - self.height) / 2
  }
  override var dismissByTap: Bool { false }
  override var customHeight: CGFloat {
    guard let importDataProcessVC else { return .zero }
    
    let animationViewHeight = importDataProcessVC.animationViewTop.constant + importDataProcessVC.animationViewHeight.constant + importDataProcessVC.animationViewBottom.constant
    let helperLabelHeight = importDataProcessVC.helperLabel.frame.height + importDataProcessVC.helperLabelBottom.constant
    
    return animationViewHeight + helperLabelHeight
  }
  override var customWidth: CGFloat {
    containerView!.frame.width - (Constants.hIndent * 2)
  }
  //MARK: - Override to set cornerRadius
  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    
    presentedView?.roundCorners(.allCorners, radius: Constants.baseCornerRadius)
  }
}

//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var hIndent: CGFloat {
    let maxIndent = 68.0
    let sizeProportion = maxIndent.sizeProportion
    
    return sizeProportion > maxIndent ? maxIndent : sizeProportion
  }
}
