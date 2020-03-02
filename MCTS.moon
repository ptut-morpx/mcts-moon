import avg, max, find, anykey from require 'functional'

class MCTSNode
	new: (@state, @move, @manager, @reward=0, @value=0, @parent, @children={}) =>
		@terminal=@manager\getresult @state

	getscore: =>
		if @value==0 then 0 else @reward/@value

	getucb1: =>
		return math.huge if @value==0
		Vi=avg [c\getscore! for c in *@children]
		N=if @parent then @parent.value else 0
		ni=@value
		Vi+2*math.sqrt (math.log N)/ni

	getmostpromisingchild: =>
		max @children, @getucb1

	populatechildren: =>
		for move, state in pairs @manager\mkchildren @state
			continue if find @children, (node) -> node.move==move
			table.insert @children, @@ state, move, @manager, 0, 0, @

	__tostring: =>
		"{state=#{@state}, move=#{@move}, score=#{@reward}/#{@value}=#{string.format '%d%%', 100*@getscore!}, nchild=#{#@children}, ucb1=#{string.format '%f', @getucb1!}#{if @terminal then ", T=#{@terminal}" else ""}}"

	prettyprint: (indent='') =>
		print indent..tostring @
		for child in *@children
			child\prettyprint indent..'\t'

	__eq: (o) =>
		@state==o.state and @move==o.move

class MCTS
	select: (root) =>
		current=root
		while #current.children!=0
			return current if current.terminal
			current=current\getmostpromisingchild!
		current

	expand: (node) =>
		if node.value!=0 and not node.terminal
			node\populatechildren!
			node=node.children[1]
		node

	rollout: (state, manager) =>
		if result=manager\getresult state
			return result
		_, state=anykey manager\mkchildren state
		@rollout state, manager

	backpropagate: (node, result) =>
		while node
			node.value+=1
			if result==node.state.player
				node.reward+=1
			elseif result==0
				node.reward+=.5
			node=node.parent

	run: (root) =>
		root\populatechildren! if #root.children
		leaf=@select root
		node=@expand leaf
		result=@rollout node.state, root.manager
		@backpropagate node, result

import min from require 'functional'
import NimGameState, NimGameManager from require 'games'

mgr=NimGameManager 22, 3, 'misere'
state=mgr\mkstate!

--state=mgr\getchild state, 2 -- 11 -> 9
--state=mgr\getchild state, 3 -- 9 -> 6
--state=mgr\getchild state, 1 -- 6 -> 5
--state=mgr\getchild state, 2 -- 5 -> 3
--state=mgr\getchild state, 2 -- 3 -> 1
--state=mgr\getchild state, 1 -- 1 -> 0 AI wins

mcts=MCTS!
root=MCTSNode state, nil, mgr
mcts\run root for i=1, 100000

print "root node", root
print "game manager", mgr
print!
--print "max score", max root.children, (node) -> node\getscore!
--print "max reward", max root.children, (node) -> node.reward
print "max value", max root.children, (node) -> node.value
--print "min score", min root.children, (node) -> node\getscore!
--print "min reward", min root.children, (node) -> node.reward
--print "min value", min root.children, (node) -> node.value
--print "most promising", root\getmostpromisingchild!
print!
for node in *root.children
	print "play", node.move, node
print!
--root\prettyprint!
