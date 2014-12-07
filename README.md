# elm-midi

This library provides function for working with MIDI. It currently supports MIDI inputs.

```elm
import Midi

main : Signal Element
main =
    asText <~ (Midi.note <~ (keepIf Midi.isNoteOn Midi.emptyMessage Midi.incoming))
```
