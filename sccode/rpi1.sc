
/*
// scan ip
nmap -sn 192.168.20.0-12

// connect to rpi
ssh pi@192.168.20.11

// pw: create

// run SC
export DISPLAY=:0.0
./sclang -a -l ~/supercolliderStandaloneRPI2/sclang.yaml XXXXX.scd

eg. 
./sclang -a -l ~/supercolliderStandaloneRPI2/sclang.yaml rpiserver.scd

// kill
killall scsynth
killall sclang

// scan ports
sudo netstat -lptu
x

// copy
scp xxxx.txt pi@r192.168.20.11:~/remote/folder/

ls              #list files
df -h           #disk free
free -h         #ram memory
top             #cpu usage (quit with 'q')
lsusb           #list usb devices
aplay -l        #list available soundcards
exit            #leave ssh
sudo halt -p    #turn off - wait for 10 blinks
sudo reboot     #restart
sudo pkill pd   #force quit on some program
ls /dev/tty*    #see if /dev/ttyUSB0 is there
rm -r sounds    #remove a folder recursively




*/




t = Server.remote(\aa, NetAddr("192.168.20.11", 57111 ));
t.addr.connect
Server.all
Server.all.remove("raspberrypi")
Server.hardFreeAll(true)
Server.allRunningServers
t.serverRunning
t.addr
{ (SinOsc.ar(101) * 0.7)!2 }.play(t);
t.sendMsg("/n_free", 1000);

b = NetAddr("192.168.20.11", 57120 );
b.disconnect
b.free
b.sendMsg("/me", "hi there boo! ");    
b.sendMsg("/interpret", "s.addr.postln");    

//
//

// usingn bela.io code to connect to rpi.

Server.default = s = Server("raspberrypi", NetAddr("192.168.20.11", 57111));
s.initTree;
s.startAliveThread;

(
fork{
	s.sync;

	(
		SynthDef("test1",{ |out = 0, frq = 45, amp = 0.4|
		    Out.ar(out,SinOsc.ar([frq,frq+1], 0.0, amp));
		}).send(s);


		SynthDef(\help_Buffer, { arg out = 0, bufnum;
		    Out.ar( out,
		        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))!2
		    )
		}).send(s)
	);

	s.sync;
	// b = Buffer.read(s, "/usr/local/share/SuperCollider/sounds/a11wlk01.wav");
	// b = Buffer.read(s, "Applause1.wav");
	// Synth.new(\help_Buffer,[\bufnum, b], target: s);

};
)


a = Synth.new("test1",[\frq, 70], target: s);
b = Synth.new("test1",[\frq, 35], target: s);
a.set(\amp,1.0)
b.set(\amp,0.9)
a.set(\frq,60)
b.set(\frq,27)
a.free
b.free
s.freeAll


b = Buffer.read(s, "Applause1.wav");
a = Synth.new(\help_Buffer,[\bufnum, b], target: s);
a.free
s.reboot
s.quit