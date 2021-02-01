"
I use an evaluation function (a heuristic) to determine my next move; it's based on an evaluation of the board for all my potential next moves and choosing the one with the highest score. On an infinite board my potential next moves are the ones 'close' (within radius distance) to already marked positions.

Instance Variables
	radius:					<Integer>		distance for determining a neighborhood
	valueTable				<Array>		array of values for evaluating open lines on a board	
	nextMoveCandidates:	<Set>			set of reasonable candidates for next moves	
	myOpenLines:			<XOLine>		set of player's potential winning lines
	rivalOpenLines:			<XOLine>		set of rival's potential winning lines
	scoreCache:			<Collection>	collection of scores and moves
"
Class {
	#name : #BotPlayer,
	#superclass : #XOPlayer,
	#instVars : [
		'radius',
		'valueTable',
		'nextMoveCandidates',
		'myOpenLines',
		'rivalOpenLines',
		'scoreCache'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #initializing }
BotPlayer >> initialize [

	| lastIndex |
	super initialize.
	radius := 1.
	nextMoveCandidates := Set new.
	myOpenLines := Set new.
	rivalOpenLines := Set new.
	scoreCache := Set new.

	"initialize table of values for the move evaluation heuristic"
	lastIndex := XOGame lengthOfLine + 1 * XOGame lengthOfLine / 2.
	valueTable := Array new: lastIndex.
	1 to: lastIndex - 3 do: [:index | valueTable at: index put: (index - 1) fibonacci].
	lastIndex - 2 to: lastIndex do: [:index | valueTable at: index put: (lastIndex - 1) fibonacci]
	
	"example for XOGame lengthOfLine = 5:
	valueTable = #(0 1 1 2 3 5 8 13 21 34 55 89 377 377 377)
	the last 3 values are set to the same high value because they mean a winning move"
]

{ #category : #private }
BotPlayer >> myBestMove [

	self deprecated

	"method removed; this is for documentation purposes only.
	evaluate all possible next move candidates and pick the best countermove;
	implementation note: scores can also be implemented as IdentityDictionary, Bag or Heap... 
	-> compare performance, readability etc.

	Alternatives:
	
	| myBestMove |
	myBestMove := nextMoveCandidates detectMax: [:each | self myScoreFor: each].
	analytics add: scoreCache copy.
	scoreCache removeAll.
	^myBestMove
	... fastest (4230ms/20moves)

	
	| countermove |
	countermove := nextMoveCandidates fold: [:move :each | 
		(self myScoreFor: each) > (self myScoreFor: move) ifTrue: [each] ifFalse: [move]].
	analytics add: myBestMove -> scoreCache copy.
	scoreCache removeAll.
	^countermove
	... slightly slower than collect: as: (4360ms)
	... also: requires score caching in myScoreFor: ... first line would be:
		scoreCache at: myMove ifPresent: [:score | ^score].   
	
	
	| countermove |
	countermove := nextMoveCandidates inject: nextMoveCandidates anyOne into:  [:move :each | 
		(self myScoreFor: each) > (self myScoreFor: move) ifTrue: [each] ifFalse: [move]].
	analytics add: myBestMove -> scoreCache copy.
	scoreCache removeAll.
	^countermove
	... slightly slower than fold: (4430ms) ; also requires caching


	| countermove scores |
	scores := nextMoveCandidates collect: [:each | each -> (self myScoreFor: each)] as: Mapping.
	countermove := scores keyAtValue: scores values max.
	analytics add: myBestMove -> scoreCache copy.
	scoreCache removeAll.
	^countermove
	... slightly slower than detectMax: (4340ms)
	
"

]

{ #category : #accessing }
BotPlayer >> myOpenLines [
	^myOpenLines
]

{ #category : #private }
BotPlayer >> myScoreFor: myMove [
	"evaluate myMove by simulating and evaluating the board situation after myMove; 
	more precisely: evaluate all open lines based on how many marked positions (of one kind) they already contain and how many lines share the same set of marked positions; the more marked positions a line contains, the more valuabel it is; also, the more open lines share the same set of marked positions, the more valuable the open lines are;
	note: Pharo doesn't support shadowed variables (like claimed in this method) - it accepts and runs the code but won't save any change containing shadowed variables"

	| claimed conflictingLines myOpenBaselines myOpenLines rivalOpenLines myScore rivalScore |

	claimed := self claimed copy add: myMove; yourself.
	conflictingLines := [:each | each includesAnyOf: lost].
	myOpenBaselines := myMove basedLines reject: conflictingLines. 
	myOpenLines := self myOpenLines copy addAll: myOpenBaselines; yourself.
	rivalOpenLines := self rivalOpenLines difference: myMove basedLines.

	myScore := self valueOf: myOpenLines relativeTo: claimed usingOffset: 2.
	rivalScore := self valueOf: rivalOpenLines relativeTo: lost usingOffset: 0.
	
	scoreCache add: myScore - rivalScore -> myMove.
	
	^myScore - rivalScore
]

{ #category : #controlling }
BotPlayer >> play: move [
	"update board status after oponent's move, select the best countermove and update board status accordingly;
	note: consider expanding next move candidates by adding 'addAll: move basedCandidates' and 'addAll: countermove basedCandidates' or extending the radius parameter - but preliminary tests showed no impact on move selection"

	| countermove |

	lost add: move.
	radius := radius min: lost size.
	nextMoveCandidates addAll: (move neighborhood: radius); removeAllFoundIn: claimed, lost.
	myOpenLines := myOpenLines difference: move basedLines.
	rivalOpenLines addAll: (move basedLines reject: [:each | each includesAnyOf: claimed]).
	
	countermove := nextMoveCandidates detectMax: [:each | self myScoreFor: each].
	analytics add: (scoreCache sorted: #key descending).
	scoreCache removeAll.
	
	claimed add: countermove.
	nextMoveCandidates addAll: (countermove neighborhood: radius); removeAllFoundIn: claimed, lost.
	myOpenLines addAll: (countermove basedLines reject: [:each | each includesAnyOf: lost]).
	rivalOpenLines := rivalOpenLines difference: countermove basedLines.

	^countermove
]

{ #category : #accessing }
BotPlayer >> rivalOpenLines [
	^rivalOpenLines
]

{ #category : #controlling }
BotPlayer >> start [
	"initialize board information, answer the initial move"
	
	nextMoveCandidates := XOGame initialMove neighborhood: radius.
	myOpenLines := XOGame initialMove basedLines.
	analytics add: {0 -> XOGame initialMove}.
	claimed add: XOGame initialMove.
	^XOGame initialMove
]

{ #category : #private }
BotPlayer >> valueIndexFor: aPattern [
	"conversion formula from a (pattern,value) pair to a linear index to the heuristic value table"
	
	^XOGame lengthOfLine + 1 * 2 - aPattern key size * (aPattern key size -1) / 2 + aPattern value

]

{ #category : #private }
BotPlayer >> valueOf: openLines relativeTo: claimed usingOffset: offset [
	"find valuable patterns, evaluate each of them and answer the total value of all patterns"

	| patterns |
	patterns := (openLines collect: [:each | each intersection: claimed] as: Bag) 
		valuesAndCounts associations select: [:each | each key size > 1].
	"collect: as: -- find all patterns and their occurences
	associations select: -- remove singleton patterns and answer an Array of associations"

	^patterns inject: 0 into: [:subTotal :next | 
		subTotal + valueTable at: (self valueIndexFor: next) - offset]

]
