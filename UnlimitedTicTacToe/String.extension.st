Extension { #name : #String }

{ #category : #'*unlimitedTicTacToe' }
String >> asPosition [
	"convert me to a Position object
	valid input is integer@integer
	no validity checking of input string (self) done"

	| move |
	self = '' ifTrue: [^nil].					"empty input returns nil"
	move := Compiler evaluate: self.		"returns a Point object x@y"
	^XOPosition new row: move y col: move x
]
