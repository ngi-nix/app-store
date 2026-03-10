module NixForge.Config exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
import NixForge.Config.App as App exposing (..)
import NixForge.Config.Package exposing (..)


type alias Config =
    { repositoryUrl : String
    , recipeDirs : RecipeDirs

    -- Warning(safety): unfortunately, Elm just cannot create a `Dict AppName App`
    -- https://github.com/elm/compiler/blob/master/hints/comparing-custom-types.md#wrapped-types
    , apps : Dict String App
    , packages : List Package
    , packagesFilter : OptionsFilter
    , appsFilter : OptionsFilter
    }


type alias OptionsFilter =
    Dict.Dict String (List String)


type alias RecipeDirs =
    { packages : String
    , apps : String
    }


configDecoder : Decode.Decoder Config
configDecoder =
    Decode.map6 Config
        (Decode.field "repositoryUrl" Decode.string)
        (Decode.field "recipeDirs" recipeDirsDecoder)
        (Decode.field "apps" (Decode.list appDecoder |> Decode.map (List.map (\app -> ( app.name |> App.unAppName, app )) >> Dict.fromList)))
        (Decode.field "packages" (Decode.list packageDecoder))
        (Decode.field "packagesFilter" optionsFilterDecoder)
        (Decode.field "appsFilter" optionsFilterDecoder)


optionsFilterDecoder : Decode.Decoder OptionsFilter
optionsFilterDecoder =
    Decode.dict (Decode.list Decode.string)


recipeDirsDecoder : Decode.Decoder RecipeDirs
recipeDirsDecoder =
    Decode.map2 RecipeDirs
        (Decode.field "packages" Decode.string)
        (Decode.field "apps" Decode.string)
