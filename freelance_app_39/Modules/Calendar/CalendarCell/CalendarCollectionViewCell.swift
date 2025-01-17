import UIKit

final class CalendarCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var contentContainer: UIView!
  @IBOutlet weak var componentsContainer: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  
  private lazy var circle = CalendarCellProgressCircle()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    componentsContainer.addSubview(circle)
    circle.fillToSuperview()
  }
  
  func setupCell(with dayModel: DayInformationModel) {
    setupFontTheme()
    setupColorTheme(with: dayModel)
    additionalUISettings(with: dayModel)
    
    dateLabel.text = dayModel.date.toString(withFormat: .day)
    
    setupProgress(to: dayModel.multiplier)
  }
}
//MARK: - Helpers
private extension CalendarCollectionViewCell {
  func setupFontTheme() {
    dateLabel.font = Constants.font
  }
  func setupColorTheme(with dayModel: DayInformationModel) {
    [contentContainer, componentsContainer].forEach {
      $0?.backgroundColor = AppColor.layerTwo
    }
    
    let timezoneHelper = CalendarTimezoneHelper()
    let todayDate = timezoneHelper.convertToUserTimezone(date: Date())
    let todayDateStartOfDay = timezoneHelper.getStartOfDay(date: todayDate)
    
    if dayModel.date.milisecondsSince1970 > todayDateStartOfDay.milisecondsSince1970 {
      dateLabel.textColor = AppColor.layerFour
      
      circle.setInvisibleMode()
    } else {
      dateLabel.textColor = AppColor.layerOne
      
      circle.setVisibleMode()
    }
  }
  func additionalUISettings(with dayModel: DayInformationModel) {
    contentContainer.isHidden = !dayModel.isActiveDate
    dateLabel.isHidden = !dayModel.isActiveDate
  }
}
//MARK: - API
extension CalendarCollectionViewCell {
  func setupProgress(to value: Float) {
    circle.setupProgress(to: value)
  }
}
//MARK: - CalendarCellProgressCircle
private final class CalendarCellProgressCircle: UIView {
  private let backgroundLayer = CAShapeLayer()
  private let bezierLayer = CAShapeLayer()
  private let lineWidth: CGFloat = Constants.lineWidth
  
  private var layerWidth: CGFloat { min(bounds.height, bounds.width) }
  private var circleRadius: CGFloat { (layerWidth - lineWidth) / 2 }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  private func commonInit() {
    // properties common to all layers
    let layers = [backgroundLayer, bezierLayer]
    
    layers.forEach {
      $0.fillColor = UIColor.clear.cgColor
      $0.lineWidth = lineWidth
      $0.lineCap = .round
      
      layer.addSublayer($0)
    }
    
    backgroundLayer.strokeColor = AppColor.accentOne.withAlphaComponent(0.2).cgColor
    
    bezierLayer.strokeColor = AppColor.accentOne.cgColor
    bezierLayer.strokeEnd = 0.01
    
    transform = CGAffineTransformRotate(transform, -(.pi / 2))
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    setupLayersBezier()
  }
  
  private func setupLayersBezier() {
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    
    let circleStartAngle: CGFloat = .zero
    let circleEndAngle: CGFloat = .pi * 2
    
    let path = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: circleStartAngle, endAngle: circleEndAngle, clockwise: true)
    
    bezierLayer.path = path.cgPath
    backgroundLayer.path = path.cgPath
  }
}
//MARK: - CalendarCellProgressCircle API
extension CalendarCellProgressCircle {
  func setupProgress(to value: Float) {
    guard bezierLayer.strokeEnd != CGFloat(value) else { return }
    let animationDuration = isBaseVCAppeared ? Constants.animationDuration : .zero
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = animationDuration
    animation.fromValue = bezierLayer.strokeEnd
    animation.toValue = value
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    bezierLayer.removeAnimation(forKey: "circleAnimation")
    bezierLayer.strokeEnd = CGFloat(value)
    bezierLayer.add(animation, forKey: "circleAnimation")
  }
  
  func setVisibleMode() {
    bezierLayer.fillColor = UIColor.clear.cgColor
    bezierLayer.strokeColor = AppColor.accentOne.cgColor
    
    backgroundLayer.strokeColor = AppColor.accentOne.withAlphaComponent(0.2).cgColor
  }
  func setInvisibleMode() {
    bezierLayer.strokeEnd = 1.0
    bezierLayer.fillColor = AppColor.layerThree.cgColor
    bezierLayer.strokeColor = AppColor.layerThree.cgColor
    
    backgroundLayer.strokeColor = AppColor.layerThree.cgColor
  }
}

//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var lineWidth: CGFloat = 3.0
  
  static var font: UIFont {
    AppFont.font(type: .semiBold, size: 16.sizeProportion)
  }
}
