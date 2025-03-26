{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Main(main) where

import Control.Concurrent ( forkIO, killThread )
import Control.Exception ( bracket )
import Control.Monad.IO.Class ( MonadIO(liftIO) )
import Network.Socket (withSocketsDo)
import Network.HTTP.Client
    ( httpLbs, defaultManagerSettings, newManager, parseRequest )
import Network.HTTP.Client.MultipartFormData
    ( formDataBody, partFileSource )
import Network.Wai.Handler.Warp ( run )
import Servant
    ( serve,
      err400,
      Proxy(..),
      throwError,
      JSON,
      type (:>),
      Post,
      Server,
      ServerError(errBody) )
import Servant.Multipart
    ( FileData(fdPayload), MultipartData(files), MultipartForm, Tmp )

import WordCount (countElementsInFile, printSelecttedOutput)

type API = MultipartForm Tmp (MultipartData Tmp) :> Post '[JSON] String

noFileError :: ServerError
noFileError = err400 {errBody = "No file is given."}

api :: Proxy API
api = Proxy

upload :: Server API
upload multipartData = do
  case files multipartData of
    (file:_) -> do
      output <- liftIO $ countElementsInFile $ fdPayload file
      return $ printSelecttedOutput output
    [] -> throwError noFileError

startServer :: IO ()
startServer = run 8080 (serve api upload)

main :: IO ()
main = withSocketsDo . bracket (forkIO startServer) killThread $ \_threadid -> do
  
  -- we fork the server in a separate thread and send a test
  -- request to it from the main thread.
  manager <- newManager defaultManagerSettings
  req <- parseRequest "http://localhost:8080/"
  resp <- flip httpLbs manager =<< formDataBody form req
  print resp

  where form =
          [ 
            partFileSource "file" "./README.md"
          ]
