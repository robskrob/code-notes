# CSS Transition (CSS Animations Series Part 1)

The `transition` property
The `animation` property with keyframes

Elements you should / should not animate

```css
// formula
.element {
  transition: [property] [duration] [ease] [delay];
}
```
Property: the property of the element we are animating
Duration: how long is this transition duration happening? 
Ease: timing function; how is that transition distributed across time. Does it ease out or in?
Delay: how long should this transition wait before it starts to happen

```css

// example
.element {
  transition: opacity 300ms ease-in-out 1s;
}
```

animating / targiting the, opacity, property. if it was set to, all, instead, then
every property on that element would be transitioned. This transition will last for 300ms
but wait a second before the transition starts. 

Animatable CSS properties:
* font-size
* background-color
* width
* left
and [more](http://oli.jp/2010/css-animatable-properties/)

Cannot animate:
* display
* font-family
* position

Performance -- these are the best [performant](https://www.html5rocks.com/en/tutorials/speed/high-performance-animations/) properties to animate:
* position 
* scale
* rotation
* transforms
* opacity

Transitioning the above properties do not cause a repaint of the elements or a reflow of the 
layout, which are very costly in terms of browser rendering. 

## Triggering - How to kickoff a transition
1. Hover pseudo class; you hover over something and it transitions.
2. Class changes; switch the class and that class you switch has the command to transition.


The `transition` property is always on the element looking for a change in whetever property. In other words,
The `transition` property never goes on a pseudo class like hover. The property, however, that you are
transitioning like `transform` goes inside the `hover` pseudo selector.  

Transitioning on :hover
* when .trigger is hovered take the .box, the child of .trigger, and transform the .box. In other words
let the parent be the trigger and let the child experience the animation. That way, when you hover over
.trigger the .box gets triggered but also when you hover over .box, .box stays being triggered.

`pointer-events: none` -- do not register any interactive events like: hover, click, mouseover etc...
you can only see this element; you cannot interact with it. In order to cancel the hover trigger on 
the child, .box, just add `pointer-events: none` to .box.
