import UIKit

final class MainViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var topBackgroundView: UIView!
  
  @IBOutlet weak var topViewContainer: UIView!
  @IBOutlet weak var topViewContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var activitySegmentControlContainer: UIView!
  @IBOutlet weak var activitySegmentControl: CustomSegmentedControl!
  @IBOutlet weak var activitySegmentControlTop: NSLayoutConstraint!
  @IBOutlet weak var activitySegmentControlLeading: NSLayoutConstraint!
  @IBOutlet weak var activitySegmentControlBottom: NSLayoutConstraint!
  @IBOutlet weak var activitySegmentControlHeight: NSLayoutConstraint!
  
  @IBOutlet weak var activityContainer: UIView!
  @IBOutlet weak var activityContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var indicatorCardsContainer: UIView!
  @IBOutlet weak var indicatorCardsContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var indicatorCardsContainerLeading: NSLayoutConstraint!
  @IBOutlet weak var indicatorCardsHStack: UIStackView!
  
  @IBOutlet weak var informationContainer: UIView!
  @IBOutlet weak var informationContainerToIndicatorCardsContainerTop: NSLayoutConstraint! //active on start
  @IBOutlet weak var informationContainerToTopBackgroundViewTop: NSLayoutConstraint! //inActive on start
  @IBOutlet weak var informationContainerBottom: NSLayoutConstraint!
  
  private lazy var navPanel = CommonNavPanel(type: .main, delegate: self)
  
  private lazy var todayView = StepsScoreView(type: .today, delegate: self)
  private lazy var todayViewLeading: NSLayoutConstraint = createTodayViewLeading()
  private lazy var todayViewBottom: NSLayoutConstraint = createTodayViewBottom()
  
  private lazy var monthView = StepsScoreView(type: .month, delegate: self)
  
  private var allIndicatorCards: [IndicatorCard] {
    indicatorCardsHStack.arrangedSubviews.compactMap { $0 as? IndicatorCard }
  }
  
  private lazy var lastSevenDaysInformationViewContainer = createLastSevenDaysInformationViewContainer()
  private lazy var lastSevenDaysVC = LastSevenDaysViewController.createFromStoryboardHelper(for: .step)
  private lazy var lastSevenDaysInformationViewContainerLeading: NSLayoutConstraint = createLastSevenDaysInformationViewContainerLeading()
  
  private lazy var calendarViewContainer = createCalendarViewContainer()
  private lazy var calendarVC = CalendarViewController.createFromStoryboard()
  
  private lazy var viewModel = MainViewModel(delegate: self)
  
  private lazy var denyNotifyingView = DenyHealthKitActivitiesNotifyingView(delegate: self)
  private lazy var denyNotifyingViewTopAnchor = createDenyNotifyingViewTopAnchor()
  private var denyNotifyingTimer: Timer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    viewModel.viewDidLoad()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !HealthKitService.shared.isActivityTypesAvailable {
      denyNotifyingView(isShow: true) { [weak self] in
        self?.scheduleDenyNotifyingTimer()
      }
    }
  }
  
  override func addUIComponents() {
    activityContainer.addSubview(todayView)
    activityContainer.addSubview(monthView)
    
    for type in IndicatorCardType.allCases {
      let cardView = IndicatorCard(cardType: type, delegate: self)
      indicatorCardsHStack.addArrangedSubview(cardView)
    }
    
    indicatorCardsContainerHeight.isActive = false
    
    informationContainer.addSubview(lastSevenDaysInformationViewContainer)
    informationContainer.addSubview(calendarViewContainer)
    
    topViewContainerHeight.isActive = false
    topViewContainer.addSubview(navPanel)
    navPanel.fillToSuperview()
    
    addChild(lastSevenDaysVC)
    lastSevenDaysInformationViewContainer.addSubview(lastSevenDaysVC.view)
    lastSevenDaysVC.view.fillToSuperview()
    lastSevenDaysVC.didMove(toParent: self)
    
    addChild(calendarVC)
    calendarViewContainer.addSubview(calendarVC.view)
    calendarVC.view.fillToSuperview()
    calendarVC.didMove(toParent: self)
    
    view.addSubview(denyNotifyingView)
    denyNotifyingView.translatesAutoresizingMaskIntoConstraints = false
    denyNotifyingViewTopAnchor.isActive = true
    denyNotifyingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.baseSideIndent).isActive = true
    denyNotifyingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.baseSideIndent).isActive = true
  }
  override func setupColorTheme() {
    [topBackgroundView, topViewContainer, activitySegmentControlContainer, activityContainer].forEach {
      $0?.backgroundColor = AppColor.accentOne
    }
    
    indicatorCardsContainer.backgroundColor = .clear
    
    activitySegmentControl.setTitleTextAttributes([.font: Constants.selectedSegmentControlFont, .foregroundColor: AppColor.accentOne], for: .selected)
    activitySegmentControl.setTitleTextAttributes([.font: Constants.normalSegmentControlFont, .foregroundColor: AppColor.layerOne], for: .normal)
    activitySegmentControl.backgroundColor = AppColor.layerSix
    
    informationContainer.backgroundColor = AppColor.backgroundOne
    lastSevenDaysInformationViewContainer.backgroundColor = AppColor.layerTwo
  }
  override func setupLocalizeTitles() {
    activitySegmentControl.setTitle(MainTitles.today.localized, forSegmentAt: 0)
    activitySegmentControl.setTitle(MainTitles.month.localized, forSegmentAt: 1)
  }
  override func setupConstraintsConstants() {
    activitySegmentControlTop.constant = Constants.activitySegmentControlTop
    activitySegmentControlLeading.constant = Constants.baseSideIndent
    activitySegmentControlBottom.constant = Constants.activitySegmentControlBottom
    activitySegmentControlHeight.constant = Constants.activitySegmentControlHeight
    
    todayView.translatesAutoresizingMaskIntoConstraints = false
    todayView.topAnchor.constraint(equalTo: activityContainer.topAnchor).isActive = true
    todayViewLeading.isActive = true
    todayView.widthAnchor.constraint(equalTo: activityContainer.widthAnchor).isActive = true
    
    monthView.translatesAutoresizingMaskIntoConstraints = false
    monthView.leadingAnchor.constraint(equalTo: todayView.trailingAnchor).isActive = true
    monthView.centerYAnchor.constraint(equalTo: todayView.centerYAnchor).isActive = true
    monthView.widthAnchor.constraint(equalTo: activityContainer.widthAnchor).isActive = true
    
    indicatorCardsContainerLeading.constant = Constants.baseSideIndent
    
    
    lastSevenDaysInformationViewContainer.translatesAutoresizingMaskIntoConstraints = false
    lastSevenDaysInformationViewContainer.topAnchor.constraint(equalTo: informationContainer.topAnchor).isActive = true
    lastSevenDaysInformationViewContainerLeading.isActive = true
    lastSevenDaysInformationViewContainer.bottomAnchor.constraint(equalTo: informationContainer.bottomAnchor).isActive = true
    lastSevenDaysInformationViewContainer.widthAnchor.constraint(equalTo: informationContainer.widthAnchor, constant: -Constants.informationContainerSubViewWidthIndent).isActive = true
    
    calendarViewContainer.translatesAutoresizingMaskIntoConstraints = false
    calendarViewContainer.topAnchor.constraint(equalTo: informationContainer.topAnchor).isActive = true
    let calendarViewContainerLeading = NSLayoutConstraint(item: calendarViewContainer, attribute: .leading, relatedBy: .equal, toItem: lastSevenDaysInformationViewContainer, attribute: .trailing, multiplier: 1.0, constant: Constants.baseSideIndent)
    calendarViewContainerLeading.priority = UILayoutPriority(998)
    calendarViewContainerLeading.isActive = true
    calendarViewContainer.bottomAnchor.constraint(equalTo: informationContainer.bottomAnchor).isActive = true
    calendarViewContainer.widthAnchor.constraint(equalTo: informationContainer.widthAnchor, constant: -Constants.informationContainerSubViewWidthIndent).isActive = true
    
    updateConstaintsOnSegmentChange()
  }
  override func additionalUISettings() {
    topBackgroundView.roundCorners([.bottomLeft, .bottomRight], radius: Constants.baseCornerRadius)
    
    indicatorCardsHStack.spacing = 12.0 // fixed
    indicatorCardsHStack.distribution = .fillEqually
    
    calendarViewContainer.cornerRadius = Constants.baseCornerRadius
    calendarViewContainer.layer.borderColor = AppColor.layerThree.cgColor
    calendarViewContainer.layer.borderWidth = 1.0
  }
  
  
  @IBAction func activitySegmentControlAction(_ sender: UISegmentedControl) {
    guard let activeType = ActivityType(rawValue: activitySegmentControl.selectedSegmentIndex) else { return }
    viewModel.updateActivityType(to: activeType) //1
    
    updateCalendarPropertiesIfNeeded() //2
    updateConstaintsOnSegmentChange() //3
    updateDenyNotifyingViewPositionIffNeeded() //4
    updateStepsScoreViewElementsVisability() //5
  }
}
//MARK: - UI NSLayoutConstraint creating
private extension MainViewController {
  func createTodayViewLeading() -> NSLayoutConstraint {
    NSLayoutConstraint(item: todayView, attribute: .leading, relatedBy: .equal,
                       toItem: activityContainer, attribute: .leading,
                       multiplier: 1.0, constant: .zero)
  }
  func createTodayViewBottom() -> NSLayoutConstraint {
    NSLayoutConstraint(item: todayView, attribute: .bottom, relatedBy: .equal,
                       toItem: activityContainer, attribute: .bottom,
                       multiplier: 1.0, constant: .zero)
  }
  func createLastSevenDaysInformationViewContainerLeading() -> NSLayoutConstraint {
    NSLayoutConstraint(item: lastSevenDaysInformationViewContainer, attribute: .leading, relatedBy: .equal,
                       toItem: informationContainer, attribute: .leading,
                       multiplier: 1.0, constant: Constants.baseSideIndent)
  }
  func createDenyNotifyingViewTopAnchor() -> NSLayoutConstraint {
    NSLayoutConstraint(item: denyNotifyingView, attribute: .top, relatedBy: .equal,
                       toItem: view, attribute: .bottom,
                       multiplier: 1.0, constant: .zero)
  }
}
extension MainViewController: StepsScoreViewDelegate {
  func layoutDidChangeHeight(to value: CGFloat, for view: StepsScoreView) {
    guard let activeType = ActivityType(rawValue: activitySegmentControl.selectedSegmentIndex) else { return }
    
    let activeTypeView: StepsScoreView
    switch activeType {
    case .today:
      activeTypeView = todayView
    case .month:
      activeTypeView = monthView
    }
    
    guard activeTypeView === view else { return }
    activityContainerHeight.constant = value
    if !todayViewBottom.isActive {
      todayViewBottom.isActive = true
    }
  }
  func shareButtonAction() {
    self.getScreenshotAndShare()
  }
}

