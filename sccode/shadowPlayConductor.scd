(
	var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches/";
	var netAddr = NetAddr.new("127.0.0.1", 10001);
	// var netAddr = NetAddr.new("192.168.20.3", 10001);
	var numOfBlobs = 4;


	var window, freqScope;
	var loadPatch, patchButton, reloadButton;
	var graphView, plotView, plotter;

	var oscListeners = [];
	var pntListener, objListener, lnkListener;
	var initListener, updateListener, deinitListener;

	var scale = 0.6;

	//------------------------------------------------------
	var pfmt = 0; //store the sum of all patch files modification time since epoch 

	var pfmtRout = Routine {|i|

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

				// \pWidth: Event.new(proto:paramModel),

				\velocity: Point(0,0),
				\label: 0,

				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\env:  nil

	);


	var blobsDict = Dictionary.new(numOfBlobs);

	// var initBlobs = {
	// 	blobs.do({|b,i|
	// 		b.channel = i;
	// 		b.dataSize = 0;
	// 		b.data = [];
	// 		b.area = 0;
	// 		b.perimeter = 0;
	// 		b.center = Point(0,0);
	// 		b.rect = Rect(0,0,0,0);
	// 		b.root = 0;
	// 	});
	// };

	var point = (
		\id: 0,
		\x: 0,
		\y: 0
	);

	var link = (
		\a: 0,
		\b: 0
	);

	var pose = (
		\id: 0,
		\l: 0,
		\r: 0,
		\t: 0,
		\b: 0,
		\points: Array.fill(0, {Event.new(proto:point)}),
		\links: Array.fill(0, {Event.new(proto:link)})
	);

	var poses = Array.fill(10, {Event.new(proto:pose)});

	var poseData = (
		\perimeter: 0,
		\ow: 0,
		\wr: 0,

	);
	//------------------------------------------------------


	//------------------------------------------------------
	var filter = {|input,history,friction = 0.5|
		(friction * input + ((1 - friction) * history))
	};

	//------------------------------------------------------
	var freeAll = {

		pfmtRout.stop;
		patches.do({|m| m.env.use{~deinit.(m)} });

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
	var patches = [
		(\file: "testPatch.scd", \start: 0, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "blazPatch.scd", \start: 240, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "viztestPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "frogPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		(\file: "longPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),

		// (\file: "conexPatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		// (\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),
		// (\file: "plucktonePatch.scd", \start: 120, \fade: 1, \env: Environment.make({}), \netAddr: netAddr),

	];
	//------------------------------------------------------

	var bootServer = {|f|
	
		var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		 var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
		//var output = ServerOptions.devices.indexOfEqual("SFandSC");
		// var output = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
		// var output = ServerOptions.devices.indexOfEqual("External Headphones");
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
	var updateGraphViewXX = {|view|

		Pen.fillColor = Color.black;
		Pen.fillRect(window.view.bounds);
		Pen.width = 1;
		Pen.fillColor = Color.green;


		poses.do({|o,i|
	
			if(o.links.size > 0,{

				Pen.strokeColor = Color.red;
				Pen.width = 0.5;

				o.links.do({|q,k|

					// urgh...need to test
					if(o.points[q.a] != nil || o.points[q.a] != nil,{

						var ax = o.points[q.a].x * scale;
						var ay = o.points[q.a].y * scale;
						var bx = o.points[q.b].x * scale;
						var by = o.points[q.b].y * scale;

						Pen.moveTo(ax@ay);
						Pen.lineTo(bx@by);
						Pen.stroke;
					});
				});
			});

			if(o.points.size > 0,{

				var rect = Rect.newSides(o.l * scale, o.t * scale, o.r * scale, o.b * scale);

				poseData.perimeter = (rect.width * 2) + (rect.height * 2);

				poseData.wr = filter.((rect.width - poseData.ow).abs * 10, poseData.wr, 0.3);

				poseData.ow = rect.width;
				
				// plotter : updating the data in a gui updae call!!?!?!
				plotter.value = plotter.value.flop;
				plotter.value = plotter.value.insert(0, [rect.width, rect.height, poseData.wr]);
				plotter.value = plotter.value.keep(200);
				plotter.value = plotter.value.flop;

				plotter.minval_(0);
				plotter.maxval_(1200);

				// draw the points
				Pen.strokeColor = Color.yellow;
				Pen.width = 0.2;
				Pen.strokeRect(rect);
				Pen.stringAtPoint(o.id.asString, rect.center, color: Color.yellow);

				o.points.do({|p,j|

					if(p.size > 0,{
						var x = p.x * scale;
						var y = p.y * scale;

						Pen.fillOval(Rect(x, y, 5, 5));
						// Pen.stringAtPoint(p.id.asString, x@y+5);
					});
				});

				o.points = nil;
				o.links = nil;
			});
		});
	};

	//------------------------------------------------------------
	var updateGraphView = {|view|

		var cols = [Color.magenta, Color.green, Color.blue, Color.yellow];
		var vx = 0,vy = 0;
		
		//•• for now juts plot the first blob in blobsDict
		var plotData = {
			var data = [0];
			if(blobsDict.values.size > 0,{
				patches.do({|m| 
					m.env.use{
						if(blobsDict.values.size > 0,{
							var d = ~onData.(blobsDict.values[0], blobsDict);
							if(d != nil, {data = d});
						});
					}; 
				});
			});
			data;
		};


		Pen.fillColor = Color.gray(0,1);
		Pen.fillRect(window.view.bounds);

		blobsDict.do({|blob,i|

			var prev = [];
			var val = blob.rect.width * 10;

			var ax, ay, bx, by, mx, my;
			var xdif, ydif, a1, b1, a2, b2;

			Pen.smoothing_(true);
			Pen.width = 1;

			Pen.fillColor = cols.at(i);
			Pen.strokeColor = cols.at(i);

			Pen.fillOval(Rect(blob.center.x, blob.center.y,6,6));
			Pen.fillRect(Rect(0 + (i*22),550,10, blob.rect.width * -1));
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
					Pen.lineTo(Point(bx, by))
;					Pen.stroke;
					prev = o;
				});
			});

		});

		//{ data.env.use{ ~plot.()} };



		// hack value
		if(blobsDict.values[0] != nil,{
			vx = blobsDict.values[0].velocity.x;
			vy = blobsDict.values[0].velocity.y;
		});
		//plotter
		plotter.value = plotter.value.flop;
		plotter.value = plotter.value.insert(0, plotData.());
		plotter.value = plotter.value.keep(50);
		plotter.value = plotter.value.flop;

		plotter.minval_(-10);
		plotter.maxval_(10);

		//•••• move to OSCListener
		patches.do({|m| m.env.use{
			if(blobsDict.values.size > 0,{
			~onUpdate.(blobsDict.values[0], blobsDict)});//•• just using first blob for now
			}; 
		});
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
						{m.env.use{~init.(m)} }, //add this to a runningPatches list?
						{m.env.use{~deinit.(m)} // remove this from the runningPatches list?
					});
				})
		});
	}!col}!row;

	//------------------------------------------------------
	QtGUI.palette = QPalette.dark; 
	window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height - 300)
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

	window.layout = VLayout(
		reloadButton = Button()
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
		graphView = UserView()
				.minHeight_(500)
				.drawFunc_(updateGraphView)
				.animate_(true)
				.clearOnRefresh_(true),

		HLayout(
			plotView = UserView()
				.minHeight_(200)
				.minWidth_(300),


			freqScope = FreqScopeView()
				.freqMode_(1)
				.active_(true),	
		)
	);

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
		initListener = OSCFunc({ |msg, time, addr, recvPort|

			var blob = Event.new(proto:blobModel);

			//•• label is unique : needs to be assigned to a synth/pattern
			blob.label = msg[1];
			blobsDict.put(msg[1],blob);
			// blobsDict.postln;
			
			patches.do({|m| m.env.use{
				if(blobsDict.values.size > 0,{
					~onInit.(blob, blobsDict)});
				}; 
			});


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

					//•• send data directly to patches
					// patches.do({|m| m.env.use{
					// 	if(blobsDict.values.size > 0,{
					// 		~onUpdate.(blob, blobsDict)});
					// 	}; 
					// });
			});

		}, '/ke/update', recvPort: 57120);

		//------------------------------------------------------
		deinitListener = OSCFunc({ |msg, time, addr, recvPort|

			if(blobsDict.at(msg[1]) != nil,{

				var blob = blobsDict.at(msg[1]);

				patches.do({|m| m.env.use{
					if(blobsDict.values.size > 0,{
						~onDeinit.(blob, blobsDict)});
					}; 
				});

				blobsDict.removeAt(msg[1]);
				// blobsDict.postln;

			});


		}, '/ke/deinit', recvPort: 57120);
		
		//------------------------------------------------------
		//
		//------------------------------------------------------
		lnkListener = OSCFunc({ |msg, time, addr, recvPort|
			var objIndex = msg[1];
			poses[objIndex].links = Array.fill(msg[2], {Event.new(proto:link)});
			msg.copySeries(3,nil).reshape(msg[2],2).do({|o, i|
				poses[objIndex].links[i].a = o[0];
				poses[objIndex].links[i].b = o[1];
			});
			// ([poses[objIndex].links, poses[objIndex].points.size]).postln;
		}, 'poscr/links');
		
		//------------------------------------------------------
		objListener = OSCFunc({ |msg, time, addr, recvPort|
			// [msg, time, addr, recvPort].postln;
			var objIndex = msg[1];

			// poses = Array.fill(numPoints + 1, {Event.new(proto:pose)});
			poses[objIndex].id = msg[1];// need to store?
			poses[objIndex].l = msg[2];
			poses[objIndex].r = msg[3];
			poses[objIndex].t = msg[4];
			poses[objIndex].b = msg[5];
		}, '/poscr/obj');

		//------------------------------------------------------
		pntListener = OSCFunc({ |msg, time, addr, recvPort|

			var objIndex = msg[1];
			var numPoints = msg[2];
			poses[objIndex].points = Array.fill(numPoints, {Event.new(proto:point)});
			msg.copySeries(3,nil).reshape(numPoints,3).do({|o, i|
				poses[objIndex].points[i].id = o[0];
				poses[objIndex].points[i].x = o[1];
				poses[objIndex].points[i].y = o[2];
				{graphView.refresh()}.defer;
			});
		}, '/poscr/pnts');

		//------------------------------------------------------

		// load all data into patches
		patches.do({|m| loadPatch.(m)});
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

