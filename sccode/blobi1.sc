
	(
	var numOfBlobs = 2;

	var window, routine;
	var graphView, updateGraphView;

	var midiOut;
	var oscListeners = [];

	var makePopupMenu;

	var devicesDir = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myapps/KinectExplorer/sccode/personalities/";
	var persList = ["d","c","g","h","i","e","f","a","b"];

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

				\label: 0,

				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\env:  nil

	);

	var filter = {|input,history,friction = 0.5|
		(friction * input + ((1 - friction) * history))
	};

	var blobs = Array.fill(numOfBlobs,{Event.new(proto:blobModel)});
	//------------------------------------------------------
	var blobFunctor = {|e|

		blobs.do({|blob,i|
			blob.env.use{~community.(blob,e)};
		});
	};

	//------------------------------------------------------
	var loadPersonality = {|name|

		var path = PathName.new(devicesDir++name++".sc");
		var file = File.new(path.asAbsolutePath,"r");
		var str = file.readAllString;
		var env = Environment.make {
			interpret(str);
		};
		env.use{~init.(midiOut, blobFunctor)};
		env.postln;
		env
	};

	//------------------------------------------------------
	MIDIClient.init;
	MIDIClient.destinations;

	midiOut = MIDIOut.newByName("IAC Driver", "Bus 1", dieIfNotFound: true);
	// midiOut = MIDIOut.newByName("Network", "Session 1", dieIfNotFound: true);
	midiOut.latency_(0.01);

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

		var cols = [Color.magenta, Color.green, Color.blue, Color.yellow];

		blobs.sortBy(\label);

		blobs.do({|blob,i|

			var prev = [];
			var val = blob.rect.width * 10;

			var ax, ay, bx, by, mx, my;
			var xdif, ydif, a1, b1, a2, b2;

			Pen.fillColor = Color.gray(1,0.01);
			Pen.fillRect(window.view.bounds);
			
			if( blob.area > 1, {

				// [blobs[0].area,blobs[1].area].postln;

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

				Pen.stringAtPoint(i.asString + ":" + blob.label.asString, blob.center.x + 20@blob.center.y);

				// blob.data.reshape(blob.data.size,2)[1].postln;
				prev = blob.data.reshape(1,2)[0];
				blob.data.reshape(blob.data.size,2).do({|o,j|

					if( (o[0].asFloat > 1) && (o[1].asFloat > 1) ,{
						// r = Rect(o[0], o[1], 4, 4);
						// Pen.fillOval(r);

						ax = prev[0];
						ay = prev[1];
						bx = o[0];
						by = o[1];
						// mx = (ax + bx) / 2;
						// my = (ay + by) / 2;


						// xdif = (bx - ax) * 2;
						// ydif = (by - ay) * 2;
						// a1 = (mx - ydif);
						// b1 = (my + xdif);
						// a2 = (mx + ydif);
						// b2 = (my - xdif);

						// r = Rect(mx, my, 2, 2);
						// Pen.fillOval(r);

					 //    Pen.moveTo(Point(mx, my));
						// Pen.quadCurveTo(Point(a1, b1), Point(ax, ay));
						// Pen.moveTo(Point(a1, b1));
						// Pen.quadCurveTo(Point(mx, my), Point(bx, by));
						// Pen.fill;
					 //    Pen.moveTo(Point(blob.center.x, blob.center.y + (blob.rect.height/2)));
						// Pen.quadCurveTo(Point(mx, my), Point(ax, ay));

					    Pen.moveTo(Point(ax, ay));
					    Pen.lineTo(Point(bx, by));
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

	window = Window("",Rect(0,0,Window.screenBounds.width * 0.5, Window.screenBounds.height * 0.5)
		.center_(Window.availableBounds.center)
	).front;


	makePopupMenu = {|i|
		PopUpMenu()
			.items_(persList)
			.action_({|b|
				blobs[i].env!?{
					blobs[i].env.use{ ~deinit.(midiOut)};
				};
				blobs[i].env = loadPersonality.(persList.at(b.value));
			})
			.valueAction_(i);
	}!numOfBlobs;

	window.layout = VLayout().add( HLayout(*makePopupMenu.()) );

	window.layout.add(
		graphView = UserView()
		.drawFunc_(updateGraphView)
		.animate_(false)
		.clearOnRefresh_(true)

	);

	numOfBlobs.do{ |i|

		oscListeners.add(
			OSCFunc({ arg msg, time, addr, recvPort;
		
				var index = msg[1].asInteger;
				//0[msg, time, addr, recvPort].postln;
				
				// if( i == index, {
					if(blobs[index] != nil,{

						blobs[index].channel = index;

						blobs[index].area = msg[2] * 100;
						blobs[index].perimeter = msg[3] * 100;

						blobs[index].center = filter.(Point(msg[4]* 1000,msg[5]* 1000), blobs[index].center, 0.9);

						blobs[index].rect = Rect(msg[6] * 1000,msg[7]* 1000,msg[8]* 1000,msg[9]* 1000);

						blobs[index][\label] = msg[10].asInteger;
						
						//11,12 velocity
						blobs[index][\dataSize] = msg[13].asInteger;
						blobs[index].data = msg.copyRange(14,256);

						// experimental
						blobs[index].pWidth.rateRaw = msg[8]* 1000;//???????

					});
					{graphView.refresh()}.defer;

				// });

				}, '/gyrosc/line', recvPort: 57120 + i);
		);
	};
	//------------------------------------------------------

	window.onClose = ({

		blobs.do({|blob,i|

			blob.env.use{
				~deinit.(midiOut);
			};
		});


		oscListeners.do{|l|l.free};

		{MIDIClient.disposeClient}.defer(1);


	});
	CmdPeriod.doOnce({window.close});

	//------------------------------------------------------


	//------------------------------------------------------

)

// NetAddr.localAddr



