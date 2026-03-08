module NixForge.Update exposing (..)

import Browser
import NixForge.Config exposing (..)
import NixForge.Config.App exposing (..)
import NixForge.Config.Package exposing (..)
import NixForge.Create exposing (..)
import NixForge.Create.Model exposing (..)
import NixForge.Create.Update exposing (..)
import NixForge.Model exposing (..)
import NixForge.Route exposing (..)
import NixForge.Select exposing (..)
import NixForge.Select.Model exposing (..)
import NixForge.Select.Update exposing (..)
import Url


type Update
    = Update_Create UpdateCreate
    | Update_Select UpdateSelect
    | Update_UrlChange Url.Url
    | Update_LinkClicked Browser.UrlRequest


update : Update -> Model -> ( Model, Cmd Update )
update upd currentModel =
    case ( upd, currentModel ) of
        ( Update_Select up, Model_Select currentModelSelect ) ->
            case updateSelect up currentModelSelect of
                Updater_Model newModel ->
                    ( Model_Select newModel, Cmd.none )

                Updater_Route newRoute ->
                    initRoute newRoute

                Updater_Cmd ( newModel, newCmd ) ->
                    ( Model_Select newModel, Cmd.map Update_Select newCmd )

        _ ->
            ( currentModel, Cmd.none )


initRoute : Route -> ( Model, Cmd Update )
initRoute route =
    case route of
        Route_Select rt ->
            case initSelect () of
                ( initModel, initCmd ) ->
                    case routeSelect rt initModel of
                        ( newModel, newCmd ) ->
                            ( Model_Select newModel, [ Cmd.map Update_Select initCmd, Cmd.map Update_Select newCmd ] |> Cmd.batch )

        Route_Create rt ->
            case initCreate () of
                ( initModel, initCmd ) ->
                    case routeCreate rt initModel of
                        ( newModel, newCmd ) ->
                            ( Model_Create newModel, [ Cmd.map Update_Create initCmd, Cmd.map Update_Create newCmd ] |> Cmd.batch )



{-
   updateRoute : Route -> Model -> ( Model, Cmd Update )
   updateRoute rt mod =
       case rt of
           Route_Select rtSelect ->
               case mod of
                   Model_Select modSelect ->
                       update (Update_Select (UpdateSelect_Route rt))
                       case updateSelect  modSelect of
                           ( finalModel, finalCmd ) ->
                               ( Model_Select finalModel
                               , Cmd.map Update_Select finalCmd
                               )

                   _ ->
                       case initSelect () of
                           ( initModel, initCmd ) ->
                               case updateRoute rt (Model_Select initModel) of
                                   ( finalModel, finalCmd ) ->
                                       ( finalModel
                                       , [ initCmd |> Cmd.map Update_Select, finalCmd ] |> Cmd.batch
                                       )


-}
{-
   liftUpdater :
       (up -> Update)
       -> (Update -> Maybe up)
       -> (model -> Model)
       -> (Model -> ( model, Cmd up ))
       -> (up -> model -> ( model, Cmd up ))
       -> Update
       -> Model
       -> ( Model, Cmd Update )
   liftUpdater injUp projUp injModel projModel upd up mod =
       case projUp up of
           Just correctUp ->
               case projModel mod of
                   ( correctModel, initCmd ) ->
                       case upd correctUp correctModel of
                           ( finalModel, finalCmd ) ->
                               ( injModel finalModel, Cmd.batch [ Cmd.map injUp initCmd, Cmd.map injUp finalCmd ] )



-}
{-
   UpdateSelect m ->
       case NixForge.Select.Update.update m mod of
           NixForge.Route.Updater_Route route ->
               ( Model { model | modelRoute = route }, Cmd.none )

           NixForge.Route.Updater_Model new ->
               ( Model { model | modelSelect = new }, Cmd.none )

           NixForge.Route.Updater_Cmd ( new, cmd ) ->
               ( Model { model | modelSelect = new }
               , Cmd.map UpdateSelect cmd
               )

   UpdateUrlChange url ->
       case NixForge.Route.fromAppUrl (AppUrl.fromUrl url) of
           Just r ->
               ( Model { model | modelRoute = r }, Cmd.none )

           Nothing ->
               ( Model model, Cmd.none )

   UpdateLinkClicked urlRequest ->
       case urlRequest of
           Browser.Internal url ->
               ( Model model, Browser.Navigation.pushUrl model.modelNavKey (Url.toString url) )

           Browser.External url ->
               ( Model model, Browser.Navigation.load url )
-}
