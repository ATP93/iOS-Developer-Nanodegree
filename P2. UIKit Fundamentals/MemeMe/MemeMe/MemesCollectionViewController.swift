/**
 * Copyright (c) 2017 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

// MARK: Types

private enum SegueIdentifier: String {
  case createMeme
  case showMeme
}

// MARK: - MemesCollectionViewController: UICollectionViewController

class MemesCollectionViewController: UICollectionViewController {
  
  // MARK: Properties
  
  var memesPersistence: MemesPersistence!
  
  fileprivate var isEmptyDataSource: Bool {
    get {
      return memesPersistence.memes.count == 0
    }
  }
  
  fileprivate static let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
  fileprivate static let numberOfMemesPerLine = 2
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    assert(memesPersistence != nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    collectionView?.reloadData()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView?.collectionViewLayout.invalidateLayout()
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch SegueIdentifier(rawValue: segue.identifier!)! {
    case .createMeme:
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! MemeViewController
      controller.title = NSLocalizedString("Create", comment: "DetailMemeController create meme title")
      controller.presentationType = .createMeme
      controller.delegate = self
    case .showMeme:
      let controller = segue.destination as! MemeViewController
      controller.title = NSLocalizedString("Detail", comment: "DetailMemeController detail meme title")
      controller.presentationType = .showMeme
      controller.delegate = self
      
      guard let selectedCell = sender as? MemeCollectionViewCell,
        let indexPath = collectionView?.indexPath(for: selectedCell) else {
          return
      }
      
      controller.meme = memesPersistence.memes[indexPath.row]
    }
  }
  
  // MARK: UICollectionViewDataSource
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (isEmptyDataSource ? 1 : memesPersistence.memes.count)
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if isEmptyDataSource {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeCollectionViewEmptyDataSourceCell.reuseIdentifier, for: indexPath) as! MemeCollectionViewEmptyDataSourceCell
      cell.createMemeButton.addTarget(self, action: #selector(MemesCollectionViewController.createMeme), for: .touchUpInside)
      
      return cell
    } else {
      let meme = memesPersistence.memes[indexPath.row]
      
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeCollectionViewCell.reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
      cell.memedImageView.image = meme.memedImage
      
      return cell
    }
  }
  
  // MARK: Actions
  
  @objc func createMeme() {
    performSegue(withIdentifier: SegueIdentifier.createMeme.rawValue, sender: self)
  }
  
}

// MARK: - MemesCollectionViewController: UICollectionViewDelegateFlowLayout

extension MemesCollectionViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    let delegateFlowLayout = collectionView.delegate as! UICollectionViewDelegateFlowLayout
    
    let screenWidth = screenSize().width
    let sectionInset = delegateFlowLayout.collectionView!(collectionView, layout: flowLayout, insetForSectionAt: indexPath.section)
    
    let itemSpacing = delegateFlowLayout.collectionView!(collectionView, layout: flowLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
    var totalItemsSpacing = itemSpacing * (CGFloat(MemesCollectionViewController.numberOfMemesPerLine - 1))
    totalItemsSpacing = max(itemSpacing, totalItemsSpacing)
    
    let width = (screenWidth - (sectionInset.left + sectionInset.right + totalItemsSpacing)) / CGFloat(MemesCollectionViewController.numberOfMemesPerLine)
    let height = (isEmptyDataSource ? MemeCollectionViewEmptyDataSourceCell.defaultHeight : width)
    
    return CGSize(width: width, height: height)
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    var insets = MemesCollectionViewController.sectionInsets
    
    if isEmptyDataSource {
      insets.top *= 4
    }
    
    return insets
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 8.0
  }
  
}

// MARK: - MemesCollectionViewController: MemeViewControllerDelegate

extension MemesCollectionViewController: MemeViewControllerDelegate {
  
  func memeViewController(_ controller: MemeViewController, didDoneOnMemeShare meme: Meme) {
    if controller.presentationType == MemeViewControllerPresentationType.createMeme {
      memesPersistence.memes.append(meme)
      memesPersistence.saveMemes()
      collectionView?.reloadData()
    }
  }
  
  func memeViewController(_ controller: MemeViewController, didDoneOnMemeEditing meme: Meme) {
    memesPersistence.saveMemes()
    collectionView?.reloadData()
  }
  
  func memeViewController(_ controller: MemeViewController, didSelectRemoveMeme meme: Meme) {
    let index = memesPersistence.memes.index(of: meme)!
    memesPersistence.memes.remove(at: index)
    memesPersistence.saveMemes()
    collectionView?.reloadData()
  }
}
