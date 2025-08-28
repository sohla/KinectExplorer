var model = (
				\dataSize: 3,
				\state: 0,
				\area: nil,
				\perimeter: nil,
				\center: nil,
				\rect: nil,
				\velocity: nil,
				\acceleration: nil,
				\velocityRate: nil,
				\accelerationRate: nil,
				\label: 0,
				\depthCamWidth: 0,
				\depthCamHeight: 0,

				\data: [[0,0]],
				\isNoteOn: false,
				\channel: 0,
				\root: 60,
				\env:  nil,
				\pattern: nil,
				\buses: nil,
				\collided: nil,

	);

  var init = {|blob|

			blob.area = Bus.control(s,1);
			blob.perimeter = Bus.control(s,1);
			blob.center = Bus.control(s,2);
			blob.rect = Bus.control(s,4);
			blob.velocity = Bus.control(s,2);
			blob.acceleration = Bus.control(s,2);
			blob.velocityRate = Bus.control(s,1);
			blob.accelerationRate = Bus.control(s,1);
	};

	var msgToBlob = {|msg, blob|

			blob.label = msg[1];
			blob.state = msg[2];
			blob.area.set(msg[3] * 100);
			blob.perimeter.set(msg[4] * 100);
			blob.center.setn([msg[5],msg[6]]);
			blob.rect.setn([msg[7] * 1000,msg[8]* 1000,msg[9]* 1000,msg[10]* 1000]);
			blob.depthCamWidth = msg[11];
			blob.depthCamHeight = msg[12];
			blob.index = msg[13].asInteger;
			blob.velocity.setn([msg[14], msg[15]]);
			blob.acceleration.setn([msg[16], msg[17]]);
			blob.velocityRate.set(msg[18]);
			blob.accelerationRate.set(msg[19]);
			blob.dataSize = msg[20].asInteger;
			blob.data = msg.copyRange(21,127*2);

	};

	var deinit = {|blob|

		blob.area.free;
		blob.perimeter.free;
		blob.center.free;
		blob.rect.free;
		blob.velocity.free;
		blob.velocityRate.free;
		blob.accelerationRate;

	};

  (
    model:model,
    init:init,
    msgToBlob:msgToBlob,
    deinit:deinit
  );