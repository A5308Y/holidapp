module Main exposing (main)

import Browser
import CommonStyles
import Element exposing (Element)
import Element.Font
import Element.Input
import Form exposing (Form(..))
import Html exposing (Html)
import Http
import HttpHelper
import Location exposing (GeneratedData(..), Location)
import RemoteData exposing (WebData)
import StatusBar
import Task
import Time
import VacationDays exposing (VacationDays)


type alias Model =
    { form : Form
    , currentTime : Maybe Time.Posix
    , timeZone : Maybe Time.Zone
    , location : Location
    , vacationDays : WebData VacationDays
    , isVacationDaysConfirmed : Bool -- Needs to be in vacationDays and unconfirmed if changed
    }


type Msg
    = CurrentTimeReceived Time.Posix
    | CurrentTimeZoneReceived Time.Zone
    | VacationDaysReceived (Result Http.Error VacationDays)
    | FormMsg Form.Msg
    | LocationMsg Location.Msg
    | VacationDaysConfirmed Bool


main : Program () Model Msg
main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { form = Form.init
      , currentTime = Nothing
      , location = Location.init
      , vacationDays = RemoteData.NotAsked
      , timeZone = Nothing
      , isVacationDaysConfirmed = False
      }
    , Cmd.batch
        [ Task.perform CurrentTimeZoneReceived Time.here
        , Task.perform CurrentTimeReceived Time.now
        , Cmd.map LocationMsg (Location.nextCommand Location.init)
        ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        ([ Sub.map FormMsg (Form.datePickerSubscription model.form)
         , Time.every (60 * 60 * 1000) CurrentTimeReceived
         ]
            ++ List.map (Sub.map LocationMsg) Location.subscriptions
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg formMsg ->
            ( { model | form = Form.update formMsg model.form }, Cmd.none )

        VacationDaysConfirmed bool ->
            ( { model | isVacationDaysConfirmed = bool }, Cmd.none )

        LocationMsg locationMsg ->
            let
                updatedLocation =
                    Location.update locationMsg model.location
            in
            ( { model | location = updatedLocation }
            , Cmd.batch
                [ Cmd.map LocationMsg (Location.nextCommand updatedLocation)
                , case Location.stateShortHand updatedLocation of
                    Nothing ->
                        Cmd.none

                    Just stateShortHand ->
                        VacationDays.fetch
                            (Time.toYear (Maybe.withDefault Time.utc model.timeZone) (Maybe.withDefault (Time.millisToPosix 0) model.currentTime))
                            stateShortHand
                            VacationDaysReceived
                ]
            )

        CurrentTimeZoneReceived newZone ->
            ( { model | timeZone = Just newZone }, Cmd.none )

        CurrentTimeReceived newTime ->
            ( { model | currentTime = Just newTime }, Cmd.none )

        VacationDaysReceived vacationDaysResult ->
            case vacationDaysResult of
                Err httpError ->
                    ( { model | vacationDays = RemoteData.Failure httpError }, Cmd.none )

                Ok vacationDays ->
                    ( { model | vacationDays = RemoteData.Success vacationDays }, Cmd.none )


view : Model -> Html Msg
view model =
    Element.layout [ Element.padding 30 ]
        (Element.row
            [ Element.width Element.fill
            , Element.centerY
            , Element.spacing 200
            , Element.alignTop
            ]
            [ case model.timeZone of
                Nothing ->
                    Element.el [] (Element.text "Getting time zone...")

                Just timeZone ->
                    case model.currentTime of
                        Nothing ->
                            Element.el [] (Element.text "Getting current time...")

                        Just currentTime ->
                            if Form.complete model.form then
                                applicationForm model timeZone currentTime

                            else
                                Element.column [ Element.spacing 25 ]
                                    [ Element.row [ Element.spacing 25, Element.width Element.fill, Element.alignTop ]
                                        [ Element.map LocationMsg (Location.statusColumn model.location)
                                        , vacationDayStatusColumn model timeZone
                                        ]
                                    , applicationForm model timeZone currentTime
                                    ]
            ]
        )


applicationForm : Model -> Time.Zone -> Time.Posix -> Element Msg
applicationForm model timeZone currentTime =
    case model.vacationDays of
        RemoteData.Success vacationDays ->
            Element.column []
                [ Element.map FormMsg (Form.inputColumn timeZone currentTime model.form)
                , Element.map FormMsg (Form.outputColumn timeZone model.location vacationDays currentTime model.form)
                ]

        _ ->
            Element.none


vacationDayStatusColumn : Model -> Time.Zone -> Element Msg
vacationDayStatusColumn model timeZone =
    Element.column
        [ Element.spacing 20, Element.Font.size 12, Element.alignTop, Element.width Element.fill ]
        (vacationDayStatus model timeZone)


vacationDayStatus : Model -> Time.Zone -> List (Element Msg)
vacationDayStatus model timeZone =
    case model.vacationDays of
        RemoteData.Success vacationDays ->
            if model.isVacationDaysConfirmed then
                [ StatusBar.view ("Vacation Day Status:" ++ "Vacation days confirmed for: " ++ Location.name model.location) StatusBar.Completed
                , Element.Input.button CommonStyles.buttonStyle
                    { onPress = Just (VacationDaysConfirmed (not model.isVacationDaysConfirmed))
                    , label = Element.el [] (Element.text "Edit")
                    }
                ]

            else
                [ StatusBar.view ("Vacation Day Status:" ++ "The following vacation Days were received for: " ++ Location.name model.location) StatusBar.Completed
                , VacationDays.view timeZone vacationDays
                , Element.Input.button CommonStyles.buttonStyle
                    { onPress = Just (VacationDaysConfirmed (not model.isVacationDaysConfirmed))
                    , label = Element.el [] (Element.text "Confirm")
                    }
                ]

        RemoteData.Failure message ->
            [ StatusBar.view ("Vacation Day Status: Error fetching vacation days: " ++ HttpHelper.messageFromHttpError message ++ ". Please enter them manually.") StatusBar.Error ]

        RemoteData.Loading ->
            [ StatusBar.view "Vacation Day Status: Loading..." StatusBar.InProgress ]

        RemoteData.NotAsked ->
            case Location.stateShortHand model.location of
                Nothing ->
                    [ StatusBar.view ("Vacation Day Status: Can't determine vacation days for: " ++ Location.name model.location ++ ". I need a valid shorthand for a German state (Bundesland)") StatusBar.InProgress ]

                Just _ ->
                    [ StatusBar.view "Vacation Day Status: Loading..." StatusBar.InProgress ]
