import UIKit

final class ProgressStepsCircleView: UIView {
  private lazy var rotatedView = ProgressStepsCircleRotatedView(isNonRatatable: false)
  private lazy var staticView = ProgressStepsCircleRotatedView(isNonRatatable: true)
  
  private let minProgress: Double = 0.0
  private let maxProgress: Double = 1.0
  private var progress: Double = 0.0 {
    didSet {
      // keep progress between 0.0 and 1.0
      progress = max(minProgress, min(maxProgress, progress))
      // update layer stroke end
      rotateLayer()
    }
  }
  private var angle: Double { (maxProgress - progress) * .pi }
  
  init() {
    super.init(frame: .zero)
    
    addSubview(rotatedView)
    rotatedView.fillToSuperview()
    
    addSubview(staticView)
    staticView.fillToSuperview()
    
    rotateLayer(animated: false)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func setProgress(_ v: CGFloat, animated: Bool) {
    self.progress = v
  }
  
  private func rotateLayer(animated: Bool = true) {
    UIView.animate(withDuration: animated ? Constants.animationDuration : .zero, delay: .zero, options: [.curveEaseInOut]) {
      self.rotatedView.transform = CGAffineTransform(rotationAngle: -self.angle)
    }
  }
}

//MARK: - ProgressStepsCircleRotatedView
fileprivate final class ProgressStepsCircleRotatedView: ProgressStepsCircleCommonView {
  private let progressLayer = CAShapeLayer()
  private let centerLayer = CAShapeLayer()
  private let rotationLayer = CAShapeLayer()
  
  private let isNonRatatable: Bool
  
  init(isNonRatatable: Bool) {
    self.isNonRatatable = isNonRatatable
    super.init(frame: .zero)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayers() {
    if isNonRatatable {
      customLayers = [rotationLayer, centerLayer]
    } else {
      customLayers = [progressLayer, rotationLayer, centerLayer]
    }
    
  }
  override func commonInitHelper() {
    if !isNonRatatable {
      progressLayer.strokeColor = AppColor.layerOne.cgColor
      progressLayer.fillColor = AppColor.layerOne.cgColor
      progressLayer.lineWidth = layerLineWidth
    }
    
    centerLayer.strokeColor = AppColor.accentOne.cgColor
    centerLayer.fillColor = AppColor.accentOne.cgColor
    centerLayer.lineWidth = layerLineWidth
    
    let appColor = isNonRatatable ? AppColor.accentOne : AppColor.layerSix
    rotationLayer.strokeColor = appColor.cgColor
    rotationLayer.fillColor = appColor.cgColor
    rotationLayer.lineWidth = layerLineWidth
  }
  override func setupLayersBezier() {
    if !isNonRatatable {
      setupProgressLayerBezier()
    }
    
    setupCenterLayerBezier()
    setupBackgroundLayerBezier()
  }
  
  private func setupProgressLayerBezier() {
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    
    let circleRadius = layerWidth / 2 - layerLineWidth
    let circleStartAngle: CGFloat = .pi
    let circleEndAngle: CGFloat = .pi * 2
    
    
    let path = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: circleStartAngle, endAngle: circleEndAngle, clockwise: true)
    
    progressLayer.path = path.cgPath
  }
  private func setupCenterLayerBezier() {
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    
    let circleRadius = layerWidth / 2 - layerLineWidth - lineWidth
    let circleStartAngle: CGFloat = 0
    let circleEndAngle: CGFloat = .pi * 2
    
    let path = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: circleStartAngle, endAngle: circleEndAngle, clockwise: true)
    
    centerLayer.path = path.cgPath
  }
  private func setupBackgroundLayerBezier() {
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    
    let circleRadius = layerWidth / 2 - layerLineWidth
    let circleStartAngle: CGFloat = .pi * 2
    let circleEndAngle: CGFloat = .pi
    
    let path = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: circleStartAngle, endAngle: circleEndAngle, clockwise: true)
    
    let leadingFigurePath = createLeadingFigure()
    let trailingFigurePath = createTrailingFigure()
    
    let resePath = UIBezierPath()
    resePath.append(path)
    resePath.append(leadingFigurePath)
    resePath.append(trailingFigurePath)
    
    if isNonRatatable {
      let additionalPath = UIBezierPath()
      
      let startPoint = CGPoint(x: bounds.maxX - layerLineWidth, y: bounds.midY - lineCornerRadius - layerLineWidth)
      additionalPath.move(to: startPoint)
      
      let cp = CGPoint(x: bounds.maxX, y: bounds.midY - (lineCornerRadius / 2))
      let endPoint = CGPoint(x: bounds.maxX, y: bounds.midY)
      additionalPath.addQuadCurve(to: endPoint, controlPoint: cp)
      
      let hPoint = CGPoint(x: endPoint.x - layerLineWidth, y: endPoint.y)
      additionalPath.addLine(to: hPoint)
      additionalPath.addLine(to: startPoint)
      
      resePath.append(additionalPath)
    }
    
    rotationLayer.path = resePath.cgPath
  }
}

