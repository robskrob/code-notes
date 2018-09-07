# Form objects
#thoughtbot

- finished video

## Law of Demeter
- Any one piece of your system should not know how all of your objects / models are put together. So if you change the data structure of one of your objects, you do not have to make sweeping changes across your system that uses this one object.
- Knowledge of how data or objects are organized should be isolated and encapsulated in one place -- not spread across your system.

Accepts nested attributes violates the Law of Demeter because if accepts nested attributes changes in your model then you will need to make changes not only in your model but also in your controller and your views that has knowledge of accepts nested attributes.
