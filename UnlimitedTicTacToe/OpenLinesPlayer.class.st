"
I try to implement BotPlayer's strategy without maintaining separate sets of open lines for each player; so far it appears separate sets considerably speed up the algorithm.

"
Class {
	#name : #OpenLinesPlayer,
	#superclass : #BotPlayer,
	#instVars : [
		'openLines'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #public }
OpenLinesPlayer >> initialize [

	super initialize.
	openLines := Set new: 100.
]

{ #category : #private }
OpenLinesPlayer >> myScoreFor: myMove [
	"note: alternatively use an object ('Evaluator') for implementing the evaluation function"
	
	| claimed openLines conflictingLines myScore rivalScore |

	claimed := self claimed copy add: myMove; yourself.
	conflictingLines := myMove basedLines select: [:each | each includesAnyOf: lost].
	openLines := self openLines copy addAll: myMove basedLines; removeAllFoundIn: conflictingLines; yourself.

	myScore := self valueOf: openLines relativeTo: claimed usingOffset: 2.
	rivalScore := self valueOf: openLines relativeTo: lost usingOffset: 0.
	
	^myScore - rivalScore
]

{ #category : #private }
OpenLinesPlayer >> openLines [
	^openLines
]

{ #category : #public }
OpenLinesPlayer >> play: move [
	"update board status after oponent's move, select the best countermove and update board status accordingly"

	| countermove conflictingLines |
	
	lost add: move. 
	nextMoveCandidates addAll: (move neighborhood: radius); removeAllFoundIn: claimed, lost.
	conflictingLines := move basedLines select: [:each | each includesAnyOf: claimed].
	openLines addAll: move basedLines; removeAllFoundIn: conflictingLines.

	countermove := self myBestMove.
	
	claimed add: countermove.
	nextMoveCandidates addAll: (countermove neighborhood: radius); removeAllFoundIn: claimed, lost.
	conflictingLines := countermove basedLines select: [:each | each includesAnyOf: lost].
	openLines addAll: countermove basedLines; removeAllFoundIn: conflictingLines.
	
	^countermove
]

{ #category : #public }
OpenLinesPlayer >> start [
	"X starts by marking 0@0 position and updating board information"
	
	| move |
	move := XOGame initialMove.					"create a new Position object representing 0@0 field"
	claimed add: move.								"mark 0@0 by X (or 'claim' the 0@0 position)"
	nextMoveCandidates := move neighborhood: radius.	"next move candidates within radius distance"
	openLines := move basedLines.						"all lines containing 0@0"
	analytics add: move -> ({move -> 0} as: Mapping).	"first move log entry"
	^move


]
