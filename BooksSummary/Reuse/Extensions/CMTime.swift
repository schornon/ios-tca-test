//
//  CMTime.swift
//  BooksSummary
//
//  Created by Serhii Chornonoh on 20.09.2024.
//

import CoreMedia

extension CMTime {
    static var zero: CMTime {
        CMTime(seconds: 0, preferredTimescale: 1)
    }
    
    var floatValue: CGFloat {
        CMTimeGetSeconds(self)
    }
}
