module CommonStyles exposing
    ( backgroundGrey
    , buttonStyle
    , buttonStyleActive
    , disabledButtonStyle
    , green
    , red
    , white
    , yellow
    )

import Element
import Element.Background
import Element.Border
import Element.Font


buttonStyle : List (Element.Attribute msg)
buttonStyle =
    [ Element.Background.color (Element.rgb 0.2 0.2 1)
    , Element.Font.color (Element.rgb 1 1 1)
    , Element.Border.rounded 5
    , Element.Border.color (Element.rgb 1 1 1)
    , Element.padding 10
    ]


buttonStyleActive : List (Element.Attribute msg)
buttonStyleActive =
    [ Element.Background.color (Element.rgb 0.1 0.6 0.9)
    , Element.Font.color (Element.rgb 1 1 1)
    , Element.Border.rounded 5
    , Element.Border.color (Element.rgb 1 1 1)
    , Element.padding 10
    ]


disabledButtonStyle : List (Element.Attribute msg)
disabledButtonStyle =
    [ Element.Background.color (Element.rgb 0.3 0.3 0.3)
    , Element.Font.color (Element.rgb 1 1 1)
    , Element.Border.rounded 10
    , Element.Border.color (Element.rgb 1 1 1)
    , Element.padding 10
    ]


red : Element.Color
red =
    Element.rgb255 250 5 5


yellow : Element.Color
yellow =
    Element.rgb255 250 250 5


green : Element.Color
green =
    Element.rgb255 5 250 5


backgroundGrey : Element.Color
backgroundGrey =
    Element.rgb255 230 230 230


white : Element.Color
white =
    Element.rgb255 250 250 250
