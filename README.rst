This library defines a `<path>` class that is designed to be as simple
to use as Python's `os.path` module, but is better than plain strings
because it gives you a type to dispatch on.  This library is inspired
by all the pain inflicted upon me by the locators library.

Unlike `os.path`, this library does no operations that actually touch
physical media; it only does file pathname manipulation.

The intention is to try out this library and see how it holds up
compared to locators.  (It can take advantage of the fact that most
(all?) file-system APIs accept `<pathname>`, which is defined as
`type-union(<string>, <locator>)`.)  If it works out well then it
could replace locators.
