"
I represent a human player; there's no error checking or anything, just the bare minimum to make it work.
"
Class {
	#name : #HumanPlayer,
	#superclass : #XOPlayer,
	#category : #UnlimitedTicTacToe
}

{ #category : #private }
HumanPlayer >> isWinner [ 

	self lastMove = '0@0' asPosition ifTrue: [^true].
	"this line to be deleted after dealing with manual entry error issues; 
	the illegal move 0@0 is just a quick escape sequence for HumanPlayer"
	
	^super isWinner 

]

{ #category : #private }
HumanPlayer >> myResponseTo: aPosition [
	"enter move as x@y and convert from a Point to a Position;
	UIManager opens a dialog window and returns a string (no input returns the empty string '');
	asPosition checks the string and returns a new Position object.
	For entering 0@-1 without a space implement a binary method @- under the Number class."

	| move |
	move := UIManager default request: 'Your opponent moves to: ', aPosition printString, String cr, String cr, 'Enter your move as x@y'.		
	move = '' ifTrue: [move := '0@0'].  "Cancel or enter empty to end the game"
	^move asPosition 
]

{ #category : #public }
HumanPlayer >> play: aMove [

	lost add: aMove.
	^claimed add: ( self myResponseTo: aMove ).
	

"	verbose version:
	| move |
	lost add: aMove.
	move := self myResponseTo: aMove.
	claimed add: move.
	^move
"
]

{ #category : #public }
HumanPlayer >> start [

	^super start
]
