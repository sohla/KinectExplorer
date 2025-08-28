(
	var port = 57120;
	var performancePort = 10005;
	//------------------------------------------------------
  var addresses = Require("Addresses.scd");
  var noteAddr = addresses.noteAddr.();
  var globalAddr = addresses.globalAddr.();
  var keAddr = addresses.keAddr.();

	//------------------------------------------------------
	var row = 3, col = 5;
  var patches = Require("Patches.scd");

	//------------------------------------------------------

  var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches2/";
  // var patchesPath = "~/Develop/OSX/Frameworks/of_v0.12.0_osx_release/apps/myApps/KinectExplorer/sccode/patches2/";

	//------------------------------------------------------
	var numOfBlobs = 4;

	var window, freqScope;
	var reloadButton;
	var plotView, plotter, serverView;

	var pntListener, objListener, lnkListener;
	var resetListener, initListener, updateListener, deinitListener, performanceListener;

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

		var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
		 // var input = ServerOptions.devices.indexOfEqual("ZoomAudioD");
		// var output = ServerOptions.devices.indexOfEqual("External Headphones");

	// var input = ServerOptions.devices.indexOfEqual("BlackHole 16ch");
	// var output = ServerOptions.devices.indexOfEqual("External Headphones");
		// var output = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
		// var input = ServerOptions.devices.indexOfEqual("Built-in Microph");
		// var output = ServerOptions.devices.indexOfEqual("Built-in Output");
		// var output = ServerOptions.devices.indexOfEqual("Radial USB Pro Output");

		o = Server.local.options;
		o.inDevice = ServerOptions.devices[input];
		o.outDevice = ServerOptions.devices[output];
		o.sampleRate = 44100.000000;
		o.memSize = 8192 * 2;
		o.numInputBusChannels = 2;
		o.numOutputBusChannels = 2;

		s.waitForBoot{
			"💫👻 welcome to sound shadows 25 👻💫".postln;
			f.();
		};
	};

	//------------------------------------------------------------
	var renderer = Require("renderer.scd");
	//------------------------------------------------------
	var patchButton = {|i|{|j|
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
		GridLayout.rows(*patchButton.()),
    renderer.(blobsDict, patches),
		HLayout(
			plotView = UserView()
				.minHeight_(200)
				.minWidth_(300),


			// freqScope = FreqScopeView()
			// 	.freqMode_(1)
			// 	.active_(true),
		)
		),
		serverView = UserView()
			.minWidth_(300)
	);

	// debug tool
// s.plotTreeView(0.5, serverView);

	plotter = Plotter("plot", Rect(0, 0, 400, 300), plotView)
		.value_((0..49));
	plotter.superpose = true;
	plotter.setProperties(\backgroundColor, Color.gray(0.25));
	plotter.setProperties(\plotColor, [Color.yellow,Color.magenta,Color.cyan]).refresh;


	bootServer.({
    
    var blobs = Require("blobs.scd");

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

			var blob = Event.new(proto:blobs.model);
			blobs[\init].(blob);
			blobs[\msgToBlob].(msg, blob);
			blobsDict.put(blob.label,blob);

		// postf("blob +: % :", blob.label);
		// blobsDict.do({|b|
		// 	postf("\t %", b.label);
		// });
		// postf("% \n");

			patches.store.do({|p|
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

				 blobs[\msgToBlob].(msg, blob);
				// if this blob is on tell all patches
				if(blob.state == 2,{
					patches.store.do({|p|
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

				patches.store.do({|p|
					if(p.isOn, {
						if(blobsDict.values.size > 0,{
							p.env.use{~onBlobDeinit.(blob, blobsDict)};

						});
					});
				});

				//needs to be longer than the fade out on the patterns inside the patch when using Ndefs
				// {blobs[\deinit].(blob);}.defer(10);
				blobs[\deinit].(blob);
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
		patches.store.do({|p| patches[\loadPatch].(p)});
		resetKE.();
	});
  
)

