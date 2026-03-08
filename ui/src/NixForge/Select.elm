module NixForge.Select exposing (..)

import Http
import NixForge.Config exposing (..)
import NixForge.Config.App exposing (..)
import NixForge.Config.Package exposing (..)
import NixForge.Output exposing (..)
import NixForge.Select.Model exposing (..)
import NixForge.Select.Update exposing (..)
import NixForge.Select.View exposing (..)


initSelect : () -> ( ModelSelect, Cmd UpdateSelect )
initSelect _ =
    ( { repositoryUrl = "github:imincik/nix-forge"
      , recipeDirPackages = ""
      , recipeDirApps = ""
      , apps = []
      , packages = []
      , selectedOutput = OutputCategory_Packages
      , selectedApp = Nothing
      , selectedPackage = Nothing
      , searchString = ""
      , error = Nothing
      }
    , getConfig
    )


getConfig : Cmd UpdateSelect
getConfig =
    Http.get
        { url = "forge-config.json"
        , expect = Http.expectJson UpdateSelect_GetConfig configDecoder
        }
