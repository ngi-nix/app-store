module Main.View.Page.Recipe exposing (..)

import Html exposing (Html, a, button, code, div, h5, main_, nav, span, text)
import Html.Attributes exposing (attribute, class, disabled, href, id, style, title)
import List.Extra as List
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Helpers.AppUrl exposing (..)
import Main.Helpers.Html exposing (..)
import Main.Helpers.Markdown as Markdown
import Main.Helpers.Nix exposing (..)
import Main.Icons exposing (..)
import Main.Model exposing (..)
import Main.Model.Page exposing (..)
import Main.Model.Preferences exposing (..)
import Main.Route as Route exposing (..)
import Main.Update exposing (..)
import Main.View.Page.App exposing (..)
import Main.View.Pagination exposing (..)
import Set


viewPageRecipeOptionsLink : Html Update
viewPageRecipeOptionsLink =
    let
        onClickRoute =
            Route_RecipeOptions
                defaultRouteRecipeOptions
    in
    a
        [ href (onClickRoute |> Route.toString)
        , style "color" "inherit"
        , style "text-decoration" "none"
        , style "cursor" "pointer"
        , class "nav-link px-0 fw-bold"
        , title "View available recipe options"
        , attribute "aria-label" "View available recipe options"
        , onClick (Update_Route onClickRoute)
        ]
        [ text "Options" ]


viewPageRecipeOptions : Model -> PageRecipeOptions -> Html Update
viewPageRecipeOptions model pageRecipeOptions =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" "1rem"
        ]
        [ nav [] <|
            List.concat
                [ [ text "in " ]
                , pageRecipeOptions.pageRecipeOptions_ancestors
                    |> List.inits
                    |> List.indexedMap
                        (\idx path ->
                            let
                                route =
                                    pageRecipeOptions.pageRecipeOptions_route

                                onClickRoute =
                                    Route_RecipeOptions { route | routeRecipeOptions_searchPath = path }
                            in
                            code
                                []
                                [ text <|
                                    if idx == 0 then
                                        ""

                                    else
                                        "."
                                , a
                                    [ href (onClickRoute |> Route.toString)
                                    , onClick (Update_Route onClickRoute)
                                    ]
                                    [ text <|
                                        if idx == 0 then
                                            "<recipe>"

                                        else
                                            path |> List.last |> Maybe.withDefault ""
                                    ]
                                ]
                        )
                , [ text ":" ]
                ]
        , div
            [ style "display" "flex"
            , style "flex-direction" "row"
            , style "gap" "1rem"
            ]
            [ nav
                [ style "display" "flex"
                , style "flex-direction" "column"
                ]
                (pageRecipeOptions.pageRecipeOptions_children
                    |> Set.toList
                    |> List.map
                        (\child ->
                            let
                                route =
                                    pageRecipeOptions.pageRecipeOptions_route

                                onClickRoute =
                                    Route_RecipeOptions
                                        { route
                                            | routeRecipeOptions_searchPath =
                                                pageRecipeOptions.pageRecipeOptions_ancestors
                                                    ++ [ child ]
                                        }
                            in
                            code
                                []
                                [ text "."
                                , a
                                    [ href (onClickRoute |> Route.toString)
                                    , onClick (Update_Route onClickRoute)
                                    ]
                                    [ text child ]
                                ]
                        )
                )
            , main_
                [ style "flex-grow" "1"
                ]
                [ viewPagination
                    pageRecipeOptions.pageRecipeOptions_pagination
                    (viewPageRecipeOptionsItem model pageRecipeOptions)
                    (\modifyRoutePagination ->
                        let
                            routeRecipeOptions =
                                pageRecipeOptions.pageRecipeOptions_route
                        in
                        Route_RecipeOptions
                            { routeRecipeOptions
                                | routeRecipeOptions_pagination = routeRecipeOptions.routeRecipeOptions_pagination |> modifyRoutePagination
                                , routeRecipeOptions_focus = Nothing
                            }
                    )
                ]
            ]
        ]


viewPageRecipeOptionsItem : Model -> PageRecipeOptions -> ( NixName, NixModuleOption ) -> Html Update
viewPageRecipeOptionsItem _ pageRecipeOptions ( optionName, option ) =
    let
        routeRecipeOptions =
            pageRecipeOptions.pageRecipeOptions_route

        itemId =
            optionName

        onClickRoute =
            Route_RecipeOptions
                { routeRecipeOptions
                    | routeRecipeOptions_focus = Just <| RouteRecipeOptionsFocus_Option itemId
                }
    in
    a
        [ class "list-item list-group-item list-group-item-action flex-column align-items-start"
        , href (onClickRoute |> Route.toString)
        , id itemId
        , onClick (Update_Route onClickRoute)
        ]
        [ div [ class "d-flex w-100 justify-content-between" ]
            [ h5
                [ class "mb-1"
                ]
                [ code [] [ text optionName ]
                ]
            ]
        , div []
            [ span [ class "fw-bold" ] [ text "Type: " ]
            , code [] [ text option.nixModuleOption_type ]
            ]
        , div []
            [ span [ class "fw-bold" ] [ text "Description: " ]
            , div []
                (option.nixModuleOption_description
                    |> Markdown.render
                )
            ]
        ]
