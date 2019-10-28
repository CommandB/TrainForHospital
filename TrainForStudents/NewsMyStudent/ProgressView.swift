import UIKit

struct ProgressProgerty {
    var width : CGFloat?
    var trackColor : UIColor?
    var progressColor : UIColor?
    var progressStart : CGFloat?
    var progressEnd : CGFloat?
    
    init(width:CGFloat, progressEnd:CGFloat, progressColor:UIColor) {
        self.width = width
        self.progressEnd = progressEnd
        self.progressColor = progressColor
        trackColor = UIColor.clear
        progressStart = 0.0
    }
    
    init() {
        width = 5
        trackColor = UIColor.clear
        progressColor = UIColor.white
        progressStart = 0.0
        progressEnd = 1
    }
    
}

class ProgressView: UIView {
    var progressProperty = ProgressProgerty.init()
    private let progressLayer = CAShapeLayer()
    var labeltext = "100%"
    init(propressProperty:ProgressProgerty,frame:CGRect,processLabelText:String) {
        self.progressProperty = propressProperty
        labeltext = processLabelText
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.clear
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height))
        label.textAlignment = .center
        label.text = labeltext
        label.textColor = UIColor.white
        label.font = UIFont.init(name: "PingFangSC-Medium", size: 16)
        self.addSubview(label)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath.init(ovalIn: bounds).cgPath
        let tracklayer = CAShapeLayer()
        tracklayer.frame = bounds
        tracklayer.fillColor = UIColor.clear.cgColor
        tracklayer.strokeColor = UIColor.cyan.cgColor
        tracklayer.lineWidth = progressProperty.width!
        tracklayer.path = path
        layer.addSublayer(tracklayer)
        
        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressProperty.progressColor?.cgColor
        progressLayer.lineWidth = progressProperty.width!
        progressLayer.path = path
        progressLayer.strokeStart = progressProperty.progressStart!
        progressLayer.strokeEnd = progressProperty.progressEnd!
        layer.addSublayer(progressLayer)
    }
    
    func setProgress(progress:CGFloat,time:CFTimeInterval,animate:Bool){
        CATransaction.begin()
        CATransaction.setDisableActions(!animate)
        CATransaction.setAnimationDuration(time)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut))
        progressLayer.strokeEnd = progress
        CATransaction.commit()
    }
    
}
