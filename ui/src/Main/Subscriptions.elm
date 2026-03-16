module Main.Subscriptions exposing (..)

import Browser.Events
import Json.Decode as Decode
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Ports.Navigation
import Main.Route exposing (..)
import Main.Update exposing (..)
import Navigation


subscriptions : Model -> Sub Update
subscriptions model =
    Sub.batch
        [ Navigation.onEvent Main.Ports.Navigation.onNavEvent Update_Navigation
        , case model.model_page of
            Page_App pageApp ->
                if pageApp.pageApp_route.routeApp_runShown then
                    Browser.Events.onKeyDown
                        (decodeEscapeKey
                            |> Decode.map
                                (\showRun ->
                                    let
                                        route =
                                            pageApp.pageApp_route
                                    in
                                    Update_Route (Route_App { route | routeApp_runShown = showRun })
                                )
                        )

                else
                    Sub.none

            _ ->
                Sub.none
        ]


decodeEscapeKey : Decode.Decoder Bool
decodeEscapeKey =
    Decode.field "key" Decode.string
        |> Decode.andThen
            (\key ->
                if key == "Escape" then
                    Decode.succeed False

                else
                    Decode.fail "Not escape"
            )
