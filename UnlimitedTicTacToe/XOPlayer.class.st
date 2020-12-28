"
I am an abstract class for various types of players implemented as subclasses. Each player is assigned a symbol (X or O; X starts). Each player keeps track of fields he moved to (claimed) and his oponent's (lost).

Instance Variables
	symbol:			<Symbol>				#X, #O or other in case of future multiplayer variant
	claimed:		<Set>					set of positions marked with player's symbol
	lost:			<Set>					set of positions marked with player's oponent's symbol
	analytics:		<OrderedCollection>	a log of moves and their corresponding analytical data

"
Class {
	#name : #XOPlayer,
	#superclass : #Object,
	#instVars : [
		'symbol',
		'claimed',
		'lost',
		'analytics'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #accessing }
XOPlayer >> analyticsAt: index limitTo: limitPrintedMoves [
	"answer some analytics (alternative moves, scores, etc.) for the index-th move;
	limit answer to limitPrintedMoves number of alternative moves;
	note: too complicated... will be reworked"
	
	| bestMoves |
	limitPrintedMoves ifNil: [^nil].
	bestMoves := (analytics at: index ifAbsent: [^nil]) sorted: #key descending.
	limitPrintedMoves = 0 ifFalse: [ | bestScore topMoves topCount bestCount | 
		bestScore := bestMoves first key.
		topMoves := (bestMoves select: [:each | each key = bestScore]).
		topCount := topMoves size min: 5.   "limit # of moves with same value"
		bestCount := bestMoves size min: limitPrintedMoves.
		bestMoves := (bestMoves first: bestCount) asSet addAll: (topMoves first: topCount); yourself.
		bestMoves := bestMoves sorted: #key descending.
		topCount < topMoves size ifTrue: [  "some moves with same value not printed"
			bestMoves := bestMoves asOrderedCollection add: '...'; yourself] 
		].
	^bestMoves asArray.  "{} printout is most readable"

]

{ #category : #accessing }
XOPlayer >> claimed [
	^claimed
]

{ #category : #initializing }
XOPlayer >> initialize [ 

	super initialize.
	claimed := OrderedCollection new.
	lost := OrderedCollection new.
	analytics := OrderedCollection new
]

{ #category : #controlling }
XOPlayer >> isWinner [
	"check if the last move was a winning one"
	
	^self lastMove basedLines anySatisfy: [:line | (line intersection: claimed) size = XOGame lengthOfLine]
]

{ #category : #accessing }
XOPlayer >> lastMove [

	^claimed last
]

{ #category : #controlling }
XOPlayer >> play: move [
	self subclassResponsibility 
]

{ #category : #printing }
XOPlayer >> printOn: aStream [ 
	"append a sequence of characters that identify the receiver to aStream."
	
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: symbol.
	aStream nextPut: $)
]

{ #category : #controlling }
XOPlayer >> start [
	"log and answer the initial move"

	^claimed add: XOGame initialMove
]

{ #category : #accessing }
XOPlayer >> symbol [
	^ symbol
]

{ #category : #accessing }
XOPlayer >> symbol: anObject [
	symbol := anObject
]
