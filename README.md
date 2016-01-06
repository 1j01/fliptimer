# [countdown.ml](http://countdown.ml)
A simple countdown timer.
Just enter an amount of time and press <kbd>Enter</kbd>.

It uses a natural time time display with a nice dynamic flipping animation.

I'd almost make the flippers into a library, but there's a slight bug.
It becomes very visible when disabling the animations
and especially when slowing down the interval at which the display is updated
because it only happens exactly when a change occurs and not the update after.
The bug can be "fixed" by disabling `display: table-cell;` in [main.css](main.css),
but this is used to vertically center the display.
