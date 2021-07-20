{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

-- This example is taken directly from cardano-api, written by Jordan Millar, IOHK

module Cardano.PlutusExample.AlwaysSucceeds where

import           Prelude                  hiding (($))

import           Cardano.Api.Shelley      (PlutusScript (..), PlutusScriptV1)

import           Codec.Serialise
import qualified Data.ByteString.Lazy     as LBS
import qualified Data.ByteString.Short    as SBS

import qualified Plutus.V1.Ledger.Scripts as Plutus
import           PlutusCore.Pretty
import           PlutusTx                 (Data (..))
import qualified PlutusTx
import           PlutusTx.Prelude         hiding (Semigroup (..), unless)

{-# INLINABLE mkValidator #-}
mkValidator :: Data -> Data -> Data -> ()
mkValidator _ _ _ = ()

validator :: Plutus.Validator
validator = Plutus.mkValidatorScript $$(PlutusTx.compile [|| mkValidator ||])

script :: Plutus.Script
script = Plutus.unValidatorScript validator

alwaysSucceedsScriptShortBs :: SBS.ShortByteString
alwaysSucceedsScriptShortBs = SBS.toShort . LBS.toStrict $ serialise script

alwaysSucceedsScript :: PlutusScript PlutusScriptV1
alwaysSucceedsScript = PlutusScriptSerialised alwaysSucceedsScriptShortBs

validatorCompiled :: PlutusTx.CompiledCode (Data -> Data -> Data -> ())
validatorCompiled = $$(PlutusTx.compile [|| mkValidator ||])

validatorPlcPretty :: Doc ann
validatorPlcPretty = prettyPlcReadableDef . PlutusTx.getPlc $ validatorCompiled

