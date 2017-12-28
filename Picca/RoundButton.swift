//
//  RoundButton.swift
//  Picca
//
//  Created by Rens Gingnagel on 13/12/2017.
//  Copyright © 2017 Rens Gingnagel. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class RoundButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
    }
}
