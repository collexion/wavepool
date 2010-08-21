// F5 = Run a block encased by parens from anywhere in it
// F6 = Run a single line
// F8 = Kill the noise

s.boot()

({RLPF.ar(
    in: Saw.ar([100, 102], 0.15),
    freq: Lag.kr(LFNoise0.kr(4, 700, 1100), 0.1),
    rq: 0.05
)}.play)
