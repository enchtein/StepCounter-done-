import UIKit

final class CustomSegmentedControl: UISegmentedControl {
  private let segmentInset: CGFloat = 5 //your inset amount
  private let segmentImage: UIImage? = UIImage(color: AppColor.layerOne) //your color
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    //remove background images
    let imageViews = subviews.filter({ $0 is UIImageView }).compactMap({ $0 as? UIImageView })
    for imageView in Array(imageViews[..<numberOfSegments]) {
      imageView.isHidden = true
    }
    
    //background
    layer.cornerRadius = bounds.height/2
    //foreground
    let foregroundIndex = numberOfSegments
    
    if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
      foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
      foregroundImageView.image = segmentImage    //substitute with our own colored image
      foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")    //this removes the weird scaling animation!
      foregroundImageView.layer.masksToBounds = true
      foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height/2
    }
  }
}

fileprivate extension UIImage {
  //creates a UIImage given a UIColor
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
