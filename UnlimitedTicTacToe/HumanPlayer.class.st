Class {
	#name : #HumanPlayer,
	#superclass : #XOPlayer,
	#category : #UnlimitedTicTacToe
}

{ #category : #public }
HumanPlayer >> initialize [ 

	super initialize 
]

{ #category : #private }
HumanPlayer >> isWinner [ 

	self lastMove = '0@0' asPosition ifTrue: [self needsWork. ^true].
	"this line to be deleted after dealing with manual entry issues; 
	the illegal move 0@0 is just a quick escape sequence for HumanPlayer"
	
	^(self lastMove basedLines select: [:line | line copy removeAllFoundIn: self claimed; isEmpty]) notEmpty

]

{ #category : #private }
HumanPlayer >> myResponseTo: aPosition [
	"enter move as x@y and convert from a Point to a Position;
	UIManager opens a dialog window and returns a string (no input returns the empty string '');
	asPosition checks the string and returns a new Position object.
	For entering 0@-1 without a space implement a binary method @- under the Number class."

	| move |
	move := UIManager default request: 'Player ', self symbol, ' moves to: ', aPosition, String cr, String cr, 'Enter your move as x@y'.		
	move = '' ifTrue: [move := '0@0'].  "Cancel or enter empty to end the game"
	^move asPosition 
]

{ #category : #public }
HumanPlayer >> play: aPosition [

	| move |
	lost add: aPosition.
	move := self myResponseTo: aPosition.
	analytics add: move -> ({move -> 0} asDictionary).
	claimed add: move.
	^move
]

{ #category : #public }
HumanPlayer >> start [

	| move |
	move := XOGame initialMove.
	claimed add: move.
	analytics add: move -> ({move -> 0} asDictionary).
	^move
]
