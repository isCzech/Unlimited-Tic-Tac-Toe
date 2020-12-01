Extension { #name : #Number }

{ #category : #'*unlimitedTicTacToe' }
Number >> @- y [ 

	"for entering 0@-1 in addition to of 0@ -1"

	^self @ y negated
]
