Extension { #name : #String }

{ #category : #'*unlimitedTicTacToe' }
String >> asPosition [
	"convert me to a Position object
	valid input is integer@integer
	no validity checking of input string (self) done
	note: Compiler evaluate: self is incompatible with Pharo which has a new compiler
	in Pharo replace by: self class compiler evaluate: self"

	| move |
	self = '' ifTrue: [^nil].					"empty input returns nil"
	(SystemVersion current version beginsWith: 'Squeak')
		ifTrue: [move := Compiler evaluate: self]
		ifFalse: [move := self class compiler evaluate: self].
	^XOPosition new row: move y col: move x
]
