module NixForge.Create.View exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, rows, style, target, value)
import Html.Events exposing (onClick, onInput)
import NixForge.Config exposing (..)
import NixForge.Config.App exposing (..)
import NixForge.Config.Package exposing (..)
import NixForge.Create.Model exposing (..)
import NixForge.Create.Update exposing (..)
import NixForge.Format exposing (format)
import NixForge.Option exposing (..)
import NixForge.Output exposing (..)


viewCreate : ModelCreate -> Html UpdateCreate
viewCreate model =
    div [ class "container" ]
        [ -- content
          div [ class "row" ]
            [ -- options list panel
              div [ class "col-lg-6 border bg-light py-3 my-3" ]
                [ div [ class "d-flex gap-2 align-items-center" ]
                    [ div [ class "flex-grow-1" ] (searchHtml model.searchString)
                    , button [ class "btn btn-primary", onClick UpdateCreate_Recipe ] [ text "Create recipe" ]
                    ]
                , div [ class "d-flex btn-group align-items-center my-2" ]
                    (categoryTabsHtml model.category)

                -- options filter buttons
                , div []
                    [ hr [] []
                    , div [ class "d-flex flex-wrap gap-2 my-2" ]
                        (optionsFilterHtml
                            (case model.category of
                                OutputCategory_Packages ->
                                    model.packagesSelectedFilter

                                OutputCategory_Applications ->
                                    model.appsSelectedFilter
                            )
                            (case model.category of
                                OutputCategory_Packages ->
                                    model.packagesFilter

                                OutputCategory_Applications ->
                                    model.appsFilter
                            )
                        )
                    ]

                -- separator
                , div [] [ hr [] [] ]

                -- options list
                , div [ class "list-group" ]
                    (optionsHtml model.options
                        model.selectedOption
                        model.searchString
                        model.category
                        (case model.category of
                            OutputCategory_Packages ->
                                model.packagesSelectedFilter

                            OutputCategory_Applications ->
                                model.appsSelectedFilter
                        )
                        (case model.category of
                            OutputCategory_Packages ->
                                model.packagesFilter

                            OutputCategory_Applications ->
                                model.appsFilter
                        )
                    )

                -- error message
                , case model.error of
                    Just errUpdate ->
                        div [ class "alert alert-danger mt-3" ] [ text ("Error: " ++ errUpdate) ]

                    Nothing ->
                        text ""
                ]

            -- option details or instructions panel
            , div [ class "col-lg-6 bg-dark text-white py-3 my-3" ]
                [ if model.showInstructions then
                    instructionsHtml model.category model.recipeDirPackages model.recipeDirApps model.options

                  else
                    case model.selectedOption of
                        Just option ->
                            optionDetailsHtml option

                        Nothing ->
                            initialInstructionsHtml
                ]
            ]
        ]


initialInstructionsHtml : Html UpdateCreate
initialInstructionsHtml =
    div []
        [ h2 [] [ text "NEW RECIPE" ]
        , p [ style "margin-bottom" "0em" ] [ text "Configure recipe options and click on 'Create recipe' button," ]
        , br [] []
        , p [ style "margin-bottom" "0em" ]
            [ text "or use LLM to generate recipes using provided "
            , a [ href "./resources/AGENTS.md", class "text-warning", target "_blank" ] [ text "AGENTS.md" ]
            , text " file"
            ]
        , codeBlock agentsPromptText
        ]