//MARK: - UI Helpers
private extension MainViewController {
  func createLastSevenDaysInformationViewContainer() -> UIView {
    let view = UIView()
    view.backgroundColor = .red
    return view
  }
  func createCalendarViewContainer() -> UIView {
    let view = UIView()
    view.backgroundColor = .green
    return view
  }
  
  func updateConstaintsOnSegmentChange() {
    switch viewModel.activityType {
    case .today:
      informationContainerToTopBackgroundViewTop.isActive = false
      informationContainerToIndicatorCardsContainerTop.isActive = true
      informationContainerBottom.constant = safeArea.bottom + Constants.todayInformationContainerBottom
      lastSevenDaysInformationViewContainerLeading.constant = Constants.baseSideIndent
    case .month:
      informationContainerToIndicatorCardsContainerTop.isActive = false
      informationContainerToTopBackgroundViewTop.isActive = true
      informationContainerBottom.constant = safeArea.bottom + Constants.monthInformationContainerBottom
      lastSevenDaysInformationViewContainerLeading.constant = -(informationContainer.frame.width - Constants.informationContainerSubViewWidthIndent)
    }
  }
  func updateStepsScoreViewElementsVisability() {
    let activeType = viewModel.activityType
    
    let activeTypeView: StepsScoreView
    switch activeType {
    case .today:
      todayViewLeading.constant = .zero
      activeTypeView = todayView
    case .month:
      todayViewLeading.constant = -activityContainer.frame.width
      activeTypeView = monthView
    }
    
    if activeType != .today {
      todayView.setupSnapshot()
    }
    
    activityContainerHeight.constant = activeTypeView.defaultHeight
    
    UIView.animate(withDuration: Constants.animationDuration, delay: 0) {
      self.todayView.layoutLabelsIfNeeded(isHide: activeType != .today)
      self.view.layoutIfNeeded()
    }
  }
  
