//
//  WallImageView.swift
//  DynamicWallPaperFromMojave
//
//  Created by dev binaryworks on 26/03/2019.
//  Copyright © 2019 dev binaryworks. All rights reserved.
//

import Cocoa

class WallImageView: NSImageView {
    
    var imageReady = false
    var idx = -1
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup(){
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    init(frame: NSRect, idx: Int) {
        super.init(frame: frame)
        self.idx = idx
        setup()
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    override func mouseUp(with event: NSEvent) {
        if(event.clickCount == 1){
            if(imageReady){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ViewImage"),
                                                object: nil,
                                                userInfo: ["id":self.idx])
            }
        }
        print(event.clickCount)
    }
    func reset(){
        self.imageReady = false
        self.image = nil
    }
    
    func setImageReady(){
        self.imageReady = true
    }
}
