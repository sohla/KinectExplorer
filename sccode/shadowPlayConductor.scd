(
	var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches/";
	// var netAddr = NetAddr.new("127.0.0.1", 10001);
	var netAddr = NetAddr.new("192.168.20.3", 10001);
	var numOfBlobs = 1;


	var window, freqScope;
	var loadPatch, patchButton;
	var graphView;

	var oscListeners = [];


	//------------------------------------------------------
	var blobModel = (
				\dataSize: 3,
				\area: 0,
				\perimeter: 0,	
				\center: Point(0,0),
				\rect: Rect(0,0,20,20),

				// \pWidth: Event.new(proto:paramModel),

				\velocity: Point(0,0),
				\label: 0,

				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\env:  nil

	);

	var blobs = Array.fill(numOfBlobs,{Event.new(proto:blobModel)});

	var initBlobs = {
		blobs.do({|b,i|
			b.channel = i;
			b.dataSize = 0;
			b.data = [];
			b.area = 0;
			b.perimeter = 0;
			b.center = Point(0,0);
			b.rect = Rect(0,0,0,0);
			b.root = 0;
		});
	};

	//------------------------------------------------------
	var filter = {|input,history,friction = 0.5|
		(friction * input + ((1 - friction) * history))
	};

	//------------------------------------------------------
	var freeAll = {


		patches.do({|m| m.env.use{~deinit.(m)} });

		oscListeners.do{|l|l.free};

		freqScope.kill;
		Ndef.clear(0);
		s.freeAll;
		s.quit;

	};


	//------------------------------------------------------
	var row = 2, col = 3;
	var patches = [
		(\file: "testPatch.scd", \start: 0, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "blazPatch.scd", \start: 240, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "viztestPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "frogPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),

		// (\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		// (\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		// (\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),

	];
	//------------------------------------------------------

	var bootServer = {|f|
	
		// var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		//  var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
		//var output = ServerOptions.devices.indexOfEqual("SFandSC");
		var input = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
		var output = ServerOptions.devices.indexOfEqual("External Headphones");
		// var input = ServerOptions.devices.indexOfEqual("Built-in Microph");
		// var output = ServerOptions.devices.indexOfEqual("Built-in Output");

		o = Server.local.options;
		o.inDevice = ServerOptions.devices[input];
		o.outDevice = ServerOptions.devices[output];
		// o.sampleRate = 41000.000000;
		o.memSize = 8192 * 2;
		o.numInputBusChannels = 2;
		o.numOutputBusChannels = 4;

		s.waitForBoot{
			"💫 welcome to shadow play 💫".postln;

			f.();
		};
	};

	//------------------------------------------------------------

	var updateGraphView = {|view|

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

				Pen.smoothing_(true);
				Pen.width = 1;

				Pen.fillColor = cols.at(i);
				Pen.strokeColor = cols.at(i);

				Pen.fillOval(Rect(blob.center.x, blob.center.y,6,6));
				Pen.fillRect(Rect(0 + (i*22),550,10, blob.rect.width * -1));
				// Pen.fillRect(Rect(12 + (i*22),550,10, blob.pWidth.rateFiltered * -1));

				Pen.strokeRect(blob.rect);

			 	Pen.moveTo(blob.center);
				Pen.lineTo(Point(blob.center.x+blob.velocity.x+6, blob.center.y+blob.velocity.y+6));
				Pen.stroke;


				Pen.stringAtPoint(i.asString + ":" + blob.label.asString, blob.center.x + 20@blob.center.y);

				prev = blob.data.reshape(1,2)[0];
				blob.data.reshape(blob.data.size,2).do({|o,j|

					if( (o[0].asFloat > 1) && (o[1].asFloat > 1) ,{
						ax = prev[0];
						ay = prev[1];
						bx = o[0];
						by = o[1];
					 	Pen.moveTo(Point(ax, ay));
						Pen.lineTo(Point(bx, by));
						Pen.stroke;
						prev = o;
					});
				});

				//•make the patch play

			},{ // area less than 1
				//•make the patch stop
			});

		});// finish processing all the blobs

		// update all the patches with all the blob data
		patches.do({|m| m.env.use{~update.(blobs,0)} });

	};

	//------------------------------------------------------------
	loadPatch = {|model|
		var path = PathName.new(patchesPath++model.file);
		var file = File.new(path.asAbsolutePath,"r");
		var str = file.readAllString;
		var env = Environment.make {
			interpret(str);
		};
		model.env = env;
	};

	//------------------------------------------------------
	patchButton = {|i|{|j|
		var index = (i * col) + j;
		var m = patches[index];
		if( m != nil,{
			Button()
				.states_([[m.file, Color.gray(0.2)],[m.file, Color.green(0.8)]])
				.font_(Font(size:16))
				.minHeight_(50)
				.minWidth_(100)

				.action_({|b|
					if(b.value == 1,	
						{m.env.use{~init.(m)}},
						{m.env.use{~deinit.(m)}
					});
				})
		});
	}!col}!row;

	//------------------------------------------------------
	QtGUI.palette = QPalette.dark; 
	window = Window("",Rect(0,0,Window.screenBounds.width/3, Window.screenBounds.height)
		.center_(Window.screenBounds.width*0.85@100)
	).front;

	//------------------------------------------------------
	window.onClose = ({ freeAll.() });
	CmdPeriod.doOnce({ freeAll.() });

	window.layout = VLayout(
		Button()
			.states_([["reload", Color.yellow]])
			.maxWidth_(100)
			.action_({|b|
				patches.do({|m| 
					loadPatch.(m);
					m.env.use{~reload.(m)}; 
				})
			}),
		Button()
			.states_([["mute", Color.white],["mute", Color.red]])
			.maxWidth_(100)
			.action_({|b|
				if(b.value == 1,{s.mute},{s.unmute});
			}),
		GridLayout.rows(*patchButton.()),	
		freqScope = FreqScopeView()
			.freqMode_(1)
			.active_(true),	
		graphView = UserView()
			.minHeight_(700)
			.drawFunc_(updateGraphView)
			.animate_(false)
			.clearOnRefresh_(true),
			);

	bootServer.({

		SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
		SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

		// start listening to OSC blob data
		initBlobs.();

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

							// 640 & 480 are coming from Kinect Explorer
							blobs[index].center = filter.(Point(msg[4]* 640,msg[5]* 480), blobs[index].center, 0.9);

							blobs[index].rect = Rect(msg[6] * 1000,msg[7]* 1000,msg[8]* 1000,msg[9]* 1000);

							blobs[index].label = msg[10].asInteger;
							
							blobs[index].velocity = Point(msg[11], msg[12]);

							blobs[index].dataSize = msg[13].asInteger;
							blobs[index].data = msg.copyRange(14,512 + 14);

							// experimental
							// blobs[index].pWidth.rateRaw = msg[8]* 1000;//???????

						});
						{graphView.refresh()}.defer;

					// });

					}, '/gyrosc/line', recvPort: 57120 + i);
			);
		};	
		//------------------------------------------------------


		// load all data into patches
		patches.do({|m| loadPatch.(m)});
	});


)


// Ptpar
// Pspawner