-- basic functions
identity=(...) -> ...
void=() -> nil
always=(value) -> () -> value
is=(value) -> (v) -> v==value
invert=(predicate) -> (...) -> not predicate ...

-- returns the keys of a table
keys=(table) ->
	[k for k in pairs table]

-- fold a list with an accumulation function
fold=(list, fn, initval=nil) ->
	local acc, stidx
	if initval
		acc, stidx=initval, 1
	else
		acc, stidx=list[1], 2
	for i=stidx, #list
		acc=fn acc, list[i]
	acc

-- maps a list through a function
map=(list, fn=identity) ->
	[fn v for v in *list]

-- checks if a member of the list verifies a predicate
some=(list, predicate=always true) ->
	for i, v in ipairs list
		return true if predicate v, i, list
	return false

-- checks if all members of the list verify a predicate
all=(list, predicate=always true) ->
	for i, v in ipairs list
		return false unless predicate v, i, list
	return true

-- creates a list containing only members verifying a predicate
filter=(list, precicate=always true) ->
	[v for i, v in ipairs list when precicate v, i, list]

-- returns the sum of all elements of a list
sum=(list) ->
	return if #list==0
		0
	else
		fold list, (a, b) -> a+b

-- returns the average of all elements of a list
avg=(list) ->
	return if #list==0
		0
	else
		(sum list)/#list

-- returns the biggest element of a list
max=(list, key=identity) ->
	return if #list==0
		nil
	else
		fold list, (a, b) -> if (key a)>(key b) then a else b

-- returns the smallest element of a list
min=(list, key=identity) ->
	return if #list==0
		nil
	else
		fold list, (a, b) -> if (key a)<(key b) then a else b

-- returns a random element of a list
any=(list) ->
	return if #list==0
		nil
	else
		list[math.random 1, #list]

-- returns a random key and value of a table
anykey=(table) ->
	return unless next table
		nil
	else
		key=any keys table
		key, table[key]

-- finds the first item verifying a predicate
find=(list, predicate=always true) ->
	for i, v in ipairs list
		return v if predicate v, i, list
	return nil

-- finds the index of the first item verifying a predicate
findindex=(list, predicate=always true) ->
	for i, v in ipairs list
		return i if predicate v, i, list
	return 0

-- checks if a list contains a given element
includes=(list, item) ->
	some list, is item

-- gets the index of the first appearance of a given element
indexof=(list, item) ->
	findindex list, is item

{
	:identity, :void, :always, :is, :invert
	:fold, :map, :filter
	:some, :all
	:sum, :avg
	:max, :min
	:find, :findindex
	:includes, :indexof
	:keys
	:any, :anykey
}
