import UIKit

final class CalendarViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var monthContainer: UIView!
  @IBOutlet weak var monthContainerHStackTop: NSLayoutConstraint!
  @IBOutlet weak var monthContainerHStackBottom: NSLayoutConstraint!
  @IBOutlet weak var monthLabel: UILabel!
  @IBOutlet weak var dateSwitchHStack: UIStackView!
  @IBOutlet weak var leftDateSwitch: UIButton!
  @IBOutlet weak var rightDateSwitch: UIButton!
  
  @IBOutlet weak var mondayLabel: UILabel!
  @IBOutlet weak var tuesdayLabel: UILabel!
  @IBOutlet weak var wednesdayLabel: UILabel!
  @IBOutlet weak var thursdayLabel: UILabel!
  @IBOutlet weak var fridayLabel: UILabel!
  @IBOutlet weak var saturdayLabel: UILabel!
  @IBOutlet weak var sundayLabel: UILabel!
  
  @IBOutlet weak var calendarCollection: UICollectionView!
  
  @IBOutlet weak var monthStepsContainer: UIView!
  @IBOutlet weak var monthStepsContainerHStackTop: NSLayoutConstraint!
  @IBOutlet weak var monthStepsContainerHStackBottom: NSLayoutConstraint!
  @IBOutlet weak var monthAverageStepsTitle: UILabel!
  @IBOutlet weak var monthAverageStepsLabel: UILabel!
  
  var isCalendarAppeared = false
  private var calendarCollectionHeight: CGFloat?
  
  private lazy var collectionFlowLayout = createCollectionFlowLayout()
  private let weekDays = CalendarWeekDays.allCases
  private var weekDaysSpacingCount: Int {
    weekDays.count - 1
  }
  
  private lazy var viewModel = CalendarViewModel(delegate: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    calendarCollection.register(UINib(nibName: CalendarCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CalendarCollectionViewCell.identifier)
    calendarCollection.dataSource = self
    calendarCollection.delegate = self
    calendarCollection.collectionViewLayout = collectionFlowLayout
    calendarCollection.isScrollEnabled = false
    
    viewModel.viewDidLoad()
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    guard isCalendarAppeared && calendarCollectionHeight == nil else { return }
    calendarCollection.reloadData()
  }
  
  override func setupColorTheme() {
    [view, monthContainer, calendarCollection, monthStepsContainer].forEach {
      $0?.backgroundColor = AppColor.layerTwo
    }
    
    monthLabel.textColor = AppColor.layerOne
    
    [mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel, sundayLabel].forEach {
      $0?.textColor = AppColor.layerFour
    }
    
    monthAverageStepsTitle.textColor = AppColor.layerFive
    monthAverageStepsLabel.textColor = AppColor.accentOne
  }
  override func setupFontTheme() {
    monthLabel.font = Constants.monthFont
    
    [mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel, sundayLabel].forEach {
      $0?.font = Constants.weekLabelsFont
    }
    
    monthAverageStepsTitle.font = Constants.monthAverageTitleFont
    monthAverageStepsLabel.font = Constants.monthAverageLabelFont
  }
  override func setupLocalizeTitles() {
    mondayLabel.text = CalendarWeekDays.monday.dayName
    tuesdayLabel.text = CalendarWeekDays.tuesday.dayName
    wednesdayLabel.text = CalendarWeekDays.wednesday.dayName
    thursdayLabel.text = CalendarWeekDays.thurthday.dayName
    fridayLabel.text = CalendarWeekDays.friday.dayName
    saturdayLabel.text = CalendarWeekDays.saturday.dayName
    sundayLabel.text = CalendarWeekDays.sunday.dayName
    
    monthAverageStepsTitle.text = MainTitles.monthAverageSteps.localized
  }
  override func setupIcons() {
    leftDateSwitch.setTitle("", for: .normal)
    leftDateSwitch.setImage(AppImage.Main.leftDateSwitch, for: .normal)
    rightDateSwitch.setTitle("", for: .normal)
    rightDateSwitch.setImage(AppImage.Main.rightDateSwitch, for: .normal)
  }
  override func setupConstraintsConstants() {
    monthContainerHStackTop.constant = Constants.monthContainerHStackTop
    monthContainerHStackBottom.constant = Constants.monthContainerHStackBottom
    
    monthStepsContainerHStackTop.constant = Constants.monthStepsContainerHStackVIndent
    monthStepsContainerHStackBottom.constant = Constants.monthStepsContainerHStackVIndent
  }
  override func additionalUISettings() {
    dateSwitchHStack.spacing = Constants.dateSwitchHStackSpasing
  }
  
  @IBAction func dateSwitchAction(_ sender: UIButton) {
    viewModel.switchDateRange(isToLeft: sender === leftDateSwitch)
  }
}

