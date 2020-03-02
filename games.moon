randomkey=(table) ->
	arr=[k for k in pairs table]
	arr[math.random 1, #arr]
randomseed=() ->
	fd=io.open '/dev/random', 'r'
	rand=fd\read 4
	fd\close!
	val=[(math.pow 256, i-1)*string.byte rand\sub i, i for i=1, 4]
	seed=val[1]+val[2]+val[3]+val[4]
	math.randomseed seed

class GameState
	nil

class GameManager
	new: =>
		error "Unimplemented"

	mkstate: (seed) =>
		error "Unimplemented"
		GameState!

	mkchildren: (state) =>
		error "Unimplemented"
		{move, GameState! for move in *({0})}

	getchild: (state, move) =>
		error "Unimplemented"
		GameState!

	getresult: (state) =>
		error "Unimplemented"
		nil

	playgame: (options) =>
		import seed, turnfn, p1fn, p2fn, startplayer, beginfn from options
		p2fn=options['p-1fn'] unless p2fn

		seed=nil unless seed
		turnfn=(() -> nil) unless turnfn
		p1fn=randomkey unless p1fn
		p2fn=randomkey unless p2fn
		beginfn=(() -> nil) unless beginfn

		turn=1
		state=@mkstate seed, startplayer
		beginfn!
		randomseed!
		while true
			possibilities=@mkchildren state
			local move
			if state.player==1
				move=p1fn possibilities, state, @
			else
				move=p2fn possibilities, state, @
			turnfn turn, state, move
			state=possibilities[move]
			if result=@getresult state
				return result
			turn+=1

	playgames: (options) =>
		import count, startplayer from options

		count=100 unless count
		startplayer='alternate' unless startplayer
		if startplayer=='random' or startplayer=='alternate'
			options={k, v for k, v in pairs options}

		stats={i, 0 for i=-1, 1}
		player=1
		for i=1, count
			if startplayer==1 or startplayer==2
				player=startplayer
			elseif startplayer=='alternate'
				player=-player
			else--if startplayer=='random'
				player=({1, -1})[math.random 1, 2]

			options.startplayer=player
			result=@playgame options
			stats[result]+=1

		stats

class NimGameState extends GameState
	new: (@pieces, @player=1) =>

	__tostring: =>
		"{#{@pieces},#{@player}}"

	__eq: (o) =>
		@pieces==o.pieces and @player==o.player

class NimGameManager extends GameManager
	new: (@startpieces=10, @maxtake=3, @gamemode='normal') =>
		error "Must have at least one piece" if @startpieces<1
		error "Can't take more than available pieces" if @maxtake>@startpieces
		error "Can't take less than 2 pieces" if @maxtake<2
		error "Invalid game variant" if @gamemode!='misere' and @gamemode!='normal'

	mkstate: (seed, startplayer=1) =>
		NimGameState @startpieces, startplayer

	mkchildren: (state) =>
		{i, NimGameState state.pieces-i, -state.player for i=1, math.min state.pieces, @maxtake}

	getchild: (state, move) =>
		NimGameState state.pieces-move, -state.player

	getresult: (state) =>
		if state.pieces==0
			if @gamemode=='misere'
				return state.player
			else
				return -state.player
		return nil

	__tostring: =>
		"{start=#{@startpieces}, max=#{@maxtake}, gamemode=#{@gamemode}}"

class LedgeGameState extends GameState
	new: (@board, @player=1) =>

	__tostring: =>
		"{#{table.concat @board},#{@player}}"

	__eq: (o) =>
		return false if @player!=o.player
		for i, v in ipairs @board
			return false if o.board[i]!=v
		return true

class LedgeGameManager extends GameManager
	new: (@length=10) =>
		error "Length must be at least 1" if @length<1

	mkstate: (seed=math.random!, startplayer=1) =>
		math.randomseed seed
		board=[math.random 0, 1 for i=1, @length]
		board[math.random 1, @length]=2
		LedgeGameState board, startplayer

	mkchildren: (state) =>
		children={}
		if state.board[1]!=0
			children['t']=LedgeGameState [i==1 and 0 or v for i, v in ipairs state.board], -state.player
		for i=2, @length
			continue if state.board[i]==0
			for j=i-1, 1, -1
				break if state.board[j]!=0
				board=[v for v in *state.board]
				board[j], board[i]=board[i], 0
				children["#{i},#{j}"]=LedgeGameState board, -state.player
		children

	getchild: (state, move) =>
		if move=='t'
			return LedgeGameState [i==1 and 0 or v for i, v in ipairs state.board], -state.player
		i, j=move\match '(%d+),(%d+)'
		board=[v for v in *state.board]
		board[j], board[i]=board[i], 0
		LedgeGameState board, -state.player

	getresult: (state) =>
		for v in *state.board
			return nil if v==2
		return -state.player

	__tostring: =>
		"{length=#{@length}}"

{
	:GameState, :GameManager
	:NimGameState, :NimGameManager
	:LedgeGameState, :LedgeGameManager
}
