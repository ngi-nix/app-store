module NixForge.Config.Package exposing (..)

import Dict
import Json.Decode as Decode


type alias Package =
    { name : String
    , description : String
    , version : String
    , homePage : String
    , mainProgram : String
    , builder : String
    }


type PackageName
    = PackageName String


packageName : String -> Maybe PackageName
packageName s =
    if String.all (\c -> 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z' || '0' <= c && c <= '9') s then
        Just (PackageName s)

    else
        Nothing


type alias OptionsFilter =
    Dict.Dict String (List String)


type alias RecipeDirs =
    { packages : String
    , apps : String
    }


optionsFilterDecoder : Decode.Decoder OptionsFilter
optionsFilterDecoder =
    Decode.dict (Decode.list Decode.string)


recipeDirsDecoder : Decode.Decoder RecipeDirs
recipeDirsDecoder =
    Decode.map2 RecipeDirs
        (Decode.field "packages" Decode.string)
        (Decode.field "apps" Decode.string)


packageBuilder : Decode.Decoder String
packageBuilder =
    Decode.field "build" (Decode.dict (Decode.maybe (Decode.oneOf [ Decode.field "enable" Decode.bool, Decode.bool ])))
        |> Decode.map findEnabledBuilder


findEnabledBuilder : Dict.Dict String (Maybe Bool) -> String
findEnabledBuilder dict =
    dict
        |> Dict.filter (\_ value -> value == Just True)
        |> Dict.keys
        |> List.head
        |> Maybe.withDefault "none"


packageDecoder : Decode.Decoder Package
packageDecoder =
    Decode.map6 Package
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "homePage" Decode.string)
        (Decode.field "mainProgram" Decode.string)
        packageBuilder
