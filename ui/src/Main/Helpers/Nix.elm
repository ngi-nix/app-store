module Main.Helpers.Nix exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, field, string)
import List.Extra as List
import Main.Helpers.List as List
import Main.Helpers.Tree as Tree exposing (Trees)
import String
import Tree


type alias NixUrl =
    String


showNixUrl : NixUrl -> String
showNixUrl url =
    if String.startsWith "github:" url then
        "https://github.com/" ++ String.dropLeft 7 url

    else if String.startsWith "path:" url then
        "#"

    else
        url


showGithubRepoSlug : NixUrl -> String
showGithubRepoSlug url =
    String.dropLeft 7 url


{-| Eg. `"apps.*.services"`
-}
type alias NixAttrId =
    String


{-| Eg. `["apps", "*", "services"]`
-}
type alias NixAttrPath =
    List NixAttrName


{-| Eg. `"services"`
-}
type alias NixAttrName =
    String


splitNixAttrId : NixAttrId -> NixAttrPath
splitNixAttrId name =
    case name of
        "" ->
            []

        _ ->
            name |> String.split "."


joinNixAttrPath : NixAttrPath -> NixAttrId
joinNixAttrPath =
    String.join "."


type alias NixModuleOptions =
    Dict NixAttrId NixModuleOption


decodeNixModuleOptions : Decoder NixModuleOptions
decodeNixModuleOptions =
    Decode.dict decodeNixModuleOption


type alias NixModuleOption =
    { nixModuleOption_declarations : List String
    , nixModuleOption_description : String
    , nixModuleOption_readOnly : Bool
    , nixModuleOption_type : String
    , nixModuleOption_default : Maybe NixLiteralExpression
    , nixModuleOption_example : Maybe NixLiteralExpression
    }


decodeNixModuleOption : Decoder NixModuleOption
decodeNixModuleOption =
    Decode.map6 NixModuleOption
        (field "declarations" (Decode.list string))
        (field "description" string)
        (field "readOnly" Decode.bool)
        (field "type" string)
        (Decode.maybe (field "default" decodeLiteralExpression))
        (Decode.maybe (field "example" decodeLiteralExpression))


type alias NixLiteralExpression =
    { nixLiteralExpression_type : String
    , nixLiteralExpression_text : String
    }


decodeLiteralExpression : Decoder NixLiteralExpression
decodeLiteralExpression =
    Decode.map2 NixLiteralExpression
        (field "_type" string)
        (field "text" string)


nixOptionsTrees : List.Assoc NixAttrId opt -> Trees ( NixAttrName, List opt )
nixOptionsTrees opts =
    opts
        |> List.map
            (\( n, opt ) ->
                let
                    path =
                        n |> splitNixAttrId
                in
                ( path, opt )
            )
        |> Tree.unflattenChart
