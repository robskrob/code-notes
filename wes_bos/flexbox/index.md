## Intro

By defining a container as display `flex` its children become flex items. 

## Flex Direction

Applied on container.

Flex direction sets the access when we are doing flexbox.

The default `flex-direction` of a `flex` container is `row;`.

There is `flex-direction` `row` and `column`.

There are two axises: the main axis and the cross access.

The main access when items are `flex-direction: row;` is from left to right of the screen. Then there is the cross access which goes from top to bottom.

When `flex-direction` changes from `row;` to `column;` The main access is no longer from left to right its from top to bottom, which forces the content of the container to be ordered from top to bottom. 

When `flex-direction` changes to `row-reverse;` the main axis runs from right to left.

When `flex-direction` changes to `column-reverse;` the main axis runs from bottom to top.

## Wrapping Elements with Flexbox

Applied on container.

The flex container will try to work with the widths you give its children but if the widths just do not fit the flex container will either evenly distribute the widths throughout the children or there's another property you can use to assign more or less width to an element. 

`flex-wrap` is applied on the container. 

When `flex-wrap:wrap;` is applied on the container the container will apply each element's width and assuming `flex-direction:row;` the element that can not fit because of its width will wrap to the next line -- in another row. 

When `flex-direction: column;` and `flex-wrap:wrap` are applied the container given each of its child's height tries to fit all its elements vertically. If the container cannot fit them all vertically then the elements that do not fit the container will wrap them in another column.

`flex-wrap: nowrap;` - default
`flex-wrap: wrap;` - lets child have its width and also spill over onto the next line or column depending on `flex-direction`
`flex-wrap: wrap-reverse;`

## Flexbox Ordering

By default the order of children is set to 0. If an item is set to a number different than 0 then the number may be before or after the default settings.

If you manipulate the order of children with `order` then highlighting them may be tricky. The reordering of child elements with `order` does not change the elements in the DOM -- their position in the DOM as elements remain the same. `order` adds merely a CSS change.


## Alignment and Centering

`justify-content` determines how the children are aligned and spaced out on the *main access*. This CSS attribute divides up the extra space either among or between your children.

`justify-content: center;`
`justify-content: flex-start;`
`justify-content: flex-end;`
`justify-content: space-between;`
`justify-content: space-around;`

## Alignment and Centering with align-items

`align-items` determines how the children are aligned and spaced out on the cross access assuming that the container to which the `align-items` is applied has significant height.

By default `align-items` is set to `stretch` by default, which will extend the children of the container from the top to the bottom of the container.

`align-items: stretch;`    - default; lengthens each item by the height of its container.
`align-items: center;`     - vertically centers items in container.
`align-items: flex-start;` - positions children at the 'start' of the container, the top left corner.
`align-items: flex-end;`   - positions children at the 'end' of the container, the bottom left corner.
`align-items: baseline;`   - aligns children, despite their various sizes, at the bottom of each child's the font or content dimensions.

## Alignment and Centering with align-content

`align-content` determines how the children are aligned and spaced out on the *cross access*. This CSS attribute divides up the extra space either among or between your children.

`align-content: center;`
`align-content: flex-end;`
`align-content: flex-start;`
`align-content: space-between;`
`align-content: space-around;`
`align-content: stretch;` - default

## Alignment and Centering with align-self

`align-self` can be applied on an individual child for alignment positioning -- it will override the `align-items` setting.

## Understanding Flexbox sizing with the flex property

Applied on children

`flex: grow shrink basis`

`flex: <number>` at what proportion should I scale either up or down my children when there's extra space or not enough space.

`flex:1;`

## Finally understanding Flexbox flex-grow, flex-shrink and flex-basis

Applied on children

`flex:1;` is a short hand for setting `flex-grow:1;` and `flex-shrink:1;`.

`flex-grow: <number>;`   - when we have extra space distribute it proportionally to the number given.
`flex-shrink: <number>;` - reduces the size of an element when there's not enough space to distribute among the elements. In other words `flex-shrink` determines how much an element ought to gives up in proportion to the other element when there's not enough room.
`flex-basis: <number>;` - sets the default width of element

