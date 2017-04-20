//
//  main.swift
//  iOSBatchResizer
//
//  Created by milano fili on 4/20/17.
//  Copyright © 2017 Medopad Ltd. All rights reserved.
//

//#!/usr/bin/swift

///////////////////////////////////
/**
 Usage :
 main.swift <inputpath> <width> <height> <outputpath>
 example :
 main.swift ../test.png 100 100 ../build
 */
///////////////////////////////////
import AppKit
import QuartzCore

//MARK: helper functions
extension NSImage {
    
    func resizeImage(_ width: CGFloat, _ height: CGFloat) -> NSImage { let img = NSImage(size: CGSize(width:width, height:height))
        
        img.lockFocus()
        let ctx = NSGraphicsContext.current()
        ctx?.imageInterpolation = .high
        self.draw(in: NSMakeRect(0, 0, width, height), from: NSMakeRect(0, 0, size.width, size.height), operation: .copy, fraction: 1)
        img.unlockFocus()
        
        return img
    }
    
    @discardableResult
    func saveAsPNG(_ filePath: String) -> Bool {
        guard let tiffData = self.tiffRepresentation else {
            print("failed to get tiffRepresentation. filePath: \(filePath)")
            return false
        }
        let imageRep = NSBitmapImageRep(data: tiffData)
        guard let imageData = imageRep?.representation(using: .PNG, properties: [:]) else {
            print("failed to get PNG representation. filePath: \(filePath)")
            return false
        }
        do {
            try imageData.write(to:URL(fileURLWithPath: filePath))
            return true
        } catch {
            print("failed to write to disk. filePath: \(filePath)")
            return false
        }
    }
}

// arguments&...
let arguments = CommandLine.arguments
if arguments.count != 6 {
    print("Usage :\n" +
          " swift main.swift <input path> <width> <height> <output path> <base file name>")
    exit(1)
}

let inputPath = arguments[1]
let widthString = arguments[2]
let heightString = arguments[3]
let width3x = CGFloat(Int(widthString)!)
let height3x = CGFloat(Int(heightString)!)
let width2x = (width3x/3.0) * 2.0
let height2x = (height3x / 3.0) * 2.0
let width1x = width3x / 3.0
let height1x = height3x / 3.0
let outputPath = arguments[4]
let baseFileName = arguments[5]

// checkout output path
if !FileManager.default.fileExists(atPath: outputPath, isDirectory: nil) {
    do {
        try FileManager.default.createDirectory(atPath: outputPath, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print("Error creating directory: \(error.localizedDescription)")
    }
}

// create & ...
if let image = NSImage(contentsOfFile:inputPath) {
    
    // resize & save 3x
    let newImage3x = image.resizeImage(width3x, height3x)
    let output3xPath = outputPath+"/"+baseFileName+"@3x.png"
    newImage3x.saveAsPNG(output3xPath)
    print ("3x file saved at path : \(output3xPath)")
    
    // resize & save 2x
    let newImage2x = image.resizeImage(width2x, height2x)
    let output2xPath = outputPath+"/"+baseFileName+"@2x.png"
    newImage2x.saveAsPNG(output2xPath)
    print ("2x file saved at path : \(output2xPath)")
    
    // resize & save 1x
    let newImage1x = image.resizeImage(width1x, height1x)
    let output1xPath = outputPath+"/"+baseFileName+"@1x.png"
    newImage1x.saveAsPNG(output1xPath)
    print ("1x file saved at path : \(output1xPath)")
    
    exit(0)
}
else {
    print("Failed to get PNG representation. filePath: \(inputPath)")
    exit(1)
}

