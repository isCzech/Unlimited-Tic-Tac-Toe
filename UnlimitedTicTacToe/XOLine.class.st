"
I represent a line of fields ('positions') on a game board. More about fields in the XOPosition description.



"
Class {
	#name : #XOLine,
	#superclass : #Set,
	#category : #UnlimitedTicTacToe
}

{ #category : #enumerating }
XOLine >> outerBoundary [
	"answer outer boundary positions; i.e. positions immediately following the inner ends of self"
	
	^self anyOne superlines 
		select: [ :each | each includesAllOf: self ] 
		thenCollect: [ :each | each removeAll: self; anyOne ]
		
	"note:
	collect: returns nil for all excluded elements so we need to use select:thenCollect:
	otherwise outerBoundary would return three elements instead of two: nil, outer1 and outer2. 
	
	Perhaps more readable version; the bytecode however is twice longer and considerably less efficient:
	
	| insideElement outsideElement outerEnds |
	outerEnds := Set new.
	insideElement := self anyOne.
	insideElement superlines do: [ :superline |
		(superline includesAllOf: self) ifTrue: [
			outsideElement := superline removeAll: self; anyOne.
			outerEnds add: outsideElement]
		].
	^outerEnds
	"
]

{ #category : #printing }
XOLine >> printOn: aStream [ 
	"append a sequence of characters that identify the receiver to aStream."

	self printNameOn: aStream.
	self sorted printElementsOn: aStream.
	aStream nextPut: Character cr
]
