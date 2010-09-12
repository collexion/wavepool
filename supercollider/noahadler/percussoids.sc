// experiments in percussive synthesizers

SynthDef.new("nihauphone", { arg pitch=60; Out.ar(0,SinOsc.ar(pitch.midicps) * XLine.ar(1, 0.0000001, 0.5) ); }).play;

SynthDef.new("cymbal", { arg freq=25000; Out.ar(0, XLine.ar(1, 0.0000001, 3.5) * LFNoise0.ar(freq, 0.25);) }).add;

x = Synth.new("cymbal", [\freq, [100, 200, 300, 400, 1000, 10000].choose]).play;
y = Synth.new("nihauphone", [\pitch, [60, 62, 63, 65, 67].choose]).play;

e = Pbind(\dur, 0.25, \instrument, Prand([\nihauphone, \cymbal], inf)).play;

