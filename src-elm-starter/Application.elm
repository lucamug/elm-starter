module Application exposing (main)

import Browser
import Html
import Html.Attributes
import Json.Encode
import Starter.Conf


type Msg
    = OnUrlRequest
    | OnUrlChange


type alias Flags =
    ()


type alias Model =
    ()


view : Model -> { body : List (Html.Html msg), title : String }
view _ =
    { title = "title"
    , body =
        [ Html.div [ Html.Attributes.style "margin" "40px" ]
            [ Html.h1 [] [ Html.text "elm-starter configuration" ]
            , Html.pre
                []
                [ Html.text <|
                    Json.Encode.encode 4 <|
                        Starter.Conf.conf
                            -- From package.jspn
                            { name = "NOT-AVAILABLE [name]"
                            , nameLong = "NOT-AVAILABLE [nameLong]"
                            , description = "NOT-AVAILABLE [description]"
                            , author = "NOT-AVAILABLE [author]"
                            , version = "NOT-AVAILABLE [version]"
                            , homepage = "http://example.com/xxx/yyy"
                            , license = "NOT-AVAILABLE [license]"
                            , twitterSite = Just "NOT-AVAILABLE [twitterSite]"
                            , twitterAuthor = Just "NOT-AVAILABLE [twitterAuthor]"
                            , snapshotWidth = Just "NOT-AVAILABLE [snapshotWidth]"
                            , snapshotHeight = Just "NOT-AVAILABLE [snapshotHeight]"
                            , themeColor = Nothing

                            -- From Git
                            , commit = "NOT-AVAILABLE [commit]"
                            , branch = "NOT-AVAILABLE [branch]"

                            -- From starter.js
                            , env = "NOT-AVAILABLE [env]"
                            , dirPw = "NOT-AVAILABLE [dirPw]"
                            , dirBin = "NOT-AVAILABLE [dirBin]"
                            , dirIgnoredByGit = "NOT-AVAILABLE [dirIgnoredByGit]"
                            , dirTemp = "NOT-AVAILABLE [dirTemp]"
                            , fileElmWorker = "NOT-AVAILABLE [fileElmWorker]"
                            }
                ]
            ]
        ]
    }


main : Program Flags Model Msg
main =
    Browser.application
        { init = \_ _ _ -> ( (), Cmd.none )
        , view = view
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = \_ -> OnUrlRequest
        , onUrlChange = \_ -> OnUrlChange
        }
