;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NAME: alix novosi                                                                               ;
; PURPOSE: Autohotkey + pikatea soundboard with mode switch.                                      ;
; DATE : 2021-04-12                                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Recommended for performance and compatibility with future AutoHotkey releases.
#NoEnv
; Enable warnings to assist with detecting common errors.
#Warn
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%
#singleinstance, force

; PlaySound is defined here.
; file generated via Python script so I can get JSON-defined data without having to
; write something to parse it.
#Include soundboard_data.ahk

; non-class functions
StopPlayback() {
    SoundPlay, _nocreate_test.wav
    return
}

Speak(thing) {
    ComObjCreate("SAPI.SpVoice").Speak(thing)
    return
}

; state and state functions
class State {
    ; four presses four holds per bank,
    ; because meta key reserved.
    static bank_size = 8

    __New() {
        ; modes - production/dev switch, debug.
        this.prod := false
        this.debug := false

        this.bank_idx := 0

        ; whether we're in bank-choosing mode or not.
        this.meta_mode := false
    }

    HandlePress(idx) {
        StopPlayback()

        ; First key goes to previous bank if pressed in meta mode.
        ; Otherwise it's an implicit mute.
        if (idx == "meta_0" and this.meta_mode) {
            this.meta_mode := false
            if (this.debug) {
                Speak("Meta off previous bank")
            }
            return
        }

        ; TODO can you get this to run the preprocessor in a not-awful way?
        if (idx == "meta_0" and not this.meta_mode) {
            return
        }

        ; first key hold, toggles meta mode.
        if (idx == "meta_1" and not this.meta_mode) {
            if (this.debug) {
                Speak("Meta on")
            }
            this.meta_mode := true
            return

        }

        if (idx == "meta_1") {
            idx = 0
        }

        if (this.meta_mode) {
            this.bank_idx := idx
            this.meta_mode := false

            if (this.debug) {
                Speak("setting bank id")
                Speak(this.bank_idx)
            }
            return
        }

        ; calculate full index including bank.
        idx += this.bank_idx * this.bank_size
        SoundPlay, yojackass.birdsite.wav
        if (this.debug) {
            Speak("playing sound" + idx)
        }
        PlaySound(idx)
        return
    }

}

NewState := new State()

; meta keys
F13::
    NewState.HandlePress("meta_0")
    return

+F13::
    NewState.HandlePress("meta_1")
    return

; regular keys
F14::
    NewState.HandlePress(1)
    return

F15::
    NewState.HandlePress(2)
    return

F16::
    NewState.HandlePress(3)
    return

F17::
    NewState.HandlePress(4)
    return


; shift+key (hold presses)
+F14::
    NewState.HandlePress(5)
    return

+F15::
    NewState.HandlePress(6)
    return

+F16::
    NewState.HandlePress(7)
    return

+F17::
    NewState.HandlePress(8)
    return
