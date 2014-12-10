import Midi
import Signal (..)
import Text (..)
import Graphics.Element (..)

main : Signal Element
main =
    asText << Midi.note <~ keepIf Midi.isNoteOn Midi.emptyMessage Midi.incoming