  func updateCalendarPropertiesIfNeeded() {
    guard viewModel.activityType == .month else { return }
    calendarVC.isCalendarAppeared = true
  }
}
//MARK: - UI Helpers (DenyNotifyingView)
private extension MainViewController {
  func scheduleDenyNotifyingTimer() {
    denyNotifyingTimer?.invalidate()
    denyNotifyingTimer = nil
    
    denyNotifyingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
      self?.denyNotifyingView(isShow: false)
      self?.denyNotifyingView.didDisappear()
    }
  }
  func denyNotifyingView(isShow: Bool, endCompletion: (() -> Void)? = nil) {
    guard !denyNotifyingView.isWasShowedInAppLifeCycle else { return }
    
    var visibleIndent = denyNotifyingView.frame.height
    switch viewModel.activityType {
    case .today: visibleIndent += safeArea.bottom + Constants.todayInformationContainerBottom
    case .month: visibleIndent += safeArea.bottom + Constants.monthInformationContainerBottom
    }
    
    denyNotifyingViewTopAnchor.constant = isShow ? -visibleIndent : .zero
    UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .curveEaseInOut) {
      self.view.layoutIfNeeded()
    } completion: { _ in
      endCompletion?()
    }
  }
  
  func updateDenyNotifyingViewPositionIffNeeded() {
    guard denyNotifyingViewTopAnchor.constant != .zero else { return }
    denyNotifyingView(isShow: true)
  }
}
//MARK: - IndicatorCardDelegate
extension MainViewController: IndicatorCardDelegate {
  func didSelectCard(with type: IndicatorCardType) {
    let vc = DetailedStatisticsViewController.createFromNib(type: type.hkType, height: lastSevenDaysInformationViewContainer.frame.height, bottomIndent: informationContainerBottom.constant)
    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = self
    
    present(vc, animated: true)
  }
}
extension MainViewController: MainViewModelDelegate {
  func activeEnergyBurnedForTodayDidChange(to value: Int) {
    activeEnergyBurnedDidChange(to: Float(value), for: .today)
  }
  
