module Html.String.Extra exposing
    ( body
    , charset
    , content
    , crossorigin
    , doctype
    , head
    , html
    , httpEquiv
    , link
    , meta
    , noscript
    , property_
    , script
    , style_
    , title_
    )

import Html.String exposing (..)
import Html.String.Attributes exposing (..)



-- HTML EXTENSIONS
--
-- Adding nodes and attributes useful to generate an entire HTML page


doctype : String
doctype =
    "<!DOCTYPE HTML>"


html : List (Attribute msg) -> List (Html msg) -> Html msg
html =
    node "html"


head : List (Attribute msg) -> List (Html msg) -> Html msg
head =
    node "head"


body : List (Attribute msg) -> List (Html msg) -> Html msg
body =
    node "body"


script : List (Attribute msg) -> List (Html msg) -> Html msg
script =
    node "script"


noscript : List (Attribute msg) -> List (Html msg) -> Html msg
noscript =
    node "noscript"


meta : List (Attribute msg) -> List (Html msg) -> Html msg
meta =
    node "meta"


link : List (Attribute msg) -> List (Html msg) -> Html msg
link =
    node "link"


style_ : List (Attribute msg) -> List (Html msg) -> Html msg
style_ =
    node "style"


title_ : List (Attribute msg) -> List (Html msg) -> Html msg
title_ =
    node "title"


charset : String -> Attribute msg
charset =
    attribute "charset"


crossorigin : String -> Attribute msg
crossorigin =
    attribute "crossorigin"


property_ : String -> Attribute msg
property_ =
    attribute "property"


content : String -> Attribute msg
content =
    attribute "content"


httpEquiv : String -> Attribute msg
httpEquiv =
    attribute "http-equiv"
