module Form exposing
    ( Form
    , Msg
    , complete
    , datePickerSubscription
    , init
    , inputColumn
    , outputColumn
    , partialDataFromForm
    , update
    , updateData
    )

import CommonStyles
import DateHelper
import DurationDatePicker
import Element exposing (Element)
import Element.Font
import Element.Input
import Element.Region
import Html
import Location exposing (Location)
import Name exposing (Name)
import RemoteData exposing (RemoteData(..))
import Signature exposing (Signature)
import Time
import TimeRange exposing (TimeRange)
import VacationDays exposing (VacationDays)


type Msg
    = CharacterEnteredForName String
    | CharacterEnteredForRemainingVacationDaysBeforeApplication String
    | CompleteFormButtonClicked
    | DisabledCompleteFormButtonClicked
    | DatePicked ( DurationDatePicker.DatePicker, Maybe ( Date, Date ) )
    | DatePickerRequested Time.Zone Date
    | SignatureMsg Signature.Msg


type Form
    = PartialForm PartialFormData
    | ValidForm CompletedFormData
    | CompletedForm CompletedFormData


type alias TodoItem =
    String


type alias Date =
    Time.Posix


type alias PartialFormData =
    { signature : Signature
    , todos : List TodoItem
    , name : Maybe String
    , requestedTimeRange : Maybe TimeRange
    , remainingVacationDaysBeforeApplication : Maybe Float
    , datePicker : DurationDatePicker.DatePicker
    }


type alias CompletedFormData =
    { signature : Signature
    , name : Name
    , requestedTimeRange : TimeRange
    , remainingVacationDaysBeforeApplication : Float
    }


initData : PartialFormData
initData =
    { signature = Signature.init
    , name = Nothing
    , requestedTimeRange = Nothing
    , remainingVacationDaysBeforeApplication = Nothing
    , todos = []
    , datePicker = DurationDatePicker.init
    }


init : Form
init =
    updateData (PartialForm initData) initData


update : Msg -> Form -> Form
update msg form =
    case form of
        ValidForm completedFormData ->
            let
                partialFormData =
                    partialFromComplete completedFormData
            in
            updateformHelper msg partialFormData form

        CompletedForm _ ->
            form

        PartialForm partialFormData ->
            updateformHelper msg partialFormData form


updateformHelper : Msg -> PartialFormData -> Form -> Form
updateformHelper msg partialFormData form =
    case msg of
        SignatureMsg signatureMsg ->
            updateData form { partialFormData | signature = Signature.update signatureMsg partialFormData.signature }

        CompleteFormButtonClicked ->
            case form of
                ValidForm formData ->
                    CompletedForm formData

                PartialForm _ ->
                    form

                CompletedForm _ ->
                    form

        DisabledCompleteFormButtonClicked ->
            let
                _ =
                    Debug.todo
            in
            updateData form partialFormData

        CharacterEnteredForName name ->
            updateData form { partialFormData | name = Just name }

        CharacterEnteredForRemainingVacationDaysBeforeApplication remainingDays ->
            updateData form { partialFormData | remainingVacationDaysBeforeApplication = String.toFloat remainingDays }

        DatePickerRequested timeZone currentDate ->
            updateData form
                { partialFormData
                    | datePicker =
                        DurationDatePicker.openPicker
                            timeZone
                            currentDate
                            (Maybe.map TimeRange.startDate partialFormData.requestedTimeRange)
                            (Maybe.map TimeRange.endDate partialFormData.requestedTimeRange)
                            partialFormData.datePicker
                }

        DatePicked ( newPicker, pickedTimeRange ) ->
            updateData form
                { partialFormData
                    | datePicker = newPicker
                    , requestedTimeRange =
                        case pickedTimeRange of
                            Nothing ->
                                partialFormData.requestedTimeRange

                            Just timeRange ->
                                Just (TimeRange.fromTuple timeRange)
                }


partialDataFromForm : Form -> PartialFormData
partialDataFromForm form =
    case form of
        PartialForm partialFormData ->
            partialFormData

        CompletedForm completedFormData ->
            partialFromComplete completedFormData

        ValidForm completedFormData ->
            partialFromComplete completedFormData


