//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension UIView {
    
    // 360度旋转图片
    func hAnimat_rotate360Degree() {
        // 让其在z轴旋转
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        // 旋转角度
        rotationAnimation.toValue = NSNumber(value: M_PI * 2.0)
        // 动画持续时间
        rotationAnimation.duration = 0.5
        // 旋转累加角度
        rotationAnimation.isCumulative = true
        // 旋转次数
        rotationAnimation.repeatCount = 1
        layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    // 停止旋转
    func stopRotate() {
        layer.removeAllAnimations()
    }
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 40, height: 40)
        label.text = "A"
        label.textColor = .black
        label.backgroundColor = .red
        label.textAlignment = .center
        
        view.addSubview(label)
        
//        label.hAnimat_rotate360Degree()


        let opt : UIView.AnimationOptions = [.curveEaseIn]
        UIView.animate(withDuration: 2, delay: 0 ,options: opt , animations: {
            label.transform = CGAffineTransform.identity.rotated(by: .pi * 2 )
            
        }, completion: { Bool in
            
          
        })
        

        
        self.view = view
    }
    
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
