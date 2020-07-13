module Html.String.Attributes exposing
    ( style, property, attribute, map
    , class, classList, id, title, hidden
    , type_, value, checked, placeholder, selected
    , accept, acceptCharset, action, autocomplete, autofocus
    , disabled, enctype, list, maxlength, minlength, method, multiple
    , name, novalidate, pattern, readonly, required, size, for, form
    , max, min, step
    , cols, rows, wrap
    , href, target, download, hreflang, media, ping, rel
    , ismap, usemap, shape, coords
    , src, height, width, alt
    , autoplay, controls, loop, preload, poster, default, kind, srclang
    , sandbox, srcdoc
    , reversed, start
    , align, colspan, rowspan, headers, scope
    , accesskey, contenteditable, contextmenu, dir, draggable, dropzone
    , itemprop, lang, spellcheck, tabindex
    , cite, datetime, pubdate, manifest
    )

{-| Helper functions for HTML attributes. They are organized roughly by
category. Each attribute is labeled with the HTML tags it can be used with, so
just search the page for `video` if you want video stuff.


# Primitives

@docs style, property, attribute, map


# Super Common Attributes

@docs class, classList, id, title, hidden


# Inputs

@docs type_, value, checked, placeholder, selected


## Input Helpers

@docs accept, acceptCharset, action, autocomplete, autofocus
@docs disabled, enctype, list, maxlength, minlength, method, multiple
@docs name, novalidate, pattern, readonly, required, size, for, form


## Input Ranges

@docs max, min, step


## Input Text Areas

@docs cols, rows, wrap


# Links and Areas

@docs href, target, download, hreflang, media, ping, rel


## Maps

@docs ismap, usemap, shape, coords


# Embedded Content

@docs src, height, width, alt


## Audio and Video

@docs autoplay, controls, loop, preload, poster, default, kind, srclang


## iframes

@docs sandbox, srcdoc


# Ordered Lists

@docs reversed, start


# Tables

@docs align, colspan, rowspan, headers, scope


# Less Common Global Attributes

Attributes that can be attached to any HTML tag but are less commonly used.

@docs accesskey, contenteditable, contextmenu, dir, draggable, dropzone
@docs itemprop, lang, spellcheck, tabindex


# Miscellaneous

@docs cite, datetime, pubdate, manifest

-}

import Html.String exposing (Attribute)
import Html.Types
import Json.Encode as Json


{-| Specify a single CSS rule.

    greeting : Html msg
    greeting =
        div
            [ style "backgroundColor" "red"
            , style "height" "90px"
            , style "width" "100%"
            ]
            [ text "Hello!" ]

There is no `Html.Styles` module because best practices for working with HTML
suggest that this should primarily be specified in CSS files. So the general
recommendation is to use this function lightly.

-}
style : String -> String -> Attribute msg
style =
    Html.Types.Style


{-| This function makes it easier to build a space-separated class attribute.
Each class can easily be added and removed depending on the boolean val it
is paired with. For example, maybe we want a way to view notices:

    viewNotice : Notice -> Html msg
    viewNotice notice =
        div
            [ classList
                [ ( "notice", True )
                , ( "notice-important", notice.isImportant )
                , ( "notice-seen", notice.isSeen )
                ]
            ]
            [ text notice.content ]

-}
classList : List ( String, Bool ) -> Attribute msg
classList conditionalClasses =
    conditionalClasses
        |> List.filter Tuple.second
        |> List.map Tuple.first
        |> String.join " "
        |> class


{-| Create _properties_, like saying `domNode.className = 'greeting'` in
JavaScript.

    import Json.Encode as Encode

    class : String -> Attribute msg
    class name =
        property "className" (Encode.string name)

Read more about the difference between properties and attributes [here].

[here]: https://github.com/elm-lang/html/blob/master/properties-vs-attributes.md

-}
property : String -> Json.Value -> Attribute msg
property =
    Html.Types.ValueProperty


stringProperty : String -> String -> Attribute msg
stringProperty =
    Html.Types.StringProperty


boolProperty : String -> Bool -> Attribute msg
boolProperty =
    Html.Types.BoolProperty


