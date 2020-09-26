port module Worker exposing (main)

import Json.Encode
import Starter.Conf
import Starter.Flags
import Starter.Model


port dataFromElmToJavascript : Json.Encode.Value -> Cmd msg


main : Program Starter.Flags.Flags Starter.Model.Model msg
main =
    Platform.worker
        { init = \flags -> ( flags, dataFromElmToJavascript (Starter.Conf.conf_ flags) )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
