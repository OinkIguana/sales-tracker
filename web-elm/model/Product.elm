module Product exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Json

import List_

type alias NewProduct =
  { localId: Int
  , name: String
  , quantity: Int
  , type_id: Int }

type alias FullProduct =
  { id: Int
  , name: String
  , quantity: Int
  , type_id: Int
  , discontinued: Bool }

type alias RequestProduct =
  { kind: String
  , id: Maybe Int
  , type_id: Int
  , name: String
  , quantity: Int
  , discontinued: Bool }

type Product
  = Clean FullProduct
  | Dirty FullProduct
  | New NewProduct

isDirty : Product -> Bool
isDirty prod = case prod of
  Clean _ -> False
  Dirty _ -> True
  New   _ -> True

decode : Decoder FullProduct
decode =
  Decode.map5 FullProduct
    (Decode.field "id" Decode.int)
    (Decode.field "name" Decode.string)
    (Decode.field "quantity" Decode.int)
    (Decode.field "type" Decode.int)
    (Decode.field "discontinued" Decode.bool)

normalize : Product -> FullProduct
normalize prod = case prod of
  Clean p -> p
  Dirty p -> p
  New   p -> FullProduct -p.localId p.name p.quantity p.type_id False

setName : String -> Product -> Product
setName name product = case product of
  New p -> New { p | name = name }
  Clean p -> Dirty { p | name = name }
  Dirty p -> Dirty { p | name = name }

setQuantity : String -> Product -> Product
setQuantity quantityStr product =
  case notSoBuggyToInt quantityStr of
    Ok quantity ->
      case product of
        New p   -> New { p | quantity = quantity }
        Clean p -> Dirty { p | quantity = quantity }
        Dirty p -> Dirty { p | quantity = quantity }
    Err _ ->
      case product of
        New p   -> New { p | quantity = 0 }
        Clean p -> Dirty { p | quantity = 0 }
        Dirty p -> Dirty { p | quantity = 0 }

toggleDiscontinued : Product -> Maybe Product
toggleDiscontinued product = case product of
  New p   -> Nothing
  Clean p -> Just <| Dirty { p | discontinued = not p.discontinued }
  Dirty p -> Just <| Dirty { p | discontinued = not p.discontinued }

notSoBuggyToInt : String -> Result String Int
notSoBuggyToInt str = case str of
  "-" -> Err "Not a number"
  "+" -> Err "Not a number"
  _   -> String.toInt str

requestFormat : Product -> Maybe RequestProduct
requestFormat product = case product of
  New p   -> Just <| RequestProduct "create" Nothing p.type_id p.name p.quantity False
  Clean p -> Nothing
  Dirty p -> Just <| RequestProduct "modify" (Just p.id) p.type_id p.name p.quantity p.discontinued

requestJson : RequestProduct -> Json.Value
requestJson request = Json.object
  [ ("kind", Json.string request.kind)
  , ("id", request.id |> Maybe.map Json.int |> Maybe.withDefault Json.null )
  , ("type", Json.int request.type_id)
  , ("name", Json.string request.name)
  , ("quantity", Json.int request.quantity)
  , ("discontinued", Json.bool request.discontinued) ]

individualClean : List FullProduct -> Product -> Product
individualClean updates product =
  let replaceNew = \p ->
    updates
      |> List_.find (\x -> x.name == p.name)
      |> Maybe.map Clean
      |> Maybe.withDefault (New p)
  in
    case product of
      Clean _ -> product
      Dirty p -> Clean p
      New   p -> replaceNew p

clean : List FullProduct -> List Product -> List Product
clean updates = List.map (individualClean updates)
