//
//  Helper.swift
//  meme
//
//  Created by SOTSYS024 on 20/10/16.
//  Copyright © 2016 SOTSYS024. All rights reserved.
//
import UIKit
import Foundation

enum alertType : Int {
    case setting
    case ok
    case onlyok
}

class Helper: NSObject, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
	var myCompletion : ((_ image : UIImage) -> Void)!
    var showToolBarHelp = true
    
	static let sharedInstance : Helper = {
		let instance = Helper()
		return instance
	}()
	
	func topViewController() -> UIViewController {
		let topVC = UIApplication.shared.keyWindow!.rootViewController!
		if topVC != nil {
			while (topVC.presentedViewController != nil) {
				if (topVC.presentedViewController is UINavigationController) {
					return topVC.presentedViewController!
				}
			}
		}
		else {
			return UIApplication.shared.keyWindow!.rootViewController!
		}
		return UIApplication.shared.keyWindow!.rootViewController!
	}
	
	func openImagePickerWithSource(type : UIImagePickerControllerSourceType, and completion :@escaping ((_ image : UIImage) -> Void) ) {
		let picker = UIImagePickerController()
		picker.sourceType = type
		picker.delegate = self
		myCompletion = completion
		self.topViewController().present(picker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		myCompletion?(info[UIImagePickerControllerOriginalImage] as! UIImage)
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
    static func openAlertWith(message : String, type : alertType , controller : UIViewController , handler : ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: constant.APPNAME, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: handler)
        switch type {
        case alertType.setting:
            let Seting = UIAlertAction(title: "Settings", style: .default, handler: handler)
            alertController.addAction(Seting)
            alertController.addAction(cancelAction)
            break
        case alertType.ok:
            let okAction = UIAlertAction(title: "Yes", style: .default, handler: handler)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
        case alertType.onlyok:
            let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
            alertController.addAction(okAction)
        default:
            break
        }
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func frameForImage(image: UIImage, inImageViewAspectFit imageView: UIImageView) -> CGRect
    {
        let imageRatio: CGFloat = image.size.width / image.size.height
        let viewRatio: CGFloat = imageView.frame.size.width / imageView.frame.size.height
        if imageRatio < viewRatio {
            let scale: CGFloat = imageView.frame.size.height / image.size.height
            let width: CGFloat = scale * image.size.width
            let topLeftX: CGFloat = (imageView.frame.size.width - width) * 0.5
            let heightscale: CGFloat = imageView.frame.size.width / image.size.width
             let height: CGFloat = heightscale * image.size.height
            return CGRect(x: topLeftX,y: 0,width: width, height: height)
        }
        else {
            let scale: CGFloat = imageView.frame.size.width / image.size.width
            let height: CGFloat = scale * image.size.height
            let topLeftY: CGFloat = (imageView.frame.size.height - height) * 0.5
            return CGRect(x: 0,y: topLeftY ,width: imageView.frame.size.width,height: height)
        }
    }
    
    static func dispatchMain(execute : @escaping () -> Void) {
        DispatchQueue.main.async(execute: execute)
    }
    
    static func dispatchMainAfter(time : DispatchTime , execute :@escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: time, execute: execute)
    }
    
    static func createImageFrom(view : UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    override static func setValue(_ value: Any?, forKey key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func setBool(_ value : Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    override static func value(forKey key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    static func bool(forKey : String) -> Bool {
        return UserDefaults.standard.bool(forKey: forKey)
    }
    
    func addKeyboardImageView() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFit
        switch UIScreen.main.bounds.size.height {
        case 420.0:
            break
        case 568.0:
            imageView.image = #imageLiteral(resourceName: "keyboard_tool_i5")
            break
        case 667.0:
            imageView.image = #imageLiteral(resourceName: "keyboard_tool_i6")
            break
        case 736.0:
            imageView.image = #imageLiteral(resourceName: "keyboard_tool_i6+")
            break
        default:
            break
        }
        imageView.isUserInteractionEnabled = true
        UIApplication.shared.windows.last?.addSubview(imageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnKeyboardTool(recognizer:)))
        imageView.addGestureRecognizer(tap)
    }
    
    func tapOnKeyboardTool(recognizer : UITapGestureRecognizer) {
        recognizer.view?.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "KeyBoardOpen")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
}


extension UIView {
    
    func addBorder(width : CGFloat, color : UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func showShadow(color : UIColor,offset : CGSize,radius : CGFloat)  {
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.masksToBounds = false
    }
    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat(M_PI)
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }
}

extension UIImage {
    func hFlip() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width, y: 0.0)
        context.scaleBy(x: -1.0, y: 1.0)
        self.draw(at: CGPoint(x: CGFloat(0), y: CGFloat(0)))
        let resultImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    func vFlip() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        self.draw(at: CGPoint(x: CGFloat(0), y: CGFloat(0)))
        let resultImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    func scaleProportional(to size: CGSize) -> UIImage {
        var size = size
        let widthRatio: CGFloat = size.width / self.size.width
        let heightRatio: CGFloat = size.height / self.size.height
        if widthRatio > heightRatio {
            size = CGSize(width: CGFloat(self.size.width * heightRatio), height: CGFloat(self.size.height * heightRatio))
        }
        else {
            size = CGSize(width: CGFloat(self.size.width * widthRatio), height: CGFloat(self.size.height * widthRatio))
        }
        return self.resizedImage(size)
    }
    
    func resizedImage(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


