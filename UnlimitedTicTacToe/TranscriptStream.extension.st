Extension { #name : #TranscriptStream }

{ #category : #'*UnlimitedTicTacToe' }
TranscriptStream >> openIfNoneLabel: aString [
	"Open a transcript window if there are no open windows."

	self countOpenTranscripts = 0 ifTrue: [self openLabel: aString]
]
