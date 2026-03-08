module NixForge.Config exposing (..)

import Json.Decode as Decode
import NixForge.Config.App exposing (..)
import NixForge.Config.Package exposing (..)


type alias Config =
    { repositoryUrl : String
    , recipeDirs : RecipeDirs
    , apps : List App
    , packages : List Package
    , packagesFilter : OptionsFilter
    , appsFilter : OptionsFilter
    }


configDecoder : Decode.Decoder Config
configDecoder =
    Decode.map6 Config
        (Decode.field "repositoryUrl" Decode.string)
        (Decode.field "recipeDirs" recipeDirsDecoder)
        (Decode.field "apps" (Decode.list appDecoder))
        (Decode.field "packages" (Decode.list packageDecoder))
        (Decode.field "packagesFilter" optionsFilterDecoder)
        (Decode.field "appsFilter" optionsFilterDecoder)
