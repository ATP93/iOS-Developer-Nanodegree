//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Ivan Magda on 03.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import AVFoundation

//------------------------------------------------
// MARK: SegueIdentifier: String
//------------------------------------------------

private enum SegueIdentifier: String {
    case PlayRecord = "playRecord"
}

//------------------------------------------------
// MARK: - RecordViewController: UIViewController
//------------------------------------------------

class RecordViewController: UIViewController {
    
    //---------------------------------------------
    // MARK: Properties
    //---------------------------------------------
    
    private static let RecordedAudioFileName = "recordedVoice.wav"
    
    private var audioRecorder: AVAudioRecorder!
    
    //---------------------------------------------
    // MARK: Outlets
    //---------------------------------------------
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    //---------------------------------------------
    // MARK: View Life Cycle
    //---------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(.NotPlaying)
    }
    
    //---------------------------------------------
    // MARK: Navigation
    //---------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.PlayRecord.rawValue {
            guard let playRecordViewController = segue.destinationViewController as? PlayRecordViewController,
                let audioRecorder = sender as? AVAudioRecorder else {
                return
            }
            
            playRecordViewController.recordedAudioURL = audioRecorder.url
        }
    }
    
    //------------------------------------------------
    // MARK: Actions
    //------------------------------------------------

    @IBAction func recordAudioDidPressed(sender: AnyObject) {
        configureUI(.Playing)
        startRecording()
    }
    
    @IBAction func stopRecordingDidPressed(sender: AnyObject) {
        configureUI(.NotPlaying)
        stopRecording()
    }
    
}

//---------------------------------------
// MARK: - ViewController (Configure UI)
//---------------------------------------

extension RecordViewController {
    
    //---------------------------------------
    // MARK: Types
    //---------------------------------------
    
    private enum PlayingState {
        case Playing
        case NotPlaying
    }
    
    //---------------------------------------
    // MARK: UI Functions
    //---------------------------------------
    
    private func configureUI(state: PlayingState) {
        switch state {
        case .Playing:
            recordingLabel.text = "Recording in progress..."
            setControlEnabled(stopRecordingButton, enabled: true)
            setControlEnabled(recordButton, enabled: false)
        case .NotPlaying:
            recordingLabel.text = "Tap to Record"
            setControlEnabled(stopRecordingButton, enabled: false)
            setControlEnabled(recordButton, enabled: true)
        }
    }
    
    private func setControlEnabled(control: UIControl, enabled: Bool) {
        control.enabled = enabled
    }
    
    private func showAlertWithTitle(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//-------------------------------------------------
// MARK: - ViewController: AVAudioRecorderDelegate
//-------------------------------------------------

extension RecordViewController: AVAudioRecorderDelegate {
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        if let error = error {
            print("Audio recorder, error during recording: \(error.localizedDescription).")
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegueWithIdentifier(SegueIdentifier.PlayRecord.rawValue, sender: recorder)
        } else {
            print("Finished recording with failure.")
        }
    }
    
    //---------------------------------------------
    // MARK: Helpers
    //---------------------------------------------
    
    private func startRecording() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let recordingName = RecordViewController.RecordedAudioFileName
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            guard filePath != nil else {
                showAlertWithTitle("An error occured", message: "Please try again later.")
                return
            }
            
            debugPrint(filePath!)
            
            audioRecorder = try AVAudioRecorder(URL: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch let exception as NSError {
            showAlertWithTitle("An error occured", message: exception.localizedDescription)
        }
    }
    
    private func stopRecording() {
        do {
            audioRecorder.stop()
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let exception as NSError {
            showAlertWithTitle("Failed to stop recording", message: exception.localizedDescription)
        }
    }
    
}

