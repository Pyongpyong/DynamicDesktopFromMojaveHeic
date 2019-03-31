//
//  WallpaperMaker.swift
//  DynamicWallPaperFromMojave
//
//  Created by dev binaryworks on 25/03/2019.
//  Copyright © 2019 dev binaryworks. All rights reserved.
//

import Foundation
import AppKit
import AVFoundation

enum WallpaperMakerError: Error {
    case NamespaceNotRegisteredError
    case AddTagImageError
    case ImageFinalizingError
    case NotSupportedSystemError
}

class WallpaperMaker {
    
    var fileNames: [String]
    let outputURL: URL
    let outputFileName: String
    let options = [kCGImageDestinationLossyCompressionQuality: 1.0]
    let imageMetaData:CGImageMetadata
    
    init(fileNames: [String], outputURL: URL, outputFileName: String, metadata: CGImageMetadata) {
        self.fileNames = fileNames
        self.outputURL = outputURL
        self.outputFileName = outputFileName
        self.imageMetaData = metadata
    }
    func resize(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.copy, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    func resizeImage(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(destSize.width), pixelsHigh: Int(destSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)
        rep?.size = destSize
        NSGraphicsContext.saveGraphicsState()
        if let aRep = rep {
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: aRep)
        }
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),     from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        let newImage = NSImage(size: destSize)
        if let aRep = rep {
            newImage.addRepresentation(aRep)
        }
        return newImage
    }
    func runthread(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                        object: nil,
                                        userInfo: ["process":"start"])
        Thread.detachNewThreadSelector(#selector(run), toTarget: self, with: nil)
    }
    
    @objc func run() throws {
        if #available(OSX 10.13, *) {
            let destinationData = NSMutableData()
            if let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, self.fileNames.count, nil) {
                
                for (index, fileName) in self.fileNames.enumerated() {
                    let fileURL = URL(fileURLWithPath: fileName)
                    print("Loading image file: '\(fileURL.absoluteString)'...")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                                    object: nil,
                                                    userInfo: ["process":"Loading image file: '\(fileURL.absoluteString)'..."])
                    guard let loadImage = NSImage(contentsOf: fileURL) else {
                        print("ERROR.")
                        return
                    }
                    print("OK")
                    let orginalImage = resizeImage(image: loadImage, w: 5120, h: 2880)
                    print(orginalImage.size)
                    if let cgImage = (orginalImage.representations as? [NSBitmapImageRep])?.first?.cgImage {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                                        object: nil,
                                                        userInfo: ["process":"Writing image file: '\(fileURL.absoluteString)'..."])
                        if index == 0 {
                            CGImageDestinationAddImageAndMetadata(destination, cgImage, self.imageMetaData, self.options as CFDictionary)
                        } else {
                            CGImageDestinationAddImage(destination, cgImage, self.options as CFDictionary)
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                                    object: nil,
                                                    userInfo: ["complete":"write file"])
                }
                print("Making wallpaper")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                                object: nil,
                                                userInfo: ["process":"make heic file"])
                guard CGImageDestinationFinalize(destination) else {
                    throw WallpaperMakerError.ImageFinalizingError
                }
                print("OK.")
                let resultpath = self.outputURL.path + "/" + self.outputFileName + ".heic"
                print(resultpath)
                //let outputURL = URL(fileURLWithPath: self.outputFileName, relativeTo: self.outputURL)
                let outputURL = URL(fileURLWithPath: resultpath)
                print("Saving data to file '\(outputURL.absoluteString)'...")
                print(outputURL)
                let imageData = destinationData as Data
                do {
                    try imageData.write(to: outputURL)
                } catch {
                    print("error:", error)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                                object: nil,
                                                userInfo: ["process":"end"])
                print("OK.")
            }
        } else {
            throw WallpaperMakerError.NotSupportedSystemError
        }
    }
}