{-| Create _attributes_, like saying `domNode.setAttribute('class', 'greeting')`
in JavaScript.

    class : String -> Attribute msg
    class name =
        attribute "class" name

Read more about the difference between properties and attributes [here].

[here]: https://github.com/elm-lang/html/blob/master/properties-vs-attributes.md

-}
attribute : String -> String -> Attribute msg
attribute =
    Html.Types.Attribute


{-| Transform the messages produced by an `Attribute`.
-}
map : (a -> msg) -> Attribute a -> Attribute msg
map =
    Html.Types.mapAttribute



-- GLOBAL ATTRIBUTES


{-| Often used with CSS to style elements with common properties.
-}
class : String -> Attribute msg
class className =
    stringProperty "className" className


{-| Indicates the relevance of an element.
-}
hidden : Bool -> Attribute msg
hidden bool =
    boolProperty "hidden" bool


{-| Often used with CSS to style a specific element. The val of this
attribute must be unique.
-}
id : String -> Attribute msg
id val =
    stringProperty "id" val


{-| Text to be displayed in a tooltip when hovering over the element.
-}
title : String -> Attribute msg
title val =
    stringProperty "title" val



-- LESS COMMON GLOBAL ATTRIBUTES


{-| Defines a keyboard shortcut to activate or add focus to the element.
-}
accesskey : Char -> Attribute msg
accesskey char =
    stringProperty "accessKey" (String.fromChar char)


{-| Indicates whether the element's content is editable.
-}
contenteditable : Bool -> Attribute msg
contenteditable bool =
    boolProperty "contentEditable" bool


{-| Defines the ID of a `menu` element which will serve as the element's
context menu.
-}
contextmenu : String -> Attribute msg
contextmenu val =
    attribute "contextmenu" val


{-| Defines the text direction. Allowed vals are ltr (Left-To-Right) or rtl
(Right-To-Left).
-}
dir : String -> Attribute msg
dir val =
    stringProperty "dir" val


{-| Defines whether the element can be dragged.
-}
draggable : String -> Attribute msg
draggable val =
    attribute "draggable" val


{-| Indicates that the element accept the dropping of content on it.
-}
dropzone : String -> Attribute msg
dropzone val =
    stringProperty "dropzone" val


{-| -}
itemprop : String -> Attribute msg
itemprop val =
    attribute "itemprop" val


{-| Defines the language used in the element.
-}
lang : String -> Attribute msg
lang val =
    stringProperty "lang" val


{-| Indicates whether spell checking is allowed for the element.
-}
spellcheck : Bool -> Attribute msg
spellcheck bool =
    boolProperty "spellcheck" bool


{-| Overrides the browser's default tab order and follows the one specified
instead.
-}
tabindex : Int -> Attribute msg
tabindex n =
    attribute "tabIndex" (String.fromInt n)



-- EMBEDDED CONTENT


{-| The URL of the embeddable content. For `audio`, `embed`, `iframe`, `img`,
`input`, `script`, `source`, `track`, and `video`.
-}
src : String -> Attribute msg
src val =
    stringProperty "src" val


{-| Declare the height of a `canvas`, `embed`, `iframe`, `img`, `input`,
`object`, or `video`.
-}
height : Int -> Attribute msg
height val =
    attribute "height" (String.fromInt val)


{-| Declare the width of a `canvas`, `embed`, `iframe`, `img`, `input`,
`object`, or `video`.
-}
width : Int -> Attribute msg
width val =
    attribute "width" (String.fromInt val)


{-| Alternative text in case an image can't be displayed. Works with `img`,
`area`, and `input`.
-}
alt : String -> Attribute msg
alt val =
    stringProperty "alt" val



-- AUDIO and VIDEO


{-| The `audio` or `video` should play as soon as possible.
-}
autoplay : Bool -> Attribute msg
autoplay bool =
    boolProperty "autoplay" bool


{-| Indicates whether the browser should show playback controls for the `audio`
or `video`.
-}
controls : Bool -> Attribute msg
controls bool =
    boolProperty "controls" bool


