//
//  DragHeicView.swift
//  HtmlParserTest
//
//  Created by dev binaryworks on 25/03/2019.
//  Copyright © 2019 dev binaryworks. All rights reserved.
//

import Cocoa

class DragHeicView: NSImageView {
    var filePath: String = "/Library/Desktop Pictures/Mojave.heic"
    let expectedExt = ["heic"]
    var imageMetaData:CGImageMetadata!
    var enableMetaData:Bool = false
    var images: Array<NSImage> = []
    
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
        
        self.filePath = path
        self.image = NSImage(byReferencingFile: self.filePath)
        print("FilePath: \(path)")
        loadHeicImage()
        return true
    }
    func loadDesktopPicture(){
        self.filePath = "/Library/Desktop Pictures/Mojave.heic"
        self.image = NSImage(byReferencingFile: self.filePath)
        loadHeicImage()
    }
    func getMetaData()->CGImageMetadata{
        return self.imageMetaData
    }
    func getImage(id: Int)->NSImage{
        var rid = -1
        for image in self.images{
            if let sid = image.name()?.lowercased(){
                if let mid = Int(sid){
                    if(mid==id){
                        rid = mid
                    }
                }
            }
        }
        print("rid: \(rid)")
        return self.images[rid]
    }
    func largeViewEnable()->Bool{
        var bool = false
        if(self.images.count==16){
            bool = true
        }
        return bool
    }
    
    @objc func run() throws {
        self.images.removeAll()
        if let data = NSData(contentsOfFile: self.filePath), let source = CGImageSourceCreateWithData(data, nil) {
            let count = CGImageSourceGetCount(source)
            
            for index in 0..<count {
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2.0*Double(index)) {
                    if let image = CGImageSourceCreateImageAtIndex(source, index, nil){
                        let limg = NSImage(cgImage: image, size: CGSize(width: 80, height: 45))
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                                        object: nil,
                                                        userInfo: ["process":"Loading image index : \(index+1)"])
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Image"),
                                                        object: nil,
                                                        userInfo: ["id":index, "image":limg])
                        let largeimg = NSImage(cgImage: image, size: CGSize(width: 710, height: 400))
                        if(largeimg.setName(String(index)))
                        {
                            self.images.append(largeimg)
                        }
                    }
                }
                print("dispatchqueue")
                /*
                 if let image = CGImageSourceCreateImageAtIndex(source, index, nil){
                 let limg = NSImage(cgImage: image, size: CGSize(width: 80, height: 45))
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Image"),
                 object: nil,
                 userInfo: ["id":index, "image":limg])
                 self.images.append(NSImage(cgImage: image, size: CGSize(width: 1280, height: 720)))
                 }
                 */
            }
            if let metaData = CGImageSourceCopyMetadataAtIndex(source, 0, nil) {
                self.imageMetaData = metaData
                enableMetaData = true
                if let tags = CGImageMetadataCopyTags(metaData) as? [CGImageMetadataTag] {
                    for tag in tags {
                        if let value = CGImageMetadataTagCopyValue(tag) {
                            let nsTypeString = value as! NSString
                            let swiftString:String = nsTypeString as String
                            print("swiftString: \(swiftString)")
                            if let decodedData = Data(base64Encoded: swiftString){
                                do {
                                    /*
                                    if let decodedString = String(data: decodedData, encoding: .utf8){
                                        print("decodedString: \(decodedString)")
                                    }
                                    
                                    let decoder = PropertyListDecoder()
                                    let settings = try decoder.decode(WallpaperDataGradient.self, from: decodedData)
                                    print("settings: \(settings)")
                                    for pls in settings.si{
                                        print(pls.i)
                                        print(pls.a)
                                        print(pls.z)
                                    }
                                    */
                                    
                                    let decoder = PropertyListDecoder()
                                    let settings:WallpaperData = try decoder.decode(WallpaperData.self, from: decodedData)
                                    
                                    //let lid = settings.ap.l
                                    var sid = 0
                                    for pls in settings.si{
                                        var addstr = "altitude: \(pls.a)\nazimuth: \(pls.z)\n"
                                        if(pls.i == 0){
                                            addstr += "isPrimary, "
                                        }
                                        if let did = settings.ap?.d{
                                            if(pls.i == did){
                                                addstr += "isDark"
                                            }
                                        }
                                        if let lid = settings.ap?.l{
                                            if(pls.i == lid){
                                                addstr += "isLight"
                                            }
                                        }
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MetaData"),
                                                                        object: nil,
                                                                        userInfo: ["id":sid, "data":addstr])
                                        sid += 1
                                    }
                                    
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func loadHeicImage(){
        Thread.detachNewThreadSelector(#selector(run), toTarget: self, with: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                        object: nil,
                                        userInfo: ["process":"loadstart"])
    }
    /*
    func loadHeicImageOld(){
        self.images.removeAll()
        if let data = NSData(contentsOfFile: self.filePath), let source = CGImageSourceCreateWithData(data, nil) {
            let count = CGImageSourceGetCount(source)
            for index in 0..<count {
                if let image = CGImageSourceCreateImageAtIndex(source, index, nil){
                    let limg = NSImage(cgImage: image, size: CGSize(width: 80, height: 45))
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Image"),
                                                    object: nil,
                                                    userInfo: ["id":index, "image":limg])
                    
                    self.images.append(NSImage(cgImage: image, size: CGSize(width: 1280, height: 720)))
                }
                if let metaData = CGImageSourceCopyMetadataAtIndex(source, index, nil) {
                    if(index == 0){
                        self.imageMetaData = metaData
                        enableMetaData = true
                    }
                    print("all metaData[\(index)]: \(metaData)")
                    let typeId = CGImageMetadataGetTypeID()
                    print("metadata typeId[\(index)]: \(typeId)")
                    if let tags = CGImageMetadataCopyTags(metaData) as? [CGImageMetadataTag] {
                        print("number of tags - \(tags.count)")
                        for tag in tags {
                            let tagType = CGImageMetadataTagGetTypeID()
                            if let name = CGImageMetadataTagCopyName(tag) {
                                print("name: \(name)")
                            }
                            if let value = CGImageMetadataTagCopyValue(tag) {
                                print("value: \(value)")
                                let nsTypeString = value as! NSString
                                let swiftString:String = nsTypeString as String
                                if let decodedData = Data(base64Encoded: swiftString){
                                    
                                    do {
                                        let decoder = PropertyListDecoder()
                                        let settings:WallpaperData = try decoder.decode(WallpaperData.self, from: decodedData)
                                        let did = settings.ap.d
                                        let lid = settings.ap.l
                                        var sid = 0
                                        for pls in settings.si{
                                            var addstr = "altitude: \(pls.a)\nazimuth: \(pls.z)\n"
                                            if(pls.i == 0){
                                                addstr += "isPrimary, "
                                            }
                                            if(pls.i == did){
                                                addstr += "isDark"
                                            }
                                            if(pls.i == lid){
                                                addstr += "isLight"
                                            }
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MetaData"),
                                                                            object: nil,
                                                                            userInfo: ["id":sid, "data":addstr])
                                            sid += 1
                                        }
                                    } catch {
                                        print(error)
                                    }
                                    if let decodedString = String(data: decodedData, encoding: .utf8){
                                        print(decodedString)
                                    }
                                }
                            }
                            if let prefix = CGImageMetadataTagCopyPrefix(tag) {
                                print("prefix: \(prefix)")
                            }
                            if let namespace = CGImageMetadataTagCopyNamespace(tag) {
                                print("namespace: \(namespace)")
                            }
                            if let qualifiers = CGImageMetadataTagCopyQualifiers(tag) {
                                print("qualifiers: \(qualifiers)")
                            }
                            print("-------")
                        }
                    }
                }
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) {
                    print("properties[\(index)]: \(properties)")
                }
            }
        }
    }
     */
}
