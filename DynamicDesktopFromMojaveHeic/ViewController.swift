//
//  ViewController.swift
//  DynamicWallPaperFromMojave
//
//  Created by dev binaryworks on 25/03/2019.
//  Copyright © 2019 dev binaryworks. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var heicview:DragHeicView!
    var itemArr:Array<ItemImageView> = []
    var imgArr:Array<WallImageView> = []
    var metaArr:Array<NSTextView> = []
    @IBOutlet weak var outputFolderText: NSTextField!
    @IBOutlet weak var outputNameText: NSTextField!
    var outputURL:URL!
    
    var itemViewer:ItemViewer!
    var progressView:ProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let py = view.frame.height - 50
        heicview = DragHeicView(frame: CGRect(x: 5, y: py, width: 80, height: 45))
        view.addSubview(heicview)
        
        for i in 0...15 {
            let py = 360 - CGFloat(Int(i%8)+1)*45
            let px = 420*CGFloat(Int(i/8))
            print(px)
            
            let idxlabel = NSTextView(frame: CGRect(x: px + 5, y: py, width: 43, height: 43))
            idxlabel.string = String(i+1)
            idxlabel.font = NSFont.systemFont(ofSize: 20)
            idxlabel.isEditable = false
            idxlabel.isSelectable = false
            view.addSubview(idxlabel)
            
            let limgview = WallImageView(frame: CGRect(x: px + 50, y: py, width: 76, height: 43), idx: i)
            view.addSubview(limgview)
            imgArr.append(limgview)
            
            let metalabel = NSTextView(frame: CGRect(x: px + 130, y: py, width: 200, height: 43))
            metalabel.isEditable = false
            metalabel.isSelectable = false
            view.addSubview(metalabel)
            metaArr.append(metalabel)
            
            let itemview = ItemImageView(frame: CGRect(x: px + 335, y: py, width: 76, height: 43))
            itemArr.append(itemview)
            view.addSubview(itemview)
        }
        self.outputFolderText.stringValue = getDocumentsDirectory()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(metadataLoad),
                                               name: NSNotification.Name(rawValue: "MetaData"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imageLoad),
                                               name: NSNotification.Name(rawValue: "Image"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imageLargeView),
                                               name: NSNotification.Name(rawValue: "ViewImage"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(processChanged),
                                               name: NSNotification.Name(rawValue: "Progress"),
                                               object: nil)
        
        self.itemViewer = ItemViewer(frame: view.frame)
        view.addSubview(self.itemViewer)
        self.progressView = ProgressView(frame: view.frame)
        view.addSubview(self.progressView)
    }
    @objc func processChanged(notification: NSNotification){
        if let process = notification.userInfo?["process"] as? String {
            print("process noti : \(process)")
            if(process=="loadstart")
            {
                for wall in self.imgArr{
                    wall.reset()
                }
                for txt in self.metaArr{
                    txt.string = ""
                }
            }
        }
    }
    @objc func imageLargeView(_ notification: Notification){
        print("image view noti")
        
        if let object = notification.userInfo as? [String: Int] {
            if let id = object["id"] {
                if(self.heicview.largeViewEnable()){
                    let img = self.heicview.getImage(id: id)
                    self.itemViewer.setImage(image: img)
                    self.itemViewer.isHidden = false
                }
            }
        }
    }
    @objc func imageLoad(_ notification: Notification){
        print("image noti")
        if let object = notification.userInfo as? [String: AnyObject] {
            if let id = object["id"] {
                if let image = object["image"] {
                    let idx = id as! Int
                    DispatchQueue.main.async {
                        self.imgArr[idx].image = image as? NSImage
                        self.imgArr[idx].setImageReady()
                        print("image set : \(idx)")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                                        object: nil,
                                                        userInfo: ["complete":"image \(idx) load"])
                        var check = 0
                        for img in self.imgArr{
                            if(img.imageReady){
                                check += 1
                            }
                        }
                        
                        if(self.imgArr.count == check){
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Progress"),
                                                            object: nil,
                                                            userInfo: ["process":"end"])
                        }
                    }
                    
                }
            }
        }
    }
    @IBAction func loadDefaultHeic(_ sender: Any) {
        heicview.loadDesktopPicture()
    }
    @objc func metadataLoad(_ notification: Notification){
        print("meta noti")
        if let object = notification.userInfo as? [String: AnyObject] {
            if let id = object["id"] {
                if let metadata = object["data"] {
                    let idx = id as! Int
                    DispatchQueue.main.async {
                        self.metaArr[idx].string = metadata as! String
                    }
                    
                }
            }
        }
    }
    func getDocumentsDirectory() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let dpaths = documentsDirectory.path
        print(dpaths)
        return dpaths
    }
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    @IBAction func makeWallpaper(_ sender: Any) {
        var fileNames: Array<String> = []
        
        var checkImageCount = 0
        for j in 0...15 {
            let filepath = itemArr[j].getImageReady()
            if(filepath){
                checkImageCount += 1
            }
            
        }
        if(checkImageCount<itemArr.count){
            print("not ready")
            _ = dialogOKCancel(question: "Not Ready", text: "Choose wallpaper images.")
            return
        }
        for i in 0...15 {
            let fileName = itemArr[i].getImagePath()
            fileNames.append(fileName)
        }
        self.outputURL = URL(string: outputFolderText.stringValue)
        let generator = WallpaperMaker(fileNames: fileNames, outputURL: self.outputURL, outputFileName: self.outputNameText.stringValue, metadata: heicview.getMetaData())
        generator.runthread()
    }
    @IBAction func setOutputFolder(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a Output Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        //dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                self.outputFolderText.stringValue = path
                print(path)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

