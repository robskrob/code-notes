# Form objects
#thoughtbot

[Form Objects | Online Video Tutorial by thoughtbot](https://thoughtbot.com/upcase/videos/form_objects)

- finished video

## Law of Demeter
- Any one piece of your system should not know how all of your objects / models are put together. So if you change the data structure of one of your objects, you do not have to make sweeping changes across your system that uses this one object.
- Knowledge of how data or objects are organized should be isolated and encapsulated in one place -- not spread across your system.

## Why is Accepts nested attributes bad?
- Accepts nested attributes violates the Law of Demeter because if accepts nested attributes changes in your model then you will need to make changes not only in your model but also in your controller and your views that has knowledge of accepts nested attributes.
- Many Rails projects will create deeply nested forms. For instance, going from User to four models away using associations is difficult to reason about.
- Makes validations complicated -- sometimes the validation of one association depends on the validation of another.
- Rails does a lot of magic in the background to make `accepts_nested_attributes_for` work. Moreover, if you are just slightly off in defining the `accepts_nested_attributes_for` then you may not get the convention `model_attributes` and if this fails then your code will not behave as you expect it to.
