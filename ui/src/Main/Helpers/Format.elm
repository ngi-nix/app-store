module Main.Helpers.Format exposing (dedent, format)


format : String -> List String -> String
format template replacements =
    let
        replace index replacement result =
            String.replace ("{" ++ String.fromInt index ++ "}") replacement result
    in
    List.indexedMap Tuple.pair replacements
        |> List.foldl (\( i, r ) acc -> replace i r acc) template


dedent : String -> String
dedent str =
    let
        lines =
            String.lines str

        countIndent line =
            let
                trimmed =
                    String.trimLeft line
            in
            if String.isEmpty trimmed then
                Nothing

            else
                Just (String.length line - String.length trimmed)

        minIndent =
            lines
                |> List.filterMap countIndent
                |> List.minimum
                |> Maybe.withDefault 0
    in
    lines
        |> List.map (String.dropLeft minIndent)
        |> String.join "\n"
        |> String.trim
