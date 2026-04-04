port module Main.Model.Preferences exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type alias Preferences =
    { preferences_install : PreferencesInstall
    , preferences_theme : PreferencesTheme
    }


defaultPreferences : Preferences
defaultPreferences =
    { preferences_install = PreferencesInstall_NixFlakes
    , preferences_theme = PreferencesTheme_Light
    }


decodePreferences : Decoder Preferences
decodePreferences =
    Decode.map2
        Preferences
        (Decode.field "install"
            (Decode.oneOf
                [ decodePreferencesInstall
                , Decode.succeed defaultPreferences.preferences_install
                ]
            )
        )
        (Decode.field "theme"
            (Decode.oneOf
                [ decodePreferencesTheme
                , Decode.succeed defaultPreferences.preferences_theme
                ]
            )
        )


type PreferencesInstall
    = PreferencesInstall_NixFlakes
    | PreferencesInstall_NixTraditional


port savePreferencesInstallString : String -> Cmd update


savePreferencesInstall : PreferencesInstall -> Cmd update
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


listPreferencesInstall : List PreferencesInstall
listPreferencesInstall =
    [ PreferencesInstall_NixFlakes
    , PreferencesInstall_NixTraditional
    ]


type PreferencesTheme
    = PreferencesTheme_Dark
    | PreferencesTheme_Light


port savePreferencesThemeString : Value -> Cmd update


savePreferencesTheme : PreferencesTheme -> Cmd update
savePreferencesTheme t =
    t
        |> encodePreferencesTheme
        |> savePreferencesThemeString


cyclePreferencesTheme : PreferencesTheme -> PreferencesTheme
cyclePreferencesTheme currentTheme =
    case currentTheme of
        PreferencesTheme_Light ->
            PreferencesTheme_Dark

        PreferencesTheme_Dark ->
            PreferencesTheme_Light


decodePreferencesTheme : Decoder PreferencesTheme
decodePreferencesTheme =
    Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "light" ->
                        Decode.succeed PreferencesTheme_Light

                    "dark" ->
                        Decode.succeed PreferencesTheme_Dark

                    _ ->
                        Decode.fail <| "Invalid PreferencesTheme: " ++ s
            )


encodePreferencesTheme : PreferencesTheme -> Value
encodePreferencesTheme theme =
    Encode.string <|
        case theme of
            PreferencesTheme_Light ->
                "light"

            PreferencesTheme_Dark ->
                "dark"
