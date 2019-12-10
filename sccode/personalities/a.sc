~init = {|midiOut|
	"a init".postln;

	Pdef(\drums,
		Pbind(
			\note, Pseq([0,1,2,3,4,5,6,7],inf),
			\args, #[],
		);
	);

	Pdef(\drums).set(\dur,0.5);
	Pdef(\drums).set(\octave,5);
	Pdef(\drums).set(\amp,0.8);
	Pdef(\drums).set(\type,\midi);
	Pdef(\drums).set(\midiout,midiOut);
	Pdef(\drums).set(\chan,0);
	Pdef(\drums).play();


	Pdef(\bass,
		Pbind(
			\note, Pseq([0,0,3,7,5,5,7,2],inf),
			\args, #[],
		);
	);

	Pdef(\bass).set(\dur,0.5);
	Pdef(\bass).set(\octave,2);
	Pdef(\bass).set(\amp,0.8);
	Pdef(\bass).set(\type,\midi);
	Pdef(\bass).set(\midiout,midiOut);
	Pdef(\bass).set(\chan,1);
	Pdef(\bass).play();
};


~update = {|blobs,i,midiOut|

	var r = [3,5,7,9];

	z = (4 - blobs[0].center.y.linlin(200,400,0,4).asInteger).max(r.size-1);

	Pdef(\drums).set(\dur,(blobs[0].pWidth.rateFiltered.abs * 0.04).reciprocal);
	Pdef(\bass).set(\dur,(blobs[0].pWidth.rateFiltered.abs * 0.04).reciprocal);
	Pdef(\bass).set(\root,r[z]);

};

~deinit = {|midiOut|
	"a deinit".postln;

	Pdef(\drums).stop();
	Pdef(\drums).clear;
	Pdef(\bass).stop();
	Pdef(\bass).clear;
	midiOut.allNotesOff(0);
	midiOut.allNotesOff(1);

};
