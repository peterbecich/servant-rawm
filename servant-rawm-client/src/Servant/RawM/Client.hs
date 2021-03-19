{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE InstanceSigs          #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes            #-}
{-# LANGUAGE TypeFamilies          #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

{- |
Module      :  Servant.RawM.Client

Copyright   :  Dennis Gosnell 2017
License     :  BSD3

Maintainer  :  Dennis Gosnell (cdep.illabout@gmail.com)
               Krasjet (nil.krjst@gmail.com)
Stability   :  experimental
Portability :  unknown

This module exports a 'HasClient' instance for 'RawM', which provides the
client implementation for the 'RawM' endpoint.
-}

module Servant.RawM.Client (
  -- * Reexport RawM API
  module Servant.RawM
) where

import Data.Proxy          (Proxy (Proxy))
import Servant.Client.Core (Client,
                            HasClient (clientWithRoute, hoistClientMonad),
                            Request, Response, RunClient)
import Servant.Client.Core.RunClient (runRequest)
import Servant.RawM

-- | Creates a client route like the following:
--
-- >>> :set -XTypeOperators
-- >>> import Data.Type.Equality ((:~:)(Refl))
-- >>> Refl :: Client m (RawM' a) :~: ((Request -> Request) -> m Response)
-- Refl
--
-- This allows modification of the underlying 'Request' to work for any sort of
-- 'Network.Wai.Application'.
--
-- Check out the
-- <https://github.com/cdepillabout/servant-rawm/tree/master/example example> in
-- the source code repository that shows a more in-depth server, client, and
-- documentation.
instance RunClient m => HasClient m (RawM' serverType) where
  type Client m (RawM' serverType) = (Request -> Request) -> m Response

  clientWithRoute
    :: Proxy m
    -> Proxy (RawM' serverType)
    -> Request
    -> Client m (RawM' serverType)
  clientWithRoute Proxy Proxy req reqFunc = runRequest $ reqFunc req

  hoistClientMonad
    :: Proxy m
    -> Proxy (RawM' serverType)
    -> (forall x. mon x -> mon' x)
    -> Client mon (RawM' serverType)
    -> Client mon' (RawM' serverType)
  hoistClientMonad Proxy Proxy f cl = f . cl

instance RunClient m => HasClient m (RawM' FileServer) where
  type Client m (RawM' FileServer) = (Request -> Request) -> m Response

  clientWithRoute
    :: Proxy m
    -> Proxy (RawM' FileServer)
    -> Request
    -> Client m (RawM' FileServer)
  clientWithRoute Proxy Proxy req reqFunc = runRequest $ reqFunc req

  hoistClientMonad
    :: Proxy m
    -> Proxy (RawM' FileServer)
    -> (forall x. mon x -> mon' x)
    -> Client mon (RawM' FileServer)
    -> Client mon' (RawM' FileServer)
  hoistClientMonad Proxy Proxy f cl = f . cl
