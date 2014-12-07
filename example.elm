import Midi

main : Signal Element
main =
    asText <~ (Midi.note <~ (keepIf Midi.isNoteOn Midi.empty Midi.incoming))
