import UIKit

final class ImportDataPresentationController: CommonPresentationController {
  private var importDataVC: ImportDataViewController? {
    presentedViewController as? ImportDataViewController
  }
  override var indent: CGFloat {
    (containerView!.frame.height - self.height) / 2
  }
  override var dismissByTap: Bool { false }
  override var customHeight: CGFloat {
    guard let importDataVC else { return .zero }
    
    let topIndent = importDataVC.contentVStackTop.constant
    let additionalSpacing = importDataVC.contentVStack.spacing * CGFloat(importDataVC.contentVStack.arrangedSubviews.count - 1)
    let titlesContainerHeight = importDataVC.titlesContainer.frame.height
    
    let buttonsVStackHeight = importDataVC.buttonsVStack.frame.height
    
    return topIndent + additionalSpacing + titlesContainerHeight + buttonsVStackHeight
  }
  override var customWidth: CGFloat {
    containerView!.frame.width - (Constants.hIndent * 2)
  }
  //MARK: - Override to set cornerRadius
  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    
    presentedView?.roundCorners(.allCorners, radius: 14.0)
  }
}

//MARK: - Constants
fileprivate struct Constants {
  static var hIndent: CGFloat {
    let maxIndent = 62.0
    let sizeProportion = maxIndent.sizeProportion
    
    return sizeProportion > maxIndent ? maxIndent : sizeProportion
  }
}
