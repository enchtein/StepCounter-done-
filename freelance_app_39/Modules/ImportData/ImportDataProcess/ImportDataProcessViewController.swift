import UIKit
import Lottie

final class ImportDataProcessViewController: CommonBasedOnPresentationViewController {
  @IBOutlet weak var animationView: LottieAnimationView!
  @IBOutlet weak var animationViewTop: NSLayoutConstraint!
  @IBOutlet weak var animationViewBottom: NSLayoutConstraint!
  @IBOutlet weak var animationViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var helperLabel: UILabel!
  @IBOutlet weak var helperLabelBottom: NSLayoutConstraint!
  
  private var visabilityTimer: Timer?
  
  private var settingsVC: SettingsViewController? {
    transitioningDelegate as? SettingsViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    removeBasePanGesture()
    scheduleVisabilityTimer()
  }
  
  override func setupColorTheme() {
    view.backgroundColor = AppColor.layerTwo
    animationView.backgroundColor = .clear
    
    helperLabel.textColor = AppColor.layerOne
  }
  override func setupFontTheme() {
    helperLabel.font = AppFont.font(type: .bold, size: 17.0)
  }
  override func setupLocalizeTitles() {
    helperLabel.text = SettingsTitles.importingData.localized + "..."
  }
  override func additionalUISettings() {
    animationView.loopMode = .loop
    animationView.play()
    
    view.clipsToBounds = true
  }
  
  private func scheduleVisabilityTimer() {
    visabilityTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] timer in
      self?.closeVC()
    }
  }
  private func closeVC() {
    visabilityTimer?.invalidate()
    visabilityTimer = nil
    
    HealthKitService.shared.resetBoduParams()
    dismiss(animated: true)
  }
}

//MARK: - Constats
fileprivate struct Constats {
  
}
