//
//  ItemImageView.swift
//  WallPaperMaker
//
//  Created by dev binaryworks on 14/03/2019.
//  Copyright © 2019 dev binaryworks. All rights reserved.
//

import Cocoa

class ItemImageView: NSImageView {
    
    var filePath: String!
    let expectedExt = ["png", "jpg"]  //file extensions allowed for Drag&Drop (example: "jpg","png","docx", etc..)
    var imageView: NSImageView!
    var imageReady = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup(){
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            self.layer?.backgroundColor = NSColor.blue.cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }
        
        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.expectedExt {
            if ext.lowercased() == suffix {
                return true
            }
        }
        return false
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
            else { return false }
        
        //GET YOUR FILE PATH !!!
        self.filePath = path
        self.image = NSImage(byReferencingFile: self.filePath!)
        let photoURL = NSURL(fileURLWithPath: self.filePath!)
        print(photoURL)
        imageReady = true
        print("FilePath: \(path)")
        return true
    }
    func getImagePath() -> String{
        return self.filePath
    }
    func getImageReady() -> Bool{
        return self.imageReady
    }
    
}
