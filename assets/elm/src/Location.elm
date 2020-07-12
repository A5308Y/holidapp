port module Location exposing
    ( CityData
    , GeneratedData(..)
    , Location(..)
    , Msg
    , cityDataDecoder
    , coordinateReceiver
    , init
    , inputForm
    , locationBlockedReceiver
    , name
    , nextCommand
    , stateShortHand
    , stateShortHandString
    , statusColumn
    , subscriptions
    , update
    , updateGeneratedCityData
    , updateGeneratedCoordinates
    )

import CommonStyles
import Element exposing (Element)
import Element.Font
import Element.Input
import Http
import Json.Decode
import StateShorthand exposing (StateShorthand)
import StatusBar
import Url.Builder


port coordinateReceiver : (( Float, Float ) -> msg) -> Sub msg


port locationBlockedReceiver : (Bool -> msg) -> Sub msg


port requestCoordinates : Bool -> Cmd msg


type Msg
    = CityDataReceived (Result Http.Error CityData)
    | LocationCoordinatesReceived Coordinates
    | LocationBlockReceived Bool
    | CharacterEnteredForCityName String
    | StateShorthandSelected StateShorthand
    | LocationEntryConfirmed Bool
    | BackendUserLocationReceived (Result Http.Error String)


type Location
    = Location LocationData


type GeneratedData
    = UnknownLocation
    | Blocked
    | Failure String
    | CoordinatesKnown Coordinates
    | Complete FullData


type alias LocationData =
    { manualData : ManualLocationData
    , generatedData : GeneratedData
    , openCageDataApiKey : String
    , fetchedUserLocation : String
    }


init : String -> Location
init openCageDataApiKey =
    Location
        { manualData = emptyManualLocationData
        , generatedData = UnknownLocation
        , openCageDataApiKey = openCageDataApiKey
        , fetchedUserLocation = ""
        }


type alias CityData =
    { city : String
    , state : String
    }


type alias Coordinates =
    ( Float, Float )


type alias FullData =
    { city : String
    , stateShorthand : StateShorthand
    , state : String
    , coordinates : Coordinates
    }


type alias ManualLocationData =
    { city : Maybe String
    , stateShorthand : Maybe StateShorthand
    , isConfirmed : Bool
    }


emptyManualLocationData : ManualLocationData
emptyManualLocationData =
    ManualLocationData Nothing Nothing False


update : Msg -> Location -> Location
update msg ((Location locationData) as location) =
    case msg of
        LocationEntryConfirmed bool ->
            let
                manualData =
                    locationData.manualData

                updatedManualData =
                    { manualData | isConfirmed = bool }
            in
            Location { locationData | manualData = updatedManualData }

        LocationCoordinatesReceived coordinates ->
            updateGeneratedCoordinates coordinates location

        LocationBlockReceived _ ->
            Location { locationData | generatedData = Blocked }

        CharacterEnteredForCityName cityName ->
            let
                manualData =
                    locationData.manualData

                updatedManualData =
                    { manualData | city = Just cityName }
            in
            Location { locationData | manualData = updatedManualData }

        StateShorthandSelected stateShorthand ->
            let
                manualData =
                    locationData.manualData

                updatedManualData =
                    { manualData | stateShorthand = Just stateShorthand }
            in
            Location { locationData | manualData = updatedManualData }

        CityDataReceived cityDataResult ->
            case cityDataResult of
                Ok cityData ->
                    updateGeneratedCityData cityData location

                Err message ->
                    let
                        _ =
                            Debug.log "Failure fetching city data" message
                    in
                    Location locationData

        BackendUserLocationReceived result ->
            case result of
                Ok string ->
                    Location { locationData | fetchedUserLocation = string }

                Err _ ->
                    location


fetchBackendUserLocation =
    Http.get
        { url = "/location"
        , expect = Http.expectString BackendUserLocationReceived
        }


nextCommand : Location -> Cmd Msg
nextCommand (Location locationData) =
    case locationData.generatedData of
        UnknownLocation ->
            Cmd.batch [ requestCoordinates True, fetchBackendUserLocation ]

        CoordinatesKnown ( latitude, longitude ) ->
            Http.get
                { url = openCageDataUrl locationData.openCageDataApiKey latitude longitude
                , expect = Http.expectJson CityDataReceived cityDataDecoder
                }

        Blocked ->
            Cmd.none

        Complete _ ->
            Cmd.none

        Failure _ ->
            Cmd.none


