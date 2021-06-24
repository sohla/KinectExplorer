
(

	// for zoom 
	var input = ServerOptions.devices.indexOfEqual("Built-in Microph");
	 // var output = ServerOptions.devices.indexOfEqual("External Headphones");
	// var output = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
	// var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
	// var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
	// var output = ServerOptions.devices.indexOfEqual("SFandSC");
	// var input = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
	var output = ServerOptions.devices.indexOfEqual("Built-in Output");
	// var output = ServerOptions.devices.indexOfEqual("JBL Charge 4");
	// var output = ServerOptions.devices.indexOfEqual("A");

	o = Server.local.options;
	o.inDevice = ServerOptions.devices[input];
	o.outDevice = ServerOptions.devices[output];
	// o.sampleRate = 48000.000000;
	o.memSize = 8192 * 1;
	o.numInputBusChannels = 2;
	o.numOutputBusChannels = 4;
	s.reboot;
)

































