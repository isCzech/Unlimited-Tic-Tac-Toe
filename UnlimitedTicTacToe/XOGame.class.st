"
I represent a game between two players - initialize the board and players, control the game and print results.

XOGame is an implementation of the 5-in-line variant of Tic-Tac-Toe played on an unlimited two-dimensional board by two players.

Usage:
	XOGame new game: BotPlayer versus: BotPlayer 		""starts a game between the computer and itself""
	XOGame new game: BotPlayer versus: HumanPlayer 	""starts a game between the computer and a human player""
	XOGame new limitMoves: 20; game: BotPlayer versus: BotPlayer 	""starts a game with 20 moves for each player""
	XOGame new limitMoves: 50; game: BotPlayer versus: HumanPlayer

Instance Variables
	limitMoves:			<Integer>		""maximum number of moves in a game; default is 3 for testing purposes""
	limitPrintedMoves:	<Integer>		""limits the printout of move's analytical data; default is 2 for testing purposes""
	playerA:			<XOPlayer>
	playerB:			<XOPlayer>

Class Variables
	InitialMove 			<XOPosition>	""0@0 - the position in the center of the board""
	LengthOfLine 		<Integer>		""default is 5""

"
Class {
	#name : #XOGame,
	#superclass : #Object,
	#instVars : [
		'limitMoves',
		'limitPrintedMoves',
		'playerA',
		'playerB'
	],
	#classVars : [
		'InitialMove',
		'LengthOfLine'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #accessing }
XOGame class >> initialMove [
	^ InitialMove
]

{ #category : #accessing }
XOGame class >> lengthOfLine [
	^ LengthOfLine
]

{ #category : #controlling }
XOGame >> game: playerClassA versus: playerClassB [
	"I initialize players and start a game"

	| result |
	Transcript openLabel: 'NEW GAME'.
	playerA := playerClassA new symbol: 'X'. 
	playerB := playerClassB new symbol: 'O'.
	result := self startGame: playerA versus: playerB.
	Transcript showln: result.


]

{ #category : #initializing }
XOGame >> initialize [

	InitialMove := '0@0' asPosition.
	LengthOfLine := 5.
	limitMoves := 3.
	limitPrintedMoves := 2.
]

{ #category : #accessing }
XOGame >> limitMoves: anObject [
	limitMoves := anObject
]

{ #category : #accessing }
XOGame >> limitPrintedMoves: anObject [
	limitPrintedMoves := anObject
]

{ #category : #printing }
XOGame >> printLastMove: player [

	self printLog: player move: (player analytics size) 

]

{ #category : #printing }
XOGame >> printLog: player move: index [
	"prints a move along with some analytical data
	print to Transcript or a file via a stream"

	| move score bestMoves |
	move := player moveAt: index.
	score := player scoreAt: index.
	Transcript showln: '', index, ' ', player symbol, ': ', (move -> score).
	index = 1 ifTrue: [^nil]. "first move printout is minimized"
	bestMoves := (player analytics at: index) value associations sort: [ :x :y | x value > y value ].
	limitPrintedMoves = 0 ifFalse: [ | topMoves bestCount topCount |
		topMoves := (bestMoves select: [:each| each value = score]).
		topCount := topMoves size clampHigh: 5.
		bestCount := bestMoves size clampHigh: limitPrintedMoves.
		bestMoves := (bestMoves first: bestCount) asSet addAll: (topMoves first: topCount); yourself.
		bestMoves := bestMoves sorted: [ :x :y | x value > y value ].
		].
	Transcript show: ' ', bestMoves.

]

{ #category : #printing }
XOGame >> printOn: aStream [ 
	"The receiver prints on aStream in terms of infix notation."
	
	super printOn: aStream.
	aStream nextPut: $(.
	playerA printOn: aStream.
	aStream nextPutAll: ' versus '.
	playerB printOn: aStream.
	aStream nextPut: $)
]

{ #category : #private }
XOGame >> startGame: playerA versus: playerB [
	"I start and loop a game of playerA versus playerB, playerA starts;
	answer the result of the game; detailed analytics log is under each player;
	implementation note: try:
	- duet strategy between both players
	- players as looped LinkedList 
	- control players using update: mechanism
	- control players using fork mechanism/semaphore
	- players exchange moves via streams"

	| moveA moveB |
	moveA := playerA start.
	self printLastMove: playerA.

	limitMoves timesRepeat: [
		moveB := playerB play: moveA.
		self printLastMove: playerB.
		playerB isWinner ifTrue: [^'playerB wins; Game Over, Loser!'].
	
		moveA := playerA play: moveB.
		self printLastMove: playerA.
		playerA isWinner ifTrue: [^'playerA wins; Game Over, Loser!'].
	].
	^'it''s a draw, Losers!'
]
