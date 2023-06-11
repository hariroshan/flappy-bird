module Main exposing (main)

import Angle
import Axis3d exposing (Axis3d)
import Block3d exposing (Block3d)
import Browser
import Camera3d exposing (Camera3d)
import Color
import Cylinder3d exposing (Cylinder3d)
import Direction3d
import Frame3d
import Json.Decode as D exposing (Decoder)
import Length exposing (Meters, meters, millimeters)
import Native exposing (Native)
import Native.Attributes as NA
import Native.Event as Ev
import Native.Frame as Frame
import Native.Layout as Layout
import Native.Page as Page
import Physics.Body as Body exposing (Body)
import Physics.Coordinates exposing (BodyCoordinates, WorldCoordinates)
import Physics.World as World exposing (World)
import Pixels exposing (Pixels, pixels)
import Point2d
import Point3d
import Quantity exposing (Quantity)
import Rectangle2d
import Scene3d exposing (Entity)
import Scene3d.Material as Material
import Sphere3d exposing (Sphere3d)
import Viewpoint3d


type Id
    = Cylinder
    | Block
    | Sphere
    | Floor


type alias Flags =
    { width : Float
    , height : Float
    }


type NavPage
    = HomePage


type alias Model =
    { rootFrame : Frame.Model NavPage
    , screenDimension :
        { width : Quantity Float Pixels
        , height : Quantity Float Pixels
        }
    , selection : Maybe Id
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { rootFrame = Frame.init HomePage
      , screenDimension =
            { width = pixels flags.width
            , height = pixels flags.height
            }
      , selection = Nothing
      }
    , Cmd.none
    )


type Msg
    = SyncFrame Bool
    | Tapped (Axis3d Meters WorldCoordinates)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SyncFrame bool ->
            ( { model | rootFrame = Frame.handleBack bool model.rootFrame }, Cmd.none )

        Tapped ray ->
            ( { model
                | selection =
                    World.raycast ray world
                        |> Maybe.map (\{ body } -> Body.data body)
              }
            , Cmd.none
              -- model.screenDimension
            )


world : World Id
world =
    World.empty
        |> World.add (Body.block floor Floor |> Body.moveTo (Point3d.millimeters 0 0 -5))
        |> World.add (Body.block block Block |> Body.moveTo (Point3d.meters -1 -1 0))
        |> World.add (Body.sphere sphere Sphere |> Body.moveTo (Point3d.meters 0 1.5 0))
        |> World.add (Body.cylinder cylinder Cylinder |> Body.moveTo (Point3d.meters 1.5 0 0))


floor : Block3d Meters BodyCoordinates
floor =
    Block3d.centeredOn Frame3d.atOrigin
        ( meters 5, meters 5, millimeters 10 )


block : Block3d Meters BodyCoordinates
block =
    Block3d.from
        (Point3d.meters -0.5 -0.5 0)
        (Point3d.meters 0.5 0.5 1.5)


sphere : Sphere3d Meters BodyCoordinates
sphere =
    Sphere3d.atPoint (Point3d.meters 0 0 0.5)
        (meters 0.5)


cylinder : Cylinder3d Meters BodyCoordinates
cylinder =
    Cylinder3d.startingAt Point3d.origin
        Direction3d.z
        { radius = meters 0.5
        , length = meters 1.5
        }


camera : Camera3d Meters WorldCoordinates
camera =
    Camera3d.perspective
        { viewpoint =
            Viewpoint3d.lookAt
                { eyePoint = Point3d.meters 5 6 4
                , focalPoint = Point3d.meters -0.5 -0.5 0
                , upDirection = Direction3d.positiveZ
                }
        , verticalFieldOfView = Angle.degrees 24
        }


bodyToEntity : Maybe Id -> Body Id -> Entity WorldCoordinates
bodyToEntity selection body =
    let
        id =
            Body.data body

        frame =
            Body.frame body

        color defaultColor =
            if selection == Just id then
                Color.white

            else
                defaultColor

        entity =
            case id of
                Floor ->
                    Scene3d.block
                        (Material.matte (color Color.darkCharcoal))
                        floor

                Block ->
                    Scene3d.blockWithShadow
                        (Material.nonmetal
                            { baseColor = color Color.red
                            , roughness = 0.25
                            }
                        )
                        block

                Sphere ->
                    Scene3d.sphereWithShadow
                        (Material.nonmetal
                            { baseColor = color Color.yellow
                            , roughness = 0.25
                            }
                        )
                        sphere

                Cylinder ->
                    Scene3d.cylinderWithShadow
                        (Material.nonmetal
                            { baseColor = color Color.blue
                            , roughness = 0.25
                            }
                        )
                        cylinder
    in
    Scene3d.placeIn frame entity


homePage : Model -> Native Msg
homePage model =
    Page.page
        SyncFrame
        []
        (Layout.stackLayout
            [ Ev.onEventWith "touch"
                { methodCalls = [ "getX", "getY" ]
                , setters = []
                }
                (decodeMouseRay camera model.screenDimension.width model.screenDimension.height Tapped)
            ]
            [ Scene3d.sunny
                { upDirection = Direction3d.z
                , sunlightDirection = Direction3d.xyZ (Angle.degrees 135) (Angle.degrees -60)
                , shadows = True
                , camera = camera
                , dimensions =
                    ( Pixels.int (round (Pixels.toFloat model.screenDimension.width))
                    , Pixels.int (round (Pixels.toFloat model.screenDimension.height))
                    )
                , background = Scene3d.transparentBackground
                , clipDepth = Length.meters 0.1
                , entities = List.map (bodyToEntity model.selection) (World.bodies world)
                }

            -- lazy3 node
            -- "elm-canvas"
            -- [ model.screenDimension.height |> NA.height
            -- ,  |> NA.width
            -- , NA.borderColor "red"
            -- , NA.borderWidth "1"
            -- ]
            -- []
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


decodeMouseRay :
    Camera3d Meters WorldCoordinates
    -> Quantity Float Pixels
    -> Quantity Float Pixels
    -> (Axis3d Meters WorldCoordinates -> msg)
    -> Decoder msg
decodeMouseRay camera3d width height rayToMsg =
    D.map2
        (\x y ->
            rayToMsg
                (Camera3d.ray
                    camera3d
                    (Rectangle2d.with
                        { x1 = pixels 0
                        , y1 = height
                        , x2 = width
                        , y2 = pixels 0
                        }
                    )
                    (Point2d.pixels x y)
                )
        )
        (D.at [ "custom", "getX" ] D.float)
        (D.at [ "custom", "getY" ] D.float)
