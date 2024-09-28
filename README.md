# Lox_Interpreter

This is the Lox Interpreter written in Swift following Robert Nystrom's book "Crafting Interpreters". 

## Running

To read a file and execute it, run: 

```
swift run -c release LoxCLI [fileName]
```

To run the interpreter interactively, run: 

```
swift run -c release LoxCLI
```

To regenerate the Expr.swift and Stmt.swift files after changing the definition of the abstract syntax tree (AST), run: 

```
swift run -c release GenerateAst [path_where_you_want_to_store_the_output]
```

## Testing

The test input file is test_input.txt. To run it and put the result in the test_output.txt file, run: 

```
swift run -c release LoxCLI test_input.txt
```
