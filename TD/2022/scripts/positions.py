# me - this DAT
# scriptOp - the OP which is cooking
import math

# press 'Setup Parameters' in the OP to call this function to re-create the parameters.
def onSetupParameters(scriptOp):
	return

# called whenever custom pulse parameter is pushed
def onPulse(par):
	return

def onCook(s):
	if ( s.numSamples <= s.inputs[0].numSamples):
		parent(2).color = (0,0,0)
	else:
		parent(2).color = (1.,0,0)
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

		# scale these values to projection (sx,sy,ex,ey are in the range -1,1)
		s["tx"][instance] = vx * 2.07
		s["ty"][instance] = vy * 1.55 
		
		if s.chan("rotend") is not None:
			startr = s["rotstart"][id]
			endr = s["rotend"][id]
			s["rz"][id]	 = (( endr - startr ) * val ) + startr
		
		if s["scx"] is not None:
			s["scx"][instance] =  s["scx"][instance] * s["value"][instance]
		
		if s["scy"] is not None:
			s["scy"][instance] =  s["scy"][instance] * s["value"][instance]
		

	return
