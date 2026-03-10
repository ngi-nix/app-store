module NixForge.Select.View.Applications exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, a, div, h5, p, small, span, text)
import Html.Attributes exposing (class, href, name)
import Html.Events exposing (onClick)
import NixForge.Config exposing (..)
import NixForge.Config.App as App exposing (..)
import NixForge.Config.Package exposing (..)
import NixForge.Output exposing (..)
import NixForge.Route exposing (..)
import NixForge.Select.Model exposing (..)
import NixForge.Select.Update exposing (..)
import NixForge.Select.View.Instructions exposing (..)


viewApps : Dict String App -> Maybe App -> String -> List (Html UpdateSelect)
viewApps apps selectedApp filter =
    apps
        |> Dict.filter (\name app -> String.contains filter name)
        |> Dict.values
        |> List.map (\app -> viewApp app selectedApp)


viewApp : App -> Maybe App -> Html UpdateSelect
viewApp app selectedApp =
    a
        [ href ("/app/" ++ App.unAppName app.name)
        , class
            ("list-group-item list-group-item-action flex-column align-items-start" ++ appActiveState app selectedApp)
        , onClick (UpdateSelect_App app)
        ]
        [ div
            [ name ("app-" ++ App.unAppName app.name)
            , class "d-flex w-100 justify-content-between"
            ]
            [ h5 [ class "mb-1" ] [ text (App.unAppName app.name) ]
            , small [] [ text ("v" ++ app.version) ]
            ]
        , p
            [ class "mb-1"
            ]
            [ text app.description ]
        , p
            [ class "mb-1 "
            ]
            [ small []
                (List.concat
                    [ if app.programs.enable then
                        [ span [ class "badge bg-secondary me-1" ] [ text "programs" ] ]

                      else
                        []
                    , if app.containers.enable then
                        [ span [ class "badge bg-secondary me-1" ] [ text "containers" ] ]

                      else
                        []
                    , if app.oci |> Dict.values |> List.any (\x -> x.enable) then
                        [ span [ class "badge bg-secondary" ] [ text "oci" ] ]

                      else
                        []
                    ]
                )
            ]
        ]


appActiveState : App -> Maybe App -> String
appActiveState app selectedApp =
    case selectedApp of
        Just sel ->
            if app.name == sel.name then
                "active"

            else
                "inactive"

        Nothing ->
            "inactive"
