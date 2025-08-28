
var renderer = {|blobsDict, patches|

    UserView()
				.minHeight_(500)
				.minWidth_(500)
        .background_(Color.black)
				.drawFunc_({|view|

              var cols = [Color.magenta, Color.green, Color.blue, Color.yellow];
              var vx = 0,vy = 0;

              var plotData = {

                var data = [0];

                if(blobsDict.values.size > 0,{
                  // for now, calling all on patches
                  patches.store.do({|p|
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
                  patches.store.do({|p|
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



              if(s.serverRunning == false,{
                Pen.strokeColor = Color.magenta;
              Pen.stringAtPoint("booting server...", 10@10, color:Color.yellow(0.5));
              });

              Pen.scale(1.3, 1.3);
              Pen.translate(-100, -20);
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

                  Pen.fillColor = cols.at(blob.label.asInteger.mod(4));
                  Pen.strokeColor = cols.at(blob.label.asInteger.mod(4));

                  Pen.fillOval(Rect(center.x-3, center.y-3, 6, 6));
                // Pen.fillRect(Rect(center.x - 5,550,10, dv));

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
            })
				.frameRate_(30)
				.animate_(true)
				.clearOnRefresh_(true)
};


renderer;