"
I represent a game between two players; i.e. I initialize the players, control the game and print results. I implement alternative control mechanisms: (A) a main loop calling players to make their moves (B) represent players as separate processes and let them control themselves using a semaphore (representing a game clock) (C) use dependency and make players dependents of each other.

Usage:
	XOGame new game: BotPlayer versus: BotPlayer 		""start a game between the computer and itself""
	XOGame new game: BotPlayer versus: HumanPlayer 	""start a game between the computer and yourself""
	XOGame new game2: BotPlayer versus: BotPlayer 		""start a game using semaphore controlled players""
	XOGame new game3: BotPlayer versus: BotPlayer 		""start a game using dependency controlled players""

	XOGame new limitMoves: 50; limitPrintedMoves: 3; game: BotPlayer versus: HumanPlayer  	""start a game limited to 50 moves; limit analytical data output to 3 best rated moves""

Instance Variables
	playerA:			<XOPlayer>
	playerB:			<XOPlayer>
	gameClock:			<Semaphore>	""a semaphore controlling players taking turns""
	move:				<Position>		""a variable for players to exchange moves"" 
	result:				<String>		""a message to be printed as a result""
	limitMoves:			<Integer>		""limit the number of moves in a game; the default is 50 moves""
	limitPrintedMoves:	<Integer>		""limit the printout of move's analytical data; the default is nil, it prints just the moves without any analytical data; 0 prints all available data""
				
Class methods:
	initialMove 			defines a move to coordinates 0,0 as the initial move
	lengthOfLine 		defines the lenghts of the winning line; the default is 5 but can be changed to any positive integer 

"
Class {
	#name : #XOGame,
	#superclass : #Object,
	#instVars : [
		'playerA',
		'playerB',
		'gameClock',
		'move',
		'result',
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
XOGame >> game2: playerClassA versus: playerClassB [
	"initialize the players, start the game game and print the result;
	note: Transcript is supposed to print the moves continuously but unlike Squeak, 
	Pharo prints them all at once at the end due to different Transcript implementation;
	note: for Human player printing results doesn't work yet as the pop-up to get Human response
	opens a new UI process that takes over the old one and finishes before players do;
	possible fix: place gameOver semaphore with negative charge after startGame"

	| time |
	playerClassA new symbol: 'X'; getReadyFor: self. 
	playerClassB new symbol: 'O'; getReadyFor: self.
	time := [ self runGame2 ] timeToRun.
	Transcript cr; show: result; cr; show: 'timeToRun: ', time printString, ' ms'; cr; flush

]

{ #category : #controlling }
XOGame >> game3: playerClassA versus: playerClassB [
	"initialize the players, run the game game and print the result;
	note: Transcript is supposed to print the moves as they are determined by the code
	but Pharo prints them all at once at the end due to different Transcript implementation"

	| time |
	playerA := playerClassA new symbol: 'X'. 
	playerB := playerClassB new symbol: 'O'.
	time := [ self runGame3 ] timeToRun.
	Transcript cr; show: result; cr; show: 'timeToRun: ', time printString, ' ms'; cr; flush

]

{ #category : #controlling }
XOGame >> game: playerClassA versus: playerClassB [
	"initialize the players, run the game game and print the result;
	note: Transcript is supposed to print the moves as they are determined by the code
	but Pharo prints them all at once at the end due to different Transcript implementation"

	| time |
	playerA := playerClassA new symbol: 'X'. 
	playerB := playerClassB new symbol: 'O'.
	time := [ self runGame ] timeToRun.
	Transcript cr; show: result; cr; show: 'timeToRun: ', time printString, ' ms'; cr; flush

]

{ #category : #accessing }
XOGame >> gameClock [
	^gameClock
]

{ #category : #initializing }
XOGame >> initialize [

	limitMoves := 50.
	
	self currentWorld submorphs 
		detect: [ :m | m model = Transcript ]
		ifNone: [ Transcript openLabel: 'NEW GAME' ].
	"Squeak, unlike Pharo, could use Transcript openIfNone; for portability let's use detect: ifNone: "

	self resetGame.

]

{ #category : #accessing }
XOGame >> limitMoves: anObject [
	limitMoves := anObject
]

{ #category : #accessing }
XOGame >> limitPrintedMoves: anObject [
	limitPrintedMoves := anObject
]

{ #category : #accessing }
XOGame >> move [
	^move
]

{ #category : #accessing }
XOGame >> move: aPosition [
	^move := aPosition
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

{ #category : #initializing }
XOGame >> resetGame [
	gameClock := Semaphore new
]

{ #category : #accessing }
XOGame >> result [
	^result
]

{ #category : #accessing }
XOGame >> result: aString [
	^result := aString
]

{ #category : #controlling }
XOGame >> runGame [
	"start and loop a game between playerA and playerB; playerA starts;
	answer the result of the game; detailed analytics log is under each player;
	note: try:
	- duet strategy between both players
	- players as circular LinkedList 
	- players exchange moves via sharedQ/streams?"

	(1 to: limitMoves) do: [ :index |
		playerA nextTurnIn: self.
		playerB nextTurnIn: self.
	] displayingProgress: 'Processing...'.    "this makes Pharo print continuously"
	result ifNil: [ result := 'it''s a draw, Losers!' ]
]

{ #category : #controlling }
XOGame >> runGame2 [
	gameClock signal
]

{ #category : #controlling }
XOGame >> runGame3 [
	"start a game between playerA and playerB; playerA starts;
	players exchange moves via my instance variable 'move';
	the winner stores the result of the game in my instance variable 'result';
	note: in case of multiplayer the order of players is defined easily"
	
	self addDependent: playerA.
	playerA addDependent: playerB.
	playerB addDependent: playerA.
	self changed. "meaning: start the game"
	"clean up; it's not critical, GC would take care of it"
	self removeDependent: playerA.
	playerA removeDependent: playerB.
	playerB removeDependent: playerA.

]
