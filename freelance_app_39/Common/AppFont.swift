import UIKit

enum FontType {
  case regular
  case semiBold
  case bold
  
  case regular_sf_pro
  case semiBold_sf_pro
  
  fileprivate var type: String {
    switch self {
    case .regular: "OpenSans-Regular" //400
    case .semiBold: "OpenSans-SemiBold" //600
    case .bold: "OpenSans-Bold" //700
      
    case .regular_sf_pro: "SFProDisplay-Regular" //400
    case .semiBold_sf_pro: "SFProDisplay-Semibold" //600
    }
  }
}

struct AppFont {
  static func font(type: FontType, size: CGFloat) -> UIFont {
    UIFont(name: type.type, size: CGFloat(size)) ?? UIFont.systemFont(ofSize: CGFloat(size))
  }
  static func font(type: FontType, size: Int) -> UIFont {
    font(type: type, size: CGFloat(size))
  }
}
