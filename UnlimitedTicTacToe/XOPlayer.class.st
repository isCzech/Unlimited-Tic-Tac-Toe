"
I am an abstract class for various types of players implemented as subclasses. Each player is assigned a symbol (X or O; X starts). Each player keeps track of fields he moved to (claimed) and his oponent's (lost). Players' turns can be controlled by a loop (using behavior in nextTurnIn:) or act as separate processes (behavior in getReadyFor:).

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
	note: too complicated... to be reworked"
	
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

{ #category : #controlling }
XOPlayer >> getReadyFor: aGame [
	"Define game's controlling mechanism for players being represented by separate processes: how the game starts, ends, how players exchange moves;
	use Processor activePriority + 1 for players to finish before the main XOGame process to allow it print results etc - this is not enough though - the UI Manager pop-up for HumanPlayer nixes this idea - needs to be fixed;
	Mutex not usable because we need to get players on the semaphore before starting the game.
	SharedQ not usable because it's behavior depends on the implementation - Squeak uses Semaphore but Pharo uses Monitor (which would prevent players from changing turns altogether); also, we'd need initial data to be thrown in the Q in order to start the game.
	note: possibly try to run critically - but first check comment at Pharo Semaphore >> critical:
	note: simplify the while loop"

	[
		[ aGame result ifNil: [ aGame gameClock wait ]. 
		aGame result isNil ] whileTrue: [
		aGame move
			ifNil: [aGame move: self start]
			ifNotNil: [:move | aGame move: (self play: move)].
		aGame printLastMove: self.
		self isWinner ifTrue: [aGame result: 'Player ', symbol, ' wins; Game Over, Loser!'].
		aGame gameClock signal.
		] 
	] forkAt: Processor activePriority + 1

]

{ #category : #initializing }
XOPlayer >> initialize [ 

	super initialize.
	claimed := OrderedCollection new.
	lost := OrderedCollection new.
	analytics := OrderedCollection new
]

{ #category : #testing }
XOPlayer >> isWinner [
	"check if the last move was a winning one"
	
	^self lastMove basedLines anySatisfy: [:line | (line intersection: claimed) size = XOGame lengthOfLine]
]

{ #category : #accessing }
XOPlayer >> lastMove [
	^claimed last
]

{ #category : #controlling }
XOPlayer >> nextTurnIn: aGame [
	"player makes one turn in a game"

	aGame result ifNotNil: [^self].    "game over"
	aGame move
		ifNil: [aGame move: self start]
		ifNotNil: [:move | aGame move: (self play: move)].
	aGame printLastMove: self.
	self isWinner ifTrue: [aGame result: 'Player ', symbol, ' wins; Game Over, Loser!']

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
	self subclassResponsibility 
]

{ #category : #accessing }
XOPlayer >> symbol [
	^ symbol
]

{ #category : #accessing }
XOPlayer >> symbol: anObject [
	symbol := anObject
]

{ #category : #controlling }
XOPlayer >> update: aGame [
	"player makes one turn in a game"

	aGame result ifNotNil: [^self].    "game over"
	aGame move
		ifNil: [aGame move: self start]
		ifNotNil: [:move | aGame move: (self play: move)].
	aGame printLastMove: self.
	self isWinner
		ifTrue: [aGame result: 'Player ', symbol, ' wins; Game Over, Loser!']
		ifFalse: [self changed: aGame]
]
