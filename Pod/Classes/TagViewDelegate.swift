//
//  TagViewDelegate.swift
//  TagView
//
//  Created by Martin Pinka on 24.02.16.
//  Copyright © 2016 Martin Pinka. All rights reserved.
//

import Foundation

public protocol TagViewDelegate {
    
    func tagView(tagView :TagView, didSelectTagAtIndex index : Int)
    func tagView(tagView :TagView, didDeselectTagAtIndex index : Int)
    
}
