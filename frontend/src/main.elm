port module Main exposing (..)

import Html exposing (div, button)
import Html.Events exposing (onClick)
import Html.App as App
import Json.Encode as Encode
import Task

import Api
import Ports
import Types
import Models.Model as Model


-- Maybe gets a model based on user localStorage.
main: Program (Maybe Types.Model)
main =
  App.programWithFlags
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- Initializes application.
init: Maybe Types.Model -> (Types.Model, Cmd Types.Msg)
init model =
  case model of
    Just model ->
      (model, Cmd.none)
    Nothing ->
      (update Types.GetUser { user = Nothing })


-- Updates the application.
update: Types.Msg -> Types.Model -> (Types.Model, Cmd Types.Msg)
update msg model  =
  case msg of
    Types.NoOp ->
      (model, Cmd.none )
    Types.ModelLoadedFromLocalStorage model ->
      (model, Cmd.none)
    Types.GetUser ->
      (model, getUser () )
    Types.GetUserSuccess user ->
      let
        newModel = { model | user = Just user }
      in
        (newModel, saveModelToLocalStorage <| newModel)
    Types.GetUserFailure err ->
      (model, Cmd.none)


-- The applications subscriptions
subscriptions: Types.Model -> Sub Types.Msg
subscriptions model =
  Sub.batch [
    Ports.onLoadModelFromLocalStorage onLoadModelFromLocalStorage
  ]


-- The applications view.
view: Types.Model -> Html.Html Types.Msg
view model =
  let
    loggedIn = case model.user of
      Nothing -> False
      Just user -> True
  in
    div []
      [ button [ onClick Types.NoOp ] [],
        div [] [ Html.text <| toString <| loggedIn ]
      ]


-- Saves the model to localStorage using the port.
saveModelToLocalStorage: Types.Model -> Cmd Types.Msg
saveModelToLocalStorage model =
  Ports.saveModelToLocalStorage <| Model.encoder <| model


-- A subscription to loading the model from local storage.
onLoadModelFromLocalStorage: String -> Types.Msg
onLoadModelFromLocalStorage modelAsStringFromStorage =
  case Model.fromJsonString modelAsStringFromStorage of
    Ok model ->
      Types.ModelLoadedFromLocalStorage model
    Err error ->
      Types.NoOp -- TODO deal with this


-- Gets the user from the API
getUser: () -> Cmd Types.Msg
getUser () =
  Api.getAccount Types.GetUserFailure Types.GetUserSuccess
