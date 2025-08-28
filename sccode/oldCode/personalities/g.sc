var channel = 8;
var name = \g;
var isHit = false;
var roots = [0,5,2].stutter(8);

~init = {|midiOut, bf|
	"d init".postln;

	~pattern = Pdef(name,
		~bind = Pbind(
			\note, Pseq([0,0,0,2,2,2,5,5,4,9,9,9,7,7,11,12,7,7,5,5,5,5,4,5,7,7,7,7].stutter(1),inf),
			\func, Pfunc({|e| bf.(e)}),
			\args, #[],
		);
	);

	Pdef(name).set(\dur,0.5);
	//Pdef(name).set(\root,0);
	// Pbindef(name, \root, Pseq([0,3,8,5].stutter(64),inf));
	// Pbindef(name, \octave, 3);
	Pdef(name).set(\octave,3);
	Pdef(name).set(\amp,0.8);
	Pdef(name).set(\type,\midi);
	Pdef(name).set(\midiout,midiOut);
	Pdef(name).set(\chan,channel);
	Pdef(name).play();


};
~community = {|b,e|
	// [b,e].postln;
};


~volume = {|v|
	Pdef(name).set(\amp,v);
};

~update = {|blobs,i,midiOut|

	var beat = 2.pow(blobs[0].pWidth.rateFiltered.explin(30,120,1,4).floor).reciprocal;
	var oct = (blobs[0].pWidth.rateFiltered.linexp(30,120,1,4).floor);
	var ca = (blobs[0].pWidth.rateFiltered.linlin(30,120,110,30).floor);
	var cb = (blobs[0].pWidth.rateFiltered.linlin(30,120,80,60).floor);
	var cc = (blobs[0].pWidth.rateFiltered.linlin(30,120,80,0).floor);
	
	Pdef(name).set(\dur,beat);
	Pdef(name).set(\octave, 3 + oct);

	if( blobs[0].area > 4, {
		if( blobs[1].area > 4, {
			isHit = false;
		},{
			if(isHit == false, {
				isHit = true;

				roots = roots.rotate(-1);
				Pdef(name).set(\root,roots[0]);
				midiOut.noteOn(4, 60 + roots[0] - [12,24].choose, 85);
				{midiOut.allNotesOff(4)}.defer(0.1);

			});

		});

	},{
		isHit = false;

	});

	midiOut.control(channel, 22, ca);
	midiOut.control(channel, 23, cb);
	// midiOut.control(channel, 28, cc);
};

~deinit = {|midiOut|
	"d deinit".postln;

	Pdef(name).stop();
	Pdef(name).clear;
	midiOut.allNotesOff(channel);
	midiOut.allNotesOff(4);

};
