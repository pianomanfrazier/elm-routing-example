module Page.Search exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Html exposing (..)
import Skeleton



-- Model


type alias Model =
    { num : Int }


init : Int -> ( Model, Cmd Msg )
init num =
    ( Model num, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )



-- VIEW


view : Model -> Skeleton.Details Msg
view model =
    { title = "Search"
    , attrs = []
    , kids =
        [ div []
            [ span [] [ model.num |> String.fromInt |> text ]
            , text " Search Page"
            ]
        ]
    }
