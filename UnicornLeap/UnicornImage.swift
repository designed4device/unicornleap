import Cocoa
import CoreMedia

class UnicornImage: LeapImage {
    
  var size: NSSize!
  var eccentricity: Float!
  let path = CGMutablePath()
  let layer = CALayer()

  init?(filename: String, eccentricity: Float) {
    super.init(filename: filename)

//    guard let size = NSImage(contentsOfFile: filename)?.size else { return nil }
    self.size = NSSize(width: 1100, height: 300)
    self.eccentricity = eccentricity

    configurePath()
    configureLayer()
  }

  func addAnimation(_ seconds: Double, animationDelay: Double) {
    super.addAnimation(seconds, path: path, layer: layer, animationDelay: animationDelay)
  }

  fileprivate func configurePath() {
    if let screen = NSScreen.main {
        let origin = CGPoint(x: -size.width, y: -size.height)
        let destination = CGPoint(x: screen.frame.size.width + size.width, y: origin.y)
        let midpoint = (destination.x + origin.x) / 2.0
        let peak = size.height + screen.frame.size.height * CGFloat(eccentricity) / 3.0
        let curvePeak = CGPoint(x: midpoint, y: peak)
        
        path.move(to: origin)
        path.addCurve(to: destination, control1: curvePeak, control2: curvePeak)
    }
  }

  fileprivate func configureLayer() {
    layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    layer.position = CGPoint(x: -size.width, y: -size.height)
    
    let label = CATextLayer()
    label.font = CTFontCreateWithName(kCMTextMarkupGenericFontName_MonospaceSansSerif, 0, nil)
    label.frame = layer.bounds
    label.fontSize = 250
    label.string = ""
    label.foregroundColor = CGColor.init(red: 100, green: 0, blue: 0, alpha: 100)
    label.alignmentMode = CATextLayerAlignmentMode.center
    label.backgroundColor = CGColor(red: 0.2, green: 0.2,  blue: 0.2, alpha: 0.7)
    
    
    let now = Date()
    let day = Calendar.current.component(.day, from: now)
    let month = Calendar.current.component(.month, from: now)
    let year = Calendar.current.component(.year, from: now)
    let eightOhSix = DateComponents(
        calendar: Calendar.current,
        year: year,
        month: month,
        day: day,
        hour:8,
        minute: 6)
        .date ?? Date()
    
    if (now < eightOhSix) {
        if #available(OSX 10.12, *) {
            let duration = DateInterval(start: now, end: eightOhSix).duration
            
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .none
            let totalSeconds = Int(duration.description.split(separator: ".")[0])!
            let seconds = String(totalSeconds % 60)
            let minutes = String(totalSeconds / 60 % 60)
            let hours = String(totalSeconds / 60 / 60)
            label.string = "\(hours.pad()):\(minutes.pad()):\(seconds.pad())"
        }
    } else if (now < eightOhSix.addingTimeInterval(TimeInterval(exactly: 30)!)) {
        label.string = "hit the gong!"
    }
    
    layer.addSublayer(label)
  }
}

extension String {
    func pad() -> String {
        if (self.count < 2) {
            return "0\(self)"
        }
        return self
    }
}
