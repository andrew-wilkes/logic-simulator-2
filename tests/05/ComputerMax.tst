// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/05/ComputerMax.tst

// Tests the Computer chip by loading into it, and then running, the program Max.hack.
// The program computes the maximum of RAM[0] and RAM[1] and writes the result in RAM[2].

load Computer.hdl,
output-file ComputerMax.out,
compare-to ComputerMax.cmp,
// Outputs the time unit, value of reset input, values of registers A, D, and PC, 
// and values of RAM[0], RAM[1], RAM[2].
output-list time%S1.4.1 reset%B2.1.2 ARegister[0]%D1.7.1 DRegister[0]%D1.7.1 PC[]%D0.4.0 RAM16K[0]%D1.7.1 RAM16K[1]%D1.7.1 RAM16K[2]%D1.7.1;

// Loads the program
ROM32K load Max.hack,

// First run: computes max(3,5)
set RAM16K[0] 3,
set RAM16K[1] 5,
output;

repeat 14 {
    tick, tock, output;
}

// Resets the PC
set reset 1,
tick, tock, output;

// Second run: computes max(23456,12345)
set reset 0,
set RAM16K[0] 23456,
set RAM16K[1] 12345,
output;

// The inputs above entail less cycles (different branching)
repeat 10 {
    tick, tock, output;
}