{-| Indicates whether the `audio` or `video` should start playing from the
start when it's finished.
-}
loop : Bool -> Attribute msg
loop bool =
    boolProperty "loop" bool


{-| Control how much of an `audio` or `video` resource should be preloaded.
-}
preload : String -> Attribute msg
preload val =
    stringProperty "preload" val


{-| A URL indicating a poster frame to show until the user plays or seeks the
`video`.
-}
poster : String -> Attribute msg
poster val =
    stringProperty "poster" val


{-| Indicates that the `track` should be enabled unless the user's preferences
indicate something different.
-}
default : Bool -> Attribute msg
default bool =
    boolProperty "default" bool


{-| Specifies the kind of text `track`.
-}
kind : String -> Attribute msg
kind val =
    stringProperty "kind" val



{--TODO: maybe reintroduce once there's a better way to disambiguate imports
{-| Specifies a user-readable title of the text `track`. -}
label : String -> Attribute msg
label val =
  stringProperty "label" val
--}


{-| A two letter language code indicating the language of the `track` text data.
-}
srclang : String -> Attribute msg
srclang val =
    stringProperty "srclang" val



-- IFRAMES


{-| A space separated list of security restrictions you'd like to lift for an
`iframe`.
-}
sandbox : String -> Attribute msg
sandbox val =
    stringProperty "sandbox" val


{-| An HTML document that will be displayed as the body of an `iframe`. It will
override the content of the `src` attribute if it has been specified.
-}
srcdoc : String -> Attribute msg
srcdoc val =
    stringProperty "srcdoc" val



-- INPUT


{-| Defines the type of a `button`, `input`, `embed`, `object`, `script`,
`source`, `style`, or `menu`.
-}
type_ : String -> Attribute msg
type_ val =
    stringProperty "type" val


{-| Defines a default val which will be displayed in a `button`, `option`,
`input`, `li`, `meter`, `progress`, or `param`.
-}
value : String -> Attribute msg
value val =
    stringProperty "value" val


{-| Indicates whether an `input` of type checkbox is checked.
-}
checked : Bool -> Attribute msg
checked bool =
    boolProperty "checked" bool


{-| Provides a hint to the user of what can be entered into an `input` or
`textarea`.
-}
placeholder : String -> Attribute msg
placeholder val =
    stringProperty "placeholder" val


{-| Defines which `option` will be selected on page load.
-}
selected : Bool -> Attribute msg
selected bool =
    boolProperty "selected" bool



-- INPUT HELPERS


{-| List of types the server accepts, typically a file type.
For `form` and `input`.
-}
accept : String -> Attribute msg
accept val =
    stringProperty "accept" val


{-| List of supported charsets in a `form`.
-}
acceptCharset : String -> Attribute msg
acceptCharset val =
    stringProperty "acceptCharset" val


{-| The URI of a program that processes the information submitted via a `form`.
-}
action : String -> Attribute msg
action val =
    stringProperty "action" val


{-| Indicates whether a `form` or an `input` can have their vals automatically
completed by the browser.
-}
autocomplete : Bool -> Attribute msg
autocomplete bool =
    stringProperty "autocomplete"
        (if bool then
            "on"

         else
            "off"
        )


{-| The element should be automatically focused after the page loaded.
For `button`, `input`, `keygen`, `select`, and `textarea`.
-}
autofocus : Bool -> Attribute msg
autofocus bool =
    boolProperty "autofocus" bool


{-| Indicates whether the user can interact with a `button`, `fieldset`,
`input`, `keygen`, `optgroup`, `option`, `select` or `textarea`.
-}
disabled : Bool -> Attribute msg
disabled bool =
    boolProperty "disabled" bool


{-| How `form` data should be encoded when submitted with the POST method.
Options include: application/x-www-form-urlencoded, multipart/form-data, and
text/plain.
-}
enctype : String -> Attribute msg
enctype val =
    stringProperty "enctype" val


{-| Associates an `input` with a `datalist` tag. The datalist gives some
pre-defined options to suggest to the user as they interact with an input.
The val of the list attribute must match the id of a `datalist` node.
For `input`.
-}
list : String -> Attribute msg
list val =
    attribute "list" val


