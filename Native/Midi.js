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
  var Utils = Elm.Native.Utils.make(localRuntime);
  var List = Elm.Native.List.make(localRuntime);

  var incomingInputId = Signal.constant('');
  incomingInputId.defaultNumberOfKids = 1;

  var incomingInputManufacturer = Signal.constant('');
  incomingInputManufacturer.defaultNumberOfKids = 1;

  var incomingInputName = Signal.constant('');
  incomingInputName.defaultNumberOfKids = 1;

  var incomingData = Signal.constant(List.fromArray([0, 0, 0]));
  incomingData.defaultNumberOfKids = 1;

  var receivedTime = Signal.constant(0);
  receivedTime.defaultNumberOfKids = 1;

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
    localRuntime.notify(incomingInputId.id, id);
    localRuntime.notify(incomingInputManufacturer.id, manufacturer);
    localRuntime.notify(incomingInputName.id, name);
    localRuntime.notify(incomingData.id, List.fromArray(event.data));
    localRuntime.notify(receivedTime.id, event.receivedTime);
  }

  if (navigator.requestMIDIAccess) {
    navigator.requestMIDIAccess().then(onMIDIInit, onMIDIReject);
  }

  return localRuntime.Native.Midi.values = {
    incomingInputId: incomingInputId,
    incomingInputManufacturer: incomingInputManufacturer,
    incomingInputName: incomingInputName,
    incomingData: incomingData,
    receivedTime: receivedTime
  };
};
