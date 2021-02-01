# Unlimited Tic-Tac-Toe
coding presentation written in Squeak 6.0 and portable to Pharo 9.0
___

Unlimited tic-tac-toe is a variant of the classic Tic-Tac-Toe, played on an infinite two-dimensional board by two players. The players seek to place 5 marks in a row (vertical, horizontal or diagonal). The game starts by placing an X mark on the 0@0 field (the 'center' of an infinite board).

The algorithm presented here works for any number of marks marks-in-a-row.

This code is a working prototype without any graphical user interface; the development is in progress. Find more detailed description under the classes and methods.

Let the computer play against itself:

<i>XOGame new game: BotPlayer versus: BotPlayer </i>

or against yourself:

<i>XOGame new game: BotPlayer versus: HumanPlayer </i>
