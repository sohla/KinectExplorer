
	(
	var window, routine;
	var graphView, updateGraphView;
	var oscListener;
	var midiOut;

		// var notes = [-5,-5,-3,-5,0,-1,-5,-5,-3,-5,2,0,-5,-5,7,4,0,-1,-3,5,5,4,0,2,0];
//		var notes = [0,3,2,-2,-4,0,-2,2];
		// var notes = [0,12,0,12,10,9,7];
		// var note = notes[0];

	var blobModel = (
				\area: 0,
				\prevArea: 0,
				\areaRate: 0,
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


	var blobs = Array.fill(4,{Event.new(proto:blobModel)});

	blobs[0].notes = [0,5,4,7,5,10,9,5,4,7,2,-2];
	blobs[0].velocity = 10;
	blobs[1].root = 60 - 24;

	// 2.do({|i|
	// 	blobs[i].area = i;
	// 	blobs[i].center = Point(200.rand*i,i *10);

	// });
	//------------------------------------------------------
	updateGraphView = {|view|

		var cols = [Color.red, Color.green, Color.blue, Color.yellow];

		blobs.do({|blob,i|

			var prev = [];
			//[i,blob].postln;

			Pen.smoothing_(true);
			Pen.width = 1;

			Pen.fillColor = cols.at(i);
			Pen.strokeColor = cols.at(i);
			Pen.fillOval(Rect(blob.center.x, blob.center.y,12,12));
			Pen.fillRect(Rect(0 + (i*22),550,10, blob.area * -1));
			Pen.fillRect(Rect(12 + (i*22),550,10, blob.areaRate * -10 ));
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
	};
	//-------------------stt----------------------------------

	QtGUI.palette = QPalette.dark; 

	window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/2)
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
		var lar = blobs[index].areaRate;

		blobs[index].dataSize = msg[2].asInteger;
		blobs[index].data = msg.copyRange(11,400);
		blobs[index].area = msg[3] * 100;
		blobs[index].perimeter = msg[4] * 100;
		blobs[index].center = Point(msg[5]* 1000,msg[6]* 1000);
		blobs[index].rect = Rect(msg[7] * 1000,msg[8]* 1000,msg[9]* 1000,msg[10]* 1000);

		blobs[index].channel = index;
		{graphView.refresh()}.defer;

		a = (blobs[index].perimeter - blobs[index].prevArea) * 10;

		blobs[index].areaRate = filter.(a, lar, 0.02);

		blobs[index].prevArea = blobs[index].perimeter;

		if( blobs[index].areaRate > 1.1,{

			if( blobs[index].isNoteOn == false,{
				blobs[index].note = blobs[index].root + blobs[index].notes[0];
				blobs[index].notes = blobs[index].notes.rotate(-1);
				blobs[index].isNoteOn = true;
				blobs[index].note.postln;
				midiOut.noteOn(blobs[index].channel,blobs[index].note,blobs[index].velocity);
				{
					midiOut.noteOff(blobs[index].channel,blobs[index].note,0);
					blobs[index].isNoteOn = false;
				}.defer(0.5 * 0.5);
			});

		});

	}, '/blobi');
	//------------------------------------------------------

	window.onClose = ({

		oscListener.free;
		{MIDIClient.disposeClient}.defer(1);

	});
	CmdPeriod.doOnce({window.close});

	//------------------------------------------------------

	MIDIClient.init;
	MIDIClient.destinations;

	midiOut = MIDIOut.newByName("IAC Driver", "Bus 1", dieIfNotFound: true);
	midiOut.latency_(0.00);
)
