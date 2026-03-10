module NixForge.Select.Model exposing (..)

import Dict exposing (Dict)
import NixForge.Config exposing (..)
import NixForge.Config.App exposing (..)


type alias ModelSelect =
    { repositoryUrl : String
    , recipeDirApps : String
    , apps : Dict String App
    , selectedApp : Maybe App
    , searchString : String
    , error : Maybe String
    }
