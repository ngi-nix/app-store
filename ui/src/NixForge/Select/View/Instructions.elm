module NixForge.Select.View.Instructions exposing
    ( appInstructionsHtml
    , footerHtml
    , headerHtml
    , installInstructionsHtml
    , installNixCmd
    , packageInstructionsHtml
    , runPackageContainerCmd
    , runPackageShellCmd
    )

import Dict
import Html exposing (Html, a, br, button, code, div, h2, h3, hr, p, pre, span, text)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Markdown
import NixForge.Config.App as App exposing (App)
import NixForge.Config.Package exposing (Package)
import NixForge.Format exposing (format)


repositoryToGithubUrl : String -> String
repositoryToGithubUrl repositoryUrl =
    if String.startsWith "github:" repositoryUrl then
        "https://github.com/" ++ String.dropLeft 7 repositoryUrl

    else if String.startsWith "path:" repositoryUrl then
        "#"

    else
        repositoryUrl


codeBlock : (String -> msg) -> String -> Html msg
codeBlock onCopy content =
    div [ class "position-relative" ]
        [ button
            [ class "btn btn-sm btn-outline-secondary position-absolute top-0 end-0 m-2"
            , onClick (onCopy content)
            ]
            [ text "Copy" ]
        , pre [ class "bg-dark text-warning p-3 rounded border border-secondary" ]
            [ code [] [ text content ] ]
        ]


headerHtml : Html msg
headerHtml =
    p []
        [ span
            [ style "margin-right" "10px" ]
            [ text "[Nix Forge]" ]
        , span
            [ class "fs-2 text-secondary" ]
            [ text "the software distribution system" ]
        ]


footerHtml : Html msg
footerHtml =
    p [ class "text-center" ]
        [ span
            [ class "text-secondary fs-8" ]
            [ text "Powered by "
            , a
                [ href "https://nixos.org"
                , target "_blank"
                ]
                [ text "Nix," ]
            , a
                [ href "https://github.com/NixOS/nixpkgs"
                , target "_blank"
                ]
                [ text " Nixpkgs" ]
            , a
                [ href "https://elm-lang.org"
                , target "_blank"
                ]
                [ text " and Elm"
                , text " . "
                ]
            , text "Developed by "
            , a
                [ href "https://github.com/imincik"
                , target "_blank"
                ]
                [ text "@imincik." ]
            , text " Contribute or report issues in "
            , a
                [ href "https://github.com/imincik/nix-forge"
                , target "_blank"
                ]
                [ text "github:imincik/nix-forge" ]
            , text " ."
            ]
        ]


installNixCmd : String
installNixCmd =
    """curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
"""


acceptFlakeConfigCmd : String
acceptFlakeConfigCmd =
    """export NIX_CONFIG="accept-flake-config = true\""""


installInstructionsHtml : (String -> msg) -> List (Html msg)
installInstructionsHtml onCopy =
    [ h2 [] [ text "QUICK START" ]
    , p [ style "margin-bottom" "0em" ]
        [ text "1. Install Nix "
        , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
            [ text "(learn more about this installer)." ]
        ]
    , codeBlock onCopy installNixCmd
    , text "2. Accept binaries pre-built by Nix Forge (optional, highly recommended) "
    , codeBlock onCopy acceptFlakeConfigCmd
    , p [ style "margin-bottom" "0em" ] [ text "and select a package or application to see the usage instructions." ]
    ]


runPackageShellCmd : String -> Package -> String
runPackageShellCmd repositoryUrl pkg =
    format """nix shell {0}#{1}
""" [ repositoryUrl, pkg.name ]


runPackageContainerCmd : String -> Package -> String
runPackageContainerCmd repositoryUrl pkg =
    format """nix build {0}#{1}.image

podman load < ./result
podman run -it --rm localhost/{1}:{2}
""" [ repositoryUrl, pkg.name, pkg.version ]


enterPackageDevenvCmd : String -> Package -> String
enterPackageDevenvCmd repositoryUrl pkg =
    format """nix develop {0}#{1}.devenv
""" [ repositoryUrl, pkg.name ]


