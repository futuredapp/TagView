//
//  TagViewDataSource.swift
//  TagView
//
//  Created by Martin Pinka on 24.02.16.
//  Copyright © 2016 Martin Pinka. All rights reserved.
//

import Foundation
import UIKit

protocol TagViewDataSource {
    
    func numberOfTags(tagView:TagView) -> Int
    func tagCellForTagView(tagView:TagView, index: Int) -> TagViewCell

    
    func heightOfTag(tagView:TagView) -> CGFloat
}