instructionsHtml : OutputCategory -> String -> String -> List Option -> Html UpdateCreate
instructionsHtml category recipeDirPackages recipeDirApps options =
    case category of
        OutputCategory_Packages ->
            let
                recipeContent =
                    generateRecipeContent category options
            in
            div [ class "p-3" ]
                [ h5 [] [ text "NEW PACKAGE" ]
                , hr [] []
                , p [] [ text "1. Create a new package directory" ]
                , codeBlock (newDirectoryCmd (recipeDirPackages ++ "/" ++ newPackageName options))
                , p [] [ text "2. Create a recipe file and add it to git" ]
                , codeBlock (newRecipeFile (recipeDirPackages ++ "/" ++ newPackageName options ++ "/recipe.nix") recipeContent)
                , codeBlock (addFileToGitCmd (recipeDirPackages ++ "/" ++ newPackageName options ++ "/recipe.nix"))
                , p [] [ text "3. Test build" ]
                , codeBlock (buildPackageCmd (newPackageName options))
                , p [] [ text "4. Run test" ]
                , codeBlock (runPackageTestCmd (newPackageName options))
                , p [] [ text "5. Submit PR" ]
                , codeBlock (addFileToGitCmd (recipeDirPackages ++ "/" ++ newPackageName options ++ "/recipe.nix"))
                , codeBlock (submitPRCmd (newPackageName options))
                ]

        OutputCategory_Applications ->
            let
                recipeContent =
                    generateRecipeContent category options
            in
            div [ class "p-3" ]
                [ h5 [] [ text "NEW APPLICATION" ]
                , hr [] []
                , p [] [ text "1. Create a new application directory" ]
                , codeBlock (newDirectoryCmd (recipeDirApps ++ "/" ++ newAppName options))
                , p [] [ text "2. Create a recipe file and add it to git" ]
                , codeBlock (newRecipeFile (recipeDirApps ++ "/" ++ newAppName options ++ "/recipe.nix") recipeContent)
                , codeBlock (addFileToGitCmd (recipeDirApps ++ "/" ++ newAppName options ++ "/recipe.nix"))
                , p [] [ text "3. Test build" ]
                , codeBlock (buildAppCmd (newAppName options))
                , p [] [ text "4. Submit PR" ]
                , codeBlock (addFileToGitCmd (recipeDirApps ++ "/" ++ newAppName options ++ "/recipe.nix"))
                , codeBlock (submitPRCmd (newAppName options))
                ]


searchHtml : String -> List (Html UpdateCreate)
searchHtml searchString =
    [ input
        [ class "form-control form-control-lg py-2 my-2"
        , placeholder "Search options by name or description..."
        , value searchString
        , onInput UpdateCreate_Search
        ]
        []
    ]


categoryTabsHtml : OutputCategory -> List (Html UpdateCreate)
categoryTabsHtml activeCategory =
    let
        categories =
            [ ( OutputCategory_Packages, "PACKAGES" )
            , ( OutputCategory_Applications, "APPLICATIONS" )
            ]

        buttonItem ( value, label ) =
            button
                [ class
                    ("btn btn-lg "
                        ++ (if value == activeCategory then
                                "btn-dark"

                            else
                                "btn-secondary"
                           )
                    )
                , onClick (UpdateCreate_SelectCategory value)
                ]
                [ text label ]
    in
    List.map buttonItem categories


optionsFilterHtml : Maybe String -> OptionsFilter -> List (Html UpdateCreate)
optionsFilterHtml activeFilter filters =
    let
        allButton =
            button
                [ class
                    ("btn btn-sm "
                        ++ (if activeFilter == Nothing then
                                "btn-warning"

                            else
                                "btn-outline-warning"
                           )
                    )
                , onClick (UpdateCreate_SelectFilter Nothing)
                ]
                [ text "All" ]

        filterButton ( optionName, _ ) =
            button
                [ class
                    ("btn btn-sm "
                        ++ (if activeFilter == Just optionName then
                                "btn-warning"

                            else
                                "btn-outline-warning"
                           )
                    )
                , onClick (UpdateCreate_SelectFilter (Just optionName))
                ]
                [ text optionName ]
    in
    allButton :: List.map filterButton (Dict.toList filters)


optionActiveState : Option -> Maybe Option -> String
optionActiveState option selectedOption =
    case selectedOption of
        Just selected ->
            if option.name == selected.name then
                " active"

            else
                " inactive"

        Nothing ->
            " inactive"


cleanOptionName : String -> String
cleanOptionName name =
    name
        |> String.replace "packages.*." ""
        |> String.replace "apps.*." ""


optionValue : Option -> String
optionValue option =
    if String.isEmpty option.value then
        option.default
            |> Maybe.map .text
            |> Maybe.withDefault ""

    else
        option.value


getOptionValue : String -> List Option -> String
getOptionValue name options =
    options
        |> List.filter (\opt -> opt.name == name)
        |> List.head
        |> Maybe.map optionValue
        |> Maybe.withDefault "no-value"


getGroupSortOrder : OutputCategory -> String -> Int
getGroupSortOrder category prefix =
    case category of
        OutputCategory_Packages ->
            case String.toLower prefix of
                "source" ->
                    1

                "build" ->
                    2

                "test" ->
                    3

                "development" ->
                    4

                _ ->
                    99

        OutputCategory_Applications ->
            case String.toLower prefix of
                "programs" ->
                    1

                "containers" ->
                    2

                "vm" ->
                    3

                _ ->
                    99


