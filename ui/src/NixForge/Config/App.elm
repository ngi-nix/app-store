module NixForge.Config.App exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode


type alias App =
    { name : String
    , description : String
    , version : String
    , usage : String
    , programs : AppPrograms
    , containers : AppContainers
    , oci : Dict String AppOci
    }


type alias AppPrograms =
    { enable : Bool
    }


type alias AppContainers =
    { enable : Bool
    }


type alias AppOci =
    { enable : Bool
    }


appDecoder : Decode.Decoder App
appDecoder =
    Decode.map7 App
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "usage" Decode.string)
        (Decode.field "programs" appProgramsDecoder)
        (Decode.field "containers" appContainersDecoder)
        (Decode.field "oci" (Decode.dict appOciDecoder))


appProgramsDecoder : Decode.Decoder AppPrograms
appProgramsDecoder =
    Decode.map AppPrograms
        (Decode.field "enable" Decode.bool)


appContainersDecoder : Decode.Decoder AppContainers
appContainersDecoder =
    Decode.map AppContainers
        (Decode.field "enable" Decode.bool)


appOciDecoder : Decode.Decoder AppOci
appOciDecoder =
    Decode.map AppOci
        (Decode.field "enable" Decode.bool)
