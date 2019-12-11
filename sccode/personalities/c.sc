var channel = 3;
var isHit = false;
var notes = [12,11,9,7,5,4,2,0];
var roots = [0,3,8];
var note = notes[0];

~init = {|midiOut, bf|
	"c init".postln;

	Pdef(\c,
		Pbind(
			\note, Pseq([0,4,7,4,7,12,16,7,12].stutter(1),inf),
			\func, Pfunc({|e| bf.(e)}),
			// \root, Pseq([0,3].stutter(36),inf),
			//\root, Pseq([0,3].stutter(12),inf),
			\args, #[],
		);
	);

	Pdef(\c).set(\dur,0.5);
	Pdef(\c).set(\octave,4);
	Pdef(\c).set(\amp,0.8);
	Pdef(\c).set(\type,\midi);
	Pdef(\c).set(\midiout,midiOut);
	Pdef(\c).set(\chan,channel);
	Pdef(\c).play();


};
~community = {|b,e|
	// [e].postln;
	//b.env.postln;
};

~volume = {|v|
	Pdef(\c).set(\amp,v);
};

~update = {|blobs,i,midiOut|

	var beat = (blobs[0].pWidth.rateFiltered.explin(30,120,1,16).floor).reciprocal * 0.8;
	var ca = (blobs[0].pWidth.rateFiltered.linlin(30,120,0,127).floor).asInteger;
	var oct = (blobs[0].center.x.linlin(130,600,0,4).floor).asInteger;


	var a = blobs[0].rect;
	var b = blobs[1].rect;



	if( blobs[0].area > 4, {
		if( blobs[1].area > 4, {
			isHit = false;
		},{
			if(isHit == false, {
				isHit = true;

				if(note == 12,{
					roots = roots.rotate(-1);
					blobs[0].root = roots[0];
					blobs[1].root = roots[0];

				});
				notes = notes.rotate(-1);
				note = notes[0];

				midiOut.noteOn(5, 60 + note + blobs[0].root, 100);
				{midiOut.allNotesOff(5)}.defer(0.1);

			});

		});

	},{
		isHit = false;

		});

	Pdef(\c).set(\octave,3+oct);
	Pdef(\c).set(\dur,beat);
	Pdef(\c).set(\root,blobs[0].root);
	midiOut.control(channel, 25, ca);



};

~deinit = {|midiOut|
	"c deinit".postln;

	Pdef(\c).stop();
	Pdef(\c).clear;
	midiOut.allNotesOff(channel);
	midiOut.allNotesOff(5);

};


