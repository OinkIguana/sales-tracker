module Load exposing (update, user)
import Http

import Model exposing (Model)
import Msg exposing (Msg(..))
import ConRequest exposing (ConRequest(..))
import Dialog exposing (Dialog(..))
import Convention exposing (asMeta, Convention(Full))
import User
import List_

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  DidLoadUser (Ok (Success user)) -> ({ model | user = user }, Cmd.none)
  DidLoadChooseConvention (Ok (Success { data, page, pages })) ->
    case model.dialog of
      ChooseConvention _ -> ({ model | dialog = ChooseConvention { cons = data, pages = pages, page = page } }, Cmd.none)
      _ -> (model, Cmd.none)
  DidLoadConvention (Ok (Success con)) ->
    let user = model.user in
    let conventions = List_.updateAt (\c -> (asMeta c).code == con.code) (always (Full con)) user.conventions in
      ({ model | user = { user | conventions = conventions } }, Cmd.none)
  _ -> (model, Cmd.none)

user : Model -> Cmd Msg
user model =
  Http.send DidLoadUser <| Http.request
    { method = "Get"
    , headers = [ Http.header "Authorization" ("Bearer " ++ model.authtoken) ]
    , url = "/api/user"
    , body = Http.emptyBody
    , expect = Http.expectJson (ConRequest.decode User.decode)
    , timeout = Nothing
    , withCredentials = False }
