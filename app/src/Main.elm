module Main exposing (main)

import Browser
import Html exposing (node)
import Html.Lazy exposing (lazy3)
import Json.Decode as D
import Native exposing (Native)
import Native.Attributes as NA
import Native.Event as Ev
import Native.Frame as Frame
import Native.Layout as Layout
import Native.Page as Page
import PhaserTask
import Task
import TaskPort
import Types exposing (..)


buildPhaserConfig : Flags -> PhaserConfig
buildPhaserConfig flags =
    { width = flags.width
    , height = flags.height
    , preventLoop = True
    , physics =
        { default = "arcade"
        , arcade =
            { gravity =
                { y = 300
                }
            , debug = False
            }
        }
    }


type alias Flags =
    { width : Int
    , height : Int
    }


type NavPage
    = HomePage


type alias Model =
    { rootFrame : Frame.Model NavPage
    , screenDimension : Flags
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { rootFrame = Frame.init HomePage
      , screenDimension = flags
      }
    , Cmd.none
    )


type Msg
    = SyncFrame Bool
    | Ready
    | InitializedPhaser (TaskPort.Result ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SyncFrame bool ->
            ( { model | rootFrame = Frame.handleBack bool model.rootFrame }, Cmd.none )

        Ready ->
            ( model
            , model.screenDimension
                |> buildPhaserConfig
                |> PhaserTask.initialize
                |> Task.attempt InitializedPhaser
            )

        InitializedPhaser result ->
            let
                _ =
                    result |> Debug.log "RESL"
            in
            ( model, Cmd.none )


homePage : Model -> Native Msg
homePage model =
    Page.page
        SyncFrame
        []
        (Layout.stackLayout []
            [ lazy3 node
                "ns-canvas"
                [ model.screenDimension.height |> String.fromInt |> NA.height
                , model.screenDimension.width |> String.fromInt |> NA.width
                , NA.borderColor "red"
                , NA.borderWidth "1"
                , Ev.on "ready" (D.succeed Ready)
                ]
                []
            ]
        )


getPage : Model -> NavPage -> Native Msg
getPage model page =
    case page of
        HomePage ->
            homePage model


view : Model -> Native Msg
view model =
    model.rootFrame
        |> Frame.view [] (getPage model)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