  func stepCountForTodayDidChange(to value: Int) {
    stepCountDidChange(to: Float(value), for: .today)
  }
  
  func distanceWalkingRunningForTodayDidChange(to value: Double) {
    distanceWalkingRunningDidChange(to: Float(value), for: .today)
  }
  
  func exerciseTimeForTodayDidChange(to value: Double) {
    exerciseTimeDidChange(to: Float(value), for: .today)
  }
  
  func calendarWillAppear() {
    calendarVC.calendarWillAppear()
  }
}
//MARK: - API
extension MainViewController {
  func stepCountDidChange(to value: Float, for activityType: ActivityType) {
    switch activityType {
    case .today:
      todayView.updateValue(to: Int(value))
    case .month:
      monthView.updateValue(to: Int(value))
    }
  }
  func activeEnergyBurnedDidChange(to value: Float, for activityType: ActivityType) {
    guard viewModel.activityType == activityType else { return }
    
    allIndicatorCards.filter { $0.cardType == .kCal }.forEach {
      $0.updateValue(to: Int(value), for: activityType)
    }
  }
  func distanceWalkingRunningDidChange(to value: Float, for activityType: ActivityType) {
    guard viewModel.activityType == activityType else { return }
    
    allIndicatorCards.filter { $0.cardType == .km }.forEach {
      $0.updateValue(to: Double(value), for: activityType)
    }
  }
  func exerciseTimeDidChange(to value: Float, for activityType: ActivityType) {
    guard viewModel.activityType == activityType else { return }
    
    allIndicatorCards.filter { $0.cardType == .hour }.forEach {
      $0.updateValue(to: Double(value), for: activityType)
    }
  }
  
  func goalsDidChange() { //changed from goals VC
    stepCountDidChange(to: Float(viewModel.stepsForToday), for: .today)
    activeEnergyBurnedDidChange(to: Float(viewModel.kCalForToday), for: .today)
  }
}
//MARK: - CommonNavPanelDelegate
extension MainViewController: CommonNavPanelDelegate {
  func achievementsButtonAction() {
    AppCoordinator.shared.push(.achievements)
  }
  func settingsButtonAction() {
    AppCoordinator.shared.push(.settings)
  }
}

//MARK: - UIViewControllerTransitioningDelegate
extension MainViewController: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    DetailedStatisticsPresentationController(presentedViewController: presented, presenting: presenting)
  }
}

//MARK: - DenyHealthKitActivitiesNotifyingViewDelegate
extension MainViewController: DenyHealthKitActivitiesNotifyingViewDelegate {
  func goToProfileAction() {
    AppCoordinator.shared.push(.profileSettings)
  }
}

enum ActivityType: Int {
  case today = 0
  case month
}
fileprivate struct Constants: CommonSettings {
  static var activitySegmentControlTop: CGFloat {
    let indent = 6.0
    return indent.sizeProportion
  }
  static var activitySegmentControlBottom: CGFloat {
    let indent = 12.0
    return indent.sizeProportion
  }
  static var activitySegmentControlHeight: CGFloat {
    let height = 44.0
    let minHeight = 34.0
    let proportionHeight = height.sizeProportion
    return proportionHeight < minHeight ? minHeight : proportionHeight
  }
  
  static let selectedSegmentControlFont = AppFont.font(type: .bold, size: 14.0)
  static let normalSegmentControlFont = AppFont.font(type: .regular, size: 14.0)
  
  static var informationContainerSubViewWidthIndent: CGFloat { baseSideIndent * 2 }
  
  static var todayInformationContainerBottom: CGFloat {
    let maxValue = 8.0
    let proportionValue = maxValue.sizeProportion
    return proportionValue > maxValue ? maxValue : proportionValue
  }
  static var monthInformationContainerBottom: CGFloat {
    let maxValue = 21.0
    let proportionValue = maxValue.sizeProportion
    return proportionValue > maxValue ? maxValue : proportionValue
  }
}
