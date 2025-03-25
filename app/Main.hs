{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Main(main) where

import Control.Concurrent
import Control.Exception
import Control.Monad.IO.Class
import Network.Socket (withSocketsDo)
import Network.HTTP.Client hiding (Proxy)
import Network.HTTP.Client.MultipartFormData
import Network.Wai.Handler.Warp
import Servant
import Servant.Multipart

import WordCount (countElements, printSelecttedOutput)

type API = MultipartForm Tmp (MultipartData Tmp) :> Post '[JSON] String

noFileError :: ServerError
noFileError = err400 {errBody = "No file is given."}

api :: Proxy API
api = Proxy

upload :: Server API
upload multipartData = do
  case files multipartData of
    (file:_) -> do
      output <- liftIO $ countElements $ fdPayload file
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
            partFileSource "file" "./sample.txt"
          ]
