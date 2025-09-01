//
//  UIFont.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 01.09.2025.
//

import UIKit

extension UIFont {
    func textSize(viewWidth:CGFloat, text:String) -> CGSize {
        let attributedText = NSAttributedString(
            string: text,
            attributes: [.font: self]
        )
        let boundingRect = attributedText.boundingRect(
            with: CGSize(width: viewWidth,
                         height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        )
        print(boundingRect, " tgerfwdqsefr ")
        return CGSize(width: ceil(boundingRect.size.width),
                      height: ceil(boundingRect.size.height))
        
    }
}
