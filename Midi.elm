module Midi where

{-| A Library for working with MIDI

# Midi Messages
@docs incoming

# Representing Notes
@docs note, isNoteOn, isNoteOff

# Utility Functions
@docs velocity, emptyMessage

-}

import Signal (Signal)
import Native.Midi
import Bitwise (and)

type Input = { id:String, name:String, manufacturer:String }
type IncomingMessage = { input:Input, receivedTime:Int, midiData:[Int] }
type Note = { noteNumber:Int, velocity:Int }

incomingInputId : Signal String
incomingInputId = Native.Midi.incomingInputId

incomingInputManufacturer : Signal String
incomingInputManufacturer = Native.Midi.incomingInputManufacturer

incomingInputName : Signal String
incomingInputName = Native.Midi.incomingInputName

incomingData : Signal [Int]
incomingData = Native.Midi.incomingData

receivedTime : Signal Int
receivedTime = Native.Midi.receivedTime

incomingInput : String -> String -> String -> Input
incomingInput id name manufacturer = { id=id, name=name, manufacturer=manufacturer }

incomingMessage : Input -> Int -> [Int] -> IncomingMessage
incomingMessage input receivedTime midiData = { input=input, receivedTime=receivedTime, midiData=midiData }

{-| The signal of incoming MIDI message.

A MIDI message has following attributes.

  * input
    * id -- the id of MIDI input
    * manufacturer -- the manufacturer of MIDI input
    * name -- the name of MIDI input
  * receivedTime -- the time that the message was received
  * midiData -- the midi data([Int])
-}
incoming : Signal IncomingMessage
incoming = lift3 incomingMessage
     (lift3 incomingInput incomingInputId incomingInputName incomingInputManufacturer)
     receivedTime
     incomingData

{-| Whether given message is "note on". -}
isNoteOn : IncomingMessage -> Bool
isNoteOn msg =
    let midiData = msg.midiData
        f = (head midiData) `and` 240
        vel = velocity midiData
    in
      case f of
        144 -> if vel == 0 then False else True
        _ -> False

{-| Whether given message is "note off". -}
isNoteOff : IncomingMessage -> Bool
isNoteOff msg =
    ((head msg.midiData) `and` 240) == 128

{-| Get following note information from given message.

  * noteNumber
  * velocity
-}
note : IncomingMessage -> Maybe Note
note msg =
    if (isNoteOff msg) || (isNoteOn msg)
    then Just { noteNumber=head <| tail msg.midiData, velocity=velocity msg.midiData }
    else Nothing

{-| The empty MIDI message. -}
emptyMessage : IncomingMessage
emptyMessage = { input=(incomingInput "" "" ""), receivedTime=0, midiData=[0, 0, 0] }

{-| Get velocity from MIDI data. -}
velocity : [Int] -> Int
velocity midiData = last <| take 3 midiData
