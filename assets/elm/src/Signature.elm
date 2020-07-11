module Signature exposing (Signature, Msg(..), init, isEmpty, isPresent, output, update, view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes
import Html.Events.Extra.Mouse as Mouse
import List.Extra exposing (groupsOf)
import Svg exposing (Svg)
import Svg.Attributes


type Msg
    = Down Mouse.Event
    | Move Mouse.Event
    | Up Mouse.Event


type DrawnLine
    = None
    | Line Int


type alias ContinousLine =
    List Position


type alias Position =
    ( Float, Float )


type alias Signature =
    { currentlyDrawnLine : DrawnLine
    , continuousLines : Array ContinousLine
    }


width : Int
width =
    600


height : Int
height =
    200


widthString : String
widthString =
    String.fromInt width


heightString : String
heightString =
    String.fromInt height


init : Signature
init =
    { currentlyDrawnLine = None
    , continuousLines = Array.fromList []
    }


isPresent : Signature -> Bool
isPresent model =
    not (isEmpty model)


isEmpty : Signature -> Bool
isEmpty model =
    Array.isEmpty model.continuousLines


update : Msg -> Signature -> Signature
update msg model =
    case msg of
        Down _ ->
            { model | currentlyDrawnLine = Line (Array.length model.continuousLines) }

        Up _ ->
            { model | currentlyDrawnLine = None }

        Move event ->
            case model.currentlyDrawnLine of
                None ->
                    model

                Line number ->
                    { model
                        | continuousLines =
                            updateContinousLines
                                number
                                event.offsetPos
                                model.continuousLines
                    }


updateContinousLines : Int -> Position -> Array ContinousLine -> Array ContinousLine
updateContinousLines number offsetPos lines =
    case Array.get number lines of
        Nothing ->
            Array.push [ offsetPos ] lines

        Just line ->
            Array.set number (offsetPos :: line) lines


view : Signature -> Html Msg
view model =
    Html.div
        [ Mouse.onDown Down
        , Mouse.onMove Move
        , Mouse.onUp Up
        , Html.Attributes.style "width" (widthString ++ "px")
        , Html.Attributes.style "height" (heightString ++ "px")
        , Html.Attributes.style "background-color" "grey"
        ]
        [ output model ]


output : Signature -> Html Msg
output model =
    Svg.svg
        [ Svg.Attributes.width widthString
        , Svg.Attributes.height heightString
        , Svg.Attributes.viewBox ("0 0 " ++ widthString ++ " " ++ heightString)
        ]
        (List.concatMap continousLineToSvg (Array.toList model.continuousLines))


continousLineToSvg : ContinousLine -> List (Svg Msg)
continousLineToSvg positions =
    let
        firstSetOfPairs =
            positions
                |> groupsOf 2

        secondSetOfPairs =
            positions
                |> List.drop 1
                |> groupsOf 2
    in
    firstSetOfPairs
        ++ secondSetOfPairs
        |> List.filterMap positionPairToLine


positionPairToLine : List Position -> Maybe (Svg Msg)
positionPairToLine positions =
    case positions of
        [ startPosition, endPosition ] ->
            Svg.line
                [ Svg.Attributes.x1 (String.fromFloat (Tuple.first startPosition))
                , Svg.Attributes.y1 (String.fromFloat (Tuple.second startPosition))
                , Svg.Attributes.x2 (String.fromFloat (Tuple.first endPosition))
                , Svg.Attributes.y2 (String.fromFloat (Tuple.second endPosition))
                , lineStyle
                ]
                []
                |> Just

        _ ->
            Nothing


lineStyle : Svg.Attribute Msg
lineStyle =
    Svg.Attributes.style "stroke: rgb(100, 100, 100); stroke-width: 2"
