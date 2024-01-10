import 'package:flutter/material.dart';

int rowLength = 12;
int columnLength = 16;

enum Direction {
  left,right,down
}

enum Tetromino{
  L,J,I,O,S,Z,T
}

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Colors.red,
  Tetromino.J: Colors.orange,
  Tetromino.I: Colors.yellow,
  Tetromino.O: Colors.green,
  Tetromino.S: Colors.blue,
  Tetromino.Z: Colors.purple,
  Tetromino.T: Colors.white,
};
