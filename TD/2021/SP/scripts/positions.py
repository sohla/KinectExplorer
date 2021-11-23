# me - this DAT
# scriptOp - the OP which is cooking

# press 'Setup Parameters' in the OP to call this function to re-create the parameters.
def onSetupParameters(scriptOp):
	return

# called whenever custom pulse parameter is pushed
def onPulse(par):
	return

def onCook(s):
	s.clear()
	if len(s.inputs[0].chans()) == 0:
		parent(2).par.render = 0
		return
	parent(2).par.render = 1
	s.copy( s.inputs[0])
	#startOp 	= s.inputs[1]
	s.appendChan( "tx" )
	s.appendChan( "ty" )
	s.appendChan( "tz" )
	if s.chan("rotend") is not None:
		s.appendChan( "rz" )
	animation = s.parent().op("animation")
	#finishOp	= s.inputs[2]
	for instance in range( s.numSamples ) :
		id	 	= instance
		val		= s["progress"][ instance ]
		val		= animation.sample( u = val, v = 0 )[0]
		# can start and finish come from in chop (OSC commands)?
		startx	= s["sx"][ id ]
		finishx	= s["ex"][ id ]
		vx		= (( finishx - startx ) * val ) + startx
		starty	= s["sy"][ id ]
		finishy	= s["ey"][ id ]
		vy		= (( finishy - starty ) * val ) + starty

		s["tx"][instance] = vx
		s["ty"][instance] = vy
		
		if s.chan("rotend") is not None:
			startr = s["rotstart"][id]
			endr = s["rotend"][id]
			s["rz"][id]	 = (( endr - startr ) * val ) + startr

	return
