//
//  TagTableViewCell.swift
//  TagView
//
//  Created by Martin Pinka on 24.02.16.
//  Copyright © 2016 Martin Pinka. All rights reserved.
//

import Foundation
import UIKit

class TagTableViewCell : UITableViewCell {

    @IBOutlet weak var tagView : TagView!
    
    
    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()

        print("cell = \(size)")
        return size
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
        //self.tagView.invalidateIntrinsicContentSize()
        //self.setNeedsUpdateConstraints()
    }
}