updateData : Form -> PartialFormData -> Form
updateData form updatedData =
    case form of
        PartialForm _ ->
            case completeFromPartial updatedData of
                Ok completedFormData ->
                    ValidForm completedFormData

                Err errors ->
                    PartialForm { updatedData | todos = errors }

        CompletedForm _ ->
            form

        ValidForm _ ->
            case completeFromPartial updatedData of
                Ok completedFormData ->
                    ValidForm completedFormData

                Err errors ->
                    PartialForm { updatedData | todos = errors }


partialFromComplete : CompletedFormData -> PartialFormData
partialFromComplete formData =
    { signature = formData.signature
    , name = Just (Name.toString formData.name)
    , requestedTimeRange = Just formData.requestedTimeRange
    , remainingVacationDaysBeforeApplication = Just formData.remainingVacationDaysBeforeApplication
    , datePicker = DurationDatePicker.init
    , todos = []
    }


completeFromPartial : PartialFormData -> Result (List String) CompletedFormData
completeFromPartial partialData =
    initialize (CompletedFormData partialData.signature)
        (validatedName partialData)
        |> combine (validatedTimeRange partialData)
        |> combine (validatedVacationDaysBeforeApplication partialData)


combine : Result e a -> Result (List e) (a -> b) -> Result (List e) b
combine res f =
    case ( res, f ) of
        ( Ok res_, Ok f_ ) ->
            Ok (f_ res_)

        ( Ok res_, Err f_ ) ->
            Err f_

        ( Err res_, Ok f_ ) ->
            Err [ res_ ]

        ( Err res_, Err f_ ) ->
            Err (res_ :: f_)


initialize : (a -> b) -> Result e a -> Result (List e) b
initialize f res =
    case res of
        Ok a_ ->
            Ok (f a_)

        Err a_ ->
            Err [ a_ ]


validatedName : PartialFormData -> Result String Name
validatedName partialData =
    case partialData.name of
        Nothing ->
            Err "Please enter your full name"

        Just name ->
            case Name.fromString name of
                Err message ->
                    Err ("Error for name: " ++ message)

                Ok validName ->
                    Ok validName


validatedTimeRange : PartialFormData -> Result String TimeRange
validatedTimeRange partialData =
    case partialData.requestedTimeRange of
        Nothing ->
            Err "Please enter a time range for your vacation request"

        Just timeRange ->
            Ok timeRange


validatedVacationDaysBeforeApplication : PartialFormData -> Result String Float
validatedVacationDaysBeforeApplication partialData =
    case partialData.remainingVacationDaysBeforeApplication of
        Nothing ->
            Err "Please enter your available number of vacation days"

        Just numberOfDays ->
            Ok numberOfDays


inputColumn : Time.Zone -> Date -> Form -> Element Msg
inputColumn timeZone currentDate form =
    case form of
        ValidForm formData ->
            Element.column [ Element.alignTop ]
                [ editableForm timeZone currentDate (partialFromComplete formData)
                , Element.Input.button CommonStyles.buttonStyle
                    { onPress = Just CompleteFormButtonClicked
                    , label = Element.el [] (Element.text "Bearbeitung abschließen (Druckansicht)")
                    }
                ]

        CompletedForm _ ->
            Element.none

        PartialForm formData ->
            Element.column []
                [ editableForm timeZone currentDate formData
                , Element.Input.button (Element.Region.description "All information is required" :: CommonStyles.disabledButtonStyle)
                    { onPress = Just DisabledCompleteFormButtonClicked
                    , label = Element.el [] (Element.text "Bearbeitung abschließen (Druckansicht)")
                    }
                ]


