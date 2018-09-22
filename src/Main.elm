module Main exposing (..)


import Browser
import Browser.Navigation as Nav
import Dict
import Html
import Page.Search as Search
import Page.Home as Home
import Page.Admin as Admin
import Skeleton
import Url
import Url.Parser as Parser exposing (Parser, (</>), custom, fragment, map, oneOf, s, top)



-- MAIN


main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = LinkClicked
    , onUrlChange = UrlChanged
    }



-- MODEL


type alias Model =
  { key : Nav.Key
  , page : Page
  }


type Page
  = Search Search.Model
  | NotFound
  | Home Home.Model
  | Admin Admin.Model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
  case model.page of
    NotFound ->
      Skeleton.view never
        { title = "Not Found"
        , attrs = []
        , kids = [ Html.div [] [ Html.text "404 Not Found"] ]
        }

    Search search ->
      Skeleton.view SearchMsg (Search.view search)

    Home home ->
      Skeleton.view HomeMsg (Home.view home)

    Admin admin ->
      Skeleton.view AdminMsg (Admin.view admin)



-- INIT


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
  stepUrl url
    { key = key
    , page = Search ( Search.Model 5 )
    }



-- UPDATE


type Msg
  = NoOp
  | LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | SearchMsg Search.Msg
  | AdminMsg Admin.Msg
  | HomeMsg Home.Msg



update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  case message of
    NoOp ->
      ( model, Cmd.none )

    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model
          , Nav.pushUrl model.key (Url.toString url)
          )

        Browser.External href ->
          ( model
          , Nav.load href
          )

    UrlChanged url ->
      stepUrl url model

    SearchMsg msg ->
      case model.page of
        Search search -> stepSearch model (Search.update msg search)
        _             -> ( model, Cmd.none )

    HomeMsg msg ->
      case model.page of
        Home home -> stepHome model (Home.update msg home)
        _         -> ( model, Cmd.none )

    AdminMsg msg ->
      case model.page of
        Admin admin -> stepAdmin model (Admin.update msg admin)
        _         -> ( model, Cmd.none )


stepSearch : Model -> ( Search.Model, Cmd Search.Msg ) -> ( Model, Cmd Msg )
stepSearch model (search, cmds) =
  ( { model | page = Search search }
  , Cmd.map SearchMsg cmds
  )


stepAdmin : Model -> ( Admin.Model, Cmd Admin.Msg ) -> ( Model, Cmd Msg )
stepAdmin model (admin, cmds) =
  ( { model | page = Admin admin }
  , Cmd.map AdminMsg cmds
  )


stepHome : Model -> ( Home.Model, Cmd Home.Msg ) -> ( Model, Cmd Msg )
stepHome model (home, cmds) =
  ( { model | page = Home home}
  , Cmd.map HomeMsg cmds
  )


-- ROUTER


stepUrl : Url.Url -> Model -> (Model, Cmd Msg)
stepUrl url model =
  let
    parser =
      oneOf
        [ route top
          ( stepHome model (Home.init 7) )
        , route ( s "admin" )
          ( stepAdmin model (Admin.init 8) )
        , route ( s "search" )
          ( stepSearch model (Search.init 9) )
        ]
  in
  case Parser.parse parser url of
    Just answer ->
      answer

    Nothing ->
      ( { model | page = NotFound }
      , Cmd.none
      )


route : Parser a b -> a -> Parser (b -> c) c
route parser handler =
  Parser.map handler parser
