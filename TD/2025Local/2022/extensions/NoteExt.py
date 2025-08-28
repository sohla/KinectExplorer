class NoteExt:

	def __init__( self, ownerComp ):
		self.ownerComp	= ownerComp
		self.dataOp		= ownerComp.op("data")
		self.noteIndex	= 0
		self.maxNotes	= 24
		self.chans 		= ['shape','duration','attack','release']#['shape','duration','attack','release','par1','par2', 'par3','par4','par5','par6'] #add additonal pars to this list if needed assuming they arrive in the osc message
		self.ichans 	= ["value","lifetotal","life", "progress", "id", "completed"]

		self.Initialize()


	def Initialize( self ):

		self.dataOp.clear()
		self.dataOp.numSamples = self.maxNotes


		for chan in self.chans:
			self.dataOp.appendChan(chan)
		for chan in self.ichans:
			self.dataOp.appendChan(chan)

		for sample in range( self.dataOp.numSamples ):
			self.dataOp["id"][sample] = sample

	def Osc_kvpmessage( self, message, args ):
		if len(message) < 2:
			return
		vars = {}
		for i, arg in enumerate( args[::2] ):
			vars[arg] = args[i * 2 +1]
			if self.dataOp.chan( arg ) == None:
				self.dataOp.appendChan( arg )

		vars["lifetotal"]	= vars['attack'] + vars['release'] # for now, need to be clear on this
		vars["release"]		= vars["release"] 	#a little less than audio release
		vars["completed"]	= 0.
		vars["life"]		= 0.
		vars["value"]		= 0.
		vars["progress"]	= 0.

		for chanName in vars.keys():
			self.dataOp[ chanName ][ self.noteIndex ] = vars[chanName]

		self.noteIndex = (self.noteIndex + 1)%self.maxNotes


	# def Osc_message( self, message ):

	# 	message = message.replace("/shadow","").split()
	# 	#message = message.replace("\\/","").split().pop(0)
	# 	message = list( map(float, message))
	# 	vars	= {el: message[i] for i,el in enumerate( self.chans )} #create a dict

	# 	vars["lifetotal"]	= vars['attack'] + vars['release'] # for now, need to be clear on this
	# 	vars["release"]		= vars["release"] * 0.75	#a little less than audio release
	# 	vars["completed"]	= 0.
	# 	vars["life"]		= 0.
	# 	vars["value"]		= 0.
	# 	vars["progress"]	= 0.

	# 	#vars['attack']		= 1.
	# 	#vars['duration']	= 1.
	# 	#vars["release"]		= 1.

	# 	for chanName in vars.keys():
	# 		self.dataOp[ chanName ][ self.noteIndex ] = vars[chanName]

	# 	self.noteIndex = (self.noteIndex + 1)%self.maxNotes

	def CalculateValue( self ):

		for i in range( self.maxNotes ):

			completed 	= self.dataOp["completed"][i]

			if completed == 0.:

				attack 		= self.dataOp["attack"][i]
				value  		= self.dataOp["value"][i]
				life   		= self.dataOp["life"][i]
				release		= self.dataOp["release"][i]
				duration	= self.dataOp["duration"][i]
				totalduration = duration + attack + release

				value = 1.
				releaseStart = duration - attack
				if life < attack:
					value = min( life / attack , 1.)

				elif life > releaseStart:
					value = max ( 1. - ( (life - releaseStart ) / release), 0.)

				life = min ( life + (1/60. ), totalduration )

				self.dataOp["value"][i] = round( value, 6 )
				self.dataOp["life"][i] = round( life, 6 )
				if life > 0.:
					self.dataOp["progress"][i] = round(life / totalduration , 6 )

				if life >= totalduration:
					self.dataOp["completed"][i] = 1.

		return

	def Range( self, lifetotal, max ):
		return ( lifetotal / max )
