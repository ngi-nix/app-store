module Main.Model exposing (..)

import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Route exposing (..)
import Main.Select.Model exposing (ModelSelect)


type Model
    = Model_Select ModelSelect
