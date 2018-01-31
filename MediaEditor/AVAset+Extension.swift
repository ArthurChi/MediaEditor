//
//  AVAset+Extension.swift
//  MediaEditor
//
//  Created by cjfire on 2018/1/30.
//  Copyright © 2018年 cjfire. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAsset {
    
    var firstVideoTrack: AVAssetTrack {
        return self.tracks(withMediaType: .video).first!
    }
    
    var firstAudioTrack: AVAssetTrack {
        return self.tracks(withMediaType: .audio).first!
    }
}
