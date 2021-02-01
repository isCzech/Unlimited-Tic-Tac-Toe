"
I represent a human player; there's no error checking or anything, just the bare minimum to make it work.
"
Class {
	#name : #HumanPlayer,
	#superclass : #XOPlayer,
	#category : #UnlimitedTicTacToe
}

{ #category : #controlling }
HumanPlayer >> isWinner [ 
	"the first line to be deleted after dealing with user entry error issues etc; 
	'escape' is just a quick escape sequence for HumanPlayer"

	self lastMove = 'escape' ifTrue: [^true].
	
	^super isWinner 

]

{ #category : #testing }
HumanPlayer >> myResponseTo: aPosition [
	"let user enter move manually as x@y and convert input from a String to a Point to a Position;
	UIManager opens a dialog window and returns a string (empty input returns empty string);
	note: no validity checking of input string (self) done yet.
	note: for entering 0@-1 without a space implement a binary method @- under the Number class.
	note: Compiler evaluate: message is incompatible with Pharo using a new Opal compiler; 
	the equivalent message in Pharo is - self class compiler evaluate: string;
	note: UIManager default request: message opens a new UI process that takes over from the old one -
	- this means the main process that started the game finishes before the players -> needs fixing"

	| label string point |
	label := 'Your opponent moves to: ', aPosition printString, String cr, String cr, 'Enter your move as x@y'.
	string := UIManager default request: label.		
	string = '' | string isNil ifTrue: [^'escape'].  	"escape sequence to end the game"
	(SystemVersion current version beginsWith: 'Squeak')
		ifTrue: [point := Compiler evaluate: string]
		ifFalse: [point := self class compiler evaluate: string].
	^XOPosition new row: point y col: point x
]

{ #category : #controlling }
HumanPlayer >> play: aMove [

	^claimed add: ( self myResponseTo: ( lost add: aMove) )	

"	verbose version:
	| move |
	lost add: aMove.
	move := self myResponseTo: aMove.
	claimed add: move.
	^move
"
]

{ #category : #controlling }
HumanPlayer >> start [

	claimed add: XOGame initialMove.
	^XOGame initialMove
]
