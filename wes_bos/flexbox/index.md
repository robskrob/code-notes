## Intro

By defining a container as display `flex` its children become flex items. 

## Flex Direction

Flex direction sets the access when we are doing flexbox.

The default `flex-direction` of a `flex` container is `row;`.

There is `flex-direction` `row` and `column`.

There are two axises: the main axis and the cross access.

The main access when items are `flex-direction: row;` is from left to right of the screen. Then there is the cross access which goes from top to bottom.

When `flex-direction` changes from `row;` to `column;` The main access is no longer from left to right its from top to bottom, which forces the content of the container to be ordered from top to bottom. 

When `flex-direction` changes to `row-reverse;` the main axis runs from right to left.

When `flex-direction` changes to `column-reverse;` the main axis runs from bottom to top.

## Wrapping Elements with Flexbox

The flex container will try to work with the widths you give its children but if the widths just do not fit the flex container will either evenly distribute the widths throughout the children or there's another property you can use to assign more or less width to an element. 

`flex-wrap` is applied on the container. 

When `flex-wrap:wrap;` is applied on the container the container will apply each element's width and assuming `flex-direction:row;` the element that can not fit because of its width will wrap to the next line -- in another row. 

When `flex-direction: column;` and `flex-wrap:wrap` are applied the container given each of its child's height tries to fit all its elements vertically. If the container cannot fit them all vertically then the elements that do not fit the container will wrap them in another column.

