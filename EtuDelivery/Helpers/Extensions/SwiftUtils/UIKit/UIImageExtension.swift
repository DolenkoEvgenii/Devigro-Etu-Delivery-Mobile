//
//  Created by Tom Baranes on 24/04/16.
//  Copyright © 2016 Tom Baranes. All rights reserved.
//

import UIKit

// MARK: Initializer

extension UIImage {

    @objc
    public convenience init(color: UIColor?) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color?.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }

}

// MARK: - Colors

extension UIImage {

    @objc
    public func filled(with color: UIColor?) -> UIImage {
        guard let color = color else {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
            return self
        }

        color.setFill()
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage)
        context.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }

    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

// MARK: - Transform

#if !os(watchOS)
extension UIImage {

    public func combined(with image: UIImage) -> UIImage? {
        let finalSize = CGSize(width: max(size.width, image.size.width),
                height: max(size.height, image.size.height))
        var finalImage: UIImage?

        UIGraphicsBeginImageContextWithOptions(finalSize, false, UIScreen.main.scale)
        draw(at: CGPoint(x: (finalSize.width - size.width) / 2, y: (finalSize.height - size.height) / 2))
        image.draw(at: CGPoint(x: (finalSize.width - image.size.width) / 2, y: (finalSize.height - image.size.height) / 2))
        finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }

}
#endif