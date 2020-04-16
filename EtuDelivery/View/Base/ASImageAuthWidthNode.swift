//
// Created by Евгений Доленко on 2019-05-02.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ASImageAuthWidthNode: ASImageNode {

    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        guard let imageSize = image?.size else {
            return constrainedSize
        }

        let w1 = imageSize.width
        let h1 = imageSize.height

        let newWidth = (constrainedSize.height * w1) / h1
        return CGSize(width: newWidth, height: constrainedSize.height)
    }
}
