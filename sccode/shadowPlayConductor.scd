(
	var noteAddr = NetAddr.new("10.1.1.2", 10001);
	var globalAddr = NetAddr.new("10.1.1.2", 10002);
	var keAddr = NetAddr("10.1.1.3",57000);
	var port = 57120;
	var performancePort = 10005;


	var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches2/";

	var numOfBlobs = 4;



	var window, freqScope;
	var loadPatch, patchButton, reloadButton;
	var graphView, plotView, plotter, serverView;

	var pntListener, objListener, lnkListener;
	var resetListener, initListener, updateListener, deinitListener, performanceListener;

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
				\acceleration: nil,
				\velocityRate: nil,
				\accelerationRate: nil,
				\label: 0,
				\depthCamWidth: 0,
				\depthCamHeight: 0,

				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\env:  nil,
				\pattern: nil,
				\buses: nil,
				\collided: nil,


	);

	var blobsDict = Dictionary.new(numOfBlobs);
	//------------------------------------------------------

	var initBlob = {|blob|

			blob.area = Bus.control(s,1);
			blob.perimeter = Bus.control(s,1);
			blob.center = Bus.control(s,2);
			blob.rect = Bus.control(s,4);
			blob.velocity = Bus.control(s,2);
			blob.acceleration = Bus.control(s,2);
			blob.velocityRate = Bus.control(s,1);
			blob.accelerationRate = Bus.control(s,1);
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
			blob.acceleration.setn([msg[16], msg[17]]);
			blob.velocityRate.set(msg[18]);
			blob.accelerationRate.set(msg[19]);
			blob.dataSize = msg[20].asInteger;
			blob.data = msg.copyRange(21,127*2);

	};

	var freeBlob = {|blob|

		blob.area.free;
		blob.perimeter.free;
		blob.center.free;
		blob.rect.free;
		blob.velocity.free;
		blob.velocityRate.free;
		blob.accelerationRate;
		
	};


	//------------------------------------------------------

	var resetKE = {

		{
			keAddr.sendMsg("/inputSettings/pixelpoint/persistance", 1);
			keAddr.sendMsg("/inputSettings/clear/on", 1);
			0.2.wait;
			keAddr.sendMsg("/inputSettings/pixelpoint/persistance", 2);
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
		//•••performanceListener.free;

		freqScope.kill;
		Ndef.clear(0);
		s.freeAll;
		s.quit;

	};

	//------------------------------------------------------
	var row = 3, col = 5;

	var patches = [

		// patch model
		// (\file: "basic1.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		// (\file: "basic2.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		// (\file: "basic3.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		// (\file: "basic4.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		// (\file: "basic5.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		// (\file: "basic6.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		// (\file: "basic7.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),

		(\file: "basicVisCalibrate.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basicVis1.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basicVis2.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basicVis3.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basicVis4.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basicVis5.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),
		(\file: "basicVis7.scd", \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2),

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
		o.numOutputBusChannels = 2;

		s.waitForBoot{
			"💫👻 welcome to sound shadows 👻💫".postln;
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
				// for now, calling all on patches
				patches.do({|p|
					if(p.isOn,{ 
						p.env.use{
							var d = ~onPlotData.(blobsDict);
							if(d != nil, {data = d});
						}; 
					});
				});
			});
			data;
		};

		var blobData = {|blob|
			var data = 0;

			if(blobsDict.values.size > 0,{
				// for now, calling all on patches
				patches.do({|p|
					if(p.isOn,{ 
						p.env.use{
							var d = ~onBlobData.(blob);
							if(d != nil, {data = d});
						}; 
					});
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

				var dv = blobData.(blob);

				Pen.smoothing_(true);
				Pen.width = 1;

				Pen.fillColor = cols.at(i);
				Pen.strokeColor = cols.at(i);

				Pen.fillOval(Rect(center.x, center.y,6,6));
				Pen.fillRect(Rect(center.x - 5,550,10, dv));

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

			~setPolyline = {|render = 1, lineWidth = 1, solid = 1|
				model.globalAddr.sendMsg("/poly_render", render); 
				model.globalAddr.sendMsg("/poly_linewidth",lineWidth); 
				model.globalAddr.sendMsg("/poly_solid", solid); 
			};

			~setPolylineColor = {|index = 0, color = #[1,1,1,1]|
				// // polyline colors
				// globalAddr.sendMsg("/poly_r", 1); 

				model.globalAddr.sendMsg("/poly_r"++(index+1), color[0]); 
				model.globalAddr.sendMsg("/poly_g"++(index+1), color[1]); 
				model.globalAddr.sendMsg("/poly_b"++(index+1), color[2]); 
				model.globalAddr.sendMsg("/poly_a"++(index+1), color[3]); 
			};


			~setColorRamp = {|color = #[1,1,1], hue = 1|
				// global color ramp
				globalAddr.sendMsg("/ramp_r", color[0]); 
				globalAddr.sendMsg("/ramp_g", color[1]); 
				globalAddr.sendMsg("/ramp_b", color[2]); 

				globalAddr.sendMsg("/ramp_hue1", hue); 
			};

			// background
			~setBackground0 = {
				globalAddr.sendMsg("/background_index",0);
			};

			~setBackground1 = {|color = #[1,1,1]|
				globalAddr.sendMsg("/background_index",1);
				globalAddr.sendMsg("/background_r", color[0]); 
				globalAddr.sendMsg("/background_g", color[1]); 
				globalAddr.sendMsg("/background_b", color[2]); 
			};


			~setBackground2 = {|blur = 0.1, step = 0.1|
				globalAddr.sendMsg("/background_index",2);
				globalAddr.sendMsg("/cell_blur", blur);
				globalAddr.sendMsg("/cell_step", step);
			};

			~setBackground3 = {|index = 0, scale = 1, rot = 0.0, mode = 0, color = #[1,1,1]|
				globalAddr.sendMsg("/background_index",3);
				globalAddr.sendMsg("/background_image_index", index); 
				globalAddr.sendMsg("/background_image_scale", scale); 
				globalAddr.sendMsg("/background_image_rotspeed", rot); 
				globalAddr.sendMsg("/background_image_blendmode",mode);
				globalAddr.sendMsg("/background_r", color[0]); 
				globalAddr.sendMsg("/background_g", color[1]); 
				globalAddr.sendMsg("/background_b", color[2]); 
			};

			~setDisplace = {|mix = 1, x = 0.0, y = 0.0, period = 0.1, noise = 1, z = 0.0|
				// displace polyline
				globalAddr.sendMsg("/displace_mix", mix);//on/off 
				globalAddr.sendMsg("/displace_x", x); 
				globalAddr.sendMsg("/displace_y", y); 
				globalAddr.sendMsg("/displace_period", period); 
				globalAddr.sendMsg("/displace_noise_harmonic", noise); 
				globalAddr.sendMsg("/displace_speedz",z); 
			};
	

			~setFeedback = {|mix=1, opacity=0.9, hue=0.2, x=0, y=0, dx=0, dy=0, edgeColor=#[0,0,0], edgeBlack=0.0, edgeStength=0.0|

				globalAddr.sendMsg("/feedback_mix", mix); 
				globalAddr.sendMsg("/feedback_opacity", opacity); 

				globalAddr.sendMsg("/feedback_hue", hue); 

				globalAddr.sendMsg("/feedback_x", x); //-1 1
				globalAddr.sendMsg("/feedback_y", y); 

				globalAddr.sendMsg("/feedback_displacex",dx); //-1 1
				globalAddr.sendMsg("/feedback_displacey", dy); 

				globalAddr.sendMsg("/feedback_edge_r", edgeColor[0]); 
				globalAddr.sendMsg("/feedback_edge_g", edgeColor[1]); 
				globalAddr.sendMsg("/feedback_edge_b", edgeColor[2]); 

				globalAddr.sendMsg("/feedback_edge_blacklevel", edgeBlack); 
				globalAddr.sendMsg("/feedback_edge_strength", edgeStength); 

			};
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
				.font_(Font(size:14))
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
		Button()
			.states_([["freeAll", Color.gray(0.2)]])
			.maxWidth_(100)
			.action_({|b|
				s.freeAll;
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
		}, '/ke/reset', recvPort: port);
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
		}, '/ke/init', recvPort: port);

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
		}, '/ke/update', recvPort: port);

		//------------------------------------------------------
		deinitListener = OSCFunc({ |msg, time, addr, recvPort|

			var blob = blobsDict.at(msg[1]);
			if(blob != nil,{

				// msgToBlob.(msg, blob);
				blob.label = msg[1]; 
				blob.state = msg[2]; 

				patches.do({|p| 
					if(p.isOn, {
						if(blobsDict.values.size > 0,{
							p.env.use{~onBlobDeinit.(blob, blobsDict)};

						});
					}); 
				});
				
				//needs to be longer than the fade out on the patterns inside the patch when using Ndefs
				{freeBlob.(blob);}.defer(10);
				// freeBlob.(blob);
				blobsDict.removeAt(msg[1]);

				// postf("blob -: % :", blob.label);
				// blobsDict.do({|b|
				// 	postf("\t %", b.label);
				// });
				// postf("% \n");

			});


		}, '/ke/deinit', recvPort: port);
		//------------------------------------------------------

		//••• TODO
		// performanceListener = OSCFunc.newMatching({ |msg, time, addr, recvPort|
		// 	msg.postln;
		// }, '/*', recvPort: performancePort);

		//------------------------------------------------------
		TempoClock.default.tempo = 1.0;
		// load all data into patches
		patches.do({|p| loadPatch.(p)});	
		resetKE.();
	});
)

// NetAddr.localAddr

// (
// a = OSCFunc({ |msg, time, addr, recvPort|
// 	msg.postln;
// }, '/ke/update', recvPort: 57120);
// )
// a.free

