Extension { #name : #Integer }

{ #category : #'*unlimitedTicTacToe' }
Integer >> fibonacci [
	"F(0)=0, F(1)=1, F(n)=F(n-2)+F(n-1)"
	
	^ self < 2 
		ifTrue: [ self ] 
		ifFalse: [ (self - 2) fibonacci + (self - 1) fibonacci ]

]
