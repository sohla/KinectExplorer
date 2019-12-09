
	(
	var window, routine;
	var graphView, updateGraphView;

	var midiOut;
	var oscListener;

	var devicesDir = "~/Develop/OSX/Frameworks/of_v0.10.0_osx_release/apps/myApps/KinectExplorer/sccode/personalities/";
	var persList = ["a","b"];

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
				\env:  nil

	);

	var filter = {|input,history,friction = 0.5|
		(friction * input + ((1 - friction) * history))
	};

	var blobs = Array.fill(1,{Event.new(proto:blobModel)});

	//------------------------------------------------------
	var loadPersonality = {|name|

		var path = PathName.new(devicesDir++name++".sc");
		var file = File.new(path.asAbsolutePath,"r");
		var str = file.readAllString;
		var env = Environment.make {
			interpret(str);
		};
		env.use{~init.()};
		env
	};
	//------------------------------------------------------


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
			var r = [3,5,7,9];
			//[i,blob].postln;
			a = blob.rect.width * 10;
			blob.areaRate = (a - blob.prevArea).abs;
			blob.areaRateFiltered = filter.(blob.areaRate , blob.areaRateFiltered, 0.01);
			blob.prevArea = a;
		
			z = (4 - blob.center.y.linlin(200,400,0,4).asInteger).max(r.size-1);
			Pdef(\drums).set(\dur,(blob.areaRateFiltered.abs * 0.04).reciprocal);
			Pdef(\bass).set(\dur,(blob.areaRateFiltered.abs * 0.04).reciprocal);
			Pdef(\bass).set(\root,r[z]);

			Pen.smoothing_(true);
			Pen.width = 1;

			Pen.fillColor = cols.at(i);
			Pen.strokeColor = cols.at(i);
			Pen.fillOval(Rect(blob.center.x, blob.center.y,12,12));
			Pen.fillRect(Rect(0 + (i*22),550,10, blob.rect.width * -1));
			Pen.fillRect(Rect(12 + (i*22),550,10, blob.areaRateFiltered * -1));
			Pen.strokeRect(blob.rect);

			prev = blob.data.reshape(1,2)[0];
			blob.data.reshape(blob.data.size,2).do({|o|

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

	window = Window("",Rect(0,0,Window.screenBounds.width * 0.7, Window.screenBounds.height * 0.7)
		.center_(Window.availableBounds.center)
	).front;

	window.layout = VLayout().add(
		PopUpMenu()
			.items_(persList)
			.action_({|b|
				blobs[0].env = loadPersonality.(persList.at(b.value));
			})
			.valueAction_(0)

	);

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
			blobs[index].center = filter.(Point(msg[5]* 1000,msg[6]* 1000), blobs[index].center, 0.3);

			blobs[index].rect = Rect(msg[7] * 1000,msg[8]* 1000,msg[9]* 1000,msg[10]* 1000);
			blobs[index].channel = index;
		});
		{graphView.refresh()}.defer;


	}, '/blobi');
	//------------------------------------------------------

	window.onClose = ({

				Pdef(\drums).stop();
				Pdef(\drums).clear;
				Pdef(\bass).stop();
				Pdef(\bass).clear;
				midiOut.allNotesOff(0);


		oscListener.free;
		{MIDIClient.disposeClient}.defer(1);


	});
	CmdPeriod.doOnce({window.close});

	//------------------------------------------------------

	MIDIClient.init;
	MIDIClient.destinations;

	midiOut = MIDIOut.newByName("IAC Driver", "Bus 1", dieIfNotFound: true);
	midiOut.latency_(0.00);

	//------------------------------------------------------


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
)




