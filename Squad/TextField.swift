//
//  TextField.swift
//  Squad
//
//  Created by Steve on 2/1/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class TextField: UITextField {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)) || action == #selector(UIResponderStandardEditActions.paste(_:)) {
            
            return false
            
        }
        
        return super.canPerformAction(action, withSender: sender)
        
    }

}
