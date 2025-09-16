(
	var port = 57120;
	var performancePort = 10005;
	//------------------------------------------------------
  var addresses = Require("Addresses.scd");
  var noteAddr = addresses.noteAddr.();
  var globalAddr = addresses.globalAddr.();
  var keAddr = addresses.keAddr.();

	//------------------------------------------------------
	var row = 4, col = 4;
  var patches = Require("Patches.scd");

	//------------------------------------------------------
	var numOfBlobs = 4;

	var window, freqScope;
	var reloadButton;
	var plotView, serverView;
	// var plotter;

	var pntListener, objListener, lnkListener;
	var resetListener, initListener, updateListener, deinitListener, performanceListener, patchListener;

	//------------------------------------------------------
	var blobsDict = Dictionary.new(numOfBlobs);
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
	var freeAll = {

		patches.store.do({|p| p.env.use{~deinit.(p)} });

		resetListener.free;
		initListener.free;
		updateListener.free;
		deinitListener.free;
		//•••performanceListener.free;

		// freqScope.kill;
		Ndef.clear(0);
		s.freeAll;
		s.quit;

	};

	//------------------------------------------------------

	var bootServer = {|f|

	// CABIN
	// var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
	// var output = ServerOptions.devices.indexOfEqual("SERIES 208i");

	// LAPTOP
	var input = ServerOptions.devices.indexOfEqual("Built-in Microph");
	var output = ServerOptions.devices.indexOfEqual("Built-in Output");


		 // var input = ServerOptions.devices.indexOfEqual("ZoomAudioD");
		// var output = ServerOptions.devices.indexOfEqual("External Headphones");

	// var input = ServerOptions.devices.indexOfEqual("BlackHole 16ch");
	// var output = ServerOptions.devices.indexOfEqual("External Headphones");
		// var output = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
		// var output = ServerOptions.devices.indexOfEqual("Radial USB Pro Output");

		o = Server.local.options;
		o.inDevice = ServerOptions.devices[input];
		o.outDevice = ServerOptions.devices[output];
		o.sampleRate = 44100.000000;
		o.memSize = 8192 * 2;
		o.numInputBusChannels = 2;
		o.numOutputBusChannels = 2;

		s.waitForBoot{
			"💫 👻 welcome to sound shadows 25 👻 💫".postln;
			f.();
		};
	};

	//------------------------------------------------------------
	var renderer = Require("renderer.scd");
	//------------------------------------------------------
	var cpuView = UserView()
		.minWidth_(60)
		.minHeight_(20)
		.animate_(true)
		.drawFunc_({|uv|
			var cpu = s.peakCPU ? 0;
			("CPU: "++cpu.asInteger++"%").drawAtPoint(16@4, Font.default, Color.yellow);
			("UGens: "++s.numUGens).drawAtPoint(100@4, Font.default, Color.yellow);
			("Groups: "++s.numGroups).drawAtPoint(200@4, Font.default, Color.yellow);
			("Synths: "++s.numSynths).drawAtPoint(300@4, Font.default, Color.yellow);
	});

	var patchButtons = {|i|{|j|
		var index = (i * col) + j;
		var p = patches.store[index];

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
            p.env.use{
              ~init.(p)
            };
					},{
						p.env.use{
              ~deinit.(p)
            };
						resetKE.();
						p.isOn = false;
					});
				})
		});
	}!col}!row;

	//------------------------------------------------------
	QtGUI.palette = QPalette.dark;
	window = Window("💫 👻 sound shadows 👻 💫",Rect(0,0,Window.screenBounds.width * 0.5, Window.screenBounds.height - 300)
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
			cpuView,
			GridLayout.rows([
			reloadButton = Button()
				.states_([["reload", Color.yellow]])
				.maxWidth_(100)
				.action_({|b|
					patches.store.do({|p|
							patches[\reloadPatch].(p);
							resetKE.();
						});
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
				UserView(),
				UserView(),
			]),
		GridLayout.rows(*patchButtons.()),
    renderer.(blobsDict, patches),
		HLayout(
			plotView = UserView()
				.minHeight_(200)
				.minWidth_(300),
		),
			Slider()
				.maxHeight_(40)
				.orientation_(\horizontal)
				.action_({|v|
					{globalAddr.sendMsg("/render_cam_x", v.value.linlin(0.0,1.0,2.0,4.0))}.defer;
				}),
			Slider()
				.maxHeight_(40)
				.orientation_(\horizontal)
				.action_({|v|
					{globalAddr.sendMsg("/render_cam_y", v.value.linlin(0.0,1.0,-4.0,4.0))}.defer;
				}),
			Slider()
				.maxHeight_(40)
				.orientation_(\horizontal)
				.action_({|v|
					{globalAddr.sendMsg("/render_cam_z", v.value.linlin(0.0,1.0,2.0,8.0))}.defer;
				}),

		),
		serverView = UserView()
			.minWidth_(300)
	);

	// debug tool
	s.plotTreeView(0.5, serverView);

	// plotter = Plotter("plot", Rect(0, 0, 400, 300), plotView)
	// 	.value_((0..49));
	// plotter.superpose = true;
	// plotter.setProperties(\backgroundColor, Color.gray(0.25));
	// plotter.setProperties(\plotColor, [Color.yellow,Color.magenta,Color.cyan]).refresh;


	bootServer.({

    var blob = Require("blob.scd");

		SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
		SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

		// start listening to OSC blob data
		//------------------------------------------------------
		resetListener = OSCFunc({ |msg, time, addr, recvPort|

			blobsDict.do({|blob|
				patches.store.do({|p| m.env.use{
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

			var label = msg[1];
			var b = Event.new(proto:blob.model);

			Routine{
				blob[\init].(b);
				s.sync;
				// msg.postln; BUG init does not have any meaningful data - sync might help
				blob[\msgToBlob].(msg, b);
				s.sync;
				blobsDict.put(label,b);

				// postf("blob init: % \n", label);

				patches.store.do({|p|
					if(p.isOn, {
						if(blobsDict.values.size > 0,{
							p.env.use{~onBlobInit.(b, blobsDict)};
						});
					});
				});

			}.play;
			//blobsDict.postln;
		}, '/ke/init', recvPort: port);

		//------------------------------------------------------
		updateListener = OSCFunc({ |msg, time, addr, recvPort|

			var label = msg[1];
			var b = blobsDict.at(label);

			if(b != nil,{

				//blobsDict.keys.postln;

				 blob[\msgToBlob].(msg, b);
				// if this blob is on tell all patches
				if(b.state == 2,{
					patches.store.do({|p|
						if(p.isOn, {
							if(blobsDict.values.size > 0,{
								p.env.use{~onBlobUpdate.(b, blobsDict)};
							});
						});
					});
				});
			});
		}, '/ke/update', recvPort: port);

		//------------------------------------------------------
		deinitListener = OSCFunc({ |msg, time, addr, recvPort|

			var label = msg[1];
			var b = blobsDict.at(label);
			if(b != nil,{
				patches.store.do({|p|
					if(p.isOn, {
						if(blobsDict.values.size > 0,{
							p.env.use{~onBlobDeinit.(b, blobsDict)};

						});
					});
				});

				Routine{
					blobsDict.removeAt(label); // must remove first before telling server!
					blob[\deinit].(b);
					s.sync;
				}.play;
				// postf("blob deinit: % \n", label);
				// postf("num of blobs: % \n", blobsDict.size);

			});

		}, '/ke/deinit', recvPort: port);
		//------------------------------------------------------
		patchListener = OSCFunc({ |msg, time, addr, recvPort|

			var index = msg[1];
			{
				patchButtons.flat.do{|b| b.valueAction_(0)};
				patchButtons.flat[index].valueAction_(1);
			}.defer;

		}, '/ke/patch', recvPort: port);

		//------------------------------------------------------
		//••• TODO
		// performanceListener = OSCFunc.newMatching({ |msg, time, addr, recvPort|
		// 	msg.postln;
		// }, '/*', recvPort: performancePort);

		//------------------------------------------------------
		TempoClock.default.tempo = 1.0;
		// load all data into patches
		patches.store.do({|p| patches[\loadPatch].(p)});
		resetKE.();

	});
	//------------------------------------------------------
	Event.addEventType(\customVisualEvent, {

		var vizMessage = {|e|
			if(noteAddr != nil, {
				{noteAddr.sendMsg("/shadow",
					"shape", e[\shape],
					"duration", e[\vdur],
					"attack", e[\vatt],
					"release", e[\vrel],
					"color", e[\color],
					"scale", e[\vscale],

					"scx", e[\scx],
					"scy", e[\scy],
					"sx", e[\sx],
					"sy", e[\sy],
					"ex", e[\ex],
					"ey", e[\ey],
					"imageindex", e[\imageindex],
					"rotstart",e[\rotstart],
					"rotend", e[\rotend],

					"speed", 1,//e[\speed],
					"freq", 20,
					"amp", 0.04,

					"wobble", e[\wobble],
				);}.defer(0.1);
			});
		};

		// currentEnvironment.postln;
		if(currentEnvironment[\dur].isKindOf(Rest) != true,{
          vizMessage.(currentEnvironment);
    });
		~type = \note;
		currentEnvironment.play;
		// true
	});

)

