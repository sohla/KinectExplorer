(
	var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches/";
	var netAddr = NetAddr.new("127.0.0.1", 10001);
	var window, freqScope;
	var loadPatch, unloadPatch, patchButton;


//------------------------------------------------------
	var freeAll = {

		freqScope.kill;
		Ndef.clear(0);
		s.freeAll;
		s.quit;

	};


	//------------------------------------------------------
	var row = 2, col = 2;
	var models = [
		(\file: "testPatch.scd", \start: 0, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "blazPatch.scd", \start: 240, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		
		(\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),

	];
	//------------------------------------------------------

	var bootBeeServer = {|f|
	
		var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
		// var output = ServerOptions.devices.indexOfEqual("SFandSC");
		// var input = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
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
	//------------------------------------------------------
	//------------------------------------------------------------
	loadPatch = {|model, reload = false|
		var path = PathName.new(patchesPath++model.file);
		var file = File.new(path.asAbsolutePath,"r");
		var str = file.readAllString;
		var env = Environment.make {
			interpret(str);
		};
		// if(reload == true,{
		// 	currentModel.env.use{~reload.(currentModel)};

		// },{
		// 	currentModel.env.use{~deinit.(currentModel)};
		// });

		model.env = env;
		// model.env.use{~init.(model)};

		//currentModel = model;
		// s.queryAllNodes;
	};

	//------------------------------------------------------

	// unloadPatch = {|model|
	// 	model.env.use{~deinit.(model)};
	// };
	// //------------------------------------------------------

	//------------------------------------------------------
	patchButton = {|i|{|j|
		// postf(">> % % : %\n",i,j, (i * models.size.half) + j);
		var index = (i * col) + j;
		var m = models[index];
		if( m != nil,{
			Button()
				.states_([[m.file, Color.gray(0.2)],[m.file, Color.green(0.8)]])
				.font_(Font(size:24))
				.minHeight_(100)
				.minWidth_(100)
				.action_({|b|
					if(b.value == 1,{
						// loadPatch.(models[index]);
						m.env.use{~init.(m)};
					},{
						// unloadPatch.(models[index]);
						m.env.use{~deinit.(m)};
					});
				})
		});
	}!col}!row;

	//------------------------------------------------------

	QtGUI.palette = QPalette.dark; 
	window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/2)
		.center_(Window.availableBounds.leftBottom)
	).front;
	//------------------------------------------------------
	window.onClose = ({ freeAll.() });
	CmdPeriod.doOnce({ freeAll.() });

	window.layout = VLayout(
		Button()
			.states_([["reload", Color.yellow]])
			.maxWidth_(100)
			.action_({|b|
				models.do({|m| m.env.use{~reload.(m)} })
			}),
		GridLayout.rows(*patchButton.()),	
		freqScope = FreqScopeView()
			.freqMode_(1)
			.active_(true),

		
	);


	bootBeeServer.({
		"hi".postln;

		SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
		SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

		// currentModel = models[0];
		// loadPatch.(models[0]);
		models.do({|m| loadPatch.(m)});
	});


)



{{2}!2}!2