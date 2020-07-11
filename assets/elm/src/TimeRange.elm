module TimeRange exposing (TimeRange, endDate, fromTuple, includes, startDate)

import Time


type TimeRange
    = TimeRange ( Time.Posix, Time.Posix )


fromTuple : ( Time.Posix, Time.Posix ) -> TimeRange
fromTuple tuple =
    TimeRange tuple


startDate : TimeRange -> Time.Posix
startDate (TimeRange ( start, _ )) =
    start


endDate : TimeRange -> Time.Posix
endDate (TimeRange ( _, end )) =
    end


includes : Time.Posix -> TimeRange -> Bool
includes date (TimeRange ( start, end )) =
    (Time.posixToMillis date > Time.posixToMillis start)
        && (Time.posixToMillis date < Time.posixToMillis end)
