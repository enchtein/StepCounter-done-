import Foundation

enum ProfileSettingsTitles: String, Localizable {
  case title
  
  //ProfileSettingsType
  case gender
  case height
  case stepLength
  case weight
  case metric
  
  //Gender
  case man
  case woman
  case nonbinary
  
  //MetricAndImperialUnit
  case poundAndft
  case kgAndcm
  
  case pound
  case ft
  case kg
  case cm
  
  case notSelected
  
  case genderAlertMsg
  case metricAlertMsg
  
  case bodyTypeDescriptionMsg
  case bodyTypeHelperMsg
}
