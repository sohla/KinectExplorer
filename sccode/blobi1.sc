
	(
	var window, routine;
	var graphView, updateGraphView;

	var midiOut;
	var oscListener;

	var devicesDir = "~/Develop/OSX/Frameworks/of_v0.10.0_osx_release/apps/myApps/KinectExplorer/sccode/personalities/";
	var persList = ["c","d","a","b"];

	var paramModel = (
		\prev: 0,
		\rateRaw: 0,
		\rateFiltered: 0
	);

	var blobModel = (
				\dataSize: 3,
				\area: 0,
				\perimeter: 0,
				\center: Point(0,0),
				\rect: Rect(0,0,20,20),

				\pWidth: Event.new(proto:paramModel),

				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\env:  nil

	);

	var filter = {|input,history,friction = 0.5|
		(friction * input + ((1 - friction) * history))
	};

	var blobs = Array.fill(2,{Event.new(proto:blobModel)});

	//------------------------------------------------------
	var loadPersonality = {|name|

		var path = PathName.new(devicesDir++name++".sc");
		var file = File.new(path.asAbsolutePath,"r");
		var str = file.readAllString;
		var env = Environment.make {
			interpret(str);
		};
		env.use{~init.(midiOut)};
		env
	};

	//------------------------------------------------------
	MIDIClient.init;
	MIDIClient.destinations;

	midiOut = MIDIOut.newByName("IAC Driver", "Bus 1", dieIfNotFound: true);
	// midiOut = MIDIOut.newByName("Network", "Session 1", dieIfNotFound: true);
	midiOut.latency_(0.00);

	//------------------------------------------------------

	blobs.do({|b,i|
		b.channel = i;
		b.dataSize = 0;
		b.data = [];
		b.area = 0;
		b.perimeter = 0;
		b.center = Point(0,0);
		b.rect = Rect(0,0,0,0);
		b.root = 0;
		b.pWidth = Event.new(proto:paramModel);

		// b.area = i;
		// b.center = Point(200.rand*i,i *10);

	});
	//------------------------------------------------------
	updateGraphView = {|view|

		var cols = [Color.red, Color.green, Color.blue, Color.yellow];

		blobs.do({|blob,i|

			var prev = [];
			var val = blob.rect.width * 10;

			if( blob.area > 1, {

				[blobs[0].area,blobs[1].area].postln;

				blob.pWidth.rateRaw = (val - blob.pWidth.prev).abs;
				blob.pWidth.rateFiltered = filter.(blob.pWidth.rateRaw , blob.pWidth.rateFiltered, 0.03);
				blob.pWidth.prev = val;

				blob.env.use{ ~volume.(0.8)};

				blob.env.use{ ~update.(blobs,i,midiOut)};

				Pen.smoothing_(true);
				Pen.width = 1;

				Pen.fillColor = cols.at(i);
				Pen.strokeColor = cols.at(i);
				Pen.fillOval(Rect(blob.center.x, blob.center.y,12,12));
				Pen.fillRect(Rect(0 + (i*22),550,10, blob.rect.width * -1));
				Pen.fillRect(Rect(12 + (i*22),550,10, blob.pWidth.rateFiltered * -1));
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

				},{
					blob.env.use{ ~volume.(0.0)};

				});

		});

	};
	//-------------------stt----------------------------------

	QtGUI.palette = QPalette.dark; 

	window = Window("",Rect(0,0,Window.screenBounds.width * 0.7, Window.screenBounds.height * 0.7)
		.center_(Window.availableBounds.center)
	).front;

	window.layout = VLayout().add( HLayout(
		PopUpMenu()
			.items_(persList)
			.action_({|b|
				blobs[0].env!?{
					blobs[0].env.use{ ~deinit.(midiOut)};
				};
				blobs[0].env = loadPersonality.(persList.at(b.value));
			})
			.valueAction_(0),
		PopUpMenu()
			.items_(persList)
			.action_({|b|
				blobs[1].env!?{
					blobs[1].env.use{ ~deinit.(midiOut)};
				};
				blobs[1].env = loadPersonality.(persList.at(b.value));
			})
			.valueAction_(1)
);
 

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

			blobs[index].pWidth.raw = msg[9]* 1000;

		});
		{graphView.refresh()}.defer;


	}, '/blobi');
	//------------------------------------------------------

	window.onClose = ({

		blobs.do({|blob,i|

			blob.env.use{
				~deinit.(midiOut);
			};
		});


		oscListener.free;
		{MIDIClient.disposeClient}.defer(1);


	});
	CmdPeriod.doOnce({window.close});

	//------------------------------------------------------


	//------------------------------------------------------

)




