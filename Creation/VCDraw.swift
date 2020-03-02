//
//  VCDraw.swift
//  Creation
//
//  Created by Nazar Khatsko on 1/28/20.
//  Copyright © 2020 Nazar Khatsko. All rights reserved.
//

import UIKit

class VCDraw: UIViewController {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imagePicture: UIImageView!
        
    @IBOutlet weak var viewPicture: UIView!
    
    @IBOutlet weak var viewSizes: UIView!
    @IBOutlet weak var labelSizeLine: UILabel!
    @IBOutlet weak var labelSizeAlpha: UILabel!
    
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var labelColor: UILabel!
    
    @IBOutlet weak var viewTools: UIView!
    @IBOutlet weak var buttonPen: UIButton!
    @IBOutlet weak var buttonBrush: UIButton!
    @IBOutlet weak var buttonIngot: UIButton!
    
    @IBOutlet weak var buttonSizes: UIButton!
    @IBOutlet weak var buttonColor: UIButton!
    @IBOutlet weak var buttonTools: UIButton!
    
    var imagePicker = UIImagePickerController()
    var lastPoint:CGPoint = CGPoint.zero
    var swiped:Bool = false
    var RGB:[CGFloat] = [0, 0, 0] // red green blue
    var LA:[CGFloat] = [10, 100] // line alpha
    var PBI:CGLineCap = .round // pen brush ingot
    
    var names:[String] = []
    var pictures:[NSData] = []
    var index:Int = 0
        
    @IBAction func buttonsRotateAction_TouchUp(_ sender: UIButton) {
        imagePicture.image = imagePicture.image!.rotate(radians: CGFloat(Double(sender.tag) * (Double.pi / 2)))
    }
    
    @IBAction func buttonPicturesAction_TouchUp(_ sender: UIButton) {
        viewPicture.isHidden = viewPicture.isHidden ? false : true
    }
    
    @IBAction func buttonsPicturesAction_TouchUp(_ sender: UIButton) {
        if sender.tag == 0 { // download
            if let image = imagePicture.image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        } else if sender.tag == 1 { // unpload
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else if sender.tag == 2 { // save
            let picture:NSData = imagePicture.image!.pngData()! as NSData
            pictures[index] = picture
            UserDefaults.standard.set(pictures, forKey: "key_pictures")
            UserDefaults.standard.synchronize()
        } else if sender.tag == 3 { // clear
            imagePicture.image = #imageLiteral(resourceName: "null")
            imagePicture.backgroundColor = .clear
        } else if sender.tag == 4 { // share
            let activityVC = UIActivityViewController(activityItems: [imagePicture.image as Any], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.viewPicture
            self.present(activityVC, animated: true, completion: nil)
        }
    }
   
    @IBAction func buttonsOptionsAction_TouchUp(_ sender: UIButton) {
        let views:[UIView] = [viewSizes, viewColor, viewTools]
        let buttons:[UIButton] = [buttonSizes, buttonColor, buttonTools]
        let images:[[UIImage]] = [[#imageLiteral(resourceName: "sizes-on"), #imageLiteral(resourceName: "sizes-off")], [#imageLiteral(resourceName: "color-on"), #imageLiteral(resourceName: "color-off")], [#imageLiteral(resourceName: "tools-on"), #imageLiteral(resourceName: "tools-off")]]

        for i in 0...views.count - 1 {
            if i != sender.tag {
                views[i].isHidden = true
                buttons[i].setImage(images[i][1], for: .normal)
                buttons[i].backgroundColor = .clear
            } else {
                views[i].isHidden = views[i].isHidden ? false : true
                buttons[i].currentImage == images[i][0] ? buttons[i].setImage(images[i][1], for: .normal) : buttons[i].setImage(images[i][0], for: .normal)
                buttons[i].backgroundColor = buttons[i].backgroundColor == .clear ? .black : .clear
            }
        }
    }
    
    @IBAction func slidersColorAction_TouchUp(_ sender: UISlider) {
        RGB[sender.tag] = CGFloat(sender.value)
        labelColor.text = "rgb(\(Int(RGB[0])), \(Int(RGB[1])), \(Int(RGB[2])))"
    }
    
    @IBAction func slidersSizesAction_TouchUp(_ sender: UISlider) {
        LA[sender.tag] = CGFloat(sender.value)
        labelSizeLine.text = "\(Int(LA[0]))%"
        labelSizeAlpha.text = "\(Int(LA[1]))%"
    }
    
    @IBAction func buttonsToolsAction_TouchUp(_ sender: UIButton) {
        let buttons:[UIButton] = [buttonPen, buttonBrush, buttonIngot]
        let images:[[UIImage]] = [[#imageLiteral(resourceName: "pen-off"), #imageLiteral(resourceName: "pen-on")], [#imageLiteral(resourceName: "brush-off"), #imageLiteral(resourceName: "brush-on")], [#imageLiteral(resourceName: "ingot-off"), #imageLiteral(resourceName: "ingot-on")]]
        let tools:[CGLineCap] = [.round, .square, .butt]

        for i in 0...buttons.count - 1 {
            if i != sender.tag {
                buttons[i].setImage(images[i][0], for: .normal)
            } else {
                buttons[i].setImage(images[i][1], for: .normal)
                PBI = tools[i]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelName.text = names[index]
        imagePicture.image = UIImage(data: pictures[index] as Data)!
    }
}

extension VCDraw: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        
        if let touch = touches.first {
            lastPoint = touch.location(in: self.imagePicture)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.imagePicture)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let value = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { imagePicture.image = value }
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    
    func drawLines(fromPoint:CGPoint, toPoint:CGPoint) {
        UIGraphicsBeginImageContext(self.imagePicture.frame.size)
        imagePicture.image?.draw(in: CGRect(x: 0, y: 0, width: self.imagePicture.frame.width, height: self.imagePicture.frame.height))
        
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(PBI)
        context?.setLineWidth(LA[0])
        context?.setStrokeColor(UIColor(red: RGB[0], green: RGB[1], blue: RGB[2], alpha: (LA[1] / 100)).cgColor)
        context?.strokePath()
        
        imagePicture.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: (rotatedSize.width / 2), y: (rotatedSize.height / 2))
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
