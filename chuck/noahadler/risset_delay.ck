adc.left => LiSa saveme => dac;
adc.left => NRev rev => dac;
Pan2 p;
-1 => p.pan;
0.1 => rev.mix;
//0 => revloop.mix;


5::second => saveme.duration;

1::second => dur slowest;
0.1::second => dur fastest;

20::second => dur accelerationtime;
now => time lastcycletime => time cycletime;

0::second => dur elapsed;

1 => saveme.loop;
1 => saveme.loopRec;

1::second => dur tick;

while (true)
{
	1 => saveme.record;
	0::samp => saveme.recPos;
	tick => now;
	0::samp => saveme.playPos;
	1 => saveme.play;
	tick => now;
	tick - 0.05::second => tick;
	if (tick == 0.5::second)
		slowest => tick;
	<<<tick>>>;
	1 => saveme.loopRec;
}

while (true)
{
	1 => saveme.record;
	now - lastcycletime +=> elapsed;
	now => lastcycletime;
	if (elapsed > accelerationtime)
		elapsed % accelerationtime => elapsed;
	//elapsed % accelerationtime => cycletime; 
	elapsed/accelerationtime => float t;
	<<<elapsed , "/" , accelerationtime , " = " , t>>>;
	if (t > 1) 1 => t;
	0::samp => saveme.recPos;
	slowest*t + fastest*(1-t)  => dur currentLapse => now;
	<<<currentLapse>>>;
	0 => saveme.record;
	50::ms => saveme.rampUp;
	//0 => saveme.playPos;
	0 => saveme.playPos;
	1 => saveme.play;
	currentLapse => now;
	//currentLapse => now;
}
