{-# LANGUAGE OverloadedStrings #-}
module Popeye.Users
    ( User(..)
    , UserName(..)
    , UserPublicKey(..)
    , Group(..)
    , getUsers
    ) where

import Control.Lens (set, view)
import Control.Monad (forM, mfilter)
import Data.Maybe (catMaybes)
import Data.Text (Text)
import Network.AWS
import Network.AWS.IAM.GetGroup
import Network.AWS.IAM.GetSSHPublicKey
import Network.AWS.IAM.ListSSHPublicKeys
import Network.AWS.IAM.Types hiding (User, Group)

newtype Group = Group { unGroup :: Text }
newtype PublicKeyId = PublicKeyId { unPublicKeyId :: Text }

newtype UserName = UserName { unUserName :: Text }
newtype UserPublicKey = UserPublicKey { unUserPublicKey :: Text }

data User = User
    { userName :: UserName
    , userPublicKeys :: [UserPublicKey]
    }

getUsers :: Group -> AWS [User]
getUsers g = do
    uns <- getUserNames g

    forM uns $ \un -> do
        pks <- mapM (getPublicKeyContent un) =<< getPublicKeyIds un

        return User
            { userName = un
            , userPublicKeys = catMaybes pks
            }

getUserNames :: Group -> AWS [UserName]
getUserNames g = do
    rsp <- send $ getGroup $ unGroup g
    return $ (UserName . view uUserName) <$> view ggrsUsers rsp

getPublicKeyIds :: UserName -> AWS [PublicKeyId]
getPublicKeyIds un = do
    rsp <- send $ set lspkUserName (Just $ unUserName un) listSSHPublicKeys
    return $ (PublicKeyId . view spkmSSHPublicKeyId) <$> view lspkrsSSHPublicKeys rsp

getPublicKeyContent :: UserName -> PublicKeyId -> AWS (Maybe UserPublicKey)
getPublicKeyContent un pk = do
    rsp <- send $ getSSHPublicKey (unUserName un) (unPublicKeyId pk) SSH
    return $ (UserPublicKey . view spkSSHPublicKeyBody)
        <$> (mfilter ((== Active) . view spkStatus) $ view gspkrsSSHPublicKey rsp)
