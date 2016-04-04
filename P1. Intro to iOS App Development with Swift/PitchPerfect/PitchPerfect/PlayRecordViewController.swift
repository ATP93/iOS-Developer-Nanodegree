//
//  PlayRecordViewController.swift
//  PitchPerfect
//
//  Created by Ivan Magda on 03.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import AVFoundation

//----------------------------------------------------
// MARK: - ButtonType: Int
//----------------------------------------------------

/// Raw values correspond to sender tags.
private enum ButtonType: Int {
    case Slow = 0, Fast, Chipmunk, Vader, Echo, Reverb
}

//----------------------------------------------------
// MARK: - PlayRecordViewController: UIViewController
//----------------------------------------------------

class PlayRecordViewController: UIViewController {
    
    //---------------------------------------------
    // MARK: Properties
    //---------------------------------------------
    
    var recordedAudioURL: NSURL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: NSTimer!
    
    //---------------------------------------------
    // MARK: Outlets
    //---------------------------------------------
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var darthvaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    //---------------------------------------------
    // MARK: View Life Cycle
    //---------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(recordedAudioURL != nil, "Recorded audio file URL must exist.")
        setupAudio()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.NotPlaying)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudio()
    }
    
    //---------------------------------------------
    // MARK: Actions
    //---------------------------------------------
    
    @IBAction func playRecordWithEffectDidPressed(sender: UIButton) {
        switch ButtonType(rawValue: sender.tag)! {
        case .Slow:
            playSound(rate: 0.5)
        case .Fast:
            playSound(rate: 1.5)
        case .Chipmunk:
            playSound(pitch: 1000)
        case .Vader:
            playSound(pitch: -1000)
        case .Echo:
            playSound(echo: true)
        case .Reverb:
            playSound(reverb: true)
        }
        
        configureUI(.Playing)
    }
    
    @IBAction func stopPlayingDidPressed(sender: AnyObject) {
        stopAudio()
    }

}
