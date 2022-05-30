(
	var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches/";
	// var netAddr = NetAddr.new("127.0.0.1", 10001);
	var netAddr = NetAddr.new("192.168.1.150", 10001);
	var keAddr = NetAddr("127.0.0.1",57000);
	var numOfBlobs = 4;


	var window, freqScope;
	var loadPatch, patchButton, reloadButton;
	var graphView, plotView, plotter, serverView;

	var oscListeners = [];
	var pntListener, objListener, lnkListener;
	var resetListener, initListener, updateListener, deinitListener;

	var scale = 0.6;

	//------------------------------------------------------
	var pfmt = 0; //store the sum of all patch files modification time since epoch 

	var pfmtRout = Routine {|i|
		//•• add first time condition to remove calling ~deinit when exec.
		loop{
			var temp = 0;
			patches.do({ |m,i| temp = temp + File.mtime(patchesPath.asAbsolutePath++m.file) });
			if(temp != pfmt,{ {reloadButton.valueAction_(0)}.defer() });
			pfmt = temp;				
			0.1.yield;
		}
	}.play;

	//------------------------------------------------------
	var blobModel = (
				\dataSize: 3,
				\state: 0,
				\area: 0,
				\perimeter: 0,	
				\center: Point(0,0),
				\rect: Rect(0,0,20,20),
				\velocity: Point(0,0),
				\label: 0,

				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\env:  nil,
				\pattern: nil,

	);


	var blobsDict = Dictionary.new(numOfBlobs);

	//------------------------------------------------------

	var resetKE = {

		{

			keAddr.sendMsg("/inputSettings/pixelpoint/persistance", 1);
			keAddr.sendMsg("/inputSettings/clear/on", 1);
			0.1.wait;
			keAddr.sendMsg("/inputSettings/pixelpoint/persistance", 15);
			keAddr.sendMsg("/inputSettings/clear/on", 0);
		}.fork

	};

	//------------------------------------------------------
	var filter = {|input,history,friction = 0.5|
		(friction * input + ((1 - friction) * history))
	};

	//------------------------------------------------------
	var freeAll = {		

		pfmtRout.stop;
		patches.do({|m| m.env.use{~deinit.(m)} });

		resetListener.free;
		initListener.free;
		updateListener.free;
		deinitListener.free;

		oscListeners.do{|l|l.free};

		freqScope.kill;
		Ndef.clear(0);
		s.freeAll;
		s.quit;

	};

	//------------------------------------------------------
	var row = 3, col = 3;
	var makePatch = {
		(\file: "fourTemplatePatch3.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false)
	};
	var patches = [
		// (\file: "testPatch.scd", \start: 0, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		// (\file: "blazPatch.scd", \start: 240, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		// (\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		// (\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		// (\file: "viztestPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		// (\file: "frogPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		// (\file: "longPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),


		// (\file: "fourTemplatePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		// (\file: "fourTemplatePatch2.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		makePatch.(),
		
		// (\file: "frogFourPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		(\file: "longFourPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		(\file: "shapeVortex.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		// (\file: "conexFourPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		(\file: "bodyElectric.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),
		(\file: "waterSoul.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr, \isOn: false),

	];
	//------------------------------------------------------

	var bootServer = {|f|
	
		var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		 var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
		// var input = ServerOptions.devices.indexOfEqual("ZoomAudioD");
		// var output = ServerOptions.devices.indexOfEqual("External Headphones");
		// var output = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
		// var output = ServerOptions.devices.indexOfEqual("External Headphones");
		// var input = ServerOptions.devices.indexOfEqual("Built-in Microph");
		// var output = ServerOptions.devices.indexOfEqual("Built-in Output");

		o = Server.local.options;
		o.inDevice = ServerOptions.devices[input];
		o.outDevice = ServerOptions.devices[output];
		o.sampleRate = 44100.000000;
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
		var vx = 0,vy = 0;
		
		var plotData = {

			var data = [0];

			if(blobsDict.values.size > 0,{
				// for now, calling all patches
				patches.do({|m| 
					m.env.use{
						var d = ~onData.(blobsDict);
						if(d != nil, {data = d});
					}; 
				});
			});
			data;
		};


		Pen.fillColor = Color.gray(0,1);
		Pen.fillRect(window.view.bounds);

		blobsDict.do({|blob,i|

			if(blob.state == 2,{

				var prev = [];
				var val = blob.rect.width * 10;

				var ax, ay, bx, by, mx, my;
				var xdif, ydif, a1, b1, a2, b2;

				Pen.smoothing_(true);
				Pen.width = 1;

				Pen.fillColor = cols.at(i);
				Pen.strokeColor = cols.at(i);

				Pen.fillOval(Rect(blob.center.x, blob.center.y,6,6));
				Pen.fillRect(Rect(blob.center.x - 5,550,10, blob.rect.width * -1));
				// Pen.fillRect(Rect(12 + (i*22),550,10, blob.pWidth.rateFiltered * -1));

				Pen.strokeRect(blob.rect);

			 	Pen.moveTo(blob.center);
				Pen.lineTo(Point(blob.center.x+ (blob.velocity.x*2), blob.center.y+(blob.velocity.y*2)));
				Pen.stroke;

				Pen.stringAtPoint(i.asString + ":" + blob.label.asString + ":" + blob.state, blob.center.x + 20@blob.center.y);

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
			});
		});

		//plotter
		plotter.value = plotter.value.flop;
		plotter.value = plotter.value.insert(0, plotData.());
		plotter.value = plotter.value.keep(50);
		plotter.value = plotter.value.flop;

		plotter.minval_(-10);
		plotter.maxval_(10);

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
		//• load synth here instead of init?
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
					if(b.value == 1,{
						resetKE.();//•• maybe not
						m.isOn = true;
						m.env.use{~init.(m)}; 
					},{
						m.env.use{~deinit.(m)}; 
						m.isOn = false;
					});
				})
		});
	}!col}!row;

	//------------------------------------------------------
	QtGUI.palette = QPalette.dark; 
	window = Window("",Rect(0,0,Window.screenBounds.width * 0.5, Window.screenBounds.height - 300)
		.center_(Window.screenBounds.width*0.85@100)
	).front;

	//------------------------------------------------------
	window.onClose = ({ freeAll.() });
	CmdPeriod.doOnce({ window.close });

	window.view.keyDownAction_({|view,char,mods,uni,code,key|
		if(uni==114,{//r
			reloadButton.valueAction_(0);
		});
	});

	window.layout = 
		HLayout(
		VLayout(
		reloadButton = Button()
			.states_([["reload", Color.yellow]])
			.maxWidth_(100)
			.action_({|b|
				resetKE.();
				patches.do({|m| 
					loadPatch.(m);
					m.env.use{
						// ~reload.(m);//•• turn off the on>>>/??
						~deinit.(m);
						if(m.isOn == true,{~init.(m)});
					}; 
				})
			}),
		Button()
			.states_([["mute", Color.white],["mute", Color.red]])
			.maxWidth_(100)
			.action_({|b|
				if(b.value == 1,{s.mute},{s.unmute});
			}),
		GridLayout.rows(*patchButton.()),	
		graphView = UserView()
				.minHeight_(500)
				.minWidth_(500)
				.drawFunc_(updateGraphView)
				.frameRate_(30)
				.animate_(true)
				.clearOnRefresh_(false),

		HLayout(
			plotView = UserView()
				.minHeight_(200)
				.minWidth_(300),


			freqScope = FreqScopeView()
				.freqMode_(1)
				.active_(true),	
		)
		),
		serverView = UserView()
			// .minHeight_(500)
			.minWidth_(300)
	);


	 // s.plotTreeView(0.5, serverView);

	plotter = Plotter("plot", Rect(0, 0, 300, freqScope.bounds.height), plotView)
		.value_((0..49));
	plotter.superpose = true;
	plotter.setProperties(\backgroundColor, Color.gray(0.25));
	plotter.setProperties(\plotColor, [Color.yellow,Color.magenta,Color.cyan]).refresh;
	

	bootServer.({

		SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
		SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

		// start listening to OSC blob data
		//initBlobs.();

		//------------------------------------------------------
		resetListener = OSCFunc({ |msg, time, addr, recvPort|

			blobsDict.do({|blob|
				patches.do({|m| m.env.use{
					if(m.isOn, {
						if(blobsDict.values.size > 0,{
							~onDeinit.(blob, blobsDict);
						});
					});
				}});
			});

			blobsDict = Dictionary.new(numOfBlobs);
			resetKE.();
		}, '/ke/reset', recvPort: 57120);
		//------------------------------------------------------
		initListener = OSCFunc({ |msg, time, addr, recvPort|

			var blob = Event.new(proto:blobModel);

			//•• label is unique : needs to be assigned to a synth/pattern
			// blob.label = msg[1];

			blob.label = msg[1]; 
			blob.state = msg[2]; 
			blob.area = msg[3] * 100;
			blob.perimeter = msg[4] * 100;

			// 640 & 480 are coming from Kinect Explorer
			blob.center = filter.(Point(msg[5]* 640,msg[6]* 480), blob.center, 0.9);

			blob.rect = Rect(msg[7] * 1000,msg[8]* 1000,msg[9]* 1000,msg[10]* 1000);

			blob.index = msg[11].asInteger;
		
			blob.velocity = Point(msg[12], msg[13]);

			blob.dataSize = msg[14].asInteger;
			blob.data = msg.copyRange(15,512 + 15);



			blobsDict.put(msg[1],blob);
			// blobsDict.postln;
			
			patches.do({|m| m.env.use{
				if(m.isOn, {
					if(blobsDict.values.size > 0,{
						// ~init.(m);
						~onInit.(blob, blobsDict);
					});
				});
			}});

			//blobsDict.postln;
		}, '/ke/init', recvPort: 57120);

		//------------------------------------------------------
		updateListener = OSCFunc({ |msg, time, addr, recvPort|

			if(blobsDict.at(msg[1]) != nil,{

				blobsDict.at(msg[1]).label = msg[1]; 
				blobsDict.at(msg[1]).state = msg[2]; 
				blobsDict.at(msg[1]).area = msg[3] * 100;
				blobsDict.at(msg[1]).perimeter = msg[4] * 100;

				// 640 & 480 are coming from Kinect Explorer
				blobsDict.at(msg[1]).center = filter.(Point(msg[5]* 640,msg[6]* 480), blobsDict.at(msg[1]).center, 0.9);

				blobsDict.at(msg[1]).rect = Rect(msg[7] * 1000,msg[8]* 1000,msg[9]* 1000,msg[10]* 1000);

				blobsDict.at(msg[1]).index = msg[11].asInteger;
			
				blobsDict.at(msg[1]).velocity = Point(msg[12], msg[13]);

				blobsDict.at(msg[1]).dataSize = msg[14].asInteger;
				blobsDict.at(msg[1]).data = msg.copyRange(15,512 + 15);

				// if this blob is on tell all patches
				if(blobsDict.at(msg[1]).state == 2,{
					patches.do({|m| m.env.use{
						if(m.isOn, {
							if(blobsDict.values.size > 0,{
								~onUpdate.(blobsDict.at(msg[1]), blobsDict);
							}); 
						});
					}});
				});
			});

		}, '/ke/update', recvPort: 57120);

		//------------------------------------------------------
		deinitListener = OSCFunc({ |msg, time, addr, recvPort|

			if(blobsDict.at(msg[1]) != nil,{

				var blob = blobsDict.at(msg[1]);

				patches.do({|m| m.env.use{
					if(m.isOn, {
						if(blobsDict.values.size > 0,{
							~onDeinit.(blob, blobsDict);

						});
					}); 
				}});

				blobsDict.removeAt(msg[1]);

			});


		}, '/ke/deinit', recvPort: 57120);
		
		//------------------------------------------------------

		// load all data into patches
		patches.do({|m| loadPatch.(m)});

		resetKE.();
	});
)



// Ptpar
// Pspawner
// s.meters



// (

// var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches/";
// var time = File.mtime(patchesPath.asAbsolutePath++"plucktonePatch.scd");
// time
// )

