import Foundation

extension UserDefaults {
  enum CodingKeys {
    static let isWelcomeAlreadyAppeadred = "isWelcomeAlreadyAppeadred"
    
    static let stepGoal = "stepGoal"
    static let kCalGoal = "kCalGoal"
    
    static let maxStepsPerDay = "maxStepsPerDay"
    
    static let gender = "gender"
    static let heightCM = "heightCM"
    static let stepLenghtCM = "stepLenghtCM"
    static let weightKG = "weightKG"
    static let metricAndImperialUnit = "metricAndImperialUnit"
  }
  
  var isWelcomeAlreadyAppeadred: Bool {
    get { return bool(forKey: CodingKeys.isWelcomeAlreadyAppeadred) }
    set { set(newValue, forKey: CodingKeys.isWelcomeAlreadyAppeadred) }
  }
  
  var stepGoal: Int {
    get { return integer(forKey: CodingKeys.stepGoal) }
    set { set(newValue, forKey: CodingKeys.stepGoal) }
  }
  var kCalGoal: Int {
    get { return integer(forKey: CodingKeys.kCalGoal) }
    set { set(newValue, forKey: CodingKeys.kCalGoal) }
  }
  
  var maxStepsPerDay: Int {
    get { return integer(forKey: CodingKeys.maxStepsPerDay) }
    set { set(newValue, forKey: CodingKeys.maxStepsPerDay) }
  }
  
  var gender: String? {
    get { return string(forKey: CodingKeys.gender) }
    set { set(newValue, forKey: CodingKeys.gender) }
  }
  var heightCM: Int? {
    get { return integer(forKey: CodingKeys.heightCM) }
    set { set(newValue, forKey: CodingKeys.heightCM) }
  }
  var stepLenghtCM: Int? {
    get { return integer(forKey: CodingKeys.stepLenghtCM) }
    set { set(newValue, forKey: CodingKeys.stepLenghtCM) }
  }
  var weightKG: Int? {
    get { return integer(forKey: CodingKeys.weightKG) }
    set { set(newValue, forKey: CodingKeys.weightKG) }
  }
  var metricAndImperialUnit: String {
    get { return string(forKey: CodingKeys.metricAndImperialUnit) ?? MetricAndImperialUnitType.kgAndcm.title }
    set { set(newValue, forKey: CodingKeys.metricAndImperialUnit) }
  }
}