{-| Defines the minimum number of characters allowed in an `input` or
`textarea`.
-}
minlength : Int -> Attribute msg
minlength n =
    attribute "minLength" (String.fromInt n)


{-| Defines the maximum number of characters allowed in an `input` or
`textarea`.
-}
maxlength : Int -> Attribute msg
maxlength n =
    attribute "maxlength" (String.fromInt n)


{-| Defines which HTTP method to use when submitting a `form`. Can be GET
(default) or POST.
-}
method : String -> Attribute msg
method val =
    stringProperty "method" val


{-| Indicates whether multiple vals can be entered in an `input` of type
email or file. Can also indicate that you can `select` many options.
-}
multiple : Bool -> Attribute msg
multiple bool =
    boolProperty "multiple" bool


{-| Name of the element. For example used by the server to identify the fields
in form submits. For `button`, `form`, `fieldset`, `iframe`, `input`, `keygen`,
`object`, `output`, `select`, `textarea`, `map`, `meta`, and `param`.
-}
name : String -> Attribute msg
name val =
    stringProperty "name" val


{-| This attribute indicates that a `form` shouldn't be validated when
submitted.
-}
novalidate : Bool -> Attribute msg
novalidate bool =
    boolProperty "noValidate" bool


{-| Defines a regular expression which an `input`'s val will be validated
against.
-}
pattern : String -> Attribute msg
pattern val =
    stringProperty "pattern" val


{-| Indicates whether an `input` or `textarea` can be edited.
-}
readonly : Bool -> Attribute msg
readonly bool =
    boolProperty "readOnly" bool


{-| Indicates whether this element is required to fill out or not.
For `input`, `select`, and `textarea`.
-}
required : Bool -> Attribute msg
required bool =
    boolProperty "required" bool


{-| For `input` specifies the width of an input in characters.

For `select` specifies the number of visible options in a drop-down list.

-}
size : Int -> Attribute msg
size n =
    attribute "size" (String.fromInt n)


{-| The element ID described by this `label` or the element IDs that are used
for an `output`.
-}
for : String -> Attribute msg
for val =
    stringProperty "htmlFor" val


{-| Indicates the element ID of the `form` that owns this particular `button`,
`fieldset`, `input`, `keygen`, `label`, `meter`, `object`, `output`,
`progress`, `select`, or `textarea`.
-}
form : String -> Attribute msg
form val =
    attribute "form" val



-- RANGES


{-| Indicates the maximum val allowed. When using an input of type number or
date, the max val must be a number or date. For `input`, `meter`, and `progress`.
-}
max : String -> Attribute msg
max val =
    stringProperty "max" val


{-| Indicates the minimum val allowed. When using an input of type number or
date, the min val must be a number or date. For `input` and `meter`.
-}
min : String -> Attribute msg
min val =
    stringProperty "min" val


{-| Add a step size to an `input`. Use `step "any"` to allow any floating-point
number to be used in the input.
-}
step : String -> Attribute msg
step n =
    stringProperty "step" n



--------------------------


{-| Defines the number of columns in a `textarea`.
-}
cols : Int -> Attribute msg
cols n =
    attribute "cols" (String.fromInt n)


{-| Defines the number of rows in a `textarea`.
-}
rows : Int -> Attribute msg
rows n =
    attribute "rows" (String.fromInt n)


{-| Indicates whether the text should be wrapped in a `textarea`. Possible
vals are "hard" and "soft".
-}
wrap : String -> Attribute msg
wrap val =
    stringProperty "wrap" val



-- MAPS


{-| When an `img` is a descendent of an `a` tag, the `ismap` attribute
indicates that the click location should be added to the parent `a`'s href as
a query string.
-}
ismap : Bool -> Attribute msg
ismap val =
    boolProperty "isMap" val


{-| Specify the hash name reference of a `map` that should be used for an `img`
or `object`. A hash name reference is a hash symbol followed by the element's name or id.
E.g. `"#planet-map"`.
-}
usemap : String -> Attribute msg
usemap val =
    stringProperty "useMap" val


