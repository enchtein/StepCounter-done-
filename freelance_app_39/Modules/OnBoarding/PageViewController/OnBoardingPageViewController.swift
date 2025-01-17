import UIKit

final class OnBoardingPageViewController: UIPageViewController, StoryboardInitializable {
  private let pageTypes = OnBoardingPageType.allCases
  private(set) var currentPageContentVCType: OnBoardingPageType = .day
  
  required init?(coder: NSCoder) {
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 10])
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let viewController = viewPageController(.zero)
    let viewControllers = [viewController]
    
    setViewControllers(viewControllers,
                       direction: .forward,
                       animated: false,
                       completion: nil)
    
    view.backgroundColor = AppColor.backgroundOne
    dataSource = self
    delegate = self
  }
  private func viewPageController(_ index: Int) -> OnBoardingPageContentViewController {
    let vc = OnBoardingPageContentViewController.createFromStoryboard()
    
    if let type = OnBoardingPageType(rawValue: index) {
      vc.updateUIAccording(type)
    }
    
    return vc
  }
}
//MARK: - UIPageViewControllerDataSource
extension OnBoardingPageViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let pageVC = viewController as? OnBoardingPageContentViewController else { return nil }
    
    let prevPageIndex = pageVC.type.rawValue - 1
    
    guard pageTypes.indices.contains(prevPageIndex) else { return nil }
    return viewPageController(prevPageIndex)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let pageVC = viewController as? OnBoardingPageContentViewController else { return nil }
    
    let nextPageIndex = pageVC.type.rawValue + 1
    
    guard pageTypes.indices.contains(nextPageIndex) else { return nil }
    return viewPageController(nextPageIndex)
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pageTypes.count
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    currentPageContentVCType.rawValue
  }
}
//MARK: - UIPageViewControllerDelegate
extension OnBoardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
      if let currentVC = pageViewController.viewControllers?.first as? OnBoardingPageContentViewController {
        currentPageContentVCType = currentVC.type
      }
      
      (parent as? OnBoardingViewController)?.updateUIAccording(currentPageContentVCType)
    }
}
//MARK: - API
extension OnBoardingPageViewController {
  func forward() {
    guard let currentPageVC = viewControllers?.first else { return }
    guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentPageVC) else { return }
    
    if let nextPageVC = nextViewController as? OnBoardingPageContentViewController {
      currentPageContentVCType = nextPageVC.type
    }
    
    setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    (parent as? OnBoardingViewController)?.updateUIAccording(currentPageContentVCType)
  }
}
