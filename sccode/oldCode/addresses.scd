// CABIN network setup
var noteAddr = NetAddr.new("192.168.1.150", 10001);
var globalAddr = NetAddr.new("192.168.1.150", 10002);
var keAddr = NetAddr("192.168.1.70",57000);


// var noteAddr = NetAddr.new("10.1.1.6", 10001);
// var globalAddr = NetAddr.new("10.1.1.6", 10002);
// var keAddr = NetAddr("10.1.1.3",57000);

// var noteAddr = NetAddr.new("127.0.0.1", 10001);
// var globalAddr = NetAddr.new("127.0.0.1", 10002);
// var keAddr = NetAddr("127.0.0.1",57000);

(
  noteAddr:noteAddr,
  globalAddr:globalAddr,
  keAddr:keAddr
);