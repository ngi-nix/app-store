module NixForge.Select.View.Packages exposing (..)

import Html exposing (Html, a, div, h5, p, small, span, text)
import Html.Attributes exposing (class, href, name)
import Html.Events exposing (onClick)
import NixForge.Config exposing (..)
import NixForge.Config.App exposing (..)
import NixForge.Config.Package exposing (..)
import NixForge.Output exposing (..)
import NixForge.Route exposing (..)
import NixForge.Select.Model exposing (..)
import NixForge.Select.Update exposing (..)
import NixForge.Select.View.Instructions exposing (..)


viewPackages : List Package -> Maybe Package -> String -> List (Html UpdateSelect)
viewPackages pkgs selectedPkg filter =
    pkgs
        |> List.filter (\pkg -> String.contains filter pkg.name)
        |> List.map (\pkg -> viewPackage pkg selectedPkg)


viewPackage : Package -> Maybe Package -> Html UpdateSelect
viewPackage pkg selectedPkg =
    a
        [ href "#"
        , class
            ("list-group-item list-group-item-action flex-column align-items-start" ++ packageActiveState pkg selectedPkg)
        , onClick (UpdateSelect_Package pkg)
        ]
        [ div
            [ name ("package-" ++ pkg.name)
            , class "d-flex w-100 justify-content-between"
            ]
            [ h5 [ class "mb-1" ] [ text pkg.name ]
            , small [] [ text ("v" ++ pkg.version) ]
            ]
        , p
            [ class "mb-1"
            ]
            [ text pkg.description ]
        , p
            [ class "mb-1 "
            ]
            [ small [] [ span [ class "badge bg-secondary" ] [ text pkg.builder ] ] ]
        ]


packageActiveState : Package -> Maybe Package -> String
packageActiveState pkg selectedPkg =
    case selectedPkg of
        Just sel ->
            if pkg.name == sel.name then
                "active"

            else
                "inactive"

        Nothing ->
            "inactive"
