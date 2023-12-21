// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/05/Memory.tst

// Tests the Memory chip by inputting values to selected addresses, 
// verifying that these addresses were indeed written to, and verifying  
// that other addresses were not accessed by mistake. In particular, we 
// focus on probing the registers in addresses 'lower RAM', 'upper RAM',
// and 'Screen', which correspond to 0, %X2000, and %X4000 in Hexadecimal 
// (0, 8192 (8K), and 16385 (16K+1) in decimal).

load Memory.hdl,
output-file Memory.out,
compare-to Memory.cmp,
// Outputs the values of the in, load, and address inputs, 
// and the value of the out output. 
output-list in%D1.6.1 load%B2.1.2 address%B1.15.1 out%D1.6.1;

echo "Before running this script, select the 'Screen' option from the 'View' menu";

set in -1,				// Sets RAM[0] = -1
set load 1,
set address 0,
tick,
output;
tock,
output;

set in 9999,			// Checks that RAM[0] was not written to when load == 0
set load 0,
tick,
output;
tock,
output;

set address %X2000,		// Checks that the upper RAM or Screen were not written to
eval,
output;
set address %X4000,
eval,
output;

set in 2222,			// Sets RAM[%X2000] = 2222
set load 1,
set address %X2000,
tick,
output;
tock,
output;

set in 9999,			// Checks that RAM[%X2000] was not written to when load == 0
set load 0,
tick,
output;
tock,
output;

set address 0,			// Checks that the lower RAM or Screen were not written to
eval,
output;
set address %X4000,
eval,
output;

set load 0,				// Low order address bits connected
set address %X0001, eval, output;
set address %X0002, eval, output;
set address %X0004, eval, output;
set address %X0008, eval, output;
set address %X0010, eval, output;
set address %X0020, eval, output;
set address %X0040, eval, output;
set address %X0080, eval, output;
set address %X0100, eval, output;
set address %X0200, eval, output;
set address %X0400, eval, output;
set address %X0800, eval, output;
set address %X1000, eval, output;
set address %X2000, eval, output;

set address %X1234,		// Sets RAM[%X1234] = 1234
set in 1234,
set load 1,
tick,
output;
tock,
output;

set load 0,
set address %X2234,		// Checks that the upper RAM or Screen were not written to 
eval, output;
set address %X6234,
eval, output;

set address %X2345,		// RAM[%X2345] = 2345
set in 2345,
set load 1,
tick,
output;
tock,
output;

set load 0,
set address %X0345,		// Checks that the lower RAM or Screen were not written to 
eval, output;
set address %X4345,
eval, output;

// Keyboard test

set address 24576,
echo "Click the Keyboard icon and hold down the 'K' key (uppercase) until you see the next message (it should appear shortly after that) ...",
// It's important to keep holding the key down since if the system is busy,
// the memory will zero itself before being outputted.

while out <> 75 {
    eval,
}

clear-echo,
output;

// Screen test

set load 1,
set in -1,
set address %X4FCF,
tick,
tock,
output,

set address %X504F,
tick,
tock,
output;

set address %X0FCF,		// Checks that the lower or upper RAM were not written to
eval,
output;
set address %X2FCF,
eval,
output;

set load 0,				// Low order address bits connected
set address %X4FCE, eval, output;
set address %X4FCD, eval, output;
set address %X4FCB, eval, output;
set address %X4FC7, eval, output;
set address %X4FDF, eval, output;
set address %X4FEF, eval, output;
set address %X4F8F, eval, output;
set address %X4F4F, eval, output;
set address %X4ECF, eval, output;
set address %X4DCF, eval, output;
set address %X4BCF, eval, output;
set address %X47CF, eval, output;
set address %X5FCF, eval, output;

set load 0,
set address 24576,
echo "Make sure you see ONLY two horizontal lines in the middle of the screen. Hold down 'Y' (uppercase) until you see the next message ...",
// It's important to keep holding the key down since if the system is busy,
// the memory will zero itself before being outputted.

while out <> 89 {
    eval,
}

clear-echo,
output;
