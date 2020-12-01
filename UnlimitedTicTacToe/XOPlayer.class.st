"
I am an abstract class for various types of players implemented as subclasses. Each player is assigned a symbol (X or O; X starts). Each player keeps track of fields he moved to (claimed) and his oponent's (lost).

Instance Variables
	symbol:			<Symbol>				#X, #O or other in case of multiplayer variant
	claimed:		<Set>					set of positions marked with player's symbol
	lost:			<Set>					set of positions marked with player's oponent's symbol
	analytics:		<OrderedCollection>	a log of moves and their corresponding analytical data

"
Class {
	#name : #XOPlayer,
	#superclass : #Object,
	#instVars : [
		'symbol',
		'claimed',
		'lost',
		'analytics'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #accessing }
XOPlayer >> analytics [ 
	"note: answer a copy so that only a player method can modify the log via direct access to the instance variable"

	^analytics copy 
]

{ #category : #accessing }
XOPlayer >> claimed [
	^claimed
]

{ #category : #initializing }
XOPlayer >> initialize [ 

	claimed := Set new.
	lost := Set new.
	analytics := OrderedCollection new.

]

{ #category : #accessing }
XOPlayer >> lastMove [
	^analytics last key
]

{ #category : #accessing }
XOPlayer >> lastScore [
	^analytics last value values max
]

{ #category : #accessing }
XOPlayer >> moveAt: index [
	"answer the index-th move from the log"

	^(analytics at: index) key
]

{ #category : #controlling }
XOPlayer >> play: move [

	self subclassResponsibility 
]

{ #category : #printing }
XOPlayer >> printOn: aStream [ 
	"The receiver prints on aStream in terms of infix notation."
	
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: symbol.
	aStream nextPut: $)
]

{ #category : #accessing }
XOPlayer >> scoreAt: index [
	"answer index-th move's score"

	^(analytics at: index) value values max
]

{ #category : #controlling }
XOPlayer >> start [

	self subclassResponsibility 
]

{ #category : #accessing }
XOPlayer >> symbol [
	^ symbol
]

{ #category : #accessing }
XOPlayer >> symbol: anObject [
	symbol := anObject
]
