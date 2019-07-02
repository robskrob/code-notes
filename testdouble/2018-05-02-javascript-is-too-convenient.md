## Javascript Is Too Convenient

http://blog.testdouble.com/posts/2018-05-02-javascript-is-too-convenient?utm_content=86242757&utm_medium=social&utm_source=twitter&hss_channel=tw-12621452

What type of function are you creating?

A function should do only one of three things -- choose only one:
* Coordinate the actions of other components
* Calculate a final value
* Control the application flow

Coordinator

* a coordinator is responsible for creating a set of actions for calling other well named functions. The coordinator manages interactions -- and that is it. 
* Just like a good manager in real life, a good manager is not splitting time actually doing the work. They are spending all of their time supporting and coordinating the team. 
* a coordinate just manages the actions within it.

```js
function coordinator() {
  return callFirstFunction
  .then(res => callSecondFunction(res))
  .then(res => callThirdFunction(res))
}
```

Calculator
* calculates math
* calculates a new type of object in our system

```js
// calculates math
function calculator(val1, val2, val3) {
  return Math.pow(Math.abs(val1 + val2) * val3, 2);
}

// calculates a new type of object in our system
function createObject(n) {
  return {key: _.get(in, 'foo.baar.baz')}
}
```

Controller

* only allows each branch to understand about itself.
* there is one function that is responsible for controlling the flow of an application.
* a controller function uses other well named things to accomplish its goal.

```js
// BAD Controller
function confusing(value) {
  if (value.foo) {
    ...
  } else if (value.bar) {
    ...
  } else {
    ...
  }
}


// GOOD Controller
function controller(value) {
  return strategies
    .find(s => s.canExecute(value))
    .execute(value)
}
```
