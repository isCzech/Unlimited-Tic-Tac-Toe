"
I represent a game between two players; i.e. I initialize the players, control the game and print results.

Usage:
	XOGame new game: BotPlayer versus: BotPlayer 		""start a game between the computer and itself""
	XOGame new game: BotPlayer versus: HumanPlayer 	""start a game between the computer and yourself""

	XOGame new limitMoves: 50; limitPrintedMoves: 3; game: BotPlayer versus: HumanPlayer  	""start a game limited to 50 moves; limit analytical data output to 3 best rated moves""

Instance Variables
	playerA:			<XOPlayer>
	playerB:			<XOPlayer>
	limitMoves:			<Integer>		""limit the number of moves in a game; the default is 50 moves""
	limitPrintedMoves:	<Integer>		""limit the printout of move's analytical data; the default is nil, it prints just the moves without any analytical data; 0 prints all available data""
				
Class methods:
	initialMove 			defines move to coordinates 0,0 as the initial move
	lengthOfLine 		defines the lenghts of the winning line; the default is 5 but can be changed to any positive integer 

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
	"initialize the players, run the game game and print the result;
	note: Transcript is supposed to print the moves as they are determined by the code
	but Pharo prints them all at once at the end due to different Transcript implementation"

	| result time |
	World submorphs 
		detect: [ :m | m model = Transcript ]
		ifNone: [ Transcript openLabel: 'NEW GAME' ].
	"Squeak, unlike Pharo, can use Transcript openIfNone - that's why the detect: ifNone: "
	playerA := playerClassA new symbol: 'X'. 
	playerB := playerClassB new symbol: 'O'.
	time := [result := self playGame] timeToRun.
	Transcript cr; show: result; cr; show: 'timeToRun: ', time printString, ' ms'; cr; flush

]

{ #category : #initializing }
XOGame >> initialize [

	limitMoves := 50
]

{ #category : #accessing }
XOGame >> limitMoves: anObject [
	limitMoves := anObject
]

{ #category : #accessing }
XOGame >> limitPrintedMoves: anObject [
	limitPrintedMoves := anObject
]

{ #category : #private }
XOGame >> playGame [
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

	(1 to: limitMoves) do: [ :index |
		moveB := playerB play: moveA.
		self printLastMove: playerB.
		playerB isWinner ifTrue: [^'playerB wins; Game Over, Loser!'].
	
		moveA := playerA play: moveB.
		self printLastMove: playerA.
		playerA isWinner ifTrue: [^'playerA wins; Game Over, Loser!'].
	] displayingProgress: 'Processing...'.
	^'it''s a draw, Losers!'
	

 "This alternative works fine in Squeak but in Pharo it doesn't show progress in Transcript, it prints everything at once at the end.
	limitMoves timesRepeat: [
		moveB := playerB play: moveA.
		self printLastMove: playerB.
		playerB isWinner ifTrue: [^'playerB wins; Game Over, Loser!'].
	
		moveA := playerA play: moveB.
		self printLastMove: playerA.
		playerA isWinner ifTrue: [^'playerA wins; Game Over, Loser!'].
	].
	^'it''s a draw, Losers!'
"
]

{ #category : #printing }
XOGame >> printLastMove: player [
	"print a move along with some analytics to Transcript (or a stream - future ext.)"

	| index |
	index := player claimed size.
	Transcript cr; show: index printString, ' ', player symbol, ': ', player lastMove printString.
	(player analyticsAt: index limitTo: limitPrintedMoves) ifNotNil: [:analytics | 
		Transcript show: ' ', analytics printString]

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
