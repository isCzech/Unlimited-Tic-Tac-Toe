"
I represent a proper mapping; I subclass off Dictionary and redefine do: to iterate over associations rather than values.

"
Class {
	#name : #Mapping,
	#superclass : #Dictionary,
	#category : #UnlimitedTicTacToe
}

{ #category : #enumerating }
Mapping >> do: aBlock [ 
	"evaluate aBlock for each of the receiver's elements, i.e. associations"

	self associationsDo: aBlock
]

{ #category : #printing }
Mapping >> printElementsOn: aStream [ 

	( self associations sort: [ :x :y | x value > y value ] ) printElementsOn: aStream
]

{ #category : #removing }
Mapping >> remove: anObject [

	self removeKey: anObject key.
]
