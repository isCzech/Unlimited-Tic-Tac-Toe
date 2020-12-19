Class {
	#name : #OldBotPlayer,
	#superclass : #BotPlayer,
	#instVars : [
		'myWeights',
		'rivalWeights'
	],
	#category : #UnlimitedTicTacToe
}

{ #category : #private }
OldBotPlayer >> evaluationFunctionDefinitions [
"OldBotPlayer evaluates all open lines based on how many symbols they already contain and whether they are 'weak' or 'strong' (strong open lines are 'closer' to victory thus more valuable). This approach has been superseded by a more general definition in BotPlayer.
	
Exact definitions (only for lines containing 5 positions):
	(i) a line is my open line iff all it's positions are free or claimed provided at least one position is claimed
	(ii) a line is a rival open line iff all it's positions are free or lost, provided at least one position is lost 
	(iii) an open line is strong iff it is not weak
	(iv) an open line containing 3 (same) symbols is weak iff (1) outer boundaries are lost or (2) just one outer boundary is lost but it's inner neighbor is claimed or (3) both outer boundaries are free but both inner boundaries are claimed
	(v) an open line containing 2 (same) symbols is weak iff the two claimed positions don't have a common neighbor; i.e. there are at least two free positions between them"
]

{ #category : #private }
OldBotPlayer >> initialize [

	super initialize.
	myWeights := {0->0. 1->0. 2->3. 3->0. 3.1->5. 3.2->8. 4->21. 5->1000} as: Dictionary.
	rivalWeights := {0->0. 1->0. 2->5. 3->0. 3.1->8. 3.2->21. 4->1000} as: Dictionary.

]

{ #category : #private }
OldBotPlayer >> myScoreFor: myMove [
	"evaluate myMove by simulating and evaluating the board situation after myMove"

	| claimed conflictingLines myOpenBaselines myOpenLines rivalOpenLines myScore rivalScore |

	claimed := self claimed copy add: myMove; yourself.
	conflictingLines := [:each | each includesAnyOf: lost].
	myOpenBaselines := myMove basedLines reject: conflictingLines. 
	myOpenLines := self myOpenLines copy addAll: myOpenBaselines; yourself.
	rivalOpenLines := self rivalOpenLines copy removeAllFoundIn: myMove basedLines; yourself.

	myScore := self valueOf: myOpenLines relativeTo: claimed and: lost using: myWeights.
	rivalScore := self valueOf: rivalOpenLines relativeTo: lost and: claimed using: rivalWeights.
	
	^myScore - rivalScore

]

{ #category : #private }
OldBotPlayer >> valueOf: openLines relativeTo: claimed and: lost using: weight [
	"assign a score to a set of open lines: group all open lines by the number of symbols they already contain and further by the weak/strong condition; resulting score will be a sum of all subset sizes multiplied by a weight;
	note: weakLineDefinition is a weak/strong condition only for lines containing 3 marked positions; it will be replaced by a more general definition"

	| groupedLines weakLineDefinition score |
	
	weakLineDefinition := 	
		[:line | | outerBoundary | outerBoundary := line outerBoundary.
		(
			(outerBoundary allSatisfy: [:each | lost includes: each])
			or: [
			(outerBoundary anySatisfy: [:each | 
					(lost includes: each) and: 
					(line anySatisfy: [:elem | (each neighbors includes: elem) and: (claimed includes: elem)])
					]) 
			] 
			"or: [ (both outer boundaries free and both inner boundaries claimed) ]"
		) ifTrue: [3.1] ifFalse: [3.2] 
		].
	
	groupedLines := (openLines groupBy: [:each | (each intersection: claimed) size]) 
		associationsSelect: [:each | each key > 1].
	
	groupedLines copy keysAndValuesDo: [:key :value | 
		key = 3 ifTrue: [groupedLines addAll: (value groupBy: weakLineDefinition)]].

	score := 0.
	groupedLines keysAndValuesDo: [:key :value | score := score + (value size * weight at: key)].
	
	^score

]
