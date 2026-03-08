module NixForge.Create.Model exposing (..)

import Browser.Navigation as Nav
import NixForge.Config.Package exposing (OptionsFilter)
import NixForge.Option exposing (Option)
import NixForge.Output exposing (..)
import Url


type alias ModelCreate =
    { options : List Option
    , packagesFilter : OptionsFilter
    , appsFilter : OptionsFilter
    , recipeDirPackages : String
    , recipeDirApps : String
    , selectedOption : Maybe Option
    , searchString : String
    , category : OutputCategory
    , packagesSelectedFilter : Maybe String
    , appsSelectedFilter : Maybe String
    , showInstructions : Bool
    , error : Maybe String
    }
