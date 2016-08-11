{-# LANGUAGE OverloadedStrings #-}
module Popeye.CLI (run) where

import Popeye.Users

import Control.Lens (set)
import Control.Monad.IO.Class
import LoadEnv
import Network.AWS
import Options.Applicative
import System.IO (stderr)

import qualified Data.Text as T
import qualified Data.Text.IO as T

data Options = Options
    { oGroups :: [Group]
    , oDebug :: Bool
    }

run :: IO ()
run = do
    loadEnv

    opts <- getOptions
    lgr <- newLogger (if oDebug opts then Debug else Error) stderr
    env <- set envLogger lgr <$> newEnv NorthVirginia Discover

    runResourceT . runAWS env $
        (mapM_ outputUser =<< getUsers (oGroups opts))

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
    <$> some (Group . T.pack <$> strOption
        (  short 'g'
        <> long "group"
        <> metavar "GROUP"
        <> help "IAM group to query"
        ))
    <*> switch
        (  short 'd'
        <> long "debug"
        <> help "Show debug information"
        )