//MARK: - UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.monthInformationModel.dayModels.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let dayModel = viewModel.getDayModel(for: indexPath)
    
    if let dayModel, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.identifier, for: indexPath) as? CalendarCollectionViewCell {
      cell.setupCell(with: dayModel)
      
      return cell
    }
    
    return UICollectionViewCell()
  }
}
//MARK: - UICollectionViewDelegate
extension CalendarViewController: UICollectionViewDelegate {
  
}
//MARK: - UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let availableHeightForCells = collectionView.frame.height - (collectionFlowLayout.minimumLineSpacing * (6 - 1))
    let cellHeight = availableHeightForCells / 6
    
    let spacingCount = collectionFlowLayout.minimumInteritemSpacing * CGFloat(weekDaysSpacingCount)
    let cellWidth = (collectionView.frame.width - spacingCount) / CGFloat(weekDays.count)
    
    if isCalendarAppeared && calendarCollectionHeight == nil {
      calendarCollectionHeight = collectionView.frame.height
    }
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
}
//MARK: - Helpers
private extension CalendarViewController {
  func createCollectionFlowLayout() -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    
    layout.minimumInteritemSpacing = Constants.itemSpacing
    layout.minimumLineSpacing = Constants.lineSpacing
    
    return layout
  }
}

//MARK: - CalendarViewModelDelegate
extension CalendarViewController: CalendarViewModelDelegate {
  func monthSumDidChange(to value: Float, for type: HealthKitActivityTypes) {
    let mainVC = (parent as? MainViewController)
    
    switch type {
    case .energy:
      mainVC?.activeEnergyBurnedDidChange(to: value, for: .month)
    case .step:
      mainVC?.stepCountDidChange(to: value, for: .month)
    case .distance:
      mainVC?.distanceWalkingRunningDidChange(to: value, for: .month)
    case .exerciseTime:
      mainVC?.exerciseTimeDidChange(to: value, for: .month)
    }
  }
  
  func monthInformationDidChange() {
    calendarCollection.reloadData()
  }
  func monthDidChange(to text: String) {
    monthLabel.text = text
  }
  
  func dayModelInformationDidChange(at indexPath: IndexPath) {
    guard let dayModel = viewModel.getDayModel(for: indexPath) else { return }
    
    let cell = calendarCollection.cellForItem(at: indexPath) as? CalendarCollectionViewCell
    cell?.setupProgress(to: dayModel.multiplier)
  }
  
  func updateRightDateSwitchButton(to isEnabled: Bool) {
    let rightButtonImage = isEnabled ? AppImage.Main.rightDateSwitch : AppImage.Main.rightDateSwitch.withRenderingMode(.alwaysTemplate)
    
    rightDateSwitch.isEnabled = isEnabled
    rightDateSwitch.setImage(rightButtonImage, for: .normal)
    rightDateSwitch.tintColor = AppColor.layerFour
  }
  
  func monthAverageStepsDidChange(to value: Int) {
    monthAverageStepsLabel.text = String(value)
  }
}
//MARK: - API
extension CalendarViewController {
  func calendarWillAppear() {
    monthSumDidChange(to: viewModel.monthInformationModel.sumValue, for: .step)
    monthSumDidChange(to: viewModel.monthKCalModel.sumValue, for: .energy)
    monthSumDidChange(to: viewModel.monthDistanceModel.sumValue, for: .distance)
    monthSumDidChange(to: viewModel.monthHourModel.sumValue, for: .exerciseTime)
  }
}
//MARK: - Constants
fileprivate struct Constants {
  static let itemSpacing: CGFloat = .zero
  static let lineSpacing: CGFloat = .zero
  
  static var dateSwitchHStackSpasing: CGFloat {
    let maxSpacing = 28.0
    let sizeProportion = maxSpacing.sizeProportion
    
    return sizeProportion > maxSpacing ? maxSpacing : sizeProportion
  }
  
  static var monthContainerHStackTop: CGFloat {
    let maxIndent = 9.0
    let sizeProportion = maxIndent.sizeProportion
    
    return sizeProportion > maxIndent ? maxIndent : sizeProportion
  }
  
  static var monthContainerHStackBottom: CGFloat {
    let maxIndent = 11.0
    let sizeProportion = maxIndent.sizeProportion
    
    return sizeProportion > maxIndent ? maxIndent : sizeProportion
  }
  
  static var monthStepsContainerHStackVIndent: CGFloat {
    let maxIndent = 8.0
    let sizeProportion = maxIndent.sizeProportion
    
    return sizeProportion > maxIndent ? maxIndent : sizeProportion
  }
  
  static var monthFont: UIFont {
    AppFont.font(type: .semiBold, size: 16.sizeProportion)
  }
  
  private static var additionalLabelsFontSize: CGFloat {
    let fontSize = 14.0
    let minFontSize = 11.0
    let sizeProportion = fontSize.sizeProportion
    
    return sizeProportion < minFontSize ? minFontSize : sizeProportion
  }
  static var weekLabelsFont: UIFont {
    AppFont.font(type: .regular, size: Self.additionalLabelsFontSize)
  }
  static var monthAverageTitleFont: UIFont {
    AppFont.font(type: .regular, size: Self.additionalLabelsFontSize)
  }
  static var monthAverageLabelFont: UIFont {
    AppFont.font(type: .bold, size: Self.additionalLabelsFontSize)
  }
}
