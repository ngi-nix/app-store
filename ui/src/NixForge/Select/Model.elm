module NixForge.Select.Model exposing (..)

import NixForge.Config exposing (..)
import NixForge.Config.App exposing (..)
import NixForge.Config.Package exposing (..)
import NixForge.Output exposing (..)


type alias ModelSelect =
    { repositoryUrl : String
    , recipeDirPackages : String
    , recipeDirApps : String
    , apps : List App
    , packages : List Package
    , selectedOutput : OutputCategory
    , selectedApp : Maybe App
    , selectedPackage : Maybe Package
    , searchString : String
    , error : Maybe String
    }
