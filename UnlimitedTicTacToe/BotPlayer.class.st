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
		'myWeights',
		'rivalWeights'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #private }
BotPlayer >> evaluationFunctionDefinitions [
"BotPlayer evaluates all open lines based on how many symbols they already contain and whether they are 'weak' or 'strong' (strong open lines are 'closer' to victory thus more valuable). 
	
Exact definitions (for lines containing 5 positions):
	(i) a line is my open line iff all it's positions are free or claimed provided at least one position is claimed
	(ii) a line is a rival open line iff all it's positions are free or lost, provided at least one position is lost 
	(iii) an open line is strong iff it is not weak
	(iv) an open line containing 3 (same) symbols is weak iff (1) outer boundaries are lost or (2) just one outer boundary is lost but it's inner neighbor is claimed or (3) both outer boundaries are free but both inner boundaries are claimed
	(v) an open line containing 2 (same) symbols is weak iff the two claimed positions don't have a common neighbor; i.e. there are at least two free positions between them
	
These definitions will be superseded by more general definitions (and implementation) for lines of any lenght."
]

{ #category : #public }
BotPlayer >> initialize [

	super initialize.
	radius := 1.
	nextMoveCandidates := Set new: 200.
	myOpenLines := Set new: 100.
	rivalOpenLines := Set new: 100.
	myWeights := {0->0. 1->0. 2->3. 3->0. 3.1->5. 3.2->8. 4->21. 5->10000} as: Dictionary.
	rivalWeights := {0->0. 1->0. 2->5. 3->0. 3.1->8. 3.2->21. 4->10000} as: Dictionary.

]

{ #category : #private }
BotPlayer >> isWinner [

	^self lastScore > 1000
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
	"evaluate myMove by simulating and evaluating the board situation after myMove"

	| claimed conflictingLines myOpenBaselines myOpenLines rivalOpenLines myScore rivalScore |

	claimed := self claimed copy add: myMove; yourself.
	conflictingLines := [:each | each includesAnyOf: lost].
	myOpenBaselines := myMove basedLines reject: conflictingLines. 
	myOpenLines := self myOpenLines copy addAll: myOpenBaselines; yourself.
	rivalOpenLines := self rivalOpenLines copy removeAllFoundIn: myMove basedLines; yourself.

	myScore := self valueOf: myOpenLines relativeTo: claimed and: lost using: myWeights.
	rivalScore := self valueOf: rivalOpenLines relativeTo: lost and: claimed using: rivalWeights.
	
	^myScore - rivalScore

]

{ #category : #public }
BotPlayer >> play: move [
	"update board status after oponent's move, select the best countermove and update board status accordingly"

	| countermove |

	lost add: move. 
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
	nextMoveCandidates := move neighborhood: radius.	"next move candidates within radius distance"
	myOpenLines := move basedLines.						"all lines containing 0@0"
	analytics add: move -> ({move -> 0} asDictionary).	"first move log entry"
	^move

]

{ #category : #private }
BotPlayer >> valueOf: openLines relativeTo: claimed and: lost using: weight [
	"assign a score to a set of open lines: group all open lines by the number of symbols they already contain and further by the weak/strong condition; resulting score will be a sum of all subset sizes multiplied by a weight;
	note: weakLineDefinition is a weak/strong condition only for lines containing 3 marked positions; it will be replaced by a more general definition"

	| groupedLines weakLineDefinition score |
	
	weakLineDefinition := 	
		[:line | | outerBoundary | outerBoundary := line outerBoundary.
		(
			(outerBoundary allSatisfy: [:each | lost includes: each])
			or: [
			(outerBoundary anySatisfy: [:each | 
					(lost includes: each) and: 
					(line anySatisfy: [:elem | (each neighbors includes: elem) and: (claimed includes: elem)])
					]) 
			] 
			"or: [ (both outer boundaries free and both inner boundaries claimed) ]"
		) ifTrue: [3.1] ifFalse: [3.2] 
		].
	
	groupedLines := openLines groupBy: [:each | (each intersection: claimed) size].
	
	groupedLines copy keysAndValuesDo: [:key :value | 
		key = 3 ifTrue: [groupedLines addAll: (value groupBy: weakLineDefinition)]].

	score := 0.
	groupedLines keysAndValuesDo: [:key :value | score := score + (value size * weight at: key)].
	
	^score

]
