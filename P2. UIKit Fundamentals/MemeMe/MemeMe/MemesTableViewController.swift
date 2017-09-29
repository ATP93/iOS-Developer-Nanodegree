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

// MARK: - MemesTableViewController: UITableViewController

class MemesTableViewController: UITableViewController {
  
  // MARK: Properties
  
  var memesPersistence: MemesPersistence!
  
  fileprivate var isEmptyDataSource: Bool {
    get {
      return memesPersistence.memes.count == 0
    }
  }
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    assert(memesPersistence != nil)
    navigationItem.leftBarButtonItem = editButtonItem
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
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
      
      guard let selectedCell = sender as? MemeTableViewCell,
        let indexPath = tableView.indexPath(for: selectedCell) else {
          return
      }
      
      controller.meme = memesPersistence.memes[indexPath.row]
    }
  }
  
  // MARK: - UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (isEmptyDataSource ? 1 : memesPersistence.memes.count)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isEmptyDataSource {
      let cell = tableView.dequeueReusableCell(withIdentifier: MemeTableViewEmptyDataSourceCell.reuseIdentifier, for: indexPath) as! MemeTableViewEmptyDataSourceCell
      cell.createMemeButton.addTarget(self, action: #selector(MemesTableViewController.createMeme), for: .touchUpInside)
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: MemeTableViewCell.reuseIdentifier) as! MemeTableViewCell
      
      let meme = memesPersistence.memes[indexPath.row]
      cell.memedImageView.image = meme.memedImage
      cell.memeTextLabel.text = "\(meme.topText) ᛫᛫᛫ \(meme.bottomText)"
      
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return (isEmptyDataSource
      ? MemeTableViewEmptyDataSourceCell.defaultHeight
      : MemeTableViewCell.defaultHeight)
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return !isEmptyDataSource
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      memesPersistence.memes.remove(at: indexPath.row)
      memesPersistence.saveMemes()
      
      if isEmptyDataSource {
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
      } else {
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
    }
  }
  
  // MARK: - UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return (isEmptyDataSource ? nil : indexPath)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  // MARK: Actions
  
  @objc func createMeme() {
    performSegue(withIdentifier: SegueIdentifier.createMeme.rawValue, sender: self)
  }
  
}

// MARK: - MemesTableViewController: MemeViewControllerDelegate

extension MemesTableViewController: MemeViewControllerDelegate {
  
  func memeViewController(_ controller: MemeViewController, didDoneOnMemeShare meme: Meme) {
    if controller.presentationType == MemeViewControllerPresentationType.createMeme {
      memesPersistence.memes.append(meme)
      memesPersistence.saveMemes()
      tableView.reloadData()
    }
  }
  
  func memeViewController(_ controller: MemeViewController, didDoneOnMemeEditing meme: Meme) {
    memesPersistence.saveMemes()
    tableView.reloadData()
  }
  
  func memeViewController(_ controller: MemeViewController, didSelectRemoveMeme meme: Meme) {
    let index = memesPersistence.memes.index(of: meme)!
    memesPersistence.memes.remove(at: index)
    memesPersistence.saveMemes()
    tableView.reloadData()
  }
  
}
