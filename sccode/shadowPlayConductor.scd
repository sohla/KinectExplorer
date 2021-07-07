(
	var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches/";
	var netAddr = NetAddr.new("127.0.0.1", 10001);
	var window, freqScope;
	var loadPatch, patchButton;


//------------------------------------------------------
	var freeAll = {

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
		
		(\file: "frogPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),

	];
	//------------------------------------------------------

	var bootServer = {|f|
	
		var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		 var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
		//var output = ServerOptions.devices.indexOfEqual("SFandSC");
		// var output = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
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
				.font_(Font(size:24))
				.minHeight_(100)
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
				patches.do({|m| 
					loadPatch.(m);
					m.env.use{~reload.(m)}; 
				})
			}),
		GridLayout.rows(*patchButton.()),	
		freqScope = FreqScopeView()
			.freqMode_(1)
			.active_(true),	
	);

	bootServer.({

		SynthDef(\mouseX, { |bus| Out.kr(bus, MouseX.kr(0,1.0))}).add;
		SynthDef(\mouseY, { |bus| Out.kr(bus, MouseY.kr(0,1.0))}).add;

		// load all data into patches
		patches.do({|m| loadPatch.(m)});
	});


)


// Ptpar
// Pspawner