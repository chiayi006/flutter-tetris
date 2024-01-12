import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tetris/pixel.dart';
import 'package:flutter_tetris/values.dart';
import 'piece.dart';

List<List<Tetromino?>> gameBoard = List.generate(
  columnLength,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.L);

  int currentScore = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    currentPiece.initializePiece();

    Duration frameRate = const Duration(milliseconds: 400);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        clearLines();
        checkLanding();
        if (gameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Game Over!'),
              content: Text('Your score is : $currentScore'),
              actions: [
                TextButton(
                    onPressed: () {
                      resetGame();
                      Navigator.pop(context);
                    },
                    child: Text('Play again'))
              ],
            ));
  }

  void resetGame() {
    gameBoard = List.generate(
      columnLength,
      (i) => List.generate(
        rowLength,
        (j) => null,
      ),
    );
    gameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int column = currentPiece.position[i] % rowLength;

      if (direction == Direction.left) {
        column -= 1;
      } else if (direction == Direction.right) {
        column += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      if (row >= columnLength || column < 0 || column >= rowLength) {
        return true;
      }

      if (row >= 0 && column >= 0) {
        if (gameBoard[row][column] != null) {
          return true;
        }
      }
    }
    return false;
  }

  void checkLanding() {
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      createNewPiece();
    }
  }

  void createNewPiece() {
    Random random = Random();
    Tetromino randomType =
        Tetromino.values[random.nextInt(Tetromino.values.length)];

    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  void clearLines() {
    for (int row = columnLength - 1; row >= 0; row--) {
      bool rowIsFull = true;
      for (int column = 0; column < rowLength; column++) {
        if (gameBoard[row][column] == null) {
          rowIsFull = false;
          break;
        }
      }
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(row, (index) => null);
        currentScore++;
      }
    }
  }

  bool isGameOver() {
    for (int column = 0; column < rowLength; column++) {
      if (gameBoard[0][column] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    child: Text('Score: $currentScore',
                        style: TextStyle(color: Colors.white, fontSize: 24))),
                SizedBox(width: 150),
                Container(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        startGame();
                      });
                    },
                    child: Text('Start',style: TextStyle(color: Colors.black),),
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                itemCount: rowLength * columnLength,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowLength),
                itemBuilder: (context, index) {
                  int row = (index / rowLength).floor();
                  int column = index % rowLength;

                  if (currentPiece.position.contains(index)) {
                    return Pixel(color: currentPiece.color);
                  } else if (gameBoard[row][column] != null) {
                    final Tetromino? tetrominoType = gameBoard[row][column];
                    return Pixel(color: tetrominoColors[tetrominoType]);
                  } else {
                    return Pixel(color: Colors.grey[900]);
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 50.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 100,
                    child: IconButton(
                        onPressed: moveLeft,
                        color: Colors.white,
                        icon: Icon(Icons.arrow_back_ios)),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: OvalBorder(),
                    ),
                    child: IconButton(
                        onPressed: rotatePiece,
                        color: Colors.black,
                        icon: Icon(Icons.rotate_right)),
                  ),
                  Container(
                    width: 100,
                    child: IconButton(
                        onPressed: moveRight,
                        color: Colors.white,
                        icon: Icon(Icons.arrow_forward_ios)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