optionHtml : Option -> Maybe Option -> Html UpdateCreate
optionHtml option selectedOption =
    let
        shortDesc =
            if String.isEmpty option.description then
                "This option has no description."

            else
                option.description
                    |> String.lines
                    |> List.head
                    |> Maybe.withDefault ""

        hasRecipeValue =
            not (String.isEmpty option.value)
    in
    a
        [ href ("#option-" ++ option.name)
        , class
            ("list-group-item list-group-item-action flex-column align-items-start" ++ optionActiveState option selectedOption)
        , onClick (UpdateCreate_SelectOption option)
        ]
        [ div [ class "d-flex w-100 justify-content-between" ]
            [ h5 [ class "mb-1" ] [ text (cleanOptionName option.name) ]
            , if hasRecipeValue then
                span [ class "badge bg-warning text-dark", style "font-size" "1.2em" ] [ text "✓" ]

              else
                text ""
            ]
        , p [ class "mb-1" ] [ text shortDesc ]
        , small [] [ text ("Type: " ++ option.optionType) ]
        ]


optionsHtml : List Option -> Maybe Option -> String -> OutputCategory -> Maybe String -> OptionsFilter -> List (Html UpdateCreate)
optionsHtml options selectedOption filter category selectedFilter filters =
    let
        -- Get list of option names for the selected filter
        selectedFilterNames =
            selectedFilter
                |> Maybe.andThen (\filterName -> Dict.get filterName filters)

        -- Check if option should be included based on selected filter
        matchesFilter option =
            case selectedFilterNames of
                Nothing ->
                    True

                Just names ->
                    List.member option.name names

        filteredOptions =
            options
                |> List.filter
                    (\option ->
                        (String.contains (String.toLower filter) (String.toLower option.name)
                            || String.contains (String.toLower filter) (String.toLower option.description)
                        )
                            && (getOptionCategory option == Just category)
                            && (option.name /= "packages")
                            && (option.name /= "apps")
                            && matchesFilter option
                    )

        topLevelOptions =
            filteredOptions
                |> List.filter (\option -> not (String.contains "." (cleanOptionName option.name)))

        specificOptions =
            filteredOptions
                |> List.filter (\option -> String.contains "." (cleanOptionName option.name))

        -- Group specific options by their prefix (before first dot)
        groupedOptions =
            specificOptions
                |> List.foldl
                    (\option acc ->
                        let
                            prefix =
                                cleanOptionName option.name
                                    |> String.split "."
                                    |> List.head
                                    |> Maybe.withDefault ""
                        in
                        Dict.update prefix
                            (\maybeList ->
                                case maybeList of
                                    Just list ->
                                        Just (option :: list)

                                    Nothing ->
                                        Just [ option ]
                            )
                            acc
                    )
                    Dict.empty
                |> Dict.toList
                |> List.sortBy (\( prefix, _ ) -> getGroupSortOrder category prefix)

        renderGroup ( prefix, groupOptions ) =
            [ div [ class "fw-bold text-muted small px-3 pt-3 pb-1" ]
                [ text (String.toUpper prefix) ]
            ]
                ++ List.map (\option -> optionHtml option selectedOption) (List.reverse groupOptions)
    in
    if List.isEmpty filteredOptions then
        [ div [ class "p-3 text-center text-muted" ]
            [ text "No options found matching your search criteria." ]
        ]

    else
        List.map (\option -> optionHtml option selectedOption) topLevelOptions
            ++ List.concatMap renderGroup groupedOptions


formatDescription : String -> List (Html UpdateCreate)
formatDescription description =
    description
        |> String.lines
        |> List.map (\line -> p [] [ text line ])


