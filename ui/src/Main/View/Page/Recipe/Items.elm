module Main.View.Page.Recipe.Items exposing (viewPageRecipeOptionsItems)

import Html exposing (Html, a, article, code, div, h5, section, span, text)
import Html.Attributes exposing (class, href, id, style)
import List.Extra as List
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Helpers.AppUrl exposing (..)
import Main.Helpers.Html exposing (..)
import Main.Helpers.List as List
import Main.Helpers.Markdown as Markdown
import Main.Helpers.Nix exposing (..)
import Main.Helpers.Tree as Tree
import Main.Icons exposing (..)
import Main.Model exposing (..)
import Main.Model.Page exposing (..)
import Main.Model.Preferences exposing (..)
import Main.Route exposing (..)
import Main.Update exposing (..)
import Main.Update.Route.Recipe exposing (..)
import Main.Update.Types exposing (..)
import Main.View.Nix exposing (..)
import Main.View.Page.App exposing (..)
import Main.View.Pagination exposing (..)
import Tree exposing (Tree)


viewPageRecipeOptionsItems : Model -> PageRecipeOptions -> Html Update
viewPageRecipeOptionsItems model page =
    viewPagination
        PaginationVisibility_AlwaysVisible
        page.pageRecipeOptions_pagination
        (viewPageRecipeOptionsItem model page)
        (\modifyRoutePagination ->
            let
                route =
                    page.pageRecipeOptions_route
            in
            Route_RecipeOptions
                { route
                    | routeRecipeOptions_pagination = route.routeRecipeOptions_pagination |> modifyRoutePagination
                    , routeRecipeOptions_focus = Nothing
                }
        )


viewItemNode : PageRecipeOptions -> InhRouteOptionsItem -> Tree NodeNixOptionFiltered -> List (Html Update)
viewItemNode page inh tree =
    let
        route =
            page.pageRecipeOptions_route
    in
    case tree |> Tree.label of
        NodeNixOptionFiltered_Out _ ->
            []

        NodeNixOptionFiltered_In ( _, opts ) ->
            let
                path =
                    pathRecipeOption inh tree
            in
            [ section
                [ id <| "option-" ++ joinNixPath path
                ]
              <|
                List.concat
                    [ [ code [ class "fs-5" ] [ text (path |> joinNixPath) ]
                      ]
                    , case route.routeRecipeOptions_focus of
                        Nothing ->
                            []

                        Just focus ->
                            case focus of
                                RouteRecipeOptionsFocus_Option focusPath ->
                                    if focusPath == path then
                                        [ viewItemNodeFocus page inh tree opts ]

                                    else
                                        []
                    ]
            ]


routeItemToggle : PageRecipeOptions -> NixPath -> Route
routeItemToggle page path =
    let
        route =
            page.pageRecipeOptions_route
    in
    Route_RecipeOptions <|
        { route
            | routeRecipeOptions_focus =
                Just <|
                    RouteRecipeOptionsFocus_Option path
        }


viewItemNodeFocus : PageRecipeOptions -> InhRouteOptionsItem -> Tree NodeNixOptionFiltered -> List NixModuleOption -> Html Update
viewItemNodeFocus page inh tree opts =
    div
        [ class "recipe-options-item"
        , style "margin-left" "2rem"
        , style "display" "grid"
        , style "grid-template-columns" "10rem 1fr"
        , style "gap" "0rem 1rem"
        ]
        (opts
            |> List.concatMap
                (\opt ->
                    List.concatMap
                        (\kv ->
                            case kv of
                                Nothing ->
                                    []

                                Just ( k, v ) ->
                                    [ text k
                                    , v
                                    ]
                        )
                        [ Just
                            ( "Type"
                            , code [] [ text opt.nixModuleOption_type ]
                            )
                        , opt.nixModuleOption_default
                            |> Maybe.map
                                (\default ->
                                    ( "Default"
                                    , default |> viewNixLiteralExpression
                                    )
                                )
                        , Just
                            ( "Description"
                            , opt.nixModuleOption_description
                                |> Markdown.render
                            )
                        , opt.nixModuleOption_example
                            |> Maybe.map
                                (\example ->
                                    ( "Example"
                                    , example |> viewNixLiteralExpression
                                    )
                                )
                        ]
                )
        )


viewPageRecipeOptionsItem : Model -> PageRecipeOptions -> ( NixPath, NixModuleOption ) -> Html Update
viewPageRecipeOptionsItem _ pageRecipeOptions ( optionPath, option ) =
    let
        routeRecipeOptions =
            pageRecipeOptions.pageRecipeOptions_route

        optionName =
            optionPath |> joinNixPath

        onClickRoute =
            Route_RecipeOptions
                { routeRecipeOptions
                    | routeRecipeOptions_focus = Just <| RouteRecipeOptionsFocus_Option optionPath
                }
    in
    a
        [ class "list-item list-group-item list-group-item-action flex-column align-items-start"
        , href (onClickRoute |> routeToString)
        , id optionName
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
                [ option.nixModuleOption_description
                    |> Markdown.render
                ]
            ]
        ]