editableForm : Time.Zone -> Date -> PartialFormData -> Element Msg
editableForm timeZone currentDate formData =
    Element.column [ Element.spacing 15, Element.width (Element.fillPortion 2 |> Element.maximum 1500) ]
        [ Element.Input.text [ Element.width (Element.fillPortion 1 |> Element.maximum 400) ]
            { onChange = CharacterEnteredForName
            , text = Maybe.withDefault "" formData.name
            , placeholder = Nothing
            , label = Element.Input.labelLeft [ Element.width (Element.fillPortion 2 |> Element.minimum 200) ] (Element.text "Name")
            }
        , Element.Input.text [ Element.width (Element.fillPortion 1 |> Element.maximum 400) ]
            { onChange = CharacterEnteredForRemainingVacationDaysBeforeApplication
            , text = String.fromFloat (Maybe.withDefault 0.0 formData.remainingVacationDaysBeforeApplication)
            , placeholder = Nothing
            , label = Element.Input.labelLeft [ Element.width (Element.fillPortion 2 |> Element.minimum 200) ] (Element.text "Urlaubsanspruch bis heute")
            }
        , Element.Input.button CommonStyles.buttonStyle
            { onPress = Just (DatePickerRequested timeZone currentDate)
            , label = Element.el [] (Element.text "Urlaubszeitraum auswählen")
            }
        , Element.html (DurationDatePicker.view datePickerSettings formData.datePicker)
        , Element.el [ Element.Font.size 16 ] (Element.text "Bitte im folgenden grauen Feld unterschreiben:")
        , Element.html (Html.map SignatureMsg (Signature.view formData.signature))
        ]


outputColumn : Time.Zone -> Location -> VacationDays -> Date -> Form -> Element Msg
outputColumn timeZone location vacationDays currentDate form =
    case form of
        CompletedForm formData ->
            let
                usedDaysResult =
                    VacationDays.daysUsed timeZone formData.requestedTimeRange vacationDays
            in
            Element.column [ Element.spacing 10, Element.width (Element.fillPortion 2 |> Element.maximum 1500), Element.alignRight ]
                [ Element.image [ Element.alignRight ]
                    { src = "public/codingrobin_logo.png"
                    , description = "Logo von Coding Robin"
                    }
                , Element.el [ Element.Font.size 22, Element.Font.bold ] (Element.text "Urlaubsantrag")
                , case usedDaysResult of
                    Ok usedDays ->
                        completeApplicationForm usedDays location timeZone vacationDays currentDate formData

                    Err message ->
                        Element.el [ Element.Font.size 16 ] (Element.text message)
                ]

        PartialForm formData ->
            Element.column [ Element.spacing 10, Element.width (Element.fillPortion 2 |> Element.maximum 1500), Element.alignRight ]
                (List.map (\todoText -> Element.el [] (Element.text todoText)) formData.todos)

        ValidForm formData ->
            let
                usedDaysResult =
                    VacationDays.daysUsed timeZone formData.requestedTimeRange vacationDays
            in
            Element.column [ Element.spacing 10, Element.width (Element.fillPortion 2 |> Element.maximum 1500), Element.alignRight ]
                [ Element.image [ Element.alignRight ]
                    { src = "public/codingrobin_logo.png"
                    , description = "Logo von Coding Robin"
                    }
                , Element.el [ Element.Font.size 22, Element.Font.bold ] (Element.text "Urlaubsantrag")
                , case usedDaysResult of
                    Ok usedDays ->
                        completeApplicationForm usedDays location timeZone vacationDays currentDate formData

                    Err message ->
                        Element.el [ Element.Font.size 16 ] (Element.text message)
                ]


daysLeftString : Time.Zone -> VacationDays -> CompletedFormData -> String
daysLeftString timeZone vacationDays formData =
    let
        usedDaysResult =
            VacationDays.daysUsed timeZone formData.requestedTimeRange vacationDays
    in
    case usedDaysResult of
        Ok usedDays ->
            String.fromFloat (formData.remainingVacationDaysBeforeApplication - usedDays)

        Err message ->
            message


completeApplicationForm : Float -> Location -> Time.Zone -> VacationDays -> Date -> CompletedFormData -> Element Msg
completeApplicationForm usedDays location timeZone vacationDays currentDate formData =
    Element.row
        [ Element.width Element.fill, Element.spaceEvenly ]
        [ applicationContentColumn usedDays location timeZone vacationDays currentDate formData
        , companyDataColumn
        ]


