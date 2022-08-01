# Chess
An assignment from [The Odin Project](https://www.theodinproject.com/) to implement the rules of chess using Ruby.

images

## How to Play

ruby lib/game.rb

An image of the chess board will be displayed with rows labelled with the numbers **1** to **8** and the columns labeled by letters **a** to **h**. Chess pieces are represented by the unicode chess symbols.
White starts and is on the bottom of the board.

Input is in the form <code>(col)(row) to (col)(row)</code>. For example, an opening move by white could be <code>a2 to a4</code>.

Information on turns, invalid input, check, promotions, and checkmate will be printed on the console.

<code>exit</code> can be used at any time to quit the game.

## Features

- Ensures valid moves.
- Determine game ending conditions
- Unit tests
checks for valid/invalid movements, including castling, promoting, en_passant
checks for win conditions, some stalemates, some deadpositions, check, checkmate
simple AI that pick a random, valid move


## Technologies