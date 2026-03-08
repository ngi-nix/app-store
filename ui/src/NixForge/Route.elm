module NixForge.Route exposing (..)

import AppUrl exposing (AppUrl)
import NixForge.Config.Package as Package


type Updater model cmd
    = Updater_Route Route
    | Updater_Model model
    | Updater_Cmd ( model, Cmd cmd )


type Route
    = Route_Select RouteSelect
    | Route_Create RouteCreate


type RouteSelect
    = RouteSelect_List
    | RouteSelect_Package Package.PackageName


type RouteCreate
    = RouteCreate_List


type Slug
    = Slug String


fromAppUrl : AppUrl -> Maybe Route
fromAppUrl url =
    case url.path of
        [] ->
            Just (Route_Select RouteSelect_List)

        [ "package", pkg ] ->
            case Package.packageName pkg of
                Just p ->
                    Just (Route_Select (RouteSelect_Package p))

                Nothing ->
                    Nothing

        [ "create" ] ->
            Just (Route_Create RouteCreate_List)

        _ ->
            Nothing


toAppUrl : Route -> AppUrl
toAppUrl page =
    case page of
        Route_Select rt ->
            case rt of
                RouteSelect_List ->
                    AppUrl.fromPath []

                RouteSelect_Package (Package.PackageName pkg) ->
                    AppUrl.fromPath [ "package", pkg ]

        Route_Create rt ->
            case rt of
                RouteCreate_List ->
                    AppUrl.fromPath [ "create" ]


toString : Route -> String
toString =
    toAppUrl >> AppUrl.toString
