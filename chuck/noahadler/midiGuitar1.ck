// Performed this using a Godin LGXSA and Axon100
// on November 29 at Collexion (opening for Dave Farris and Tatsuya Nakatani)
// The performance was a qualified success -- unique but lacklustre

adc => JCRev r => dac;

Mandolin mando[6];

for (0 => int i; i<6; ++i)
{
	0.1 => mando[i].gain;
	mando[i] => r;
}

0.001 => r.mix;

0.5 => float legato;
-1 => int octaveShift;

0.125::second => dur qn;

// long running process controls beat
fun void TempoShift()
{
	0.25::second => qn;
	
	// accelerando for one minute to 0.125::second
	now => time accel_begin;
	1::minute + accel_begin => time accel_end;
	while (now < accel_end)
	{
		(accel_end - now) / (accel_end - accel_begin) => float t;
		0.25::second * t + 0.125::second * (1-t) => qn;
		qn => now;
	}
	
}

fun void ModulateReverb(float start_mix, float end_mix, dur length)
{
	// accelerando for one minute to 0.125::second
	now => time begin;
	length + begin => time end;
	while (now < end)
	{
		(end - now) / (end - begin) => float t;
		t*start_mix + (1-t)*end_mix => r.mix;
		qn => now;
	}
}

fun void OctaveBounces()
{
	-2 => octaveShift;
	8::qn => now;
	-1 => octaveShift;
	8::qn => now;
	0 => octaveShift;
	4::qn => now;
	1 => octaveShift;
	4::qn => now;
	2 => octaveShift;
	4::qn => now;
	
	now + 32::qn => time end;
	while (now < end)
	{
		Std.rand2(-2,2) => octaveShift;
		qn => now;
	}
}

fun void LegatoWarp(float start, float end, dur length)
{
	now + length => time end_time;
	
	while (now < end_time)
	{
		(end_time - now) / length => float t;
		t*start + (1-t)*end => legato;
		qn => now;
	}
}

fun void TenMinutes()
{
	now + 10::minute => time performance;
	
	spork ~ LegatoWarp(0.1, 0.7, 30::second);
	spork ~ TempoShift();
	spork ~ ModulateReverb(0.5, 0, 0.5::minute);
	spork ~ OctaveBounces();	
		
	
	while (now < performance)
	{
		
		Std.rand2f(0.5,1) * 0.5::minute => now;
		
		Std.rand2(0,4) => int which;
		if (which == 0)
		{
			spork ~ LegatoWarp(Std.rand2f(0.1,0.9), Std.rand2f(0.1,0.9), Std.rand2f(1.0,3.0) * 10::second);
		}
		
		0.01 => r.mix;
		
		1::minute => now;
		
		
	}
	
}

spork ~ TenMinutes();

float stringVol[6];
int stringPitch[6];
float stringFreq[6];

// run arp on single string
fun void ArpGrid(int channel, int beats[])
{
	while (true)
	{
		for (0 => int beat; beat<beats.cap(); ++beat)
		{
			if (stringVol[channel] > 0 && beats[beat] == 1)
			{
				mando[channel].noteOn(stringVol[channel] / 127.0);
				legato * 1::qn => now;
				mando[channel].noteOff(stringVol[channel] / 127.0);
				(1-legato) * 1::qn => now;
			}
			else
			{
				1::qn => now;
			}
		}
	}
}


MidiIn min;
MidiMsg msg;

//open midi receiver, exit on fail
if ( !min.open(1) )
{
	<<<"Failed to open MIDI input">>>;
	me.exit();
}

//MidiGuitarString strings[6];


for (0 => int chan; chan<6; ++chan)
{
	int beats[Std.rand2(1,2)*Std.rand2(1,2)*4];
	for (0 => int beat; beat<beats.cap(); ++beat)
		Std.rand2(0,1) => beats[beat];
	spork ~ ArpGrid(chan, beats);
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
			Std.mtof(12*octaveShift + stringPitch[channel] + 12*(msg.data3*128 + msg.data2)/8192.0) => stringFreq[channel] => mando[channel].freq;
		}
		else if (command == 11)
		{
			// CC
			if (msg.data2 == 7)
			{
				for (0 => int i; i<6; ++i)
				{
					0.1 * msg.data3/127.0 => mando[i].gain;
				}
			}
		}
	}
}
