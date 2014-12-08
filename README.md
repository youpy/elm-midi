# elm-midi

This library provides function for working with MIDI using Web MIDI API.
It currently supports receiving MIDI messages from MIDI inputs.

```elm
import Midi

main : Signal Element
main =
    asText << Midi.note <~ keepIf Midi.isNoteOn Midi.emptyMessage Midi.incoming
```
