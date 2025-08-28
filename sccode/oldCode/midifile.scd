(
	// basic loading of midi file
	var path = "~/Develop/SuperCollider/tome/midifiles/";
	var midiFile = SimpleMIDIFile.read(path++"air.mid");

	//var t = midiFile.p.asStream;
	// midiFile.midiEvents.size.postln;
	// midiFile.asDicts.do({ |item|[item,t.next(Event.default)].postln; });
	//midiFile.asDicts.do({ |item| item.postln; });
	// midiFile.play;
	// midiFile.tracks;
	midiFile.generatePatternSeqs[1];
//	midiFile.noteOnEvents(0,0).postln;
)


Event.eventTypes.keys

(// looking into a Ppar as stream
var a, b;
a = Pbind(\note, Pseq([7, 4, 0], 4), \dur, Pseq([1, 0.5, 1.5], inf));
b = Pbind(\note, Pseq([5, 10, 12], 4), \dur, 1);
c = Ppar([ a, b ]);
t = c.asStream;
20.do({ t.next(Event.default).postln; });
)




(
	// diving into the data
	var path = "~/Develop/SuperCollider/tome/midifiles/";
	var midiFile = SimpleMIDIFile.read(path++"chords.mid");

	var t = midiFile.p.asStream;
	4.do({ t.next((Event.default)).postln; });
)


// example of controlling a pattern using gui. 
s.latency = 0.05
( 
var    pattern = Pbind(
        \degree, Pseries(7, Pwhite(1, 3, inf) * Prand(#[-1, 1], inf), inf).fold(0, 14)
            + Prand(#[[0, -2, -4], [0, -3, -5], [0, -2, -5], [0, -1, -4]], inf),
        \dur, Pwrand(#[0.2, 0.3], #[0.2, 0.3], inf)
    ),
    player, window;

window = Window.new("Pattern trigger", Rect(5, 100, 150, 100))
        // onClose is fairly important
        // without it, closing the window could leave the pattern playing
    .onClose_({ player.stop });
Button.new(window, Rect(5, 5, 140, 90))
    .states_([["Pattern NEXT"]])
    .font_(Font.new("Helvetica", 18))
    .action_({ |button|
            player = pattern.next(()).play();
            {player.stop;}.defer(0.01);
    });
window.front;
)



(
	//l  loading midi file and stepping thru each note on each track
	var path = "~/Develop/SuperCollider/tome/midifiles/";
	var midiFile = SimpleMIDIFile.read(path++"major.mid");

	var t = midiFile.p.asStream;
	//4.do({ t.next(Event.default).play; });

	var player, window;

	window = Window.new("Pattern trigger", Rect(5, 100, 150, 100))
	    .onClose_({ player.stop });
	
	Button.new(window, Rect(5, 5, 140, 90))
	    .states_([["Pattern NEXT"]])
	    .font_(Font.new("Helvetica", 18))
	    .action_({ |button|
	            player = t.next(Event.default).play();
	            {player.stop;}.defer(0.01);
	    });
	window.front;
)





(
	// basic loading of midi file
	var path = "~/Develop/SuperCollider/Projects/tome/midifiles/";
	var midiFile = SimpleMIDIFile.read(path++"chords.mid");
	var currentAbs = -1;
	var chords = [];
	var currentNotes = [];
	var index = -1;

	midiFile.asDicts.select({|o| o.type == \noteOn}).do({ |item| 
		item.absTime.postln;

		if(currentAbs == item.absTime,{
			currentNotes = currentNotes.add(item);
			chords = chords.put(index,currentNotes);
		},{
			currentNotes = [];
			currentNotes = currentNotes.add(item);
			chords = chords.add(currentNotes);
			index = index + 1;
			currentAbs = item.absTime;
		}); 
	});

	chords.do({|item| 
		item.collect({|o| o.note}).post;
		item[0].absTime.postln;
	});
)



