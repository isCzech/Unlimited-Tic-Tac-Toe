"
I represent a game between two players; i.e. I initialize the players, control the game and print results.

Usage:
	XOGame new game: BotPlayer versus: BotPlayer 		""start a game between the computer and itself""
	XOGame new game: BotPlayer versus: HumanPlayer 	""start a game between the computer and yourself""

	XOGame new limitMoves: 50; limitPrintedMoves: 3; game: BotPlayer versus: HumanPlayer  	""start a game with limited to 50 moves and limit analytical data to be printed to 3 best rated moves""

Instance Variables
	playerA:			<XOPlayer>
	playerB:			<XOPlayer>
	limitMoves:			<Integer>		""maximum number of moves in a game; the default is 50 moves""
	limitPrintedMoves:	<Integer>		""limits the printout of move's analytical data; the default 1 prints just the moves without analytical data; 0 prints all available data""
				
Class methods:
	initialMove 			defines 0@0 as the initial move
	lengthOfLine 		defines the lenghts of the winning line; 5 by default but can be changed to any positive integer 

"
Class {
	#name : #XOGame,
	#superclass : #Object,
	#instVars : [
		'playerA',
		'playerB',
		'limitMoves',
		'limitPrintedMoves'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #accessing }
XOGame class >> initialMove [
	"this represents infinite playing field's 'center' which is the initial field marked with X"
	
	^XOPosition new row: 0 col: 0
]

{ #category : #accessing }
XOGame class >> lengthOfLine [
	"this is the number of marks players seek to place in a row to win; typically 5-in-a-row but the algorithm works for any positive integer"
	
	^5
]

{ #category : #controlling }
XOGame >> game: playerClassA versus: playerClassB [
	"initialize players, start the game game and print the result"

	| result |
	Transcript openIfNoneLabel: 'NEW GAME'.
	playerA := playerClassA new symbol: 'X'. 
	playerB := playerClassB new symbol: 'O'.
	result := self startGame: playerA versus: playerB.
	Transcript showln: result

]

{ #category : #initializing }
XOGame >> initialize [

	limitMoves := 50.
	limitPrintedMoves := 1.
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
	"print a move along with some analytical data to Transcript (or a file via a stream - future ext.)"

	| move score bestMoves |
	move := player moveAt: index.
	score := player scoreAt: index.
	Transcript showln: '', index, ' ', player symbol, ': ', move.
	index = 1 ifTrue: [^nil]. "first move printout allways without analytics"
	limitPrintedMoves = 1 ifTrue: [^nil].  "all moves printout without analytics"
	bestMoves := (player analytics at: index) value associations sort: [ :x :y | x value > y value ].
	limitPrintedMoves = 0 ifFalse: [ | topMoves bestCount topCount |  "sort and limit analytics printout"
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
	"append a sequence of characters that identify the receiver to aStream."
	
	super printOn: aStream.
	aStream nextPut: $(.
	playerA printOn: aStream.
	aStream nextPutAll: ' versus '.
	playerB printOn: aStream.
	aStream nextPut: $)
]

{ #category : #private }
XOGame >> startGame: playerA versus: playerB [
	"start and loop a game between playerA and playerB; playerA starts;
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
