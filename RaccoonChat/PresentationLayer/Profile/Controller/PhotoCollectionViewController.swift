//
//  PhotoCollectionViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 17/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PhotoCell"

class PhotoCollectionViewController: UICollectionViewController {

  let activityIndicator = UIActivityIndicatorView(style: .gray)

  var imageService: IImageService! = ImageService()

  var completion: ((UIImage?) -> Void)?

  var photos: [PhotoModel]!

  private let itemsPerRow: CGFloat = 3.0
  private let inset: CGFloat = 8.0

  override func viewDidLoad() {
    super.viewDidLoad()

    let collectionViewWidth = self.collectionView.bounds.width
    let itemWidth = (collectionViewWidth - self.inset - 8) / itemsPerRow

    if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = 4
      layout.minimumInteritemSpacing = 0
      layout.sectionInset = UIEdgeInsets(top: 20, left: 4, bottom: 10, right: 4)
      layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    }

    self.view.addSubview(activityIndicator)
    activityIndicator.hidesWhenStopped = true
    activityIndicator.center = self.view.center

    activityIndicator.startAnimating()
    imageService.fetchData { photos, error in
      DispatchQueue.main.async {
        self.photos = photos
        if let error = error {
          Logger.write(error)
        }
        self.activityIndicator.stopAnimating()
        self.collectionView.reloadData()
      }
    }
  }

  // MARK: - UICollectionViewDataSource

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let photos = photos {
      return photos.count
    } else {
      return 18
    }
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    guard let photoCell = cell as? PhotoCell,
      let photos = photos else {
      return cell
    }

    if let image = photos[indexPath.row].image {
      photoCell.image = image
      return photoCell
    }

    imageService.loadImage(urlString: photos[indexPath.row].imageURL) { image, error in
      self.photos[indexPath.row].image = image
      DispatchQueue.main.async {
        photoCell.image = image
        if let error = error {
          Logger.write(error)
        }
      }
    }

    return photoCell
  }

  // MARK: - UICollectionViewDelegate
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let completion = self.completion {
      completion(photos[indexPath.row].image)
    }
    self.dismiss(animated: true, completion: nil)
  }

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