packageInstructionsHtml : String -> String -> (String -> msg) -> Maybe Package -> List (Html msg)
packageInstructionsHtml repositoryUrl recipeDirPackages onCopy maybePkg =
    case maybePkg of
        Nothing ->
            [ text "No package is selected."
            ]

        Just pkg ->
            [ h2 [] [ text pkg.name ]
            , hr [] []
            , h3 [] [ text "USAGE" ]
            , p
                [ style "margin-bottom" "0em"
                ]
                [ text "Run package in a shell environment" ]
            , codeBlock onCopy (runPackageShellCmd repositoryUrl pkg)
            , p
                [ style "margin-bottom" "0em"
                ]
                [ text "Run package in a container" ]
            , codeBlock onCopy (runPackageContainerCmd repositoryUrl pkg)
            , hr [] []
            , h3 [] [ text "DEVELOPMENT" ]
            , p
                [ style "margin-bottom" "0em"
                ]
                [ text "Enter development environment (all dependencies included)" ]
            , codeBlock onCopy (enterPackageDevenvCmd repositoryUrl pkg)
            , hr [] []
            , text "Home page: "
            , a
                [ href pkg.homePage
                , target "_blank"
                ]
                [ text pkg.homePage ]
            , br [] []
            , text "Recipe : "
            , a
                [ href (repositoryToGithubUrl repositoryUrl ++ "/blob/master/" ++ recipeDirPackages ++ "/" ++ pkg.name ++ "/recipe.nix")
                , target "_blank"
                ]
                [ text (recipeDirPackages ++ "/" ++ pkg.name ++ "/recipe.nix") ]
            ]


runAppShellCmd : String -> App -> String
runAppShellCmd repositoryUrl app =
    format """nix shell {0}#{1}
""" [ repositoryUrl, App.unAppName app.name ]


runAppContainerCmd : String -> App -> String
runAppContainerCmd repositoryUrl app =
    format """nix build {0}#{1}.containers

for image in ./result/*.tar.gz; do
    podman load < $image
done

podman-compose --profile services --file $(pwd)/result/compose.yaml up
""" [ repositoryUrl, App.unAppName app.name ]


runAppVmCmd : String -> App -> String
runAppVmCmd repositoryUrl app =
    format """nix run {0}#{1}.oci
""" [ repositoryUrl, App.unAppName app.name ]


appInstructionsHtml : String -> String -> (String -> msg) -> Maybe App -> List (Html msg)
appInstructionsHtml repositoryUrl recipeDirApps onCopy maybeApp =
    case maybeApp of
        Nothing ->
            [ text "No application is selected."
            ]

        Just app ->
            [ h2 [] [ text (App.unAppName app.name) ]
            , hr [] []
            , h3 [] [ text "USAGE" ]
            , if not (String.isEmpty app.usage) then
                div []
                    [ Markdown.toHtml [ class "markdown-content" ] (String.trim app.usage)
                    , hr [] []
                    ]

              else
                text ""
            , if not app.programs.enable && not app.containers.enable && not (app.oci |> Dict.values |> List.any (\x -> x.enable)) then
                p [ style "color" "red" ] [ text "No output is enabled for this app. Enable at least one of the - programs, containers or OCI - in recipe file." ]

              else
                text ""
            , if app.programs.enable then
                div []
                    [ p [ style "margin-bottom" "0em" ] [ text "Run application programs (CLI, GUI) in a shell environment" ]
                    , codeBlock onCopy (runAppShellCmd repositoryUrl app)
                    ]

              else
                text ""
            , if app.containers.enable then
                div []
                    [ p [ style "margin-bottom" "0em" ] [ text "Run application services in containers" ]
                    , codeBlock onCopy (runAppContainerCmd repositoryUrl app)
                    ]

              else
                text ""
            , if app.oci |> Dict.values |> List.any (\x -> x.enable) then
                div []
                    (app.oci
                        |> Dict.toList
                        |> List.map
                            (\( n, v ) ->
                                div []
                                    [ p [ style "margin-bottom" "0em" ]
                                        [ text "Run application services in OCI container \"", text n, text "\"" ]
                                    , codeBlock onCopy (runAppVmCmd repositoryUrl app)
                                    ]
                            )
                    )

              else
                text ""
            , hr [] []
            , text "Recipe: "
            , a
                [ href (repositoryToGithubUrl repositoryUrl ++ "/blob/master/" ++ recipeDirApps ++ "/" ++ App.unAppName app.name ++ "/recipe.nix")
                , target "_blank"
                ]
                [ text (recipeDirApps ++ "/" ++ App.unAppName app.name ++ "/recipe.nix") ]
            , a
                [ href "options.html"
                , target "_blank"
                ]
                [ text " (configuration options)" ]
            ]
