module Main exposing (main)

import AppUrl
import Browser
import Json.Encode
import Main.Config
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Route exposing (..)
import Main.Subscriptions
import Main.Update exposing (..)
import Main.View
import Url


main : Program String Model Update
main =
    Browser.element
        { init = init
        , view = Main.View.view
        , update = Main.Update.update
        , subscriptions = Main.Subscriptions.subscriptions
        }


init : String -> ( Model, Cmd Update )
init href =
    let
        model =
            { model_config = Main.Config.initConfig
            , model_search = ""
            , model_page = Page_Search
            , model_errors = []
            }
    in
    case href |> Url.fromString of
        Nothing ->
            ( model, Cmd.none )

        Just url ->
            model
                |> update
                    (Update_Navigation
                        { appUrl = url |> AppUrl.fromUrl
                        , state = Json.Encode.null
                        }
                    )
