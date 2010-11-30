JCRev r => dac;

Mandolin mando[6];

for (0 => int i; i<6; ++i)
{
	0.1 => mando[i].gain;
	mando[i] => r;
}

0.1 => r.mix;


function void MandoNote(StkInstrument mando, int midiNote)
{
	Std.mtof(midiNote) => mando.freq;
	mando.noteOn(0.75);
	1::second => now;
	mando.noteOff(0.15);
	1::second => now;
}

//spork ~ MandoNote(mando, 60);

MidiIn min;
MidiMsg msg;

//open midi receiver, exit on fail
if ( !min.open(1) )
{
	<<<"Failed to open MIDI input">>>;
	me.exit();
}

//MidiGuitarString strings[6];
float stringVol[6];
int stringPitch[6];
float stringFreq[6];

public void PluckString(int string, int note)
{
	note => stringPitch[string];
	Std.mtof(note) => stringFreq[string] => mando[string].freq;
	mando[string].noteOn(0.5);
	1::second => now;
	mando[string].noteOff(0.5);
}

while( true )
{
	// wait on midi event
	min => now;
	
	// receive midimsg(s)
	while( min.recv( msg ) )
	{
		msg.data1 & 15 => int channel;
		msg.data1 / 16 => int command;
		
		//<<< channel, command, msg.data2, msg.data3 >>>;
		
		if (command == 9)
		{
			//spork ~ MandoNote(mando, msg.data2 + 12);
			//spork ~ PluckString(channel, msg.data2);
			msg.data2 => stringPitch[channel];
			Std.mtof(stringPitch[channel]) => stringFreq[channel];
			mando[channel].noteOn(msg.data3/127.0);
			
		}
		else if (command == 8)
		{
			mando[channel].noteOff(msg.data3/127.0);
		}
		else if (command == 14)
		{
			// pitch bend
			Std.mtof(stringPitch[channel] + 12*(msg.data3*127 + msg.data2)/8192.0) => stringFreq[channel] => mando[channel].freq;
		}
	}
}