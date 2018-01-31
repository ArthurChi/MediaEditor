//
//  ViewController.swift
//  MediaEditor
//
//  Created by cjfire on 2018/1/30.
//  Copyright © 2018年 cjfire. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let video: AVURLAsset = {
        let path = Bundle.main.path(forResource: "sd1517195101_2", ofType: "MP4")
        let url = URL(fileURLWithPath: path!)
        return AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
    }()
    
    let audio: AVAsset = {
        
        let path = Bundle.main.path(forResource: "un01a", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        return AVAsset(url: url)
    }()
    
    let audioEcomoicist: AVAsset = {
        let path = Bundle.main.path(forResource: "e", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        return AVAsset(url: url)
    }()
    
    let editManager = EditManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let basePath: NSString = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! as NSString
//        let fixPath: String = basePath.appendingPathComponent("abc.mov") as String
//
//        editManager.fixOnlyVideoAndAudio(video: video, audio: audio, outputURL: URL(fileURLWithPath: fixPath)) {
//            print("finished")
//        }
        
//        let watermarkVideoPath: String = basePath.appendingPathComponent("water.mov") as String
//
//        editManager.watermark(video: video, outputURL: URL(fileURLWithPath: watermarkVideoPath), size: view.bounds.size) {
//            print("finished watermark")
//        }
        
        let mixPath: String = basePath.appendingPathComponent("mix.mov") as String
        
        editManager.audioMix(video: video, audios: [audio, audioEcomoicist], outputURL: URL(fileURLWithPath: mixPath)) {
            print("finished mix")
        }
    }
    
}

