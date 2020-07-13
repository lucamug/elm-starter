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
                            { dirPw = "dirPw"
                            , dirBin = "dirBin"
                            , dirIgnoredByGit = "dirIgnoredByGit"
                            , dirTemp = "dirTemp"
                            , fileElmWorker = "fileElmWorker"
                            , gitCommit = "NOT-AVAILABLE"
                            , gitBranch = "NOT-AVAILABLE"
                            , env = "NOT-AVAILABLE"
                            , version = "NOT-AVAILABLE"
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