applicationContentColumn : Float -> Location -> Time.Zone -> VacationDays -> Date -> CompletedFormData -> Element Msg
applicationContentColumn usedDays location timeZone vacationDays currentDate formData =
    Element.column [ Element.spacing 8 ]
        [ Element.el [ Element.Font.size 16 ] (Element.text ("Name: " ++ Name.toString formData.name))
        , Element.el [ Element.Font.size 16 ]
            (Element.text
                ("Hiermit beantrage ich Urlaub vom: "
                    ++ DateHelper.textFromDate timeZone (TimeRange.startDate formData.requestedTimeRange)
                    ++ " bis zum: "
                    ++ DateHelper.textFromDate timeZone (TimeRange.endDate formData.requestedTimeRange)
                    ++ "."
                )
            )
        , Element.el [ Element.Font.size 16 ] (Element.text ("Es werden dafür " ++ String.fromFloat usedDays ++ " Tage Urlaub benötigt."))
        , Element.el [ Element.Font.size 16 ] (Element.text ("Urlaubsanspruch bis heute: " ++ String.fromFloat formData.remainingVacationDaysBeforeApplication))
        , Element.el [ Element.Font.size 16 ] (Element.text ("Heute beantragte Urlaubstage: " ++ String.fromFloat usedDays))
        , Element.el [ Element.Font.size 16 ] (Element.text ("Resturlaub: " ++ daysLeftString timeZone vacationDays formData))
        , Element.el [ Element.Font.size 16 ] (Element.text "Unterschrift Arbeitnehmerin")
        , Element.html (Html.map SignatureMsg (Signature.output formData.signature))
        , Element.el [ Element.Font.size 16 ] (Element.text (Location.name location ++ ", den " ++ DateHelper.textFromDate timeZone currentDate))
        ]


companyDataColumn : Element Msg
companyDataColumn =
    Element.column
        [ Element.spacing 10, Element.alignTop, Element.alignRight ]
        [ Element.row [ Element.alignRight ]
            [ Element.column [ Element.alignRight, Element.spacing 5 ]
                [ Element.el [ Element.Font.size 16, Element.alignRight, Element.Font.bold ] (Element.text "Telefon")
                , Element.el [ Element.Font.size 16, Element.alignRight ] (Element.text "+49 160906 59729")
                ]
            ]
        , Element.row [ Element.alignRight ]
            [ Element.column [ Element.alignRight, Element.spacing 5 ]
                [ Element.el [ Element.Font.size 16, Element.alignRight, Element.Font.bold ] (Element.text "Email")
                , Element.el [ Element.Font.size 16, Element.alignRight ] (Element.text "robin@coding-robin.de")
                ]
            ]
        , Element.row [ Element.alignRight ]
            [ Element.column [ Element.alignRight, Element.spacing 5 ]
                [ Element.el [ Element.Font.size 16, Element.alignRight, Element.Font.bold ] (Element.text "Steuernummer")
                , Element.el [ Element.Font.size 16, Element.alignRight ] (Element.text "23 / 438 / 61085")
                ]
            ]
        , Element.row [ Element.alignRight ]
            [ Element.column [ Element.alignRight, Element.spacing 5 ]
                [ Element.el [ Element.Font.size 16, Element.alignRight, Element.Font.bold ] (Element.text "USt.-IdNr.")
                , Element.el [ Element.Font.size 16, Element.alignRight ] (Element.text "DE264168609")
                ]
            ]
        ]


datePickerSettings : DurationDatePicker.Settings Msg
datePickerSettings =
    DurationDatePicker.defaultSettings Time.utc DatePicked


datePickerSubscription : Form -> Sub Msg
datePickerSubscription form =
    case form of
        CompletedForm _ ->
            Sub.none

        ValidForm _ ->
            Sub.none

        PartialForm formData ->
            DurationDatePicker.subscriptions datePickerSettings DatePicked formData.datePicker


complete : Form -> Bool
complete form =
    case form of
        CompletedForm _ ->
            True

        _ ->
            False



--type alias Validation =
--    Form -> Result String a
--type alias Validations =
--    List Validation
--allInformationFilledOut : PartialFormData -> Bool
--allInformationFilledOut data =
--    Signature.isPresent data.signature
