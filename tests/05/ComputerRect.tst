// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/05/ComputerRect.tst

// Tests the Computer chip by loading into it, and then running, the program Rect.hack.
// The program draws a rectangle of width 16 pixels and length RAM[0] at the top left
// corner of the screen.

load Computer.hdl,
output-file ComputerRect.out,
compare-to ComputerRect.cmp,
// Outputs the time unit, values of registers A, D, and PC, 
// and values of RAM[0], RAM[1], RAM[2].
output-list time%S1.4.1 ARegister[0]%D1.7.1 DRegister[0]%D1.7.1 PC[]%D0.4.0 RAM16K[0]%D1.7.1 RAM16K[1]%D1.7.1 RAM16K[2]%D1.7.1;

// Loads the program
ROM32K load Rect.hack,

echo "A small rectangle should be drawn at the top left of the screen";

// Draws a rectangle 16 pixels wide and 4 pixels long
set RAM16K[0] 4,
output;

repeat 63 {
    tick, tock, output;
}
