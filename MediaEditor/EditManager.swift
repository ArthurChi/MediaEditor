//
//  EditManager.swift
//  MediaEditor
//
//  Created by cjfire on 2018/1/30.
//  Copyright © 2018年 cjfire. All rights reserved.
//

import UIKit
import AVFoundation

class EditManager {
    
    typealias CompleteHandler = () -> ()
    
    func audioMix(video: AVAsset, audios: [AVAsset], outputURL: URL, handler: CompleteHandler?) {
        
        let duraion = video.firstVideoTrack.timeRange.duration
        
        let composition = AVMutableComposition()
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        try? videoTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: duraion), of: video.firstVideoTrack, at: kCMTimeZero)
        
        var inputParams = Array<AVAudioMixInputParameters>()
        
        for audio in audios {
            let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? audioTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: duraion), of: audio.firstAudioTrack, at: kCMTimeZero)
            let mixInputParameter = AVMutableAudioMixInputParameters(track: audioTrack)
            inputParams.append(mixInputParameter)
        }
        
        let mutableAudioMix = AVMutableAudioMix()
        mutableAudioMix.inputParameters = inputParams
        
        if let exportSession = AVAssetExportSession(asset: (composition.copy() as! AVAsset), presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            exportSession.audioMix = mutableAudioMix
            
            self.export(session: exportSession, handler: handler)
        }
    }
    
    func watermark(video: AVAsset, outputURL: URL, size: CGSize, handler: CompleteHandler?) {
        
        let composition = AVMutableComposition()
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let duration = video.firstAudioTrack.timeRange.duration
        
        try? videoTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: duration), of: video.firstVideoTrack, at: kCMTimeZero)
        try? audioTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: duration), of: video.firstAudioTrack, at: kCMTimeZero)
        
        let videoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack!)
        
        let t1 = CGAffineTransform(translationX: videoTrack!.naturalSize.height, y: 0)
        let t2 = t1.rotated(by: 90 * CGFloat.pi / 180)
        videoCompositionLayerInstruction.setTransform(t2, at: kCMTimeZero)
        
        let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
        videoCompositionInstruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: duration)
        videoCompositionInstruction.layerInstructions = [videoCompositionLayerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        let size = video.tracks(withMediaType: .video).first!.naturalSize
        videoComposition.renderSize = CGSize(width: size.height, height: size.width)
        videoComposition.frameDuration = CMTimeMake(1, 30)//video.firstVideoTrack.minFrameDuration
        videoComposition.instructions = [videoCompositionInstruction]
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        
        let imageLayer = CALayer()
        let image = UIImage(named: "ic_wmark_default")!
        imageLayer.contents = image.cgImage
        imageLayer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(imageLayer)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        if let exportSession = AVAssetExportSession(asset: (composition.copy() as! AVAsset), presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            exportSession.videoComposition = videoComposition
            self.export(session: exportSession, handler: handler)
        }
    }
    
    // 将取视频和音频进行合成
    func fixOnlyVideoAndAudio(video: AVAsset, audio: AVAsset, outputURL: URL, handler: CompleteHandler?) {
        
        let composition = self.composition(video: video, audio: audio)
        
        if let exportSession = AVAssetExportSession(asset: (composition.copy() as! AVAsset), presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            self.export(session: exportSession, handler: handler)
        }
    }
    
    private func composition(video: AVAsset, audio: AVAsset? = nil) -> AVMutableComposition {
        
        let composition = AVMutableComposition()
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // https://www.jianshu.com/p/16cb14f53933
        let duration = video.firstAudioTrack.timeRange.duration
        
        try? videoTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: duration), of: video.firstVideoTrack, at: kCMTimeZero)
        
        if let audio = audio {
            try? audioTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: duration), of: audio.firstAudioTrack, at: kCMTimeZero)
        } else {
            try? audioTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: duration), of: video.firstAudioTrack, at: kCMTimeZero)
        }
        
        return composition
    }
    
    
    private func export(session: AVAssetExportSession, handler: CompleteHandler?) {
        
        let outputPath = (session.outputURL?.path)!
        
        if FileManager.default.fileExists(atPath: outputPath) {
            try? FileManager.default.removeItem(atPath: outputPath)
        }
        
        session.exportAsynchronously {
            if session.status == .completed {
                handler?()
            } else if session.status == .failed {
                print(session.error ?? "nil")
            }
        }
    }
}
