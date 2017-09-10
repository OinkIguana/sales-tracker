module Page exposing (Page(..), signIn)
import Status exposing (Status(..))

type Page
  = Dashboard
  | Products
  | Prices
  | Convention
  | SignIn { email: String
           , password: String
           , c_email: String
           , c_password: String
           , terms_accepted: Bool
           , is_sign_in: Bool
           , status: Status }

signIn : Page
signIn = SignIn { email = "", password = "", c_email = "", c_password = "", terms_accepted = False, is_sign_in = True, status = Success "" }