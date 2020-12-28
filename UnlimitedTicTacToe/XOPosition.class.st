"
I represent a field ('a position') on a game board. The fields are referenced by their coordinates; the board is infinite and the starting position for a game is the 'zero' field (i.e. the field with coordinates 0,0 in case of a two dimensional board).

Instance Variables
	col:			<Integer>		'x' coordinate
	row:		<Integer>		'y' coordinate
	basedLines <Set>			variable to reuse the result of a computation

Implementation note: XOPosition subclassed off Magnitude for possible reuse of methods like between, clamp etc.
Consider using Traits to reuse Point methods (create Trait from Point Class).
"
Class {
	#name : #XOPosition,
	#superclass : #Magnitude,
	#instVars : [
		'col',
		'row',
		'basedLines'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #comparing }
XOPosition >> < anObject [
	"I define sorting order for Positions: 'left to right and bottom up';
	i.e. 'x@y' < 'u@v' when x<u or x=u and y<v
	e.g. '0@-1' < '1@-2' < '1@0'"

	self == anObject
		ifTrue: [ ^ false ].
	self class = anObject class
		ifFalse: [ ^ false ].
	self col = anObject col ifTrue: [^self row < anObject row].
	^ self col < anObject col
]

{ #category : #comparing }
XOPosition >> = anObject [
	"Answer whether the receiver and anObject represent the same object;
	two positions are equal when their coordinates are equal."

	self == anObject
		ifTrue: [ ^ true ].
	self class = anObject class
		ifFalse: [ ^ false ].
	^ self col = anObject col and: [ self row = anObject row ]

]

{ #category : #enumerating }
XOPosition >> basedCandidates [
	"answer all positions in self basedLines as potential candidates for the next move"
	
	^self basedLines inject: Set new into: [:res :line | res addAll: line; yourself]
]

{ #category : #enumerating }
XOPosition >> basedLines [
	"answer all lines I'm an element of, lazy initialize"
		
	^basedLines ifNil: [self basedLines: XOGame lengthOfLine] 

]

{ #category : #enumerating }
XOPosition >> basedLines: length [
	"answer the set of all lines self is an element ofů
	note: in order to reuse set operations, equality and hash have to be overriden for the XOPosition class;
	note: to extend to higher dimensions use unit vectors in hypercube in the inner loop"
	
	| lines stop |
	lines := Set new: length * 4.
	stop := length - 1.
	0 to: stop do: [:s | 
		|vertical horizontal forward backward|	
		vertical := XOLine new: length.
		horizontal := XOLine new: length.
		forward := XOLine new: length.
		backward := XOLine new: length.
		0 to: stop do: [:x |
			vertical add: (self class new row: (row-s+x) col: (col)).
			horizontal add: (self class new row: (row) col: (col-s+x)).
			forward add: (self class new row: (row-s+x) col: (col-s+x)).
			backward add: (self class new row: (row-s+x) col: (col+s-x)).
			].
		lines add: vertical; add: horizontal; add: forward; add: backward
		].
	^lines	

]

{ #category : #accessing }
XOPosition >> col [
	^col
]

{ #category : #accessing }
XOPosition >> col: columnIndex row: rowIndex [

	row := rowIndex.
	col := columnIndex.
]

{ #category : #testing }
XOPosition >> elementOf: aCollection [

	^aCollection includes: self
]

{ #category : #comparing }
XOPosition >> hash [
	"Answer an integer value that is related to the identity of the receiver; bitXor recommended by the Squeak refactoring tool."
	
	^ self col hash bitXor: self row hash 
	

	"
	my suggestion: 
	^(self col hash) * 1151 + (self row hash)
	both work ok; more extensive hashing performance testing needed
	"
]

{ #category : #enumerating }
XOPosition >> neighborhood: radius [
	"answer all positions in your (self) neighborhood within radius distance;
	possibly expand by self basedCandidates"
	
	^self neighbors: radius
]

{ #category : #enumerating }
XOPosition >> neighbors [
	"answer immediate neighbors of self"
	
	^self neighbors: 1
]

{ #category : #enumerating }
XOPosition >> neighbors: radius [
	"answer all your neighbors positions within radius distance"
	
	| neighbors |
	neighbors := Set new.
	radius negated to: radius do: [:r |
		radius negated to: radius do:[:c |
			neighbors add: (self class new row: (self row+r) col: (self col+c))
			]
		].
	neighbors remove: self.
	^neighbors
]

{ #category : #printing }
XOPosition >> printOn: aStream [ 
	"append a sequence of characters that identify the receiver to aStream."

	col printOn: aStream.
	aStream nextPut: $/.
	row printOn: aStream
]

{ #category : #accessing }
XOPosition >> row [
	^row
]

{ #category : #accessing }
XOPosition >> row: rowIndex col: columnIndex [

	row := rowIndex.
	col := columnIndex
]

{ #category : #enumerating }
XOPosition >> superlines [
	"all super-lines (Game defines line length n) I'm an element of
	i.e. all (unordered) (n+1)-tuples containing self
	superlines are used to find internal and external ends of gamelines"
	
	^self basedLines: XOGame lengthOfLine + 1
]
