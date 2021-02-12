# Animation Property & Keframes

## Keyframes
* on the root of the CSS page
* there are no selectors
* they are not nested
* [name] -- name it whatever you want. We will use that name later on to call the selector
* animation and keyframes are a pair that work together

```css
@keyframes [name] {
  from {
    [styles];
  }
  to {
    [styles];
  }
}
```

```css
@keyframes [myframes] {
  from {
    height: 200px;
    background: orange;
  }
  to {
    height: 400px
    background: pink;
  }
}
```

```css
.element {
  animation: [name] [duration] [timing-function] [delay] [iteration-count] [direction] [fill-mode] [play-state];
}
```

The `animation` property is inside the selector. The `animation` propety does not hang 
outside like the `keyframes` do.

`name` should match the name of the keyframes exactly. This is how you tie the keyframes 
to the `animation` property of the element.

The keyframes are what the animation does and the animation is how its done, like: the speed, 
the duration, the timing function, the delay, how many times it does the animation.

```css
.element {
  animation: myframes 2s ease-in-out 0s infinite normal forwards paused;
}
```
