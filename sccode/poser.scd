(	
	var window;
	var graphView;
	var pntListener, objListener, lnkListener;
	var scale = 0.8;

	var point = (
		\id: 0,
		\x: 0,
		\y: 0
	);

	var link = (
		\a: 0,
		\b: 0
	);

	var object = (
		\id: 0,
		\l: 0,
		\r: 0,
		\t: 0,
		\b: 0,
		\points: Array.fill(0, {Event.new(proto:point)}),
		\links: Array.fill(0, {Event.new(proto:link)})
	);

	var objects = Array.fill(10, {Event.new(proto:object)});


	//------------------------------------------------------
	var freeAll = {

		pntListener.free;
		objListener.free;
		lnkListener.free;
		Ndef.clear(0);
		s.freeAll;
		s.quit;

	};

	//------------------------------------------------------------
	var updateGraphView = {|view|

			Pen.fillColor = Color.black;
			Pen.fillRect(window.view.bounds);
			Pen.width = 1;
			Pen.fillColor = Color.green;


			objects.do({|o,i|
		
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
	//------------------------------------------------------

	QtGUI.palette = QPalette.dark; 
	window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/3)
		.center_(Window.screenBounds.width*0.85@100)
	).front;
	
	window.layout = VLayout(
		graphView = UserView()
			.minHeight_(700)
			.drawFunc_(updateGraphView)
			.animate_(false)
			.clearOnRefresh_(true),
	);

	//------------------------------------------------------
	window.onClose = ({ freeAll.() });
	CmdPeriod.doOnce({ freeAll.() });

	lnkListener = OSCFunc({ |msg, time, addr, recvPort|
		var objIndex = msg[1];
		objects[objIndex].links = Array.fill(msg[2], {Event.new(proto:link)});
		msg.copySeries(3,nil).reshape(msg[2],2).do({|o, i|
			objects[objIndex].links[i].a = o[0];
			objects[objIndex].links[i].b = o[1];
		});
		// ([objects[objIndex].links, objects[objIndex].points.size]).postln;
	}, 'poscr/links');
	
	objListener = OSCFunc({ |msg, time, addr, recvPort|
		// [msg, time, addr, recvPort].postln;
		var objIndex = msg[1];

		// objects = Array.fill(numPoints + 1, {Event.new(proto:object)});
		objects[objIndex].id = msg[1];// need to store?
		objects[objIndex].l = msg[2];
		objects[objIndex].r = msg[3];
		objects[objIndex].t = msg[4];
		objects[objIndex].b = msg[5];
	}, '/poscr/obj');

	pntListener = OSCFunc({ |msg, time, addr, recvPort|

		var objIndex = msg[1];
		var numPoints = msg[2];
		objects[objIndex].points = Array.fill(numPoints, {Event.new(proto:point)});
		msg.copySeries(3,nil).reshape(numPoints,3).do({|o, i|
			objects[objIndex].points[i].id = o[0];
			objects[objIndex].points[i].x = o[1];
			objects[objIndex].points[i].y = o[2];
			{graphView.refresh()}.defer;
		});
	}, '/poscr/pnts');


)


/*
0	nose
1	leftEye
2	rightEye
3	leftEar
4	rightEar
5	leftShoulder
6	rightShoulder
7	leftElbow
8	rightElbow
9	leftWrist
10	rightWrist
11	leftHip
12	rightHip
13	leftKnee
14	rightKnee
15	leftAnkle
16	rightAnkle

*/

/*

ID, l, r, t, b, numKeyPoints, ID, x, y, ID, x, y....., numLinks, ai, bi, ai, bi......





*/




b = Bus.control(s);
b.value = 1.5

b.plot