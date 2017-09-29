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

import Foundation

// MARK: Types

private enum CoderKey: String {
  case memes
}

// MARK: - MemesPersistence

class MemesPersistence {
  
  // MARK: Properties
  
  var memes: [Meme]!
  
  // MARK: Init
  
  init() {
    loadMemes()
  }
  
  // MARK: Save/Load
  
  @discardableResult func saveMemes() -> Bool {
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: data)
    archiver.encode(memes, forKey: CoderKey.memes.rawValue)
    archiver.finishEncoding()
    
    do {
      try data.write(toFile: dataFilePath(), options: .atomic)
    } catch let e as NSError {
      print("Failed to save memes to the documents directory. Error: \(e.localizedDescription)")
      return false
    }
    
    return true
  }
  
  fileprivate func loadMemes() {
    func instantiateMemesArray() {
      memes = [Meme]()
    }
    
    let path = dataFilePath()
    if FileManager.default.fileExists(atPath: path) {
      guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
        instantiateMemesArray()
        return
      }
      
      let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
      guard let memes = unarchiver.decodeObject(forKey: CoderKey.memes.rawValue) as? [Meme] else {
        instantiateMemesArray()
        return
      }
      
      self.memes = memes
    } else {
      instantiateMemesArray()
    }
  }
  
  // MARK: Paths
  
  fileprivate func documentsDirectory() -> String {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  }
  
  fileprivate func dataFilePath() -> String {
    return (documentsDirectory() as NSString)
      .appendingPathComponent("\(CoderKey.memes.rawValue).plist")
  }
  
}
