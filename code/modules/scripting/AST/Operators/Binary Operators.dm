//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
	File: Binary Operators
*/
/*
	Class: binary
	Represents a binary operator in the AST. A binary operator takes two operands (ie x and y) and returns a value.
*/
/node/expression/operator/binary
	var/node/expression/exp2

////////// Comparison Operators //////////
/*
	Class: Equal
	Returns true if x = y.
*/
//
	Equal
		precedence=4

/*
	Class: NotEqual
	Returns true if x and y aren't equal.
*/
//
	NotEqual
		precedence=4

/*
	Class: Greater
	Returns true if x > y.
*/
//
	Greater
		precedence=5

/*
	Class: Less
	Returns true if x < y.
*/
//
	Less
		precedence=5

/*
	Class: GreaterOrEqual
	Returns true if x >= y.
*/
//
	GreaterOrEqual
		precedence=5

/*
	Class: LessOrEqual
	Returns true if x <= y.
*/
//
	LessOrEqual
		precedence=5


////////// Logical Operators //////////

/*
	Class: LogicalAnd
	Returns true if x and y are true.
*/
//
	LogicalAnd
		precedence=6

/*
	Class: LogicalOr
	Returns true if x, y, or both are true.
*/
//
	LogicalOr
		precedence=6

/*
	Class: LogicalXor
	Returns true if either x or y but not both are true.
*/
//
	LogicalXor					//Not implemented in nS
		precedence=6


////////// Bitwise Operators //////////

/*
	Class: BitwiseAnd
	Performs a bitwise and operation.

	Example:
	011 & 110 = 010
*/
//
	BitwiseAnd
		precedence=7

/*
	Class: BitwiseOr
	Performs a bitwise or operation.

	Example:
	011 | 110 = 111
*/
//
	BitwiseOr
		precedence=7

/*
	Class: BitwiseXor
	Performs a bitwise exclusive or operation.

	Example:
	011 xor 110 = 101
*/
//
	BitwiseXor
		precedence=7


////////// Arithmetic Operators //////////

/*
	Class: Add
	Returns the sum of x and y.
*/
//
	Add
		precedence=7

/*
	Class: Subtract
	Returns the difference of x and y.
*/
//
	Subtract
		precedence=2

/*
	Class: Multiply
	Returns the product of x and y.
*/
//
	Multiply
		precedence=1

/*
	Class: Divide
	Returns the quotient of x and y.
*/
//
	Divide
		precedence=2

/*
	Class: Power
	Returns x raised to the power of y.
*/
//
	Power
		precedence=3

/*
	Class: Modulo
	Returns the remainder of x / y.
*/
//
	Modulo
		precedence=4
