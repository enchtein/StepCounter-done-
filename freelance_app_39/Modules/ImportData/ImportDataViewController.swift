import UIKit

final class ImportDataViewController: CommonBasedOnPresentationViewController {
  @IBOutlet weak var contentVStack: UIStackView!
  @IBOutlet weak var contentVStackTop: NSLayoutConstraint!
  
  @IBOutlet weak var titlesContainer: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var helperLabel: UILabel!
  
  @IBOutlet weak var buttonsVStack: UIStackView!
  @IBOutlet weak var firstSeparator: UIView!
  @IBOutlet weak var importButton: UIButton!
  @IBOutlet weak var importButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var secondSeparator: UIView!
  @IBOutlet weak var cancelButton: UIButton!
  
  private var settingsVC: SettingsViewController? {
    transitioningDelegate as? SettingsViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    removeBasePanGesture()
  }
  
  override func setupColorTheme() {
    [view, titlesContainer].forEach {
      $0?.backgroundColor = AppColor.layerTwo
    }
    
    [titleLabel, helperLabel].forEach {
      $0?.textColor = AppColor.layerOne
    }
    
    buttonsVStack.backgroundColor = AppColor.layerOne
    [importButton, cancelButton].forEach {
      $0?.backgroundColor = AppColor.layerTwo
      $0?.setTitleColor(AppColor.accentOne, for: .normal)
    }
    [firstSeparator, secondSeparator].forEach {
      $0?.backgroundColor = AppColor.layerThree
    }
  }
  override func setupFontTheme() {
    titleLabel.font = AppFont.font(type: .semiBold_sf_pro, size: 17.0)
    helperLabel.font = AppFont.font(type: .regular_sf_pro, size: 13.0)
    
    importButton.titleLabel?.font = AppFont.font(type: .semiBold_sf_pro, size: 17.0)
    cancelButton.titleLabel?.font = AppFont.font(type: .regular_sf_pro, size: 17.0)
  }
  override func setupLocalizeTitles() {
    titleLabel.text = SettingsTitles.importingData.localized
    helperLabel.text = SettingsTitles.importingHelperMsg.localized
    
    importButton.setTitle(SettingsTitles.import.localized, for: .normal)
    cancelButton.setTitle(CommonAppTitles.cancel.localized, for: .normal)
  }
  override func additionalUISettings() {
    importButton.addTarget(self, action: #selector(setOpaqueButton), for: .touchDown)
    importButton.addTarget(self, action: #selector(setNonOpaquesButton), for: .touchDragExit)
    importButton.addTarget(self, action: #selector(setOpaqueButton), for: .touchDragEnter)
    importButton.addTarget(self, action: #selector(setNonOpaquesButton), for: .touchUpInside)
    
    cancelButton.addTarget(self, action: #selector(setOpaqueButton), for: .touchDown)
    cancelButton.addTarget(self, action: #selector(setNonOpaquesButton), for: .touchDragExit)
    cancelButton.addTarget(self, action: #selector(setOpaqueButton), for: .touchDragEnter)
    cancelButton.addTarget(self, action: #selector(setNonOpaquesButton), for: .touchUpInside)
    
    view.clipsToBounds = true
  }
  @IBAction func importButtonAction(_ sender: UIButton) {
    dismiss(animated: true) { [weak self] in
      self?.settingsVC?.importHealthKitData()
    }
  }
  @IBAction func cancelButtonAction(_ sender: UIButton) {
    dismiss(animated: true)
  }
}
//MARK: - Helpers
private extension ImportDataViewController {
  @objc func setOpaqueButton(_ sender: UIButton) {
    updateButtonOpacity(sender, true)
  }
  @objc func setNonOpaquesButton(_ sender: UIButton) {
    updateButtonOpacity(sender, false)
  }
  func updateButtonOpacity(_ sender: UIButton, _ isOpaque: Bool) {
    sender.layer.opacity = isOpaque ? Constants.actionsOpacity.highlighted : Constants.actionsOpacity.base
  }
}

fileprivate struct Constants {
  static let actionsOpacity = TargetActionsOpacity()
}
