{-# LANGUAGE OverloadedStrings #-}
module Popeye.CLI (run) where

import Popeye.Users

import Control.Monad.IO.Class
import LoadEnv
import Network.AWS
import Options.Applicative

import qualified Data.Text as T
import qualified Data.Text.IO as T

data Options = Options { oGroup :: Group }

run :: IO ()
run = do
    loadEnv

    env <- newEnv NorthVirginia Discover
    opts <- getOptions

    runResourceT . runAWS env $
        (mapM_ outputUser =<< getUsers (oGroup opts))

outputUser :: MonadIO m => User -> m ()
outputUser u = do
    let hdr = "# " <> unUserName (userName u)
        keys = map unUserPublicKey $ userPublicKeys u

    liftIO $ T.putStrLn $ T.unlines $ hdr:keys

getOptions :: IO Options
getOptions = execParser $ info (helper <*> parseOptions)
    (fullDesc <> progDesc "Generate authorized_keys from users in an IAM group")

parseOptions :: Parser Options
parseOptions = Options
    <$> Group . T.pack
    <$> strOption
        (  long "group"
        <> short 'g'
        <> metavar "GROUP"
        <> help "IAM group to query"
        )
