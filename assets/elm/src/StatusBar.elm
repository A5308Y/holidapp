module StatusBar exposing (Status(..), view)

import CommonStyles
import Element exposing (Element)
import Element.Background
import Element.Font
import Html
import Html.Attributes


type Status
    = Error
    | InProgress
    | Completed


view : String -> Status -> Element msg
view message status =
    Element.row
        [ Element.Background.color CommonStyles.backgroundGrey
        , Element.width (Element.px 500)
        , Element.height (Element.px 20)
        , Element.spacing 10
        , Element.padding 50
        ]
        [ Element.paragraph []
            [ Element.el [ Element.Font.color (color status) ] (icon status)
            , Element.el [] (Element.text (" " ++ message))
            ]
        ]


icon : Status -> Element msg
icon status =
    Element.html (Html.i [ Html.Attributes.class ("fas fa-" ++ iconName status) ] [])


iconName : Status -> String
iconName status =
    case status of
        Error ->
            "times-circle"

        InProgress ->
            "exclamation-circle"

        Completed ->
            "check-circle"


color : Status -> Element.Color
color status =
    case status of
        Error ->
            CommonStyles.red

        InProgress ->
            CommonStyles.yellow

        Completed ->
            CommonStyles.green