//MARK: - ProgressStepsCircleCommonView
fileprivate class ProgressStepsCircleCommonView: UIView {
  /// The linewidth of this thick arc
  let lineWidth: CGFloat = Constants.lineWidth
  var lineCornerRadius: CGFloat {
    lineWidth / 4
  }
  var straightLineWidth: CGFloat {
    lineWidth - (lineCornerRadius * 2)
  }
  
  let layerLineWidth = 1.0
  
  var processedBounds: CGRect {
    superview?.bounds ?? bounds
  }
  var layerWidth: CGFloat {
    processedBounds.height - (layerLineWidth * 2)
  }
  
  var customLayers: [CAShapeLayer] = []
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  private func commonInit() {
    setupLayers()
    
    // properties common to all layers
    customLayers.forEach { lay in
      lay.fillColor = UIColor.clear.cgColor
      layer.addSublayer(lay)
    }
    
    commonInitHelper()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    setupLayersBezier()
  }
  
  open func setupLayers() {}
  open func commonInitHelper() { }
  open func setupLayersBezier() { }
  
  func createLeadingFigure() -> UIBezierPath {
    let leadingFigurePath = UIBezierPath()
    let leadingFigureLeadingStart = CGPoint(x: bounds.minX + layerLineWidth, y: bounds.midY - lineCornerRadius)
    let leadingFigureLeadingCP = CGPoint(x: bounds.minX + layerLineWidth + (lineCornerRadius / 4), y: bounds.midY - (lineCornerRadius / 4))
    let leadingFigureLeadingEnd = CGPoint(x: bounds.minX + layerLineWidth + lineCornerRadius + layerLineWidth, y: bounds.midY)
    leadingFigurePath.move(to: leadingFigureLeadingStart)
    leadingFigurePath.addQuadCurve(to: leadingFigureLeadingEnd, controlPoint: leadingFigureLeadingCP)
    
    let leadingFigureStraightLineTopEnd = CGPoint(x: leadingFigureLeadingEnd.x + straightLineWidth, y: leadingFigureLeadingEnd.y)
    leadingFigurePath.addLine(to: leadingFigureStraightLineTopEnd)
    
    
    let leadingFigureTrailingCP = CGPoint(x: leadingFigureStraightLineTopEnd.x + (lineCornerRadius * 0.75), y: leadingFigureStraightLineTopEnd.y - (lineCornerRadius / 4))
    let leadingFigureTrailingTopEnd = CGPoint(x: leadingFigureStraightLineTopEnd.x + lineCornerRadius, y: leadingFigureStraightLineTopEnd.y - lineCornerRadius)
    leadingFigurePath.addQuadCurve(to: leadingFigureTrailingTopEnd, controlPoint: leadingFigureTrailingCP)
    
    let leadingFigureTrailingBottomEnd = CGPoint(x: leadingFigureTrailingTopEnd.x, y: leadingFigureTrailingTopEnd.y + lineCornerRadius + layerLineWidth + layerLineWidth + layerLineWidth)
    leadingFigurePath.addLine(to: leadingFigureTrailingBottomEnd)
    
    let leadingFigureLeadingStraightLineEnd = CGPoint(x: leadingFigureTrailingBottomEnd.x - lineWidth - layerLineWidth, y: leadingFigureTrailingBottomEnd.y)
    leadingFigurePath.addLine(to: leadingFigureLeadingStraightLineEnd)
    
    return leadingFigurePath
  }
  func createTrailingFigure() -> UIBezierPath {
    let xPos = bounds.maxX - lineWidth - layerLineWidth - layerLineWidth - layerLineWidth
    
    let leadingFigurePath = UIBezierPath()
    let leadingFigureLeadingStart = CGPoint(x: xPos + layerLineWidth, y: bounds.midY - lineCornerRadius)
    let leadingFigureLeadingCP = CGPoint(x: xPos + layerLineWidth + (lineCornerRadius / 4), y: bounds.midY - (lineCornerRadius / 4))
    let leadingFigureLeadingEnd = CGPoint(x: xPos + layerLineWidth + lineCornerRadius, y: bounds.midY)
    leadingFigurePath.move(to: leadingFigureLeadingStart)
    leadingFigurePath.addQuadCurve(to: leadingFigureLeadingEnd, controlPoint: leadingFigureLeadingCP)
    
    let leadingFigureStraightLineTopEnd = CGPoint(x: leadingFigureLeadingEnd.x + straightLineWidth, y: leadingFigureLeadingEnd.y)
    leadingFigurePath.addLine(to: leadingFigureStraightLineTopEnd)
    
    
    let leadingFigureTrailingCP = CGPoint(x: leadingFigureStraightLineTopEnd.x + (lineCornerRadius * 0.75), y: leadingFigureStraightLineTopEnd.y - (lineCornerRadius / 4))
    let leadingFigureTrailingTopEnd = CGPoint(x: leadingFigureStraightLineTopEnd.x + lineCornerRadius, y: leadingFigureStraightLineTopEnd.y - lineCornerRadius)
    leadingFigurePath.addQuadCurve(to: leadingFigureTrailingTopEnd, controlPoint: leadingFigureTrailingCP)
    
    let leadingFigureTrailingBottomEnd = CGPoint(x: leadingFigureTrailingTopEnd.x, y: leadingFigureTrailingTopEnd.y + lineCornerRadius + layerLineWidth + layerLineWidth + layerLineWidth)
    leadingFigurePath.addLine(to: leadingFigureTrailingBottomEnd)
    
    let leadingFigureLeadingStraightLineEnd = CGPoint(x: leadingFigureTrailingBottomEnd.x - lineWidth - layerLineWidth, y: leadingFigureTrailingBottomEnd.y)
    leadingFigurePath.addLine(to: leadingFigureLeadingStraightLineEnd)
    
    return leadingFigurePath
  }
}

//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var lineWidth: CGFloat {
    let maxWidth = 32.0
    let minWidth = 24.0
    let proportionWidth = maxWidth.sizeProportion
    
    return proportionWidth < minWidth ? minWidth : proportionWidth
  }
}
