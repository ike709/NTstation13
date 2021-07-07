/*
	File: Errors
*/
/*
	Class: scriptError
	An error scanning or parsing the source code.
*/
/scriptError
	var/message

/scriptError/New(msg=null)
		if(msg)message=msg

/scriptError/BadToken
	message="Unexpected token: "
	var/token/token
	New(token/t)
		token=t
		if(t&&t.line) message="[t.line]: [message]"
		if(istype(t))message+="[t.value]"
		else message+="[t]"

/scriptError/InvalidID
	////parent_type=/scriptError/BadTokenor/BadToken
	message="Invalid identifier name: "

/scriptError/ReservedWord
	////parent_type=/scriptError/BadTokenor/BadToken
	message="Identifer using reserved word: "

/scriptError/BadNumber
	////parent_type=/scriptError/BadTokenor/BadToken
	message = "Bad number: "

/scriptError/BadReturn
	var/token/token
	message = "Unexpected return statement outside of a function."
	New(token/t)
		src.token=t

/scriptError/EndOfFile
	message = "Unexpected end of file."

/scriptError/ExpectedToken
	message="Expected: '"
/scriptError/ExpectedToken/New(id, token/T)
	if(T && T.line) message="[T.line]: [message]"
	message+="[id]'. "
	if(T)message+="Found '[T.value]'."


/scriptError/UnterminatedComment
	message="Unterminated multi-line comment statement: expected */"

/scriptError/DuplicateFunction
	New(name, token/t)
	message="Functio defined twice."

/scriptError/ParameterFunction
	message = "You cannot use a function inside a parameter."

	New(token/t)
		var/line = "?"
		if(t)
			line = t.line
		message = "[line]: [message]"

/*
	Class: runtimeError
	An error thrown by the interpreter in running the script.
*/
/runtimeError
	var
		name
/*
	Var: message
	A basic description as to what went wrong.
*/
		message
		stack/stack


/*
	Proc: ToString
	Returns a description of the error suitable for showing to the user.
*/
/runtimeError/proc/ToString()
	. = "[name]: [message]"
	if(!stack.Top()) return
	.+="\nStack:"
	while(stack.Top())
		var/node/statement/FunctionCall/stmt=stack.Pop()
		. += "\n\t [stmt.func_name]()"

/runtimeError/TypeMismatch
	name="TypeMismatchError"
	New(op, a, b)
		message="Type mismatch: '[a]' [op] '[b]'"

/runtimeError/UnexpectedReturn
	name="UnexpectedReturnError"
	message="Unexpected return statement."

/runtimeError/UnknownInstruction
	name="UnknownInstructionError"
	message="Unknown instruction type. This may be due to incompatible compiler and interpreter versions or a lack of implementation."

/runtimeError/UndefinedVariable
	name="UndefinedVariableError"
	New(variable)
		message="Variable '[variable]' has not been declared."

/runtimeError/UndefinedFunction
	name="UndefinedFunctionError"
	New(function)
		message="Function '[function]()' has not been defined."

/runtimeError/DuplicateVariableDeclaration
	name="DuplicateVariableError"
	New(variable)
		message="Variable '[variable]' was already declared."

/runtimeError/IterationLimitReached
	name="MaxIterationError"
	message="A loop has reached its maximum number of iterations."

/runtimeError/RecursionLimitReached
	name="MaxRecursionError"
	message="The maximum amount of recursion has been reached."

/runtimeError/DivisionByZero
	name="DivideByZeroError"
	message="Division by zero attempted."

/runtimeError/MaxCPU
	name="MaxComputationalUse"
	message="Maximum amount of computational cycles reached (>= 1000)."