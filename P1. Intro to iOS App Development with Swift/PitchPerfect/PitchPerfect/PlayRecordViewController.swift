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
import AVFoundation

// MARK: - ButtonType: Int

/// Raw values correspond to sender tags.
private enum ButtonType: Int {
  case slow, fast, chipmunk, vader, echo, reverb
}

// MARK: - PlayRecordViewController: UIViewController

class PlayRecordViewController: UIViewController {
  
  // MARK: Properties
  
  var recordedAudioURL: URL!
  var audioFile: AVAudioFile!
  var audioEngine: AVAudioEngine!
  var audioPlayerNode: AVAudioPlayerNode!
  var stopTimer: Timer!
  
  // MARK: Outlets
  
  @IBOutlet weak var snailButton: UIButton!
  @IBOutlet weak var rabbitButton: UIButton!
  @IBOutlet weak var chipmunkButton: UIButton!
  @IBOutlet weak var darthvaderButton: UIButton!
  @IBOutlet weak var echoButton: UIButton!
  @IBOutlet weak var reverbButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    assert(recordedAudioURL != nil, "Recorded audio file URL must exist.")
    setupAudio()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureUI(.notPlaying)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopAudio()
  }
  
  // MARK: Actions
  
  @IBAction func playRecordWithEffectDidPressed(_ sender: UIButton) {
    switch ButtonType(rawValue: sender.tag)! {
    case .slow:
      playSound(rate: 0.5)
    case .fast:
      playSound(rate: 1.5)
    case .chipmunk:
      playSound(pitch: 1000)
    case .vader:
      playSound(pitch: -1000)
    case .echo:
      playSound(echo: true)
    case .reverb:
      playSound(reverb: true)
    }
    
    configureUI(.playing)
  }
  
  @IBAction func stopPlayingDidPressed(_ sender: AnyObject) {
    stopAudio()
  }
  
}
