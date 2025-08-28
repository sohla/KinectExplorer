~init = {|midiOut|
	"b init".postln;

	Pdef(\melody,
		Pbind(
			\note, Pseq([[0,3],-2,0,[2,5],3,7,[5,8],5,3,[7,3],5,5,[3,0],2,-2,[-2,2]],inf),
			\args, #[],
		);
	);

	Pdef(\melody).set(\dur,0.5);
	Pdef(\melody).set(\root,9);
	Pdef(\melody).set(\octave,4);
	Pdef(\melody).set(\amp,0.8);
	Pdef(\melody).set(\type,\midi);
	Pdef(\melody).set(\midiout,midiOut);
	Pdef(\melody).set(\chan,2);
	Pdef(\melody).play();

};
~volume = {|v|
	Pdef(\melody).set(\amp,v);
};
~update = {|blobs,i,midiOut|
	var r = [3,4,5,6].reverse;
	
	var z = (blobs[1].center.y.linlin(350,450,0,3)).floor;
	// z.postln;
	Pdef(\melody).set(\octave,r[z]);

	Pdef(\melody).set(\dur,(blobs[0].pWidth.rateFiltered.abs * 0.04).reciprocal);

};


~deinit = {|midiOut|
	"b deinit".postln;
	Pdef(\melody).stop();
	Pdef(\melody).clear;
	midiOut.allNotesOff(2);

};