openCageDataUrl : String -> Float -> Float -> String
openCageDataUrl openCageDataApiKey latitude longitude =
    Url.Builder.crossOrigin
        "https://api.opencagedata.com"
        [ "geocode", "v1", "json" ]
        [ Url.Builder.string "q" (String.fromFloat latitude ++ "," ++ String.fromFloat longitude)
        , Url.Builder.string "key" openCageDataApiKey
        ]


updateGeneratedCityData : CityData -> Location -> Location
updateGeneratedCityData cityData (Location locationData) =
    case locationData.generatedData of
        UnknownLocation ->
            Location { locationData | generatedData = Failure "Received city data without having sent coordinates. This should not be possible. Please contact support." }

        Failure message ->
            Location { locationData | generatedData = Failure ("Received city data without having sent coordinates. This should not be possible. Even worse: We somehow ended up here from a failure state: " ++ message ++ " Please contact support.") }

        Blocked ->
            Location { locationData | generatedData = Blocked }

        CoordinatesKnown coordinates ->
            case StateShorthand.fromStateName cityData.state of
                Just stateShorthand ->
                    Location
                        { locationData
                            | generatedData =
                                Complete
                                    { city = cityData.city
                                    , stateShorthand = stateShorthand
                                    , state = cityData.state
                                    , coordinates = coordinates
                                    }
                        }

                Nothing ->
                    Location { locationData | generatedData = Failure ("Couldn't resolve state name: " ++ cityData.state ++ ". This might indicate a failure in the API returning state names. Please contact support with this error messages.") }

        Complete fullData ->
            case StateShorthand.fromStateName cityData.state of
                Just stateShorthand ->
                    Location
                        { locationData
                            | generatedData =
                                Complete
                                    { fullData
                                        | city = cityData.city
                                        , stateShorthand = stateShorthand
                                        , state = cityData.state
                                    }
                        }

                Nothing ->
                    Location { locationData | generatedData = Failure ("Couldn't resolve state name: " ++ cityData.state ++ ". This might indicate a failure in the API returning state names. Please contact support with this error messages.") }


updateGeneratedCoordinates : Coordinates -> Location -> Location
updateGeneratedCoordinates newCoordinates (Location locationData) =
    case locationData.generatedData of
        Failure _ ->
            Location { locationData | generatedData = CoordinatesKnown newCoordinates }

        UnknownLocation ->
            Location { locationData | generatedData = CoordinatesKnown newCoordinates }

        CoordinatesKnown _ ->
            Location { locationData | generatedData = CoordinatesKnown newCoordinates }

        Blocked ->
            Location { locationData | generatedData = Blocked }

        Complete fullData ->
            Location
                { locationData | generatedData = Complete { fullData | coordinates = newCoordinates } }


cityDataDecoder : Json.Decode.Decoder CityData
cityDataDecoder =
    Json.Decode.map2 CityData
        (Json.Decode.at [ "results" ] (Json.Decode.index 0 (Json.Decode.at [ "components", "city" ] Json.Decode.string)))
        (Json.Decode.at [ "results" ] (Json.Decode.index 0 (Json.Decode.at [ "components", "state" ] Json.Decode.string)))


inputForm : Location -> Element Msg
inputForm (Location locationData) =
    Element.column [ Element.width Element.fill, Element.spacing 10 ]
        [ Element.el [] (Element.text "Please enter your location:")
        , Element.Input.text [ Element.width (Element.fillPortion 1 |> Element.maximum 400) ]
            { onChange = CharacterEnteredForCityName
            , text = Maybe.withDefault "" locationData.manualData.city
            , placeholder = Nothing
            , label = Element.Input.labelLeft [ Element.width (Element.fillPortion 2 |> Element.minimum 200) ] (Element.text "City")
            }
        , Element.wrappedRow [ Element.spacing 3 ]
            (List.map
                (stateShorthandButton locationData.manualData.stateShorthand)
                StateShorthand.all
            )
        ]


stateShorthandButton : Maybe StateShorthand -> StateShorthand -> Element Msg
stateShorthandButton selectedStateShorthand stateShorthand =
    let
        buttonStyle =
            case selectedStateShorthand of
                Nothing ->
                    CommonStyles.buttonStyle

                Just selectedShorthand ->
                    if selectedShorthand == stateShorthand then
                        CommonStyles.buttonStyleActive

                    else
                        CommonStyles.buttonStyle
    in
    Element.Input.button buttonStyle
        { onPress = Just (StateShorthandSelected stateShorthand)
        , label = Element.el [] (Element.text (StateShorthand.toString stateShorthand))
        }


