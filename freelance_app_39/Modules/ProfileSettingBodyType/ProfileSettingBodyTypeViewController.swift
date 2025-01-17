import UIKit

final class ProfileSettingBodyTypeViewController: CommonBasedOnPresentationViewController {
  @IBOutlet weak var contentVStackTop: NSLayoutConstraint!
  @IBOutlet weak var contentVStackBottom: NSLayoutConstraint!
  
  @IBOutlet weak var topContainer: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var closeButtonTop: NSLayoutConstraint!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var closeButtonBottom: NSLayoutConstraint!
  
  @IBOutlet weak var contentVStack: UIStackView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var dataPickerLeadingEmptyView: UIView!
  @IBOutlet weak var dataPickerLeadingEmptyViewWidth: NSLayoutConstraint!
  @IBOutlet weak var dataPicker: UIPickerView!
  @IBOutlet weak var dataPickerTrailingEmptyView: UIView!
  @IBOutlet weak var dataPickerHeight: NSLayoutConstraint!
  @IBOutlet weak var helperLabel: UILabel!
  @IBOutlet weak var saveButton: CommonButton!
  
  private var bodyType: ProfileSettingsType = .height
  static func createFromNib(type: ProfileSettingsType, presentDirection: TransitionDirection = .bottom) -> Self {
    let vc = Self.createFromNibHelper(presentDirection: presentDirection)
    vc.bodyType = type
    
    return vc
  }
  override var isPanGestureShouldRecognizeSimultaneouslyWith: Bool { false }
  
  private lazy var viewModel = ProfileSettingBodyTypeViewModel(delegate: self, bodyType: bodyType)
  private var profileSettingsVC: ProfileSettingsViewController? {
    transitioningDelegate as? ProfileSettingsViewController
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    dataPicker.dataSource = self
    dataPicker.delegate = self
    
    viewModel.viewDidLoad()
  }
  override func setupColorTheme() {
    [view, topContainer].forEach {
      $0?.backgroundColor = AppColor.layerTwo
    }
    
    [dataPickerLeadingEmptyView, dataPickerTrailingEmptyView].forEach {
      $0?.backgroundColor = .clear
    }
    
    titleLabel.textColor = AppColor.layerOne
    descriptionLabel.textColor = AppColor.layerOne
    helperLabel.textColor = AppColor.layerFour
  }
  override func setupFontTheme() {
    titleLabel.font = Constants.titleLabelFont
    descriptionLabel.font = Constants.descriptionLabelFont
    helperLabel.font = Constants.helperLabelFont
  }
  override func setupLocalizeTitles() {
    switch bodyType {
    case .gender: break
    case .height:
      titleLabel.text = ProfileSettingsTitles.height.localized
    case .stepLength:
      titleLabel.text = ProfileSettingsTitles.stepLength.localized
    case .weight:
      titleLabel.text = ProfileSettingsTitles.weight.localized
    case .metric: break
    }
    
    descriptionLabel.text = ProfileSettingsTitles.bodyTypeDescriptionMsg.localized
    helperLabel.text = String(format: ProfileSettingsTitles.bodyTypeHelperMsg.localized, "\(viewModel.getStepLenghtСoefficient())", "\(viewModel.getCurrentHeight())")
    
    saveButton.setupTitle(with: CommonAppTitles.save.localized)
  }
  override func setupIcons() {
    closeButton.setTitle("", for: .normal)
    closeButton.setImage(AppImage.Main.close, for: .normal)
  }
  override func setupConstraintsConstants() {
    contentVStackBottom.constant = safeArea.bottom + Constants.contentVStackBottomBottom
    
    if bodyType == .weight {
      dataPickerLeadingEmptyViewWidth.constant = Constants.dataPickerLeadingEmptyViewWidthForWeight
    } else {
      dataPickerLeadingEmptyViewWidth.constant = Constants.dataPickerLeadingEmptyViewWidth
    }
  }
  override func additionalUISettings() {
    contentVStack.spacing = Constants.contentVStackSpacing
    
    descriptionLabel.isHidden = bodyType != .stepLength
    helperLabel.isHidden = bodyType != .stepLength
  }
  @IBAction func closeButtonAction(_ sender: UIButton) {
    dismiss(animated: true)
  }
  @IBAction func saveButtonAction(_ sender: CommonButton) {
    viewModel.saveButtonAction()
    profileSettingsVC?.reloadCell(for: bodyType)
    
    dismiss(animated: true)
  }
}
//MARK: - UIPickerViewDataSource
extension ProfileSettingBodyTypeViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    viewModel.numberOfComponents()
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    viewModel.numberOfRows(in: component)
  }
}
//MARK: - UIPickerViewDelegate
extension ProfileSettingBodyTypeViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    let pickerLabel: UILabel = (view as? UILabel) ?? UILabel()
    pickerLabel.textAlignment = .center
    
    switch component {
    case viewModel.emptyComponentIndex: pickerLabel.attributedText = NSAttributedString()
    case viewModel.dataSourceComponentIndex:
      let value = viewModel.dataSource[row]
      
      if viewModel.selectedDataSourceItem == row {
        pickerLabel.attributedText = NSAttributedString(string: String(value), attributes: [.font: AppFont.font(type: .semiBold, size: 23.sizeProportion), .foregroundColor: AppColor.accentOne])
      } else {
        pickerLabel.attributedText = NSAttributedString(string: String(value), attributes: [.font: AppFont.font(type: .regular, size: 21.sizeProportion), .foregroundColor: AppColor.layerFour])
      }
    case viewModel.parameterComponentIndex:
      pickerLabel.textAlignment = .left
      pickerLabel.attributedText = NSAttributedString(string: getParameter(), attributes: [.font: AppFont.font(type: .regular, size: 21.sizeProportion), .foregroundColor: AppColor.layerOne])
    default: pickerLabel.attributedText = NSAttributedString()
    }
    
    return pickerLabel
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if component == viewModel.dataSourceComponentIndex {
      viewModel.updateSelectedItem(with: row)
      pickerView.reloadAllComponents()
    }
  }
  
  private func getParameter() -> String {
    let selectedUnit = MetricAndImperialUnitType(rawValue: UserDefaults.standard.metricAndImperialUnit) ?? .kgAndcm
    
    let text: String
    switch bodyType {
    case .gender: text = ""
    case .height, .stepLength:
      text = selectedUnit == .kgAndcm ? ProfileSettingsTitles.cm.localized : ProfileSettingsTitles.ft.localized
    case .weight:
      text = selectedUnit == .kgAndcm ? ProfileSettingsTitles.kg.localized : ProfileSettingsTitles.pound.localized
    case .metric: text = ""
    }
    
    return text
  }
}
//MARK: - ProfileSettingBodyTypeViewModelDelegate
extension ProfileSettingBodyTypeViewController: ProfileSettingBodyTypeViewModelDelegate {
  func updateUI(according selectedItem: Int, in component: Int) {
    dataPicker.selectRow(selectedItem, inComponent: component, animated: false)
  }
  func updateSaveButtonAvailability(to isEnabled: Bool) {
    saveButton.isEnabled = isEnabled
  }
}

