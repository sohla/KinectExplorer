(

		// var input = ServerOptions.devices.indexOfEqual("Built-in Microph");
		 // var output = ServerOptions.devices.indexOfEqual("External Headphones");
		// var output = ServerOptions.devices.indexOfEqual("Soundflower (2ch)");
		// var input = ServerOptions.devices.indexOfEqual("SERIES 208i");
		var output = ServerOptions.devices.indexOfEqual("SERIES 208i");
		var input = ServerOptions.devices.indexOfEqual("SERIES 208i");

		o = Server.local.options;
		o.inDevice = ServerOptions.devices[input];
		o.outDevice = ServerOptions.devices[output];
		// o.sampleRate = 41000.000000;
		o.memSize = 8192 * 4;
		o.numInputBusChannels = 2;
		o.numOutputBusChannels = 2;
		s.reboot;
	)
































