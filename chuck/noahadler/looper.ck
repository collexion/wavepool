// Live looping setup using an FCB1010, Ax100, TouchOSC

adc => LiSa looper => dac;
adc => JCRev r => dac;

float stringVol[6];
int stringPitch[6];
float stringFreq[6];

0 => int octaveShift;
0 => r.mix;

40::second => looper.duration;
1 => looper.loop;
1 => looper.loopRec;
1 => looper.play;
1.0 => looper.rate;

MidiIn min;
MidiMsg msg;

MidiIn midiFootController;

if ( !midiFootController.open(8) )
{
	<<<"Failed to open MIDIsport front panel for FCB1010">>>;
	me.exit();
}

<<< "Opened footcontroller on ", midiFootController >>>;
spork ~ FootpedalMIDIController(midiFootController);

//open midi receiver, exit on fail
if ( !min.open(1) )
{
	<<<"Failed to open MIDI input">>>;
	me.exit();
}

<<< "Opened MIDI input ", min >>>;

fun void FootpedalMIDIController(MidiIn fc)
{
	now => time loopStart;

	while (true)
	{
		fc => now;

		while(fc.recv(msg))
		{
			msg.data1 & 15 => int channel;
			msg.data1 / 16 => int command;
			
			<<< channel, command, msg.data2, msg.data3 >>>;

			if (channel == 6 && command == 9 && msg.data2 == 1)
			{
				<<< "RECORD" >>>;
				if (msg.data3 > 0)
				{
					now => loopStart;
					0::samp => looper.recPos => looper.playPos;
					1 => looper.record;
				}
				else if (msg.data3 == 0)
				{
					0 => looper.record;
					1 => looper.loop;
					1 => looper.play;
					now - loopStart => looper.loopEnd;
					<<< "Loop from ", loopStart, " to ", now >>>;
				}
			}

		}
	}
}


fun void ProcessMidiGuitar(MidiIn midiGuitarIn)
{
	while( true )
	{
		// wait on midi event
		midiGuitarIn => now;
		
		// receive midimsg(s)
		while( midiGuitarIn.recv( msg ) )
		{
			msg.data1 & 15 => int channel;
			msg.data1 / 16 => int command;
			
			<<< channel, command, msg.data2, msg.data3 >>>;
			
			if (command == 9)
			{
				//spork ~ MandoNote(mando, msg.data2 + 12);
				//spork ~ PluckString(channel, msg.data2);
				msg.data2 => stringPitch[channel];
				Std.mtof(12*octaveShift + stringPitch[channel]) => stringFreq[channel];
				msg.data3 => stringVol[channel];
				//mando[channel].noteOn(msg.data3/127.0);
				
			}
			else if (command == 8)
			{
				//mando[channel].noteOff(msg.data3/127.0);
				0 => stringVol[channel];
			}
			else if (command == 14)
			{
				// pitch bend
				Std.mtof(12*octaveShift + stringPitch[channel] + 12*(msg.data3*128 + msg.data2)/8192.0) => stringFreq[channel];
			}
			else if (command == 11)
			{
				// CC
				if (msg.data2 == 7)
				{
					for (0 => int i; i<6; ++i)
					{
						//0.1 * msg.data3/127.0 => mando[i].gain;
					}
				}
			}
		}
	}
}



while (true)
{
	1::second => now;
}

