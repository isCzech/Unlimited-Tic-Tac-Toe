"
I'm using an evaluation function to determine my next move; it's based on an evaluation of the board for all my potential next moves and choosing the one with the highest score. On an unlimited board only moves close (within radius distance) to the previous ones (of both me and my oponent) are considered.

Instance Variables
	radius:				<Object>
	myOpenLines:		<Object>
	rivalOpenLines:		<Object>
	upForGrabs:		<Object>


"
Class {
	#name : #BotPlayer,
	#superclass : #XOPlayer,
	#instVars : [
		'radius',
		'myOpenLines',
		'rivalOpenLines',
		'nextMoveCandidates'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #public }
BotPlayer >> initialize [

	super initialize.
	radius := 1.
	nextMoveCandidates := Set new: 200.
	myOpenLines := Set new: 100.
	rivalOpenLines := Set new: 100.
	
]

{ #category : #private }
BotPlayer >> isWinner [

	^self lastScore > 1000
]

{ #category : #private }
BotPlayer >> myMove [
	"evaluating all possible next moves and picking the best countermove;
	implementation note: scores can also be implemented as IdentityDictionary, Bag or Heap... 
	-> compare performance, readability etc.
	for scores Dictionary may not be the best - OC of associations may be better..."

	| countermove scores |
	scores := Mapping new.
	nextMoveCandidates do: [:each | scores add: each -> (self myScoreFor: each)].
	countermove := scores keyAtValue: scores values max.
	analytics add: countermove -> scores.
	^countermove
]

{ #category : #private }
BotPlayer >> myScoreFor: aMove [
	"evaluation function (so far for lines of 5 only); evaluates all open lines based on how many symbols they already contain and whether they are 'weak' or 'strong' (strong open lines are 'closer' to victory thus more valuable). Exact definitions are:
	(i) a line is my open line iff all it's positions are free or claimed provided at least one position is claimed
	(ii) a line is a rival open line iff all it's positions are free or lost, provided at least one position is lost 
	(iii) an open line is strong iff it is not weak
	(iv) an open line containing 3 (same) symbols is weak iff (1) outer boundaries are lost or (2) just one outer boundary is lost but it's inner neighbor is claimed or (3) both outer boundaries are free but both inner boundaries are claimed
	(v) an open line containing 2 (same) symbols is weak iff the two claimed positions don't have a common neighbor; i.e. there are at least two free positions between them"

	| score claimed myOL myOL1 myOL2 myOL3 myOL4 rivalOL rivalOL1 rivalOL2 rivalOL3 myStrongOL3 myWeakOL3 rivalStrongOL3 rivalWeakOL3 myWeakOpenLines rivalWeakOpenLines myBaselines |
	
	myBaselines := aMove basedLines.
	myOL := myOpenLines copy addAll: (myBaselines reject: [:each | each includesAnyOf: lost]); yourself.
	rivalOL := rivalOpenLines copy removeAllFoundIn: myBaselines; yourself.
	claimed := self claimed copy add: aMove; yourself.

	myWeakOpenLines := [:line | | outerBoundary | outerBoundary := line outerBoundary. "has always two elements"
		(outerBoundary allSatisfy: [:each | lost includes: each])  	"both outer boundaries lost"
		or: [
		(outerBoundary anySatisfy: [:each | 
				(lost includes: each) and: 
				(line anySatisfy: [:elem | (each neighbors includes: elem) and: (claimed includes: elem)])
				])
		]
		"or: [ (both outer boundaries free and both inner boundaries claimed) ]"
	].
	rivalWeakOpenLines := [:line | | outerBoundary | outerBoundary := line outerBoundary.
		(outerBoundary allSatisfy: [:each | claimed includes: each])
		or: [
		(outerBoundary anySatisfy: [:each | 
				(claimed includes: each) and: 
				(line anySatisfy: [:elem | (each neighbors includes: elem) and: (lost includes: elem)])
				])
		]
		"or: [ (both outer boundaries free and both inner boundaries lost) ]"
	].

	(myOL select: [:each | (each copy removeAllFoundIn: claimed; size) = 0]) ifNotEmpty: [^10000]. 	"winning move"
	(rivalOL select: [:each | (each copy removeAllFoundIn: lost; size) = 1]) ifNotEmpty: [^-10000]. 		"losing move"
	
	myOL1 := myOL select: [:each | (each copy removeAllFoundIn: claimed; size) = 4].
	myOL2 := myOL select: [:each | (each copy removeAllFoundIn: claimed; size) = 3].
	myOL3 := myOL select: [:each | (each copy removeAllFoundIn: claimed; size) = 2].
	myOL4 := myOL select: [:each | (each copy removeAllFoundIn: claimed; size) = 1].

	rivalOL1 := rivalOL select: [:each | (each copy removeAllFoundIn: lost; size) = 4].
	rivalOL2 := rivalOL select: [:each | (each copy removeAllFoundIn: lost; size) = 3].
	rivalOL3 := rivalOL select: [:each | (each copy removeAllFoundIn: lost; size) = 2].

	myWeakOL3 := myOL3 select: myWeakOpenLines.
	myStrongOL3 := myOL3 reject: myWeakOpenLines.
	rivalWeakOL3 := rivalOL3 select: rivalWeakOpenLines.
	rivalStrongOL3 := rivalOL3 reject: rivalWeakOpenLines.

	self needsWork. "implementation note: improve by adding weak and strong OL4s and maybe even OL2s"

	score := (myOL1 size // 5) + (3 * myOL2 size) + (5 * myWeakOL3 size) + (8 * myStrongOL3 size) + (21 * myOL4 size)
			- (rivalOL1 size //3) - (5 * rivalOL2 size) - (8 * rivalWeakOL3 size) - (21 * rivalStrongOL3 size).
	^score.
	



	
]

{ #category : #public }
BotPlayer >> play: move [
	"self plays countermove in response to oponent's move
	upForGrabs refers to a set of all free positions in the neigborhood of all played (claimed or lost) as potential next moves"

	| countermove |
	"updating game status after oponent's move
	freeMoveNeigborhood :=  (move neighborhood: radius); removeAllFoundIn: claimed, lost."
	lost add: move. 
	nextMoveCandidates addAll: (move neighborhood: radius); removeAllFoundIn: claimed, lost.
	myOpenLines removeAllFoundIn: (move basedLines).
	rivalOpenLines addAll: (move basedLines reject: [:each | each includesAnyOf: claimed]).
	
	countermove := self myMove.
	
	"updating game status after my countermove"
	claimed add: countermove.
	nextMoveCandidates addAll: (countermove neighborhood: radius); removeAllFoundIn: claimed, lost.
	myOpenLines addAll: (countermove basedLines reject: [:each | each includesAnyOf: lost]).
	rivalOpenLines removeAllFoundIn: (countermove basedLines).
	^countermove
]

{ #category : #public }
BotPlayer >> start [
	"X starts by playing to 0@0 position"
	
	| move |
	move := XOGame initialMove.				"creates a new Position object representing 0@0"
	claimed add: move.							"0@0 occupied (claimed) by X"
	nextMoveCandidates := move neighborhood: radius.	"next move candidates within radius distance"
	myOpenLines := move basedLines.			"all lines containing 0@0"
	analytics add: move -> ({move -> 0} asDictionary).	"first move log entry"
	^move

]
