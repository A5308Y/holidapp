module DateHelper exposing (monthToNumber, textFromDate)

import Time exposing (Month(..))


textFromDate : Time.Zone -> Time.Posix -> String
textFromDate zone date =
    String.padLeft 2 '0' (String.fromInt (Time.toDay zone date))
        ++ "."
        ++ String.padLeft 2 '0' (String.fromInt (monthToNumber (Time.toMonth zone date)))
        ++ "."
        ++ String.fromInt (Time.toYear zone date)


monthToNumber : Time.Month -> Int
monthToNumber month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12