//MARK: - Constants
fileprivate struct Constants {
  static var titleLabelFont: UIFont {
    let fontSize = 24.0
    return AppFont.font(type: .bold, size: fontSize.sizeProportion)
  }
  static var descriptionLabelFont: UIFont {
    let fontSize = 16.0
    return AppFont.font(type: .regular, size: fontSize.sizeProportion)
  }
  static var helperLabelFont: UIFont {
    let fontSize = 14.0
    return AppFont.font(type: .regular, size: fontSize.sizeProportion)
  }
  
  static var pickerValueFont: UIFont {
    let fontSize = 16.0
    return AppFont.font(type: .regular, size: fontSize.sizeProportion)
  }
  static var pickerParameterFont: UIFont {
    let fontSize = 23.0
    return AppFont.font(type: .semiBold, size: fontSize.sizeProportion)
  }
  
  static var contentVStackSpacing: CGFloat {
    let maxSpacing = 32.0
    let sizeProportion = maxSpacing.sizeProportion
    
    return sizeProportion > maxSpacing ? maxSpacing : sizeProportion
  }
  
  static var contentVStackBottomBottom: CGFloat {
    let maxValue = 8.0
    let proportionValue = maxValue.sizeProportion
    return proportionValue > maxValue ? maxValue : proportionValue
  }
  
  static var dataPickerLeadingEmptyViewWidth: CGFloat {
    let maxWidth = 71.5
    let sizeProportion = maxWidth.sizeProportion
    
    return sizeProportion > maxWidth ? maxWidth : sizeProportion
  }
  static var dataPickerLeadingEmptyViewWidthForWeight: CGFloat {
    let maxWidth = 51.5
    let sizeProportion = maxWidth.sizeProportion
    
    return sizeProportion > maxWidth ? maxWidth : sizeProportion
  }
}
