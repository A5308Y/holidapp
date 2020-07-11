module StateShorthand exposing
    ( StateShorthand
    , all
    , fromStateName
    , fromTwoCharString
    , toStateName
    , toString
    )


type StateShorthand
    = StateShorthand Shorthand


type Shorthand
    = BW
    | BY
    | BE
    | BB
    | HB
    | HH
    | HE
    | NI
    | MV
    | NW
    | RP
    | SL
    | SN
    | ST
    | SH
    | TH


all : List StateShorthand
all =
    List.map StateShorthand [ BW, BY, BE, BB, HB, HH, HE, NI, MV, NW, RP, SL, SN, ST, SH, TH ]


toString : StateShorthand -> String
toString (StateShorthand shorthand) =
    case shorthand of
        BW ->
            "BW"

        BY ->
            "BY"

        BE ->
            "BE"

        BB ->
            "BB"

        HB ->
            "HB"

        HH ->
            "HH"

        HE ->
            "HE"

        NI ->
            "NI"

        MV ->
            "MV"

        NW ->
            "NW"

        RP ->
            "RP"

        SL ->
            "SL"

        SN ->
            "SN"

        ST ->
            "ST"

        SH ->
            "SH"

        TH ->
            "TH"


toStateName : StateShorthand -> String
toStateName (StateShorthand shorthand) =
    case shorthand of
        BW ->
            "Baden-Württemberg"

        BY ->
            "Bavaria"

        BE ->
            "Berlin"

        BB ->
            "Brandenburg"

        HB ->
            "Bremen"

        HH ->
            "Hamburg"

        HE ->
            "Hesse"

        NI ->
            "Lower Saxony"

        MV ->
            "Mecklenburg-Western Pomerania"

        NW ->
            "North Rhine-Westphalia"

        RP ->
            "Rhineland-Palatinate"

        SL ->
            "Saarland"

        SN ->
            "Saxony"

        ST ->
            "Saxony-Anhalt"

        SH ->
            "Schleswig-Holstein"

        TH ->
            "Thuringia"


fromStateName : String -> Maybe StateShorthand
fromStateName stateName =
    case stateName of
        "Baden-Württemberg" ->
            Just (StateShorthand BW)

        "Bavaria" ->
            Just (StateShorthand BY)

        "Berlin" ->
            Just (StateShorthand BE)

        "Brandenburg" ->
            Just (StateShorthand BB)

        "Bremen" ->
            Just (StateShorthand HB)

        "Hamburg" ->
            Just (StateShorthand HH)

        "Hesse" ->
            Just (StateShorthand HE)

        "Lower Saxony" ->
            Just (StateShorthand NI)

        "Mecklenburg-Western Pomerania" ->
            Just (StateShorthand MV)

        "North Rhine-Westphalia" ->
            Just (StateShorthand NW)

        "Rhineland-Palatinate" ->
            Just (StateShorthand RP)

        "Saarland" ->
            Just (StateShorthand SL)

        "Saxony" ->
            Just (StateShorthand SN)

        "Saxony-Anhalt" ->
            Just (StateShorthand ST)

        "Schleswig-Holstein" ->
            Just (StateShorthand SH)

        "Thuringia" ->
            Just (StateShorthand TH)

        _ ->
            Nothing


fromTwoCharString : String -> Maybe StateShorthand
fromTwoCharString twoCharString =
    case twoCharString of
        "SN" ->
            Just (StateShorthand SN)

        "BE" ->
            Just (StateShorthand BE)

        "BW" ->
            Just (StateShorthand BW)

        "BY" ->
            Just (StateShorthand BY)

        "BB" ->
            Just (StateShorthand BB)

        "HB" ->
            Just (StateShorthand HB)

        "HH" ->
            Just (StateShorthand HH)

        "HE" ->
            Just (StateShorthand HE)

        "MV" ->
            Just (StateShorthand MV)

        "NI" ->
            Just (StateShorthand NI)

        "NW" ->
            Just (StateShorthand NW)

        "RP" ->
            Just (StateShorthand RP)

        "SL" ->
            Just (StateShorthand SL)

        "ST" ->
            Just (StateShorthand ST)

        "SH" ->
            Just (StateShorthand SH)

        "TH" ->
            Just (StateShorthand TH)

        _ ->
            Nothing
