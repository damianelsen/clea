//
//  Toast.swift
//  Clea
//
//  Created by Damian Elsen on 9/29/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class Toast {
    
    enum ToastType {
        case Information
        case Warning
        case Error
    }
    
    static func show(message: String, withType type: ToastType, forController controller: UIViewController) {
        var imageName: String
        var imageColorName: String
        switch type {
        case .Warning:
            imageName = "exclamationmark.circle.fill"
            imageColorName = CleaConstants.taskDueColorName
        case .Error:
            imageName = "xmark.circle.fill"
            imageColorName = CleaConstants.taskOverdueColorName
        default:
            imageName = "info.circle.fill"
            imageColorName = CleaConstants.taskScheduledColorName
        }
        
        let toastImage = UIImage(systemName: imageName)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = toastImage?.withTintColor(UIColor(named: imageColorName)!)
        imageAttachment.bounds = CGRect(x: 0, y: -4.0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        completeText.append(NSMutableAttributedString(string: "  "))
        completeText.append(NSMutableAttributedString(string: message))
        completeText.addAttributes([.foregroundColor: UIColor(named: CleaConstants.accentColorName)!, .font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: completeText.length))
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textAlignment = .center;
        toastLabel.attributedText = completeText
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 1
        
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor(named: CleaConstants.toastBackgroundColorName)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 20;
        toastContainer.clipsToBounds = true
        toastContainer.addSubview(toastLabel)
        
        controller.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -10)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 10)
        toastContainer.addConstraints([a1, a2, a3, a4])
        
        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .width, relatedBy: .lessThanOrEqual, toItem: controller.view, attribute: .width, multiplier: 1, constant: -90)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .centerX, relatedBy: .equal, toItem: controller.view, attribute: .centerX, multiplier: 1, constant: 1)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .top, relatedBy: .equal, toItem: controller.view, attribute: .top, multiplier: 1, constant: 40)
        controller.view.addConstraints([c1, c2, c3])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    
}
