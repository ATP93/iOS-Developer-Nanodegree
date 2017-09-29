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

// MARK: - PlayRecordViewController

extension PlayRecordViewController {
  
  // MARK: Types
  
  enum PlayingState {
    case playing
    case notPlaying
  }
  
  fileprivate struct Alerts {
    static let DismissAlert = "Dismiss"
    static let RecordingDisabledTitle = "Recording Disabled"
    static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
    static let RecordingFailedTitle = "Recording Failed"
    static let RecordingFailedMessage = "Something went wrong with your recording."
    static let AudioRecorderError = "Audio Recorder Error"
    static let AudioSessionError = "Audio Session Error"
    static let AudioRecordingError = "Audio Recording Error"
    static let AudioFileError = "Audio File Error"
    static let AudioEngineError = "Audio Engine Error"
  }
  
  // MARK: Audio Functions
  
  func setupAudio() {
    // initialize (recording) audio file
    do {
      audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
    } catch {
      showAlert(Alerts.AudioFileError, message: String(describing: error))
    }
    print("Audio has been setup")
  }
  
  func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
    
    // initialize audio engine components
    audioEngine = AVAudioEngine()
    
    // node for playing audio
    audioPlayerNode = AVAudioPlayerNode()
    audioEngine.attach(audioPlayerNode)
    
    // node for adjusting rate/pitch
    let changeRatePitchNode = AVAudioUnitTimePitch()
    if let pitch = pitch {
      changeRatePitchNode.pitch = pitch
    }
    if let rate = rate {
      changeRatePitchNode.rate = rate
    }
    audioEngine.attach(changeRatePitchNode)
    
    // node for echo
    let echoNode = AVAudioUnitDistortion()
    echoNode.loadFactoryPreset(.multiEcho1)
    audioEngine.attach(echoNode)
    
    // node for reverb
    let reverbNode = AVAudioUnitReverb()
    reverbNode.loadFactoryPreset(.cathedral)
    reverbNode.wetDryMix = 50
    audioEngine.attach(reverbNode)
    
    // connect nodes
    if echo == true && reverb == true {
      connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
    } else if echo == true {
      connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
    } else if reverb == true {
      connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
    } else {
      connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
    }
    
    // schedule to play and start the engine!
    audioPlayerNode.stop()
    audioPlayerNode.scheduleFile(audioFile, at: nil) {
      var delayInSeconds: Double = 0
      
      if let lastRenderTime = self.audioPlayerNode.lastRenderTime,
        let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
        if let rate = rate {
          delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
        } else {
          delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
        }
      }
      
      // schedule a stop timer for when audio finishes playing
      self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(self.stopAudio), userInfo: nil, repeats: false)
      RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    do {
      try audioEngine.start()
    } catch {
      showAlert(Alerts.AudioEngineError, message: String(describing: error))
      return
    }
    
    // play the recording!
    audioPlayerNode.play()
  }
  
  @objc func stopAudio() {
    if let stopTimer = stopTimer {
      stopTimer.invalidate()
    }
    
    configureUI(.notPlaying)
    
    if let audioPlayerNode = audioPlayerNode {
      audioPlayerNode.stop()
    }
    
    if let audioEngine = audioEngine {
      audioEngine.stop()
      audioEngine.reset()
    }
  }
  
  // MARK: Connect List of Audio Nodes
  
  fileprivate func connectAudioNodes(_ nodes: AVAudioNode...) {
    for x in 0..<nodes.count-1 {
      audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
    }
  }
  
  // MARK: UI Functions
  
  private func configureUI(_ playState: PlayingState) {
    switch(playState) {
    case .playing:
      setPlayButtonsEnabled(false)
      stopButton.isEnabled = true
    case .notPlaying:
      setPlayButtonsEnabled(true)
      stopButton.isEnabled = false
    }
  }
  
  fileprivate func setPlayButtonsEnabled(_ enabled: Bool) {
    snailButton.isEnabled = enabled
    chipmunkButton.isEnabled = enabled
    rabbitButton.isEnabled = enabled
    darthvaderButton.isEnabled = enabled
    echoButton.isEnabled = enabled
    reverbButton.isEnabled = enabled
  }
  
  fileprivate func showAlert(_ title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
}
