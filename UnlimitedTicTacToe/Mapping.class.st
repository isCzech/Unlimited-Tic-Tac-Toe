Class {
	#name : #Mapping,
	#superclass : #Dictionary,
	#category : #UnlimitedTicTacToe
}

{ #category : #'as yet unclassified' }
Mapping >> do: aBlock [ 
	"Evaluate aBlock for each of the receiver's elements (associations)."

	self associationsDo: aBlock
]

{ #category : #'as yet unclassified' }
Mapping >> remove: anObject [

	self removeKey: anObject key.
]
