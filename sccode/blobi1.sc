
	(
	var window, routine;
	var graphView, updateGraphView;
	var oscListener;
	var midiOut;
	var numBlobs;
	var ptn = Array.fill(16,{|i|i=90.rrand(65).asAscii});
	var synth = Synth.new(\dk_blobi);

		// var notes = [-5,-5,-3,-5,0,-1,-5,-5,-3,-5,2,0,-5,-5,7,4,0,-1,-3,5,5,4,0,2,0];
//		var notes = [0,3,2,-2,-4,0,-2,2];
		// var notes = [0,12,0,12,10,9,7];
		// var note = notes[0];

	var blobModel = (
				\area: 0,
				\prevArea: 0,
				\areaRate: 0,
				\areaRateFiltered: 0,
				\dataSize: 3,
				\perimeter: 0,
				\center: Point(0,0),
				\rect: Rect(0,0,20,20),
				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\velocity: 100,
				\notes: [0,12,0,12,10,9,7],
				\note: 0,

	);

	var filter = {|input,history,friction = 0.5|
		(friction * input + ((1 - friction) * history))
	};

	var blobs = Array.fill(1,{Event.new(proto:blobModel)});

	//------------------------------------------------------

	//------------------------------------------------------

	blobs[0].notes = [0,5,4,7,5,10,9,5,4,7,2,-2];
	blobs[0].velocity = 10;
	// blobs[1].root = 60 - 24;

	blobs.do({|b,i|
		b.channel = i;
		b.dataSize = 0;
		b.data = [];
		b.area = 0;
		b.perimeter = 0;
		b.center = Point(0,0);
		b.rect = Rect(0,0,0,0);
		// b.area = i;
		// b.center = Point(200.rand*i,i *10);

	});
	//------------------------------------------------------
	updateGraphView = {|view|

		var cols = [Color.red, Color.green, Color.blue, Color.yellow];

		blobs.do({|blob,i|

			var prev = [];
			//[i,blob].postln;
			a = blob.rect.width * 10;
			blob.areaRate = (a - blob.prevArea).abs;
			blob.areaRateFiltered = filter.(blob.areaRate , blob.areaRateFiltered, 0.01);
			blob.prevArea = a;
		
			//(blob.areaRateFiltered.abs * 0.1).postln;

			Pdef(ptn).set(\dur,(blob.areaRateFiltered.abs * 0.05).reciprocal);

			Pen.smoothing_(true);
			Pen.width = 1;

			Pen.fillColor = cols.at(i);
			Pen.strokeColor = cols.at(i);
			Pen.fillOval(Rect(blob.center.x, blob.center.y,12,12));
			Pen.fillRect(Rect(0 + (i*22),550,10, blob.rect.width * -1));
			Pen.fillRect(Rect(12 + (i*22),550,10, blob.areaRateFiltered * -1));
			Pen.strokeRect(blob.rect);

			prev = blob.data.reshape(1,2)[0];
			blob.data.reshape(blob.dataSize+1,2).do({|o|

				if( (o[0].asFloat > 1) && (o[1].asFloat > 1) ,{
					r = Rect(o[0], o[1], 4, 4);
					Pen.fillOval(r);
				    Pen.moveTo(Point(prev[0],prev[1]));
				    Pen.lineTo(Point(o[0],o[1]));
					Pen.stroke;
					prev = o;
				});
			});

		});

		// a = blobs[0].rect;
		// b = blobs[1].rect;
		
		// if (a.left < (b.left + b.width) &&
		//    ((a.left + a.width) > b.left) &&
		//    (a.top < (b.top + b.height)) &&
		//    ((a.top + a.height) > b.top), {
		//    		["collide", Date.gmtime.asString].postln;
		// });


	};
	//-------------------stt----------------------------------

	QtGUI.palette = QPalette.dark; 

	window = Window("",Rect(0,0,Window.screenBounds.width * 0.7, Window.screenBounds.height * 0.7)
		.center_(Window.availableBounds.center)
	).front;

	window.layout = HLayout();

	window.layout.add(
		graphView = UserView()
		.drawFunc_(updateGraphView)
		.animate_(false)
		.clearOnRefresh_(true)

	);


	oscListener = OSCFunc({ arg msg, time, addr, recvPort;
		//[msg, time, addr, recvPort].postln;skkstt
		var index = msg[1].asInteger;
	
		if(blobs[index] != nil,{
			blobs[index][\dataSize] = msg[2].asInteger;
			blobs[index].data = msg.copyRange(11,400);
			blobs[index].area = msg[3] * 100;
			blobs[index].perimeter = msg[4] * 100;
			blobs[index].center = Point(msg[5]* 1000,msg[6]* 1000);
			blobs[index].rect = Rect(msg[7] * 1000,msg[8]* 1000,msg[9]* 1000,msg[10]* 1000);
			blobs[index].channel = index;
		});
		{graphView.refresh()}.defer;

		// -----------------------------------------------------

		// if(index == 0,{
		// 	a = [\a,\b,\c,\d,\e,\f,\g,\h];
			
		// 	blobs[index].data.reshape(blobs[index].dataSize+1,2).do({|o,i|
		// 		var dist = blobs[index].center.dist(Point(o[0],o[1]));
		// 		i = i.mod(7);

		// 		synth.set(a[i],(dist * 2) - 100);
			
		// 	});
		// });

		// -----------------------------------------------------
		// if( blobs[index].areaRate > 1.1,{

		// 	if( blobs[index].isNoteOn == false,{
		// 		blobs[index].note = blobs[index].root + blobs[index].notes[0];
		// 		blobs[index].notes = blobs[index].notes.rotate(-1);
		// 		blobs[index].isNoteOn = true;
		// 		//blobs[index].note.postln;
		// 		midiOut.noteOn(blobs[index].channel,blobs[index].note,blobs[index].velocity);
		// 		{
		// 			midiOut.noteOff(blobs[index].channel,blobs[index].note,0);
		// 			blobs[index].isNoteOn = false;
		// 		}.defer(0.5 * 0.5);
		// 	});

		// });

	}, '/blobi');
	//------------------------------------------------------

	window.onClose = ({

				Pdef(ptn).stop();
				Pdef(ptn).clear;
				midiOut.allNotesOff(0);


		oscListener.free;
		{MIDIClient.disposeClient}.defer(1);

		synth.free;

	});
	CmdPeriod.doOnce({window.close});

	//------------------------------------------------------

	MIDIClient.init;
	MIDIClient.destinations;

	midiOut = MIDIOut.newByName("IAC Driver", "Bus 1", dieIfNotFound: true);
	midiOut.latency_(0.00);

	//------------------------------------------------------


	Pdef(ptn,
		Pbind(
			\note, Pseq([0,1,2,3,4,5,6,7],inf),
			// \root, Pseq([0,3,8,5,2,7].stutter(24),inf),
			\octave, 3,
			//\func, Pfunc({|e| ~onEvent.(e)}),
			\args, #[],
		);
	);

	Pdef(ptn).set(\dur,0.5);
	Pdef(ptn).set(\octave,5);
	Pdef(ptn).set(\amp,0.8);
	Pdef(ptn).set(\type,\midi);
	Pdef(ptn).set(\midiout,midiOut);
	Pdef(ptn).set(\chan,0);
	Pdef(ptn).play();

)




