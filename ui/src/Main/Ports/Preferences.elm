port module Main.Ports.Preferences exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Main.Model exposing (..)


port savePreferencesInstallString : String -> Cmd msg


savePreferencesInstall : PreferencesInstall -> Cmd msg
savePreferencesInstall pref =
    savePreferencesInstallString <|
        case pref of
            PreferencesInstall_NixFlakes ->
                "nix_flake"

            PreferencesInstall_NixTraditional ->
                "nix_traditional"


decodePreferencesInstall : Decoder PreferencesInstall
decodePreferencesInstall =
    Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "nix_flake" ->
                        Decode.succeed PreferencesInstall_NixFlakes

                    "nix_traditional" ->
                        Decode.succeed PreferencesInstall_NixTraditional

                    _ ->
                        Decode.fail <| "Invalid PreferencesInstall: " ++ s
            )
