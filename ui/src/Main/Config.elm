module Main.Config exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Main.Config.App as Config exposing (..)


type alias Config =
    { config_repository : String
    , config_apps : Dict AppName App
    }


initConfig : Config
initConfig =
    { config_repository = "github:imincik/nix-forge"
    , config_apps = Dict.empty
    }


decodeConfig : Decoder Config
decodeConfig =
    Decode.map2 Config
        (Decode.field "repositoryUrl" Decode.string)
        (Decode.field "apps"
            (Decode.list Config.decodeApp
                |> Decode.map (List.map (\app -> ( app.app_name, app )) >> Dict.fromList)
            )
        )
