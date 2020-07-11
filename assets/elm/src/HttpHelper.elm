module HttpHelper exposing (messageFromHttpError)

import Http exposing (Error(..))


messageFromHttpError : Error -> String
messageFromHttpError httpError =
    case httpError of
        BadUrl message ->
            "Url nicht gefunden: " ++ message

        Timeout ->
            "Seite reagiert nicht"

        NetworkError ->
            "Netzwerkfehler (Ist deine Verbindung noch da?)"

        BadStatus code ->
            "Http Fehler " ++ String.fromInt code

        BadBody body ->
            "Fehlerhafter Request " ++ body