{-| Declare the shape of the clickable area in an `a` or `area`. Valid vals
include: default, rect, circle, poly. This attribute can be paired with
`coords` to create more particular shapes.
-}
shape : String -> Attribute msg
shape val =
    stringProperty "shape" val


{-| A set of vals specifying the coordinates of the hot-spot region in an
`area`. Needs to be paired with a `shape` attribute to be meaningful.
-}
coords : String -> Attribute msg
coords val =
    stringProperty "coords" val



-- REAL STUFF


{-| Specifies the horizontal alignment of a `caption`, `col`, `colgroup`,
`hr`, `iframe`, `img`, `table`, `tbody`, `td`, `tfoot`, `th`, `thead`, or
`tr`.
-}
align : String -> Attribute msg
align val =
    stringProperty "align" val


{-| Contains a URI which points to the source of the quote or change in a
`blockquote`, `del`, `ins`, or `q`.
-}
cite : String -> Attribute msg
cite val =
    stringProperty "cite" val



-- LINKS AND AREAS


{-| The URL of a linked resource, such as `a`, `area`, `base`, or `link`.
-}
href : String -> Attribute msg
href val =
    stringProperty "href" val


{-| Specify where the results of clicking an `a`, `area`, `base`, or `form`
should appear. Possible special vals include:

  - \_blank &mdash; a new window or tab
  - \_self &mdash; the same frame (this is default)
  - \_parent &mdash; the parent frame
  - \_top &mdash; the full body of the window

You can also give the name of any `frame` you have created.

-}
target : String -> Attribute msg
target val =
    stringProperty "target" val


{-| Indicates that clicking an `a` and `area` will download the resource
directly.
-}
download : String -> Attribute msg
download val =
    stringProperty "download" val


{-| Two-letter language code of the linked resource of an `a`, `area`, or `link`.
-}
hreflang : String -> Attribute msg
hreflang val =
    stringProperty "hreflang" val


{-| Specifies a hint of the target media of a `a`, `area`, `link`, `source`,
or `style`.
-}
media : String -> Attribute msg
media val =
    attribute "media" val


{-| Specify a URL to send a short POST request to when the user clicks on an
`a` or `area`. Useful for monitoring and tracking.
-}
ping : String -> Attribute msg
ping val =
    stringProperty "ping" val


{-| Specifies the relationship of the target object to the link object.
For `a`, `area`, `link`.
-}
rel : String -> Attribute msg
rel val =
    attribute "rel" val



-- CRAZY STUFF


{-| Indicates the date and time associated with the element.
For `del`, `ins`, `time`.
-}
datetime : String -> Attribute msg
datetime val =
    attribute "datetime" val


{-| Indicates whether this date and time is the date of the nearest `article`
ancestor element. For `time`.
-}
pubdate : String -> Attribute msg
pubdate val =
    attribute "pubdate" val



-- ORDERED LISTS


{-| Indicates whether an ordered list `ol` should be displayed in a descending
order instead of a ascending.
-}
reversed : Bool -> Attribute msg
reversed bool =
    boolProperty "reversed" bool


{-| Defines the first number of an ordered list if you want it to be something
besides 1.
-}
start : Int -> Attribute msg
start n =
    stringProperty "start" (String.fromInt n)



-- TABLES


{-| The colspan attribute defines the number of columns a cell should span.
For `td` and `th`.
-}
colspan : Int -> Attribute msg
colspan n =
    attribute "colspan" (String.fromInt n)


{-| A space separated list of element IDs indicating which `th` elements are
headers for this cell. For `td` and `th`.
-}
headers : String -> Attribute msg
headers val =
    stringProperty "headers" val


{-| Defines the number of rows a table cell should span over.
For `td` and `th`.
-}
rowspan : Int -> Attribute msg
rowspan n =
    attribute "rowspan" (String.fromInt n)


{-| Specifies the scope of a header cell `th`. Possible vals are: col, row,
colgroup, rowgroup.
-}
scope : String -> Attribute msg
scope val =
    stringProperty "scope" val


{-| Specifies the URL of the cache manifest for an `html` tag.
-}
manifest : String -> Attribute msg
manifest val =
    attribute "manifest" val
