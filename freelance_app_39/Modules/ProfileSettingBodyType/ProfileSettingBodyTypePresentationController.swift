import UIKit

final class ProfileSettingBodyTypePresentationController: CommonPresentationController {
  private var profileSettingsBodyTypeVC: ProfileSettingBodyTypeViewController? {
    presentedViewController as? ProfileSettingBodyTypeViewController
  }
  override var indent: CGFloat {
    containerView!.frame.height - self.height
  }
  override var customHeight: CGFloat {
    guard let bodyTypeVC = profileSettingsBodyTypeVC else { return .zero }
    let vIndent = bodyTypeVC.contentVStackTop.constant + bodyTypeVC.contentVStackBottom.constant
    let titleContainerHeight = bodyTypeVC.closeButtonTop.constant + bodyTypeVC.closeButtonHeight.constant + bodyTypeVC.closeButtonBottom.constant
    
    let visibleSubviews = bodyTypeVC.contentVStack.arrangedSubviews.filter { !$0.isHidden }
    let vStackSpacing = bodyTypeVC.contentVStack.spacing * CGFloat(visibleSubviews.count - 1)
    
    var contentHeight: CGFloat = .zero
    if !bodyTypeVC.descriptionLabel.isHidden {
      contentHeight += bodyTypeVC.descriptionLabel.frame.height
    }
    contentHeight += bodyTypeVC.dataPickerHeight.constant
    if !bodyTypeVC.helperLabel.isHidden {
      contentHeight += bodyTypeVC.helperLabel.frame.height
    }
    contentHeight += bodyTypeVC.saveButton.frame.height
    
    return vIndent + vStackSpacing + titleContainerHeight + contentHeight
  }
  //MARK: - Override to set cornerRadius
  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    
    presentedView?.roundCorners([.topLeft, .topRight], radius: 6.0)
  }
}
