module Skeleton exposing
    ( Details
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Json.Decode as D



-- NODE


type alias Details msg =
    { title : String
    , attrs : List (Attribute msg)
    , kids : List (Html msg)
    }



-- VIEW


view : (a -> msg) -> Details a -> Browser.Document msg
view toMsg details =
    { title =
        details.title
    , body =
        [ viewHeader
        , Html.map toMsg <|
            div (class "center" :: details.attrs) details.kids
        , viewFooter
        ]
    }



-- VIEW HEADER


viewHeader : Html msg
viewHeader =
    div []
        [ a [ href "/" ] [ text "Home" ]
        , a [ href "/search"] [ text "Search" ]
        , a [ href "/admin" ] [ text "Admin" ]
        ]



-- VIEW FOOTER


viewFooter : Html msg
viewFooter =
    div [] [ text " ~~~ FOOTER ~~~ " ]
