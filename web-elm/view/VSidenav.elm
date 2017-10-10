module VSidenav exposing (view)
import Html exposing (Html, div, a, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onWithOptions, onClick)
import Json.Decode as Decode

import Model exposing (Model)
import Msg exposing (Msg(..))
import Lists exposing (list, row, clickable)
import Routing

navigateTo : String -> List (Html.Attribute Msg)
navigateTo url =
  let options =
    { stopPropagation = False
    , preventDefault = True }
  in
    [ onWithOptions "click" options (Decode.succeed <| DoNav url)
    , href url ]

doSignOut : List (Html.Attribute Msg)
doSignOut =
  let
    options =
      { stopPropagation = False
      , preventDefault = True }
  in let url = Routing.signInPath in
     [ onWithOptions "click" options (Decode.succeed <| DoSignOut )
     , href url ]

-- TODO: the items are tab focusable even when the sidenav is hidden
--       might be as simple as adding pointer-events: none to the closed menu
view : Model -> Html Msg
view { sidenav_visible } =
  let visibility = if sidenav_visible then "--open" else "" in
  let items =
    [ (navigateTo Routing.dashboardPath, "Dashboard")
    , (navigateTo Routing.inventoryPath, "Inventory")
    , (navigateTo Routing.pricingPath, "Pricing")
    , (navigateTo Routing.conventionsPath, "Conventions")
    , (navigateTo Routing.settingsPath, "Settings")
    , (doSignOut, "Sign Out") ] in
  div [ class "sidenav"]
    [ div [ class <| "sidenav__backdrop" ++ visibility, onClick ToggleSidenav ] []
    , div [ class <| "sidenav__content" ++ visibility ] [ list (uncurry navListRow) items ] ]

navListRow : List (Html.Attribute Msg) -> String -> Html Msg
navListRow attrs title =
  a ([ class "ca__nav-link", row] ++ clickable ++ attrs) [text title]
