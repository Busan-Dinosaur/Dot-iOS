//
//  PhotoPickerable.swift
//  FoodBowl
//
//  Created by COBY_PRO on 11/9/23.
//

import UIKit
import MapKit
import Photos

import YPImagePicker

protocol PhotoPickerable: UIGestureRecognizerDelegate {
    func photoesAddButtonDidTap()
    func setPhotoes(images: [UIImage], location: CLLocationCoordinate2D?)
    func setPhoto(image: UIImage)
}

extension PhotoPickerable where Self: UIViewController {
    func photoesAddButtonDidTap() {
        var config = YPImagePickerConfiguration()
        config.onlySquareImagesFromCamera = true
        config.library.maxNumberOfItems = 4
        config.library.minNumberOfItems = 0
        config.library.mediaType = .photo
        config.startOnScreen = YPPickerScreen.library
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "FoodBowl"
        
        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        let barButtonAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline, weight: .regular)]
        UINavigationBar.appearance().titleTextAttributes = titleAttributes // Title fonts
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes, for: .normal) // Bar Button fonts
        config.wordings.libraryTitle = "갤러리"
        config.wordings.cameraTitle = "카메라"
        config.wordings.next = "다음"
        config.wordings.cancel = "취소"
        config.colors.tintColor = .mainColor
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if !cancelled {
                var photoLocation: CLLocationCoordinate2D? = nil
                let images: [UIImage] = items.compactMap { item in
                    if case .photo(let photo) = item {
                        if let location = photo.asset?.location?.coordinate {
                            photoLocation = location
                        }
                        return photo.image
                    } else {
                        return nil
                    }
                }
                self.setPhotoes(images: images, location: photoLocation)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.present(picker, animated: true, completion: nil)
        }
    }
    
    func photoAddButtonDidTap() {
        var config = YPImagePickerConfiguration()
        config.onlySquareImagesFromCamera = true
        config.library.defaultMultipleSelection = false
        config.library.mediaType = .photo
        config.startOnScreen = YPPickerScreen.library
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "FoodBowl"

        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        let barButtonAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline, weight: .regular)]
        UINavigationBar.appearance().titleTextAttributes = titleAttributes // Title fonts
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes, for: .normal) // Bar Button fonts
        config.wordings.libraryTitle = "갤러리"
        config.wordings.cameraTitle = "카메라"
        config.wordings.next = "다음"
        config.wordings.cancel = "취소"
        config.colors.tintColor = .mainColor

        let picker = YPImagePicker(configuration: config)

        picker.didFinishPicking { [unowned picker] items, cancelled in
            if !cancelled {
                let images: [UIImage] = items.compactMap { item in
                    if case .photo(let photo) = item {
                        return photo.image
                    } else {
                        return nil
                    }
                }
                self.setPhoto(image: images[0])
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    func setPhotoes(images: [UIImage], location: CLLocationCoordinate2D?) { }
    func setPhoto(image: UIImage) { }
}
