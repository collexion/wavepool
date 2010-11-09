public class Noahstrument
{
    SinOsc s => PoleZero pz => JCRev r;
    440 => s.freq;
    0.25 => pz.a1;
    0.4 => pz.gain;
    
    public void connect(UGen o)
    {
        r => o;
    }
    
    public int pitch(int p)
    {
        Std.mtof(p) => s.freq;
    }
}

Noahstrument n;
n.connect(dac);

72 => n.pitch;
1::second => now;
67 => n.pitch;
1::second => now;
65 => n.pitch;
0.5::second => now;
60 => n.pitch;
2::second => now;
