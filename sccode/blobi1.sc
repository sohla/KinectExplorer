
	(
	var window, routine;
	var graphView, updateGraphView;
	var oscListener;

	var blobModel = (
				\area: 0,
				\dataSize: 3,
				\perimeter: 0,
				\center: Point(0,0),
				\rect: Rect(0,0,20,20),
				\data: [[0,0]]

	);

	var blobs = Array.fill(4,{Event.new(proto:blobModel)});

	// 2.do({|i|
	// 	blobs[i].area = i;
	// 	blobs[i].center = Point(200.rand*i,i *10);

	// });
	//------------------------------------------------------
	updateGraphView = {|view|

		var cols = [Color.red, Color.green, Color.blue, Color.yellow];

		blobs.do({|blob,i|
			var prev = [];
			
			
			//[i,blob].postln;
			Pen.smoothing_(true);
			Pen.width = 1;

			Pen.fillColor = cols.at(i);
			Pen.strokeColor = cols.at(i);
			Pen.fillOval(Rect(blob.center.x, blob.center.y,12,12));
			Pen.fillRect(Rect(0 + (i*22),550,10, blob.area * -1));
			Pen.fillRect(Rect(12 + (i*22),550,10, blob.perimeter * -1));
			Pen.strokeRect(blob.rect);

			prev = blob.data.reshape(1,2)[0];
			blob.data.reshape(blob.dataSize+1,2).do({|o|

				if( (o[0].asFloat > 1) && (o[1].asFloat > 1) ,{
					r = Rect(o[0], o[1], 4, 4);
					Pen.fillOval(r);
				     Pen.moveTo(Point(prev[0],prev[1]));
				    Pen.lineTo(Point(o[0],o[1]));
					Pen.stroke;
					prev = o;
				});
			});

		});
	};
	//-------------------stt----------------------------------

	QtGUI.palette = QPalette.dark; 

	window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	).front;

	window.layout = HLayout();

	window.layout.add(
		graphView = UserView()
		.drawFunc_(updateGraphView)
		.animate_(false)
		.clearOnRefresh_(true)

	);


	oscListener = OSCFunc({ arg msg, time, addr, recvPort;
		//[msg, time, addr, recvPort].postln;skkstt

		var index = msg[1].asInteger;
		blobs[index].dataSize = msg[2].asInteger;
		blobs[index].data = msg.copyRange(11,400);
		blobs[index].area = msg[3] * 100;
		blobs[index].perimeter = msg[4] * 100;
		blobs[index].center = Point(msg[5]* 1000,msg[6]* 1000);
		blobs[index].rect = Rect(msg[7] * 1000,msg[8]* 1000,msg[9]* 1000,msg[10]* 1000);
		{graphView.refresh()}.defer;

	}, '/blobi');
	//------------------------------------------------------

	window.onClose = ({

		oscListener.free;

	});
	CmdPeriod.doOnce({window.close});

	)
