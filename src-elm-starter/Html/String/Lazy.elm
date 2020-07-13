module Html.String.Lazy exposing (lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8)

{-|


# 🔥 This isn't actually lazy in this library..

.. because we can't keep track of the model without existential types. It just
eagerly evaluates. This set of function is here to serve as a drop-in
replacement.

@docs lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8

-}

import Html.String exposing (Html)


{-| A performance optimization that delays the building of virtual DOM nodes.

Calling `(view model)` will definitely build some virtual DOM, perhaps a lot of
it. Calling `(lazy view model)` delays the call until later. During diffing, we
can check to see if `model` is referentially equal to the previous value used,
and if so, we just stop. No need to build up the tree structure and diff it,
we know if the input to `view` is the same, the output must be the same!

-}
lazy : (a -> Html msg) -> a -> Html msg
lazy f x =
    f x


{-| Same as `lazy` but checks on two arguments.
-}
lazy2 : (a -> b -> Html msg) -> a -> b -> Html msg
lazy2 f x y =
    f x y


{-| Same as `lazy` but checks on three arguments.
-}
lazy3 : (a -> b -> c -> Html msg) -> a -> b -> c -> Html msg
lazy3 f x y z =
    f x y z


{-| Same as `lazy` but checks on four arguments.
-}
lazy4 : (a -> b -> c -> Html msg) -> a -> b -> c -> Html msg
lazy4 f x y z =
    f x y z


{-| Same as `lazy` but checks on five arguments.
-}
lazy5 : (a -> b -> c -> Html msg) -> a -> b -> c -> Html msg
lazy5 f x y z =
    f x y z


{-| Same as `lazy` but checks on six arguments.
-}
lazy6 : (a -> b -> c -> Html msg) -> a -> b -> c -> Html msg
lazy6 f x y z =
    f x y z


{-| Same as `lazy` but checks on seven arguments.
-}
lazy7 : (a -> b -> c -> Html msg) -> a -> b -> c -> Html msg
lazy7 f x y z =
    f x y z


{-| Same as `lazy` but checks on eight arguments.
-}
lazy8 : (a -> b -> c -> Html msg) -> a -> b -> c -> Html msg
lazy8 f x y z =
    f x y z
