module Main.Select.Model exposing (..)

import Dict exposing (Dict)
import Main.Config exposing (..)
import Main.Config.App exposing (..)


type alias ModelSelect =
    { repositoryUrl : String
    , recipeDirApps : String
    , apps : Dict String App
    , selectedApp : Maybe App
    , searchString : String
    , error : Maybe String
    }
