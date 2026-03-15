module Main exposing (main)

import AppUrl
import Browser
import Http
import Json.Encode
import Main.Config
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Navigation
import Main.Route exposing (..)
import Main.Update exposing (..)
import Main.View
import Navigation
import Url


main : Program String Model Update
main =
    Browser.element
        { init = init
        , view = Main.View.view
        , update = Main.Update.update
        , subscriptions = subscriptions
        }


init : String -> ( Model, Cmd Update )
init href =
    let
        model =
            { model_config = Main.Config.initConfig
            , model_search = ""
            , model_route = Route_Search ""
            , model_focus = ModelFocus_Error { msg = "Invalid address: " ++ href }
            }
    in
    case href |> Url.fromString of
        Nothing ->
            ( model, cmdGetConfig )

        Just url ->
            case url |> AppUrl.fromUrl |> Main.Route.fromAppUrl of
                Err err ->
                    ( { model | model_focus = ModelFocus_Error { msg = Main.Route.showRouteError err } }
                    , cmdGetConfig
                    )

                Ok route ->
                    let
                        ( m, _ ) =
                            model |> update (Update_Route route)
                    in
                    ( m, cmdGetConfig )


cmdGetConfig : Cmd Update
cmdGetConfig =
    Http.get
        { url = "/forge-config.json"
        , expect = Http.expectJson Update_GetConfig Main.Config.decodeConfig
        }


subscriptions : Model -> Sub Update
subscriptions _ =
    Navigation.onEvent Main.Navigation.onNavEvent Update_GotNavigationEvent
