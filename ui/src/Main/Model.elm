module Main.Model exposing (..)

import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Error exposing (..)
import Main.Route exposing (..)


type alias Model =
    { model_config : Config
    , model_search : String
    , model_route : Route
    , model_focus : ModelFocus
    , model_errors : List Error
    }


type ModalTab
    = ModalTab_Programs
    | ModalTab_Container
    | ModalTab_VM


type ModelFocus
    = ModelFocus_App ModelFocusApp
    | ModelFocus_Search


type alias ModelFocusApp =
    { modelFocusApp_app : App
    , modelFocusApp_showRunModal : Bool
    , modelFocusApp_activeModalTab : ModalTab
    }
