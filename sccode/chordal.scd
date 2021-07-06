(
{
var root, scale;
		var trig, p, s, exc, x, freq;
		root = 40;
		// scale = #[0,7,9,11,14,16];
			freq = (root).midicps;
			exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
			e = SinOsc.ar([freq,freq+1],0,0.1);
			s = (Klank.ar(`[
					Array.series(12, [freq,freq+1], [freq,freq+1]),
					Array.geom(12,1,rrand(0.5,0.9)),
					Array.fill(12, {rrand(1.0,3.0)})
				], exc) * 0.1).softclip;
			s = Splay.ar(s+e);
}.play;
)
