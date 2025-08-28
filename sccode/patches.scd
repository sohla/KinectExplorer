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
	var patches = files.collect({|f| genPatch.(f)});

  patches;