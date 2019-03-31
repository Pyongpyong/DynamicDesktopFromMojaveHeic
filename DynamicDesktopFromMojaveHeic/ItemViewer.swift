//
//  ItemViewer.swift
//  DynamicWallPaperFromMojave
//
//  Created by dev binaryworks on 27/03/2019.
//  Copyright © 2019 dev binaryworks. All rights reserved.
//

import Foundation
import Cocoa

class ItemViewer: NSView {
    
    var imageView: NSImageView!
    var closeBtn: NSButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup(){
        let bg:NSImageView = NSImageView(frame: self.frame)
        bg.wantsLayer = true
        bg.layer?.backgroundColor = NSColor.black.cgColor
        self.addSubview(bg)
        
        self.imageView = NSImageView(frame: NSRect(x: 55, y: 40 , width: 710, height: 400))
        self.addSubview(self.imageView)
        self.closeBtn = NSButton(frame: NSRect(x: 55, y: 10, width: 710, height: 30))
        self.closeBtn.title = "Close"
        self.closeBtn.target = self
        self.closeBtn.action = #selector(closeClick)
        self.addSubview(self.closeBtn)
        self.isHidden = true
    }
    func setImage(image: NSImage){
        self.imageView.image = image
    }
    
    @objc func closeClick(){
        self.isHidden = true
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
}
