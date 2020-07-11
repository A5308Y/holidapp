module VacationDays exposing
    ( VacationDays
    , addDay
    , arePresent
    , daysUsed
    , feiertagsApiDecoder
    , fetch
    , init
    , listEntryForDay
    , view
    )

import DateHelper exposing (textFromDate)
import Dict exposing (Dict)
import Element exposing (Element)
import Html.Attributes
import Http
import Json.Decode
import Json.Decode.Extra
import RemoteData exposing (RemoteData(..), WebData)
import StateShorthand exposing (StateShorthand)
import Time
import Time.Extra
import TimeRange exposing (TimeRange)
import Url.Builder


type alias VacationDayInfo =
    { date : Time.Posix
    , note : String
    }


type alias VacationDay =
    { name : String
    , date : Time.Posix
    , note : String
    }


type VacationDays
    = VacationDays (List VacationDay)


init : VacationDays
init =
    VacationDays []


arePresent : WebData VacationDays -> Bool
arePresent remoteVacationDays =
    case remoteVacationDays of
        Success (VacationDays vacationDays) ->
            not (List.isEmpty vacationDays)

        _ ->
            False


view : Time.Zone -> VacationDays -> Element msg
view timeZone (VacationDays vacationDays) =
    vacationDays
        |> List.map (listEntryForDay timeZone)
        |> Element.column [ Element.spacing 7 ]


listEntryForDay : Time.Zone -> VacationDay -> Element msg
listEntryForDay timeZone vacationDayWithName =
    Element.el [ Element.htmlAttribute (Html.Attributes.title vacationDayWithName.note) ]
        (Element.text
            (textFromDate timeZone vacationDayWithName.date
                ++ ": "
                ++ vacationDayWithName.name
                ++ (if String.isEmpty vacationDayWithName.note then
                        ""

                    else
                        "*"
                   )
            )
        )


addDay : String -> VacationDayInfo -> List VacationDay -> List VacationDay
addDay dayName vacationDayInfo vactionDays =
    VacationDay dayName vacationDayInfo.date vacationDayInfo.note :: vactionDays


vacationDaysFromDict : Dict String VacationDayInfo -> VacationDays
vacationDaysFromDict dict =
    dict
        |> Dict.foldl addDay []
        |> List.sortBy (.date >> Time.posixToMillis)
        |> VacationDays


feiertagsApiDecoder : Json.Decode.Decoder VacationDays
feiertagsApiDecoder =
    Json.Decode.map vacationDaysFromDict (Json.Decode.dict vacationDayInfoDecoder)


vacationDayInfoDecoder : Json.Decode.Decoder VacationDayInfo
vacationDayInfoDecoder =
    Json.Decode.map2 VacationDayInfo
        (Json.Decode.field "datum" Json.Decode.Extra.datetime)
        (Json.Decode.field "hinweis" Json.Decode.string)


daysUsed : Time.Zone -> TimeRange -> VacationDays -> Result String Float
daysUsed zone timeRange (VacationDays vacationDays) =
    if List.isEmpty vacationDays then
        Err "Need bank holidays for your location to calculate the necessary vacation days. Allow the app to know your location or enter the bank holidays for your period yourself."

    else
        let
            vacationDaysInRange =
                List.filter (\vacationDay -> TimeRange.includes vacationDay.date timeRange) vacationDays

            startDate =
                TimeRange.startDate timeRange

            endDate =
                TimeRange.endDate timeRange
        in
        -- +1 to include the day of the endDate (should probably be better modelled in the range directly)
        Ok
            ((1
                + Time.Extra.diff Time.Extra.Day zone startDate endDate
                - Time.Extra.diff Time.Extra.Saturday zone startDate endDate
                - Time.Extra.diff Time.Extra.Sunday zone startDate endDate
                - List.length vacationDaysInRange
             )
                |> toFloat
            )


fetch : Int -> StateShorthand -> (Result Http.Error VacationDays -> msg) -> Cmd msg
fetch currentYear shorthand msg =
    Http.get
        { url = feiertagsApiUrl currentYear shorthand
        , expect = Http.expectJson msg feiertagsApiDecoder
        }


feiertagsApiUrl : Int -> StateShorthand -> String
feiertagsApiUrl currentYear shorthand =
    Url.Builder.crossOrigin "https://feiertage-api.de"
        [ "api/" ]
        -- Yes really with a "/". The API is a little unconventional
        [ Url.Builder.int "jahr" currentYear
        , Url.Builder.string "nur_land" (StateShorthand.toString shorthand)
        ]
