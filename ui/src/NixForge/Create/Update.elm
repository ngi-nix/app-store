module NixForge.Create.Update exposing (..)

import Dict
import Http
import NixForge.Clipboard exposing (copyToClipboard)
import NixForge.Config exposing (..)
import NixForge.Config.App exposing (..)
import NixForge.Config.Package exposing (..)
import NixForge.Create.Model exposing (..)
import NixForge.HTTP as HTTP
import NixForge.Option exposing (..)
import NixForge.Output exposing (..)
import NixForge.Route exposing (..)


type UpdateCreate
    = UpdateCreate_CopyCode String
    | UpdateCreate_GetConfig (Result Http.Error Config)
    | UpdateCreate_GetOptions (Result Http.Error OptionsData)
    | UpdateCreate_Recipe
    | UpdateCreate_RecipeValue String
    | UpdateCreate_Route Route
    | UpdateCreate_Search String
    | UpdateCreate_SelectCategory OutputCategory
    | UpdateCreate_SelectFilter (Maybe String)
    | UpdateCreate_SelectOption Option


updateCreate : UpdateCreate -> ModelCreate -> Updater ModelCreate UpdateCreate
updateCreate msg model =
    case msg of
        UpdateCreate_CopyCode code ->
            Updater_Cmd
                ( model, copyToClipboard code )

        UpdateCreate_GetConfig res ->
            case res of
                Ok config ->
                    Updater_Model
                        { model
                            | packagesFilter = config.packagesFilter
                            , appsFilter = config.appsFilter
                            , recipeDirPackages = config.recipeDirs.packages
                            , recipeDirApps = config.recipeDirs.apps
                        }

                Err err ->
                    Updater_Model
                        { model | error = Just (HTTP.errorToString err) }

        UpdateCreate_GetOptions res ->
            case res of
                Ok optionsData ->
                    Updater_Model
                        { model
                            | options =
                                Dict.values optionsData
                                    |> List.sortBy .name
                            , error = Nothing
                        }

                Err err ->
                    Updater_Model
                        { model | error = Just (HTTP.errorToString err) }

        UpdateCreate_Recipe ->
            Updater_Model
                { model | showInstructions = True, selectedOption = Nothing }

        UpdateCreate_RecipeValue value ->
            case model.selectedOption of
                Just option ->
                    let
                        updatedOption =
                            { option | value = value }
                    in
                    Updater_Model
                        { model
                            | selectedOption = Just updatedOption
                            , options =
                                List.map
                                    (\opt ->
                                        if opt.name == option.name then
                                            updatedOption

                                        else
                                            opt
                                    )
                                    model.options
                        }

                Nothing ->
                    Updater_Model
                        model

        UpdateCreate_Route route ->
            case route of
                Route_Create r ->
                    Updater_Cmd (routeCreate r model)

                _ ->
                    Updater_Route route

        UpdateCreate_Search string ->
            Updater_Model
                { model | searchString = string }

        UpdateCreate_SelectCategory category ->
            Updater_Model
                { model | category = category, selectedOption = Nothing, showInstructions = False }

        UpdateCreate_SelectFilter filter ->
            case model.category of
                OutputCategory_Packages ->
                    Updater_Model
                        { model | packagesSelectedFilter = filter }

                OutputCategory_Applications ->
                    Updater_Model
                        { model | appsSelectedFilter = filter }

        UpdateCreate_SelectOption option ->
            Updater_Model
                { model | selectedOption = Just option, showInstructions = False }


routeCreate : RouteCreate -> ModelCreate -> ( ModelCreate, Cmd UpdateCreate )
routeCreate rt model =
    case rt of
        RouteCreate_List ->
            ( { model
                | category = OutputCategory_Packages
              }
            , Cmd.none
            )


getOptionCategory : Option -> Maybe OutputCategory
getOptionCategory option =
    if String.startsWith "packages" option.name then
        Just OutputCategory_Packages

    else if String.startsWith "apps" option.name then
        Just OutputCategory_Applications

    else
        Nothing
