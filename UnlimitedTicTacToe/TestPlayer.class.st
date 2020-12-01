Class {
	#name : #TestPlayer,
	#superclass : #BotPlayer,
	#category : #UnlimitedTicTacToe
}

{ #category : #private }
TestPlayer >> myScoreFor: myMove [
	"evaluation function (so far for lines of 5 only); evaluates all open lines based on how many symbols they already contain and whether they are 'weak' or 'strong' (strong open lines are 'closer' to victory thus more valuable). Exact definitions are:
	(i) a line is my open line iff all it's positions are free or claimed provided at least one position is claimed
	(ii) a line is a rival open line iff all it's positions are free or lost, provided at least one position is lost 
	(iii) an open line is strong iff it is not weak
	(iv) an open line containing 3 (same) symbols is weak iff (1) outer boundaries are lost or (2) just one outer boundary is lost but it's inner neighbor is claimed or (3) both outer boundaries are free but both inner boundaries are claimed
	(v) an open line containing 2 (same) symbols is weak iff the two claimed positions don't have a common neighbor; i.e. there are at least two free positions between them
	evaluation: all open lines grouped by the number of symbols they already contain and further by the weak/strong condition; resulting score is a sum of all subset sizes multiplied by weights defined below
	remains to implement: blocks for weak/strong condition for each size (2 and 4, plus maybe a rule for greater sizes)"

	| claimed myWeakOpenLines3 rivalWeakOpenLines3 myGroupedOL rivalGroupedOL myWeights rivalWeights myNewOpenLines rivalNewOpenLines score myOpenBaselines conflictingLines |

	claimed := self claimed copy add: myMove; yourself.
	conflictingLines := [:each | each includesAnyOf: lost].
	myOpenBaselines := myMove basedLines reject: conflictingLines. 
	myNewOpenLines := myOpenLines copy addAll: myOpenBaselines; yourself.
	rivalNewOpenLines := rivalOpenLines copy removeAllFoundIn: myMove basedLines; yourself.

	"^scoreOf myNewOpenLines - scoreOf rivalNewOpenLines   params: claimed lost
	stop distinguishing my and rival - use just openLines"

	myWeights := {1->0. 2->3. 3->0. 3.1->5. 3.2->8. 4->21. 5->10000} as: Dictionary.
	rivalWeights := {1->0. 2->5. 3->0. 3.1->8. 3.2->21. 4->10000} as: Dictionary.

	myWeakOpenLines3 := [:line | | outerBoundary | outerBoundary := line outerBoundary. "has always two elements"
		"define inner boundaries, lazy initialize"
		(outerBoundary allSatisfy: [:each | lost includes: each])  	"both outer boundaries lost"
		or: [
		(outerBoundary anySatisfy: [:each | 
				(lost includes: each) and: 
				(line anySatisfy: [:elem | (each neighbors includes: elem) and: (claimed includes: elem)])
				])
		ifTrue: [3.1] ifFalse: [3.2] 
		]
		"or: [ (both outer boundaries free and both inner boundaries claimed) ]"
	].
	rivalWeakOpenLines3 := [:line | | outerBoundary | outerBoundary := line outerBoundary.
		(outerBoundary allSatisfy: [:each | claimed includes: each])
		or: [
		(outerBoundary anySatisfy: [:each | 
				(claimed includes: each) and: 
				(line anySatisfy: [:elem | (each neighbors includes: elem) and: (lost includes: elem)])
				])
		ifTrue: [3.1] ifFalse: [3.2] 
		]
		"or: [ (both outer boundaries free and both inner boundaries lost) ]" 
	].


	myGroupedOL := myNewOpenLines groupBy: [:each | (each intersection: claimed) size].
	rivalGroupedOL := rivalNewOpenLines groupBy: [:each | (each intersection: lost) size].

	myGroupedOL copy keysAndValuesDo: [:key :value | key = 3 ifTrue: [
		myGroupedOL addAll: (value groupBy: myWeakOpenLines3)]].
	rivalGroupedOL copy keysAndValuesDo: [:key :value | key = 3 ifTrue: [
		rivalGroupedOL addAll: (value groupBy: rivalWeakOpenLines3)]].
	self needsWork. "note: improve by adding weak and strong OL4s and OL2s and a rule for higher orders"

	score := 0.
	myGroupedOL keysAndValuesDo: [:key :value | score := score + (value size * myWeights at: key)].
	rivalGroupedOL keysAndValuesDo: [:key :value | score := score - (value size * rivalWeights at: key)].
	
	^score

	
"
pripadne predefinovat groupBy: pod Set jako OC of Sets, aby bylo konzistentni s mym pouzitim Set... anebo je to fuk....

	myOLGrouped := OrderedCollection new.
	1 to: 4 do: [:i | myOLGrouped at: i ifAbsentPut: [Set new]].
	myOL do: [:each | 
		| key | 
		key :=  (each intersection: claimed) size.
		(myOLGrouped at: key ifAbsentPut: [Set new]) add: each].
"

	
]
