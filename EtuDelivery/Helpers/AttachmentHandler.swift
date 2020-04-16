//
//  AttachmentHandler.swift
//  AttachmentHandler
//
//  Created by Deepak on 25/01/18.
//  Copyright © 2018 Deepak. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation
import Photos
import os.log

protocol AttachmentDelegate: class {
    func imagePicked(_ data: Data, _ image: UIImage)
    func filePicked(_ fileURL: URL)
}

class AttachmentHandler: NSObject {
    static let shared = AttachmentHandler()
    fileprivate var currentVC: UIViewController?
    fileprivate var sourceView: UIView?

    var delegate: AttachmentDelegate?

    enum AttachmentType: String {
        case camera, photoLibrary
    }

    struct Constants {
        static let actionFileTypeHeading = "media_menuTitle".localized()
        static let actionFileTypeDescription = "media_menuMessage".localized()
        static let camera = "media_menuCamera".localized()
        static let phoneLibrary = "media_menuGallery".localized()
        static let file = "media_menuDocument".localized()

        static let alertForPhotoLibraryMessage = "media_warningGallery".localized()
        static let alertForCameraAccessMessage = "media_warningCamera".localized()

        static let settingsBtnTitle = "media_warningSettings".localized()
        static let cancelBtnTitle = "media_menuCancel".localized()
    }

    func pickImageFromCamera(vc: UIViewController, source: UIView){
        currentVC = vc
        sourceView = source
        self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
    }

    func showPhotoAttachmentActionSheet(vc: UIViewController, source: UIView) {
        currentVC = vc
        sourceView = source
        let actionSheet = UIAlertController(title: Constants.actionFileTypeHeading, message: Constants.actionFileTypeDescription, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (_) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
        }))

        actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (_) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!)
        }))

        actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sourceView
        }

        vc.present(actionSheet, animated: true, completion: nil)
    }

    func showDocumentPicker(vc: UIViewController) {
        currentVC = vc
        documentPicker()
    }

    func authorisationStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController) {
        currentVC = vc

        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.camera {
                openCamera()
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary {
                photoVideoLibrary()
            }
        case .denied:
            self.addAlertForSettings(attachmentTypeEnum)
        case .notDetermined:
            /* PHPhotoLibrary.requestAuthorization({ (status) in
                 if status == PHAuthorizationStatus.authorized {*/
            if attachmentTypeEnum == AttachmentType.camera {
                self.openCamera()
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary {
                self.photoVideoLibrary()
            }
                /*} else {
                    self.addAlertForSettings(attachmentTypeEnum)
                }
            })*/
        case .restricted:
            self.addAlertForSettings(attachmentTypeEnum)
        }
    }

    //This function is used to open camera from the iphone and
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }

    func photoVideoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }

    func documentPicker() {
        let importMenu = UIDocumentMenuViewController(documentTypes: ["public.item"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        currentVC?.present(importMenu, animated: true, completion: nil)
    }

    func addAlertForSettings(_ attachmentTypeEnum: AttachmentType) {
        var alertTitle: String = ""
        if attachmentTypeEnum == AttachmentType.camera {
            alertTitle = Constants.alertForCameraAccessMessage
        }
        if attachmentTypeEnum == AttachmentType.photoLibrary {
            alertTitle = Constants.alertForPhotoLibraryMessage
        }

        let settingUnavailableAlertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: Constants.settingsBtnTitle, style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: Constants.cancelBtnTitle, style: .default, handler: nil)
        settingUnavailableAlertController.addAction(cancelAction)
        settingUnavailableAlertController.addAction(settingsAction)

        if let popoverController = settingUnavailableAlertController.popoverPresentationController {
            popoverController.sourceView = sourceView
        }

        currentVC?.present(settingUnavailableAlertController, animated: true, completion: nil)
    }
}

extension AttachmentHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if #available(iOS 11.0, *) {
                let url = info[UIImagePickerController.InfoKey.imageURL] as? URL
                compressImage(url, image)
            } else {
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                compressImage(url, image)
            }
        }

        currentVC?.dismiss(animated: true, completion: nil)
    }

    fileprivate func compressImage(_ fileURL: URL?, _ image: UIImage) {
        var image = image
        image = image.fixRotation()
        image = resizeImage(image: image, targetSize: CGSize(width: 900, height: 900))
        print(image.size)

        if let compressedImageData = image.jpegData(compressionQuality: 0.75) {
            delegate?.imagePicked(compressedImageData, image)
            os_log("disk compressed image size : %f kb", Double(compressedImageData.count / 1024))
        }
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        if (size.width < targetSize.width && size.height < targetSize.height) {
            return image
        }

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if (widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension AttachmentHandler: UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        currentVC?.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        os_log("document picker url %@", url.absoluteString)
        delegate?.filePicked(url)
    }

    //    Method to handle cancel action.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
}