import UIKit

class HudView:UIView{
    var text:String = ""
    
    class func hud(view:UIView, animated:Bool)->HudView{
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        hudView.show(animated: animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let width:CGFloat = 100
        let height:CGFloat = 100
        
        let rect = CGRect(x: bounds.size.width/2 - width/2,
                          y: bounds.size.height/2 - height/2,
                          width: width,
                          height: height)
        let filletCorner = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        UIColor(white: 0.2, alpha: 0.5).setFill()
        filletCorner.fill()
        
        guard let image = UIImage(named: "Checkmark") else {return}
        let imagePoint = CGPoint(x: center.x - image.size.width/2,
                                     y: center.y - image.size.height/2 - height/8)
        image.draw(at: imagePoint)
        
        let attribs = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16),
                       NSAttributedString.Key.foregroundColor:UIColor.white]
        let textSize = text.size(withAttributes: attribs)
        let textPoint = CGPoint(
            x: center.x - textSize.width/2,
            y: center.y - textSize.height/2 + height/4)
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    func show(animated:Bool){
        if animated{
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3){
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }
        }
    }
}
