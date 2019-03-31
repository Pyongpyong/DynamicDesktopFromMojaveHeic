//
//  WallpaperItem.swift
//  DynamicWallPaperFromMojave
//
//  Created by dev binaryworks on 25/03/2019.
//  Copyright © 2019 dev binaryworks. All rights reserved.
//

import Foundation

class WallpaperData : Codable {
    var si: [WallpaperItem] = []
    var ap:Bright? = Bright()
}

class WallpaperItem : Codable {
    var a: Double = 0.0
    var z: Double = 0.0
    var i: Int = 0
}

class Bright: Codable {
    var d: Int = 0
    var l: Int = 0
}

class WallpaperDataGradient : Codable {
    var si: [WallpaperItem] = []
}
