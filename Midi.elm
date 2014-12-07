module Midi where

{-| A Library for working with MIDI

@docs incoming
@docs empty
@docs isNoteOn
@docs isNoteOff
@docs note
@docs velocity

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

{-| The incoming MIDI message -}
incoming : Signal IncomingMessage
incoming = lift3 incomingMessage
     (lift3 incomingInput incomingInputId incomingInputName incomingInputManufacturer)
     receivedTime
     incomingData

{-| The empty MIDI message -}
empty = { input=(incomingInput "" "" ""), receivedTime=0, midiData=[0, 0, 0] }

isNoteOn : IncomingMessage -> Bool
isNoteOn msg =
    let midiData = msg.midiData
        f = (head midiData) `and` 240
        vel = velocity midiData
    in
      case f of
        144 -> if vel == 0 then False else True
        _ -> False

isNoteOff : IncomingMessage -> Bool
isNoteOff msg =
    ((head msg.midiData) `and` 240) == 128

note : IncomingMessage -> Maybe Note
note msg =
    if (isNoteOff msg) || (isNoteOn msg)
    then Just { noteNumber=head <| tail msg.midiData, velocity=velocity msg.midiData }
    else Nothing

velocity : [Int] -> Int
velocity midiData = last <| take 3 midiData
