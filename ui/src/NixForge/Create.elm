module NixForge.Create exposing (..)

import Dict
import Http
import NixForge.Config exposing (..)
import NixForge.Config.App exposing (..)
import NixForge.Config.Package exposing (..)
import NixForge.Create.Model exposing (..)
import NixForge.Create.Update exposing (..)
import NixForge.Create.View exposing (..)
import NixForge.Option exposing (..)
import NixForge.Output exposing (..)


initCreate : () -> ( ModelCreate, Cmd UpdateCreate )
initCreate _ =
    ( { options = []
      , packagesFilter = Dict.empty
      , appsFilter = Dict.empty
      , recipeDirPackages = ""
      , recipeDirApps = ""
      , selectedOption = Nothing
      , searchString = ""
      , category = OutputCategory_Packages
      , packagesSelectedFilter = Nothing
      , appsSelectedFilter = Nothing
      , showInstructions = False
      , error = Nothing
      }
    , Cmd.batch [ getOptions, getConfig ]
    )


getOptions : Cmd UpdateCreate
getOptions =
    Http.get
        { url = "options.json"
        , expect = Http.expectJson UpdateCreate_GetOptions optionsDecoder
        }


getConfig : Cmd UpdateCreate
getConfig =
    Http.get
        { url = "forge-config.json"
        , expect = Http.expectJson UpdateCreate_GetConfig configDecoder
        }
