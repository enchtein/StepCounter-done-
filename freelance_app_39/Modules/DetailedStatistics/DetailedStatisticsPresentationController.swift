import Foundation

final class DetailedStatisticsPresentationController: CommonPresentationController {
  private var addOrEditExerciseVC: DetailedStatisticsViewController? {
    presentedViewController as? DetailedStatisticsViewController
  }
  
  override var indent: CGFloat {
    containerView!.frame.height - self.height
  }
  override var customHeight: CGFloat {
    if let addOrEditExerciseVC {
      let vIndent = addOrEditExerciseVC.contentVStackTop.constant + addOrEditExerciseVC.contentVStackBottom.constant
      
      let vStackSpacing = addOrEditExerciseVC.contentVStack.spacing * CGFloat(addOrEditExerciseVC.contentVStack.arrangedSubviews.count - 1)
      let titleContainerHeight = addOrEditExerciseVC.closeButtonTop.constant + addOrEditExerciseVC.closeButtonHeight.constant + addOrEditExerciseVC.closeButtonBottom.constant
      
      let indicatorsContainerHeight = addOrEditExerciseVC.indicatorsContainerHeight.constant
      
      return vIndent + vStackSpacing + titleContainerHeight + indicatorsContainerHeight
    }
    return .zero
  }
  //MARK: - Override to set cornerRadius
  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    
    presentedView?.roundCorners([.topLeft, .topRight], radius: 6.0)
  }
}
