module UDialog exposing (update)
import Delay exposing (after)
import Time exposing (millisecond)
import Dom exposing (focus)
import Task

import GraphQL exposing (query, mutation, getConventionPage, addConvention)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Dialog exposing (Dialog(..))
import Convention exposing (Convention(..))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  CloseDialog -> { model | dialog = Closed model.dialog } ! [ after 300 millisecond EmptyDialog ]
  EmptyDialog -> { model | dialog = None } ! []
  ShowErrorMessage err -> { model | dialog = Error err } ! [ focusClose ]
  OpenChooseConvention -> { model | dialog = ChooseConvention { data = [], pages = 0, page = 0 } } ![ focusClose, loadConventions 0 model ]
  DialogPage offset ->
    case model.dialog of
      ChooseConvention { data, pages, page } ->
        { model
        | dialog = ChooseConvention { data = data, pages = pages, page = (page + offset) }
        } ! [ loadConventions (page + offset) model ]
      _ -> model ! []
  AddConvention con ->
    let user = model.user in
    if user.keys > 0 then
      { model
      | user =
        { user
        | conventions = Meta con :: user.conventions
        , keys = user.keys - 1
        }
      } ! [ purchaseConvention con.code model ]
    else model ! [] -- silent fail because the button should be disabled
  _ -> model ! []

focusClose : Cmd Msg
focusClose = focus "dialog-focus-target" |> Task.attempt (always Ignore)

loadConventions : Int -> Model -> Cmd Msg
loadConventions = query DidLoadChooseConvention << (flip getConventionPage 5)

purchaseConvention : String -> Model -> Cmd Msg
purchaseConvention = mutation (always Ignore) << addConvention
