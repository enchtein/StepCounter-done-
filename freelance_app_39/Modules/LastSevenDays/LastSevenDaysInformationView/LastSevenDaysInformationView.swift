import UIKit

final class LastSevenDaysInformationView: UIView {
  private var model: DaysRangeInformationModel
  
  private lazy var title = createTitle()
  private lazy var averageTitle = createAverageTitle()
  private lazy var averageLabel = createAverageLabel()
  
  private lazy var dayViews: [DayInformationView] = model.dayModels.map { DayInformationView(model: $0) }
  
  init(model: DaysRangeInformationModel) {
    self.model = model
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    let averageHStack = UIStackView()
    averageHStack.axis = .horizontal
    averageHStack.spacing = Constants.averageSpacing
    averageHStack.addArrangedSubview(averageTitle)
    averageHStack.addArrangedSubview(averageLabel)
    
    
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.addArrangedSubview(title)
    hStack.addArrangedSubview(averageHStack)
    
    let commonVStack = UIStackView()
    commonVStack.axis = .vertical
    commonVStack.spacing = Constants.spacing
    commonVStack.addArrangedSubview(hStack)
    
    
    let dayInfoHStack = UIStackView()
    dayInfoHStack.axis = .horizontal
    dayInfoHStack.alignment = .fill
    dayInfoHStack.distribution = .fillEqually
    dayInfoHStack.spacing = Constants.dayInformationSpacing
    
    for dayView in dayViews {
      dayInfoHStack.addArrangedSubview(dayView)
    }
    commonVStack.addArrangedSubview(dayInfoHStack)
    
    
    addSubview(commonVStack)
    commonVStack.fillToSuperview(verticalIndents: Constants.sideIndent, horizontalIndents: Constants.sideIndent)
  }
}
//MARK: - UI elements creating
private extension LastSevenDaysInformationView {
  func createTitle() -> UILabel {
    let label = UILabel()
    label.font = Constants.titleFont
    label.textColor = Constants.titleColor
    label.text = String(format: MainTitles.lastDays.localized, model.dayModels.count)
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    
    return label
  }
  func createAverageTitle() -> UILabel {
    let label = UILabel()
    label.font = Constants.averageTitleFont
    label.textColor = Constants.averageTitleColor
    label.text = MainTitles.average.localized
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    return label
  }
  func createAverageLabel() -> UILabel {
    let label = UILabel()
    label.font = Constants.averageLabelFont
    label.textColor = Constants.averageLabelColor
    label.text = model.formattedAvarageValue
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    return label
  }
}
//MARK: - API
extension LastSevenDaysInformationView {
  func updateValues(according model: DaysRangeInformationModel) {
    self.model = model
    averageLabel.text = model.formattedAvarageValue
    
    for (index, dayView) in dayViews.enumerated() {
      guard model.dayModels.indices.contains(index) else { continue }
      let dayModel = model.dayModels[index]
      
      dayView.updateValues(according: dayModel)
    }
  }
}
//MARK: - Constants
fileprivate struct Constants {
  static let sideIndent: CGFloat = 16.0
  static let averageSpacing: CGFloat = 2.0
  static let spacing: CGFloat = 8.5
  static let dayInformationSpacing: CGFloat = 8.0
  
  static var titleFont: UIFont {
    let fontSize = 17.0
    
    return AppFont.font(type: .bold, size: fontSize.sizeProportion)
  }
  static let titleColor = AppColor.layerOne
  
  static var averageTitleFont: UIFont {
    let fontSize = 14.0
    
    return AppFont.font(type: .regular, size: fontSize.sizeProportion)
  }
  static let averageTitleColor = AppColor.layerFour
  
  static var averageLabelFont: UIFont {
    let fontSize = 14.0
    
    return AppFont.font(type: .bold, size: fontSize.sizeProportion)
  }
  static let averageLabelColor = AppColor.layerOne
}
