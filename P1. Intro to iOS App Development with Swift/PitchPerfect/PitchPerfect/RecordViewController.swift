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

private let recordedAudioFileName = "recordedVoice.wav"

// MARK: SegueIdentifier: String

private enum SegueIdentifier: String {
  case playRecord = "playRecord"
}

// MARK: - RecordViewController: UIViewController

class RecordViewController: UIViewController {
  
  // MARK: Properties
  
  fileprivate var audioRecorder: AVAudioRecorder!
  fileprivate var shouldSegueToSoundPlayer = false
  
  // MARK: Outlets
  
  @IBOutlet weak var recordingLabel: UILabel!
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var stopRecordingButton: UIButton!
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if shouldSegueToSoundPlayer {
      do {
        let audioRecorder = try AVAudioRecorder(url: audioFileURL()!, settings: [:])
        performSegue(withIdentifier: SegueIdentifier.playRecord.rawValue, sender: audioRecorder)
        
        shouldSegueToSoundPlayer = false
      } catch let e as NSError {
        print("An error occured: \(e.localizedDescription)")
      }
    }
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == SegueIdentifier.playRecord.rawValue {
      guard let playRecordViewController = segue.destination as? PlayRecordViewController,
        let audioRecorder = sender as? AVAudioRecorder else {
          return
      }
      
      playRecordViewController.recordedAudioURL = audioRecorder.url
    }
  }
  
  // MARK: Helpers
  
  fileprivate func setup() {
    configureUI(.notPlaying)
    
    if let audioFilePath = audioFileURL()?.path {
      shouldSegueToSoundPlayer = FileManager.default.fileExists(atPath: audioFilePath)
    }
  }
  
  // MARK: Actions
  
  @IBAction func recordAudioDidPressed(_ sender: AnyObject) {
    configureUI(.playing)
    startRecording()
  }
  
  @IBAction func stopRecordingDidPressed(_ sender: AnyObject) {
    configureUI(.notPlaying)
    stopRecording()
  }
  
}

// MARK: - ViewController (Configure UI)

extension RecordViewController {
  
  // MARK: Types
  
  fileprivate enum PlayingState {
    case playing
    case notPlaying
  }
  
  // MARK: UI Functions
  
  fileprivate func configureUI(_ state: PlayingState) {
    switch state {
    case .playing:
      recordingLabel.text = "Recording in progress..."
      setControlEnabled(stopRecordingButton, enabled: true)
      setControlEnabled(recordButton, enabled: false)
    case .notPlaying:
      recordingLabel.text = "Tap to Record"
      setControlEnabled(stopRecordingButton, enabled: false)
      setControlEnabled(recordButton, enabled: true)
    }
  }
  
  fileprivate func setControlEnabled(_ control: UIControl, enabled: Bool) {
    control.isEnabled = enabled
  }
  
  fileprivate func showAlertWithTitle(_ title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
}

// MARK: - ViewController: AVAudioRecorderDelegate

extension RecordViewController: AVAudioRecorderDelegate {
  
  func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    if let error = error {
      print("Audio recorder, error during recording: \(error.localizedDescription).")
    }
  }
  
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    if flag {
      performSegue(withIdentifier: SegueIdentifier.playRecord.rawValue, sender: recorder)
    } else {
      print("Finished recording with failure.")
    }
  }
  
  // MARK: Helpers
  
  fileprivate func startRecording() {
    let filePath = audioFileURL()
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
      
      guard filePath != nil else {
        showAlertWithTitle("An error occured", message: "Please try again later.")
        return
      }
      
      debugPrint(filePath!)
      
      audioRecorder = try AVAudioRecorder(url: filePath!, settings: [:])
      audioRecorder.delegate = self
      audioRecorder.isMeteringEnabled = true
      audioRecorder.prepareToRecord()
      audioRecorder.record()
    } catch let exception as NSError {
      showAlertWithTitle("An error occured", message: exception.localizedDescription)
    }
  }
  
  fileprivate func stopRecording() {
    do {
      audioRecorder.stop()
      try AVAudioSession.sharedInstance().setActive(false)
    } catch let exception as NSError {
      showAlertWithTitle("Failed to stop recording", message: exception.localizedDescription)
    }
  }
  
  fileprivate func audioFileURL() -> URL? {
    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let recordingName = recordedAudioFileName
    
    return URL(fileURLWithPath: "\(dirPath)/\(recordingName)")
  }
  
}
