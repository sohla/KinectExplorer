var patchesPath = "~/Develop/OSX/Frameworks/of_v0.11.0_osx_release/apps/myApps/KinectExplorer/sccode/patches2/";


var addresses = Require("Addresses.scd");
var noteAddr = addresses.noteAddr.();
var globalAddr = addresses.globalAddr.();
  
var files = [
  "basicVisCalibrate.scd",
  "blackVis.scd",
  "tempBlobLife.scd",
  "tempBlobPattern.scd",
  "tempBlobTrack.scd",

  "earth.scd",
  "sunFire.scd",
  "water.scd",
  "discoStripes.scd",
  "colorShape.scd",
  "basicVis7.scd",

  "blazSplit.scd",
  "conexParty.scd",

  "toDraw.scd",
  "vol.scd",
];

var genPatch = {|file|
  (\file: file, \env: Environment.make({}), \noteAddr: noteAddr, \globalAddr: globalAddr, \isOn: false, \fadeIn: 1, \fadeOut: 2)
};

var store = files.collect({|f| genPatch.(f)});

// var startWatcher = {|model|
//   var path = PathName.new(patchesPath++model.file);

//   model.env.use{
//     ~fileTime = File.mtime(path.asAbsolutePath);
//     ~fileWatcher = Routine {
//       loop{
//         if(~fileTime != File.mtime(path.asAbsolutePath),{
//             ~fileTime = File.mtime(path.asAbsolutePath);
//             ~deinit.(model);
//             interpret(str);
//             ~init.(model);
//             ("Patch" + model.file + "updated").postln;
//         }); 
//         0.1.yield;
//       }
//     }.play;
//   };
// };

var load = {|model|
  var path = PathName.new(patchesPath++model.file);
  var file = File.new(path.asAbsolutePath,"r");
  var str = file.readAllString;
  var env = Environment.make {

    ~setRGBColor= {|color = #[1,1,1,1]|
      model.globalAddr.sendMsg("/poly_r", color[0]);
      model.globalAddr.sendMsg("/poly_g", color[1]);
      model.globalAddr.sendMsg("/poly_b", color[2]);
      model.globalAddr.sendMsg("/poly_a", color[3]);
    };


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
      globalAddr.sendMsg("/background_r", 0);
      globalAddr.sendMsg("/background_g", 0);
      globalAddr.sendMsg("/background_b", 0);
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

      "set feedback".postln;
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

// (
//   store:store,
//   load:load
// )

(
  store:store,
  load:load
)