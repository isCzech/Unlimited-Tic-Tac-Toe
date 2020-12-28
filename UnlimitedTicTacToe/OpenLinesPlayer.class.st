"
I try to implement BotPlayer's strategy without maintaining separate sets of open lines for each player; however so far it appears this simplyfication considerably slows down the algorithm.

"
Class {
	#name : #OpenLinesPlayer,
	#superclass : #BotPlayer,
	#instVars : [
		'openLines'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #initializing }
OpenLinesPlayer >> initialize [

	super initialize.
	openLines := Set new.
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

{ #category : #accessing }
OpenLinesPlayer >> openLines [
	^openLines
]

{ #category : #controlling }
OpenLinesPlayer >> play: move [
	"update board status after oponent's move, select the best countermove and update board status accordingly"

	| countermove conflictingLines |
	
	lost add: move. 
	nextMoveCandidates addAll: (move neighborhood: radius); removeAllFoundIn: claimed, lost.
	conflictingLines := move basedLines select: [:each | each includesAnyOf: claimed].
	openLines addAll: move basedLines; removeAllFoundIn: conflictingLines.

	countermove := nextMoveCandidates detectMax: [:each | self myScoreFor: each].
	
	claimed add: countermove.
	nextMoveCandidates addAll: (countermove neighborhood: radius); removeAllFoundIn: claimed, lost.
	conflictingLines := countermove basedLines select: [:each | each includesAnyOf: lost].
	openLines addAll: countermove basedLines; removeAllFoundIn: conflictingLines.
	
	^countermove
]

{ #category : #controlling }
OpenLinesPlayer >> start [
	"initialize board information, answer the initial move"

	openLines := XOGame initialMove basedLines.
	^super start


]
