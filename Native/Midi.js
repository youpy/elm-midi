Elm.Native = Elm.Native || {};
Elm.Native.Midi = {};
Elm.Native.Midi.make = function(localRuntime) {
  Elm.Native.Midi.midi = Elm.Native.Midi.midi || null;
  Elm.Native.Midi.inputs = Elm.Native.Midi.inputs || [];

  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.Midi = localRuntime.Native.Midi || {};
  if (localRuntime.Native.Midi.values) {
    return localRuntime.Native.Midi.values;
  }

  var Signal = Elm.Signal.make(localRuntime);
  var List = Elm.Native.List.make(localRuntime);

  var incoming = Signal.constant({
    input: {
      id: '',
      manufacturer: '',
      name: ''
    },
    receivedTime: 0,
    midiData: List.fromArray([0, 0, 0])
  });

  function onMIDIInit(m) {
    var midi;
    var inputId;

    Elm.Native.Midi.midi = midi = m;

    if (midi.inputs.size > 0) {
      var it = midi.inputs.values();
      for (var o = it.next(); !o.done; o = it.next()) {
        Elm.Native.Midi.inputs.push(o.value);
      }

      Elm.Native.Midi.inputs.forEach(function(input) {
        input.onmidimessage = function(event) {
          MIDIMessageEventHandler(
            input.id,
            input.manufacturer,
            input.name,
            event
          );
        };
      });
    }
  }

  function onMIDIReject(err) { console.log(err); }

  function MIDIMessageEventHandler(id, manufacturer, name, event) {
    localRuntime.notify(incoming.id, {
      input: {
        id: id,
        manufacturer: manufacturer,
        name: name
      },
      receivedTime: event.receivedTime,
      midiData: List.fromArray(event.data)
    });
  }

  if (navigator.requestMIDIAccess) {
    navigator.requestMIDIAccess().then(onMIDIInit, onMIDIReject);
  }

  return localRuntime.Native.Midi.values = {
    incoming: incoming
  };
};
