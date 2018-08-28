# Refactoring Fast Order Line, with Joe Ferris

#thoughtbot

- finished watching

When refactoring controller action endpoints you should pull most of the logic out into its own class. Then write characteriziation tests: tests that describe how the code works now -- then we can refactor it.

[Syntastic plugin](https://github.com/vim-syntastic/syntastic) -- can check for variables that are not being used.

`_` as a variable is a ruby way for saying, "I am not using this variable / data."

When a method is really long the next step for you is to extract methods out of it.:

Tests should be run from the editor.

Once you extract a bunch of methods to clean up and make sense of the code now its time to extract objects. You can extract objects by identifying pieces that you refer to a lot across all of your methods. In our case, `@orders` is referenced a lot. Perhaps we can make an object that represents the orders we are building. 

