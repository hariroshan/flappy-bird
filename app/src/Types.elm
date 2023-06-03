module Types exposing (..)

import Json.Encode as E


type alias Arcade =
    { gravity :
        { y : Int
        }
    , debug : Bool
    }


type alias Physics =
    { default : String
    , arcade : Arcade
    }


type alias PhaserConfig =
    { width : Int
    , height : Int
    , preventLoop : Bool
    , physics : Physics
    }


encodePhaserConfig : PhaserConfig -> E.Value
encodePhaserConfig config =
    E.object
        [ ( "width", E.int config.width )
        , ( "height", E.int config.height )
        , ( "preventLoop", E.bool config.preventLoop )
        , ( "physics", encodePhysics config.physics )
        ]


encodePhysics : Physics -> E.Value
encodePhysics physics =
    E.object
        [ ( "default", E.string physics.default )
        , ( "arcade", encodeArcade physics.arcade )
        ]


encodeArcade : Arcade -> E.Value
encodeArcade arcade =
    E.object
        [ ( "gravity", E.object [ ( "y", E.int arcade.gravity.y ) ] )
        , ( "debug", E.bool arcade.debug )
        ]
