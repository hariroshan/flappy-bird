module PhaserTask exposing (..)

import TaskPort exposing (Task, call, ignoreValue)
import Types exposing (..)


initialize : PhaserConfig -> Task ()
initialize =
    call
        { function = "initialize"
        , valueDecoder = ignoreValue
        , argsEncoder = encodePhaserConfig
        }
