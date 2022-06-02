(
	var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches2/";
	var netAddr = NetAddr.new("127.0.0.1", 10001);
	// var netAddr = NetAddr.new("192.168.1.150", 10001);
	var keAddr = NetAddr("127.0.0.1",57000);
	var numOfBlobs = 4;


	var window, freqScope;
	var loadPatch, patchButton, reloadButton;
	var graphView, plotView, plotter, serverView;

	var pntListener, objListener, lnkListener;
	var resetListener, initListener, updateListener, deinitListener;

	var scale = 0.6;

	//------------------------------------------------------
	var pfmt = 0; //store the sum of all patch files modification time since epoch 

	var pfmtRout = Routine {|i|
		//•• add first time condition to remove calling ~deinit when exec.
		loop{
			var temp = 0;
			patches.do({ |p,i| temp = temp + File.mtime(patchesPath.asAbsolutePath++p.file) });
			if(temp != pfmt,{ {reloadButton.valueAction_(0)}.defer() });
			pfmt = temp;				
			0.1.yield;
		}	
	}.play;

	//------------------------------------------------------
	var blobModel = (
				\dataSize: 3,
				\state: 0,
				\area: nil,
				\perimeter: nil,	
				\center: nil,
				\rect: nil,
				\velocity: nil,
				\label: 0,
				\depthCamWidth: 0,
				\depthCamHeight: 0,

				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\env:  nil,
				\pattern: nil,
				\buses: nil


	);

	var blobsDict = Dictionary.new(numOfBlobs);
	//------------------------------------------------------

	var initBlob = {|blob|

			blob.area = Bus.control(s,1);
			blob.perimeter = Bus.control(s,1);
			blob.center = Bus.control(s,2);
			blob.rect = Bus.control(s,4);
			blob.velocity = Bus.control(s,2);
	};

	var msgToBlob = {|msg, blob|

			blob.label = msg[1]; 
			blob.state = msg[2]; 
			blob.area.set(msg[3] * 100);
			blob.perimeter.set(msg[4] * 100);
			blob.center.setn([msg[5],msg[6]]);
			blob.rect.setn([msg[7] * 1000,msg[8]* 1000,msg[9]* 1000,msg[10]* 1000]);
			blob.depthCamWidth = msg[11];
			blob.depthCamHeight = msg[12];
			blob.index = msg[13].asInteger;
			blob.velocity.setn([msg[14], msg[15]]);
			blob.dataSize = msg[16].asInteger;
			blob.data = msg.copyRange(17,127*2);

	};

	var freeBlob = {|blob|

		blob.area.free;
		blob.perimeter.free;
		blob.center.free;
		blob.rect.free;
		blob.velocity.free;

		
	};


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
		patches.do({|p| p.env.use{~deinit.(p)} });

		resetListener.free;
		initListener.free;
		updateListener.free;
		deinitListener.free;


		freqScope.kill;
		Ndef.clear(0);
		s.freeAll;
		s.quit;

	};

	//------------------------------------------------------
	var row = 3, col = 3;

	var patches = [

		// patch model
		(\file: "basic1.scd", \env: Environment.make({}), \netAddr: netAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basic2.scd", \env: Environment.make({}), \netAddr: netAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basic3.scd", \env: Environment.make({}), \netAddr: netAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basic4.scd", \env: Environment.make({}), \netAddr: netAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basic5.scd", \env: Environment.make({}), \netAddr: netAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),

	];
	//------------------------------------------------------

	var bootServer = {|f|
	
		var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		 var output = ServerOptions.devices.indexOfEqual("SERIES 208i");		// var input = ServerOptions.devices.indexOfEqual("ZoomAudioD");
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
						var d = ~onPlotData.(blobsDict);
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

				var rect  = Rect.fromArray(blob.rect.getnSynchronous(4));
				var center = Point(blob.center.getnSynchronous(2)[0] * blob.depthCamWidth, blob.center.getnSynchronous(2)[1] * blob.depthCamHeight);
				var velocity = Point(blob.velocity.getnSynchronous(2)[0], blob.velocity.getnSynchronous(2)[1]);

				var ax, ay, bx, by, mx, my;
				var xdif, ydif, a1, b1, a2, b2;

				Pen.smoothing_(true);
				Pen.width = 1;

				Pen.fillColor = cols.at(i);
				Pen.strokeColor = cols.at(i);

				Pen.fillOval(Rect(center.x, center.y,6,6));
				Pen.fillRect(Rect(center.x - 5,550,10, rect.width * -1));

				Pen.strokeRect(rect);

			 	Pen.moveTo(center);
				Pen.lineTo(Point(center.x+ (velocity.x*2), center.y+(velocity.y*2)));
				Pen.stroke;

				Pen.stringAtPoint(i.asString + ":" + blob.label.asString + ":" + blob.state, center.x + 20@center.y);

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

			//•• add shared functionality here ••//
			interpret(str);
		};
		model.env = env;
		//• load synth here instead of init?
	};

	//------------------------------------------------------
	patchButton = {|i|{|j|
		var index = (i * col) + j;
		var p = patches[index];
		if( p != nil,{
			Button()
				.states_([[p.file, Color.gray(0.2)],[p.file, Color.green(0.8)]])
				.font_(Font(size:16))
				.minHeight_(50)
				.minWidth_(100)

				.action_({|b|
					if(b.value == 1,{
						resetKE.();//•• maybe not
						p.isOn = true;
						p.env.use{~init.(p)}; 
					},{
						p.env.use{~deinit.(p)}; 
						resetKE.();
						p.isOn = false;
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
				
				patches.do({|p| 
					// resetKE.();
					if(p.isOn,{
						p.env.use{
							~deinit.(p);
						}; 
					});
					
					loadPatch.(p);

					if(p.isOn,{
						p.env.use{
							~init.(p);
						}; 
						resetKE.();
					});
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
			.minWidth_(300)
	);

	// debug tool
	s.plotTreeView(0.5, serverView);

	plotter = Plotter("plot", Rect(0, 0, 300, freqScope.bounds.height), plotView)
		.value_((0..49));
	plotter.superpose = true;
	plotter.setProperties(\backgroundColor, Color.gray(0.25));
	plotter.setProperties(\plotColor, [Color.yellow,Color.magenta,Color.cyan]).refresh;
	

	bootServer.({

		SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
		SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

		// start listening to OSC blob data
		//------------------------------------------------------
		resetListener = OSCFunc({ |msg, time, addr, recvPort|

			blobsDict.do({|blob|
				patches.do({|p| m.env.use{
					if(p.isOn, {
						if(blobsDict.values.size > 0,{
							~onBlobDeinit.(blob, blobsDict);
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

			initBlob.(blob);
			msgToBlob.(msg, blob);
			blobsDict.put(blob.label,blob);

			// postf("blob +: % :", blob.label);
			// blobsDict.do({|b|
			// 	postf("\t %", b.label);
			// });
			// postf("% \n");
			
			patches.do({|p|
				if(p.isOn, {
					if(blobsDict.values.size > 0,{
						 p.env.use{~onBlobInit.(blob, blobsDict)};
					});
				});
			});

			//blobsDict.postln;
		}, '/ke/init', recvPort: 57120);

		//------------------------------------------------------
		updateListener = OSCFunc({ |msg, time, addr, recvPort|

			var blob = blobsDict.at(msg[1]);
			if(blob != nil,{

				 msgToBlob.(msg, blob);
				
				// if this blob is on tell all patches
				if(blob.state == 2,{
					patches.do({|p| 
						if(p.isOn, {
							if(blobsDict.values.size > 0,{
								p.env.use{~onBlobUpdate.(blob, blobsDict)};
							}); 
						});
					});
				});
			});

		}, '/ke/update', recvPort: 57120);

		//------------------------------------------------------
		deinitListener = OSCFunc({ |msg, time, addr, recvPort|

			var blob = blobsDict.at(msg[1]);
			if(blob != nil,{


				patches.do({|p| 
					if(p.isOn, {
						if(blobsDict.values.size > 0,{
							p.env.use{~onBlobDeinit.(blob, blobsDict)};

						});
					}); 
				});
				
				//needs to be longer than the fade out on the patterns inside the patch when using Ndefs
				{freeBlob.(blob);}.defer(11);
				// freeBlob.(blob);
				blobsDict.removeAt(msg[1]);

				// postf("blob -: % :", blob.label);
				// blobsDict.do({|b|
				// 	postf("\t %", b.label);
				// });
				// postf("% \n");

			});


		}, '/ke/deinit', recvPort: 57120);
		
		//------------------------------------------------------

		TempoClock.default.tempo = 1.0;
		// load all data into patches
		patches.do({|p| loadPatch.(p)});

		resetKE.();
	});
)

