Class {
	#name : 'MyPawn',
	#superclass : 'MyPiece',
	#category : 'Myg-Chess-Core',
	#package : 'Myg-Chess-Core'
}

{ #category : 'moveCompute' }
MyPawn >> addCaptureIfPossible: targetSquare to: legalSquares [ 
    (targetSquare notNil and: [targetSquare hasPiece and: [targetSquare contents color ~= self color] ]) 
        ifTrue: [ legalSquares add: targetSquare ]
]

{ #category : 'moveCompute' }
MyPawn >> addDiagonalCaptures: legalSquares [
	| targetSquare |
    targetSquare := self isWhite ifTrue: [ square up ] ifFalse: [ square down ].
    
    targetSquare ifNotNil: [
        self addCaptureIfPossible: targetSquare right to: legalSquares.
        self addCaptureIfPossible: targetSquare left to: legalSquares.
    ]
]

{ #category : 'moveCompute' }
MyPawn >> addEnPassantCaptures: legalSquares [

	| targetSquare |
	targetSquare := self isWhite
		                ifTrue: [ square up ]
		                ifFalse: [ square down ].

	targetSquare ifNotNil: [
		self checkEnPassantCapture: square right targetSquare: targetSquare addTo: legalSquares side: 'right'.
		self checkEnPassantCapture: square left targetSquare: targetSquare addTo: legalSquares side: 'left' ]
]

{ #category : 'moveCompute' }
MyPawn >> addFirstMove: legalSquares [

	| firstSquare secondSquare |
	firstSquare := self isWhite
		               ifTrue: [ square up ]
		               ifFalse: [ square down ].


	secondSquare := firstSquare ifNotNil: [
		                self isWhite
			                ifTrue: [ (self isOnStartingRank and: [ firstSquare hasPiece not ]) ifTrue: [ firstSquare up ] ]
			                ifFalse: [ (self isOnStartingRank and: [ firstSquare hasPiece not ]) ifTrue: [ firstSquare down ] ] ].

	secondSquare ifNotNil: [ legalSquares add: secondSquare ]
]

{ #category : 'moveCompute' }
MyPawn >> addRegularMove: legalSquares [

	| nextSquare |
	nextSquare := self isWhite
		              ifTrue: [ square up ]
		              ifFalse: [ square down ].


	nextSquare ifNotNil: [ nextSquare hasPiece ifFalse: [ legalSquares add: nextSquare ] ]
]

{ #category : 'moveCompute' }
MyPawn >> checkEnPassantCapture: sideSquare targetSquare: targetSquare addTo: legalSquares side: aSide [

	| sidePiece otherPieceLastMove gameLastMove lastMoveEnd |
	(sideSquare notNil and: [ sideSquare hasPiece ]) ifFalse: [ ^ self ].

	sidePiece := sideSquare contents.

	"Vérifier si la pièce adjacente est un pion"
	(sidePiece isKindOf: self class ) ifFalse: [ ^ self ].

	"Vérifier si c'était le premier mouvement du pion adjacent"
	sidePiece moveCount = 1 ifFalse: [ ^ self ].

	otherPieceLastMove := sidePiece lastSquare ifNotNil: [ :sq | sq name ] ifNil: [ '' ].

	gameLastMove := square board game lastMove.

	lastMoveEnd := gameLastMove ifNotNil: [ gameLastMove last: 2 ] ifNil: [ nil ].

	otherPieceLastMove = lastMoveEnd ifTrue: [
		legalSquares add: (aSide = 'right'
				 ifTrue: [ targetSquare right ]
				 ifFalse: [ targetSquare left ]) ]
]

{ #category : 'accessing' }
MyPawn >> id [

	^ 'P'
]

{ #category : 'moveCompute' }
MyPawn >> isOnStartingRank [ 
    ^ self isWhite
        ifTrue: [ (square name at: 2) = $2 ]
        ifFalse: [ (square name at: 2) = $7 ]

]

{ #category : 'rendering' }
MyPawn >> renderPieceOn: aSquare [ 
	
	^ aSquare renderPawn: self
]

{ #category : 'rendering' }
MyPawn >> targetSquaresLegal: aBoolean [

	| legalSquare |
	legalSquare := OrderedCollection new.
	
		self addRegularMove: legalSquare .
		self addDiagonalCaptures: legalSquare .
		self addFirstMove: legalSquare .
		self addEnPassantCaptures: legalSquare .

	^ legalSquare 
]
