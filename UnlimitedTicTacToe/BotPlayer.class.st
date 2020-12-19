"
I use an evaluation function (a heuristic) to determine my next move; it's based on an evaluation of the board for all my potential next moves and choosing the one with the highest score. On an infinite board my potential next moves are the ones 'close' (within radius distance) to already marked positions.

Instance Variables
	radius:					<Object>
	myOpenLines:			<Object>
	rivalOpenLines:			<Object>
	nextMoveCandidates:	<Object>	
"
Class {
	#name : #BotPlayer,
	#superclass : #XOPlayer,
	#instVars : [
		'radius',
		'nextMoveCandidates',
		'myOpenLines',
		'rivalOpenLines',
		'valueTable'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #private }
BotPlayer >> indexFor: key and: value [ 
	"conversion formula from a (key,value) pair to a linear index"

	^XOGame lengthOfLine + 1 * 2 - key * (key -1) / 2 + value. 

]

{ #category : #public }
BotPlayer >> initialize [

	| n |
	super initialize.
	radius := 1.
	nextMoveCandidates := Set new: 200.
	myOpenLines := Set new: 100.
	rivalOpenLines := Set new: 100.
	myWeights := {0->0. 1->0. 2->3. 3->0. 3.1->5. 3.2->8. 4->21. 5->1000} as: Dictionary.
	rivalWeights := {0->0. 1->0. 2->5. 3->0. 3.1->8. 3.2->21. 4->1000} as: Dictionary.

	n := XOGame lengthOfLine.
	valueTable := Array new: 3*n.
	1 to: 3*n-3 do: [:i | valueTable at: i put: (i-1) fibonacci].
	3*n-2 to: 3*n do: [:i | valueTable at: i put: (3*n-1) fibonacci].
	
	"example for n=5:
	valueTable = #(0 1 1 2 3 5 8 13 21 34 55 89 377 377 377)"
]

{ #category : #private }
BotPlayer >> myBestMove [
	"evaluate all possible next moves and pick the best countermove;
	implementation note: scores can also be implemented as IdentityDictionary, Bag or Heap... 
	-> compare performance, readability etc.
	Dictionary may not be the best choice - OC of associations may be better..."

	| countermove scores |
	scores := Mapping new.
	nextMoveCandidates do: [:each | scores add: each -> (self myScoreFor: each)].
	countermove := scores keyAtValue: scores values max.
	analytics add: countermove -> scores.
	^countermove
]

{ #category : #private }
BotPlayer >> myOpenLines [
	^myOpenLines
]

{ #category : #private }
BotPlayer >> myScoreFor: myMove [
	"evaluate myMove by simulating and evaluating the board situation after myMove; 
	more precisely: evaluate all open lines based on how many marked positions (of one kind) they already contain and how many lines share the same set of marked positions; the more marked positions a line contains, the more valuabel it is; also, the more open lines share the same set of marked positions, the more valuable the open lines are."

	| claimed conflictingLines myOpenBaselines myOpenLines rivalOpenLines myScore rivalScore |

	claimed := self claimed copy add: myMove; yourself.
	conflictingLines := [:each | each includesAnyOf: lost].
	myOpenBaselines := myMove basedLines reject: conflictingLines. 
	myOpenLines := self myOpenLines copy addAll: myOpenBaselines; yourself.
	rivalOpenLines := self rivalOpenLines copy removeAllFoundIn: myMove basedLines; yourself.

	myScore := self valueOf: myOpenLines relativeTo: claimed usingOffset: 2.
	rivalScore := self valueOf: rivalOpenLines relativeTo: lost usingOffset: 0.
	
	^myScore - rivalScore
]

{ #category : #public }
BotPlayer >> play: move [
	"update board status after oponent's move, select the best countermove and update board status accordingly;
	note: consider expanding next move candidates by adding 'addAll: move basedCandidates' and 'addAll: countermove basedCandidates' or extending the radius parameter - but preliminary tests showed no impact on move selection"

	| countermove |

	lost add: move.
	radius := radius min: lost size.
	nextMoveCandidates addAll: (move neighborhood: radius); removeAllFoundIn: claimed, lost.
	myOpenLines removeAllFoundIn: (move basedLines).
	rivalOpenLines addAll: (move basedLines reject: [:each | each includesAnyOf: claimed]).
	
	countermove := self myBestMove.
	
	claimed add: countermove.
	nextMoveCandidates addAll: (countermove neighborhood: radius); removeAllFoundIn: claimed, lost.
	myOpenLines addAll: (countermove basedLines reject: [:each | each includesAnyOf: lost]).
	rivalOpenLines removeAllFoundIn: (countermove basedLines).

	^countermove
]

{ #category : #private }
BotPlayer >> rivalOpenLines [
	^rivalOpenLines
]

{ #category : #public }
BotPlayer >> start [
	"X starts by marking 0@0 position and updating board information"
	
	| move |
	move := XOGame initialMove.					"create a new Position object representing 0@0 field"
	claimed add: move.								"mark 0@0 by X (or 'claim' the 0@0 position)"
	nextMoveCandidates := move neighborhood: radius.	"select next move candidates"
	myOpenLines := move basedLines.						"all open lines containing 0@0"
	analytics add: move -> ({move -> 0} as: Mapping).	"first move log entry"
	^move

]

{ #category : #private }
BotPlayer >> valueOf: openLines relativeTo: claimed usingOffset: offset [

	| patterns |
	patterns := (openLines collect: [:each | each intersection: claimed] as: Bag) 
		valuesAndCounts associations select: [:each | each key size > 1].

	^patterns inject: 0 into: [:subTotal :next | 
		subTotal + valueTable at: (self indexFor: next key size and: next value) - offset].

]
