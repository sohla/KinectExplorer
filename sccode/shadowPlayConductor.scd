(
	var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches/";
	var netAddr = NetAddr.new("127.0.0.1", 10001);
	var window;
	var loadPatch;


//------------------------------------------------------
	var freeAll = {

		Ndef.clear(0);
		s.freeAll;
		s.quit;

	};


	//------------------------------------------------------
	var models = [
		(\file: "testPatch.scd", \start: 0, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "blazPatch.scd", \start: 240, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),

	];
	var currentModel = models[0];
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
		model.env = Environment.make {
			interpret(str);
		};
		if(reload == true,{
			currentModel.env.use{~reload.(currentModel)};

		},{
			currentModel.env.use{~deinit.(currentModel)};
		});
		model.env.use{~init.(model)};

		currentModel = model;
		// s.queryAllNodes;
	};

	//------------------------------------------------------

	//------------------------------------------------------

	//------------------------------------------------------


	//------------------------------------------------------

	QtGUI.palette = QPalette.dark; 
	window = Window("",Rect(0,0,Window.screenBounds.width/4, Window.screenBounds.height/4)
		.center_(Window.availableBounds.leftBottom)
	).front;
	//------------------------------------------------------
	window.onClose = ({ freeAll.() });
	CmdPeriod.doOnce({ freeAll.() });

	window.layout = HLayout(
		PopUpMenu()
			.items_(models.collect({|o,i| o.file}))
			.action_({|p| loadPatch.(models[p.value]) })
			.valueAction_(0),
		Button()
			.states_([["reload"]])
			.action_({|b|
				loadPatch.(currentModel, true);
			})
	);


	bootBeeServer.({
		"hi".postln;

		SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
		SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

		currentModel = models[0];
		loadPatch.(models[0]);

	});


)


