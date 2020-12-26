"
I represent a proper mapping; I subclass off Dictionary and redefine do: to iterate over associations rather than values, and other methods to better represent a math mapping.

"
Class {
	#name : #Mapping,
	#superclass : #Dictionary,
	#category : #UnlimitedTicTacToe
}

{ #category : #adding }
Mapping >> addAll: aCollection [ 
	"Include all the elements of aCollection as the receiver's elements. Answer 
	aCollection. Actually, any object responding to #do: can be used as argument."

	aCollection do: [:each | self add: each].
	^ aCollection
]

{ #category : #enumerating }
Mapping >> do: aBlock [ 
	"evaluate aBlock for each of the receiver's elements, i.e. associations"

	self associationsDo: aBlock
]

{ #category : #private }
Mapping >> fillFrom: aCollection with: aBlock [
	"Evaluate aBlock with each of aCollections's elements as the argument.  
	Collect the resulting values into self. Answer self. For portability from Squeak 5.3 to Pharo 8.0"

	aCollection do: [ :each |
		self add: (aBlock value: each) ]
]

{ #category : #'math functions' }
Mapping >> maxValue [

	^self values max
]

{ #category : #printing }
Mapping >> printElementsOn: aStream [ 

	( self associations sort: [ :x :y | x value > y value ] ) printElementsOn: aStream
]

{ #category : #removing }
Mapping >> remove: anObject [

	self removeKey: anObject key.
]