name : Location -> String
name (Location locationData) =
    if locationData.manualData /= emptyManualLocationData then
        let
            cityName =
                Maybe.withDefault "Unknown City" locationData.manualData.city

            stateName =
                case locationData.manualData.stateShorthand of
                    Nothing ->
                        "Unknown State"

                    Just stateShorthand ->
                        StateShorthand.toStateName stateShorthand
        in
        cityName ++ " (" ++ stateName ++ ")"

    else
        case locationData.generatedData of
            UnknownLocation ->
                "Location unknown (so far)"

            Blocked ->
                "Location service not reachable."

            Failure message ->
                "Encountered an error while trying to generate automatic location data: " ++ message

            CoordinatesKnown ( latitude, longitude ) ->
                "At: (" ++ String.fromFloat latitude ++ ", " ++ String.fromFloat longitude ++ ")"

            Complete fullData ->
                fullData.city ++ " (" ++ fullData.state ++ ", " ++ StateShorthand.toString fullData.stateShorthand ++ ")"


stateShortHandString : Location -> Maybe String
stateShortHandString (Location locationData) =
    case locationData.manualData.stateShorthand of
        Just shorthand ->
            Just (StateShorthand.toString shorthand)

        Nothing ->
            case locationData.generatedData of
                Complete fullData ->
                    Just (StateShorthand.toString fullData.stateShorthand)

                _ ->
                    Nothing


stateShortHand : Location -> Maybe StateShorthand
stateShortHand (Location locationData) =
    case locationData.manualData.stateShorthand of
        Just shorthand ->
            Just shorthand

        Nothing ->
            case locationData.generatedData of
                Complete fullData ->
                    Just fullData.stateShorthand

                _ ->
                    Nothing


subscriptions : List (Sub Msg)
subscriptions =
    [ coordinateReceiver LocationCoordinatesReceived
    , locationBlockedReceiver LocationBlockReceived
    ]


statusColumn : Location -> Element Msg
statusColumn location =
    Element.column
        [ Element.spacing 20
        , Element.Font.size 12
        , Element.alignTop
        , Element.width Element.fill
        ]
        (statusElements location)


statusBar : StatusBar.Status -> String -> Element Msg
statusBar status text =
    Element.row [] [ StatusBar.view ("Location Status: " ++ text) status ]


statusElements : Location -> List (Element Msg)
statusElements ((Location locationData) as location) =
    case locationData.manualData.city of
        Just _ ->
            case locationData.manualData.stateShorthand of
                Just _ ->
                    if locationData.manualData.isConfirmed then
                        [ statusBar StatusBar.Completed ("Entered full location data: " ++ name location ++ ".")
                        , Element.Input.button CommonStyles.buttonStyle
                            { onPress = Just (LocationEntryConfirmed (not locationData.manualData.isConfirmed))
                            , label = Element.el [] (Element.text "Edit")
                            }
                        ]

                    else
                        [ statusBar StatusBar.Completed ("Entered full location data: " ++ name location ++ ".")
                        , inputForm location
                        , Element.Input.button CommonStyles.buttonStyle
                            { onPress = Just (LocationEntryConfirmed (not locationData.manualData.isConfirmed))
                            , label = Element.el [] (Element.text "Confirm")
                            }
                        ]

                Nothing ->
                    [ statusBar StatusBar.InProgress "Please select a state."
                    , inputForm location
                    ]

        Nothing ->
            case locationData.manualData.stateShorthand of
                Just _ ->
                    [ statusBar StatusBar.InProgress "Please enter a city name."
                    , inputForm location
                    ]

                Nothing ->
                    case locationData.generatedData of
                        Blocked ->
                            [ statusBar StatusBar.Error "Location service not reachable."
                            , Element.el [] (Element.text locationData.fetchedUserLocation)
                            , inputForm location
                            ]

                        UnknownLocation ->
                            [ statusBar StatusBar.InProgress "Determining Location..." ]

                        Failure _ ->
                            [ statusBar StatusBar.InProgress "Failed while determining Location." ]

                        CoordinatesKnown ( latitude, longitude ) ->
                            [ statusBar StatusBar.InProgress ("Determining city at: (" ++ String.fromFloat latitude ++ ", " ++ String.fromFloat longitude ++ ")...") ]

                        Complete _ ->
                            [ statusBar StatusBar.Completed ("Received full location data: " ++ name location ++ ".") ]
