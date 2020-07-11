module Name exposing (Name, fromString, toString)


type Name
    = Name String


fromString : String -> Result String Name
fromString potentialName =
    if String.length potentialName > 80 then
        Err "Maximum number of characters is 80"

    else if String.length potentialName == 0 then
        Err "Minumum number of characters is 1"

    else
        Ok (Name potentialName)


toString : Name -> String
toString (Name string) =
    string
