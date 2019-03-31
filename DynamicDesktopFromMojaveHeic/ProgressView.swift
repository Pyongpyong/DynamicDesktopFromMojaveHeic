//
//  ProgressView.swift
//  DynamicWallPaperFromMojave
//
//  Created by dev binaryworks on 28/03/2019.
//  Copyright © 2019 dev binaryworks. All rights reserved.
//

import Foundation
import Cocoa

class ProgressView: NSView {
    
    var processTextView:NSTextView!
    var processBar:NSProgressIndicator!
    var processBarValue:Double = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup(){
        let bg:NSTextView = NSTextView(frame: self.frame)
        bg.isEditable = false
        bg.isSelectable = false
        self.addSubview(bg)
        
        processTextView = NSTextView(frame: CGRect(x: 0, y: self.frame.height/3, width: self.frame.width, height: self.frame.height/4))
        processTextView.isEditable = false
        processTextView.isSelectable = false
        processTextView.alignment = NSTextAlignment.center
        self.addSubview(processTextView)
        
        processBar = NSProgressIndicator(frame: CGRect(x: self.frame.width/4, y: self.frame.height/2 - 50, width: self.frame.width/2, height: 100))
        self.addSubview(processBar)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(processChanged),
            name: NSNotification.Name(rawValue: "Progress"),
            object: nil)
        self.isHidden = true
    }
    func show(){
        self.processBarValue = 0
        self.processBar.minValue = 0
        self.processBar.maxValue = 17
        self.processBar.isIndeterminate = false
        self.processBar.doubleValue = self.processBarValue
        self.processTextView.string = "process start!"
        self.isHidden = false
    }
    func increaseProcessBar()
    {
        DispatchQueue.main.async {
            self.processBarValue += 1
            //    self.processBar.increment(by: 1)
            self.processBar.doubleValue = self.processBarValue
        }
    }
    func changeProcessText(text: String)
    {
        DispatchQueue.main.async {
            self.processTextView.string = text
        }
    }
    func hiddenProcessUI(){
        DispatchQueue.main.async {
            self.isHidden = true
        }
    }
    @objc private func processChanged(notification: NSNotification){
        if let process = notification.userInfo?["process"] as? String {
            print("process noti : \(process)")
            if(process=="end")
            {
                hiddenProcessUI()
            }
            else if(process=="start")
            {
                show()
            }
            else if(process=="loadstart")
            {
                show()
            }
            else
            {
                changeProcessText(text: process)
            }
        }
        if let complete = notification.userInfo?["complete"] as? String {
            print(complete)
            increaseProcessBar()
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
}
