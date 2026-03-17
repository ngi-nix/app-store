module Main.Helpers.Markdown exposing (..)

import Html exposing (Html, text)
import Main.Helpers.Html as Html
import Markdown.Parser
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)


render : (String -> update) -> String -> List (Html update)
render onCopy markdownStr =
    markdownStr
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "Failed to parse markdown")
        |> Result.andThen (Markdown.Renderer.render (customRenderer onCopy))
        |> Result.withDefault [ text "Error rendering markdown." ]


customRenderer : (String -> update) -> Renderer (Html update)
customRenderer onCopy =
    { defaultHtmlRenderer
        | codeBlock =
            \block ->
                block.body |> Html.codeBlock onCopy
    }