optionDetailsHtml : Option -> Html UpdateCreate
optionDetailsHtml option =
    div [ class "p-3" ]
        [ h5 [ class "text-warning" ] [ text (cleanOptionName option.name) ]
        , hr [] []
        , p [ class "mb-1 fw-bold" ] [ text "Description:" ]
        , div [] (formatDescription option.description)
        , hr [] []
        , p [ class "mb-1 fw-bold" ] [ text "Type:" ]
        , p [] [ text option.optionType ]
        , case option.default of
            Just defaultVal ->
                div []
                    [ p [ class "mb-1 fw-bold" ] [ text "Default:" ]
                    , codeBlock defaultVal.text
                    ]

            Nothing ->
                text ""
        , case option.example of
            Just exampleVal ->
                div []
                    [ p [ class "mb-1 mt-3 fw-bold" ] [ text "Example:" ]
                    , codeBlock exampleVal.text
                    ]

            Nothing ->
                text ""
        , hr [] []
        , div [ class "d-flex justify-content-between align-items-center mb-1" ]
            [ p [ class "mb-0 fw-bold" ] [ text "Value:" ]
            , case option.example of
                Just exampleVal ->
                    if String.isEmpty exampleVal.text then
                        text ""

                    else
                        button
                            [ class "btn btn-sm btn-outline-warning"
                            , onClick (UpdateCreate_RecipeValue exampleVal.text)
                            ]
                            [ text "Copy example" ]

                Nothing ->
                    text ""
            ]
        , textarea
            [ class "form-control text-warning border-secondary"
            , style "background-color" "#2d2d2d"
            , value option.value
            , onInput UpdateCreate_RecipeValue
            , rows 3
            ]
            []
        ]


codeBlock : String -> Html UpdateCreate
codeBlock content =
    div [ class "position-relative" ]
        [ button
            [ class "btn btn-sm btn-outline-secondary position-absolute top-0 end-0 m-2"
            , onClick (UpdateCreate_CopyCode content)
            ]
            [ text "Copy" ]
        , pre [ class "bg-dark text-warning p-3 rounded border border-secondary" ]
            [ code [] [ text content ] ]
        ]



-- INSTRUCTIONS FUNCTIONS


generateRecipeContent : OutputCategory -> List Option -> String
generateRecipeContent category options =
    let
        filteredOptions =
            options
                |> List.filter (\opt -> getOptionCategory opt == Just category && not (String.isEmpty opt.value))

        ( topLevel, specific ) =
            filteredOptions
                |> List.partition (\opt -> not (String.contains "." (cleanOptionName opt.name)))

        grouped =
            specific
                |> List.foldl
                    (\opt acc ->
                        let
                            prefix =
                                cleanOptionName opt.name |> String.split "." |> List.head |> Maybe.withDefault ""
                        in
                        Dict.update prefix (\ml -> Just (opt :: Maybe.withDefault [] ml)) acc
                    )
                    Dict.empty
                |> Dict.toList
                |> List.sortBy (\( prefix, _ ) -> getGroupSortOrder category prefix)
                |> List.concatMap (Tuple.second >> List.reverse)

        -- `*` in option name will be replaced by `default` string
        format opt =
            "  " ++ String.replace "*" "default" (cleanOptionName opt.name) ++ " = " ++ opt.value ++ ";"
    in
    (topLevel ++ grouped)
        |> List.map format
        |> String.join "\n"


agentsPromptText : String
agentsPromptText =
    """Based on instructions in AGENTS.md file, analyze the source code
located in <SOURCE-CODE-LOCATION> and create a Nix Forge package
and application recipes.
"""


newPackageName : List Option -> String
newPackageName options =
    String.replace "\"" "" (getOptionValue "packages.*.name" options)


newAppName : List Option -> String
newAppName options =
    String.replace "\"" "" (getOptionValue "apps.*.name" options)


newDirectoryCmd : String -> String
newDirectoryCmd directory =
    format """mkdir -p {0}
touch {0}/recipe.nix
""" [ directory ]


newRecipeFile : String -> String -> String
newRecipeFile filename recipeContent =
    format """# {0}

{ config, lib, pkgs, mypkgs, ... }:

{
{1}
}
""" [ filename, recipeContent ]


addFileToGitCmd : String -> String
addFileToGitCmd filename =
    format "git add {0}" [ filename ]


buildPackageCmd : String -> String
buildPackageCmd package =
    format """nix build .#{0} -L
nix build .#{0}.image -L
""" [ package ]


buildAppCmd : String -> String
buildAppCmd package =
    format """nix build .#{0} -L
nix build .#{0}.containers -L
nix build .#{0}.vm -L
""" [ package ]


runPackageTestCmd : String -> String
runPackageTestCmd package =
    format "nix build .#{0}.test -L" [ package ]


submitPRCmd : String -> String
submitPRCmd package =
    format """git commit -m "Add new {0} recipe"
gh pr create
""" [ package ]
