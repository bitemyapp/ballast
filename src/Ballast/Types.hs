{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Ballast.Types
       ( Username(..)
       , Password(..)
       ) where

import Data.Aeson
import Data.Aeson.Types
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy.Char8 as BSL
import qualified Data.Char as DC
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics

-- | Username type used for HTTP Basic authentication.
newtype Username = Username { username :: ByteString } deriving (Read, Show, Eq)

-- | Password type used for HTTP Basic authentication.
newtype Password = Password { password :: ByteString } deriving (Read, Show, Eq)

newtype SKU =
  SKU { unSku :: Text }
  deriving (Eq, Show)

mkSku :: Text -> Maybe SKU
mkSku sku
  | T.length sku > 16 = Nothing
  | T.length sku < 1 = Nothing
  | otherwise = Just (SKU sku)

-- max 16 characters
-- haskellbookskuty

data Rate =
  Rate {
    rateOptions :: RateOptions
  } deriving (Eq, Generic, Show)

instance ToJSON Rate where
  toJSON rate =
    genericToJSON options rate
    where
      options =
        defaultOptions { fieldLabelModifier = downcaseHead . drop 4
                       , omitNothingFields = True
                       }

data RateOptions =
  RateOptions {
    rateOptionCurrency :: Currency
  , rateOptionGroupBy :: GroupBy
  , rateOptionCanSplit :: Integer
  , rateOptionWarehouseArea :: WarehouseArea
  , rateOptionChannelName :: Maybe Text
  } deriving (Eq, Generic, Show)

downcaseHead :: [Char] -> [Char]
downcaseHead [] = []
downcaseHead (x:xs) =
  (DC.toLower x) : xs

instance ToJSON RateOptions where
  toJSON ro =
    genericToJSON options ro
    where
      options =
        defaultOptions { fieldLabelModifier = downcaseHead . drop 10
                       , omitNothingFields = True
                       }

defaultRateOptions =
  RateOptions USD GroupByAll 1 WarehouseAreaUS Nothing

data Currency =
  USD
  deriving (Eq, Show)

instance ToJSON Currency where
  toJSON USD = String "USD"

tshow :: Show a => a -> Text
tshow = T.pack . show

omitNulls :: [(Text, Value)] -> Value
omitNulls = object . filter notNull where
  notNull (_, Null)      = False
  -- notNull (_, Array a) = (not . V.null) a
  notNull _              = True

data GroupBy =
    GroupByAll
  | GroupByWarehouse
  deriving (Eq, Show)

instance ToJSON GroupBy where
  toJSON GroupByAll = String "all"
  toJSON GroupByWarehouse = String "warehouse"

data WarehouseArea =
  WarehouseAreaUS
  deriving (Eq, Show)

instance ToJSON WarehouseArea where
  toJSON WarehouseAreaUS = String "US"

-- {
--     # Rates setup options
--     "options": {
--         # The currency in which rates are presented
--         "currency": "USD",
--         # The criteria by which to group different rates. Valid options are "all" (default), "warehouse"
--         "groupBy": "all",
--         # Specifies whether the items to be shipped can be split into more than one shipments
--         "canSplit": 1,
--         # Area from where shipment can be made (can be continent or country)
--         "warehouseArea": "US",
--         # Used to assign a pre-defined set of shipping and/or customization preferences
--         "channelName": "My Channel"
--     },
--     "order": {
--         # Shipping address
--         "shipTo": {
--             # Recipient's address
--             "address1": "6501 Railroad Avenue SE",
--             "address2": "Room 315",
--             "address3": "",
--             "city": "Snoqualmie",
--             "postalCode": "85283",
--             "region": "WA",
--             "country": "US",
--             # Specifies whether the recipient is a commercial entity. 0 = no, 1 = yes
--             "isCommercial": 0,
--             # Specifies whether the recipient is a PO box. 0 = no, 1 = yes
--             "isPoBox": 0
--         },
--         # The items for which to generate shipping rates
--         "items": [
--             {
--                 # Item's SKU
--                 "sku": "Laura-s_Pen",
--                 # Number of items to shipped
--                 "quantity": 1
--             },
--             {
--                 "sku": "TwinPianos",
--                 "quantity": 1
--             }
--         ]
--     }
-- }

-- {
--     "properties": {
--         "options": {
--             "properties": {
--                 "canSplit": {
--                     "type": "integer"
--                 },
--                 "currency": {
--                     "type": "string"
--                 },
--                 "groupBy": {
--                     "type": "string"
--                 },
--                 "warehouseId": {
--                     "type": "integer"
--                 },
--                 "warehouseExternalId": {
--                     "type": "string"
--                 },
--                 "warehouseRegion": {
--                     "type": "string"
--                 },
--                 "warehouseArea": {
--                     "type": "string"
--                 },
--                 "ignoreUnknownSkus": {
--                     "type": "integer"
--                 }
--             },
--             "required": [
--             ],
--             "type": "object"
--         },
--         "order": {
--             "properties": {
--                 "items": {
--                     "items": [
--                         {
--                             "properties": {
--                                 "quantity": {
--                                     "type": "integer"
--                                 },
--                                 "sku": {
--                                     "type": "string"
--                                 }
--                             },
--                             "required": [
--                                 "sku",
--                                 "quantity"
--                             ],
--                             "type": "object"
--                         }
--                     ],
--                     "type": "array"
--                 },
--                 "shipTo": {
--                     "properties": {
--                         "address1": {
--                             "type": "string"
--                         },
--                         "address2": {
--                             "type": "string"
--                         },
--                         "address3": {
--                             "type": "string"
--                         },
--                         "city": {
--                             "type": "string"
--                         },
--                         "postalCode": {
--                             "type": "string"
--                         },
--                         "region": {
--                             "type": "string"
--                         }
--                         "country": {
--                             "type": "string"
--                         },
--                         "isCommercial": {
--                             "type": "integer"
--                         },
--                         "isPoBox": {
--                             "type": "integer"
--                         }
--                     },
--                     "required": [
--                         "country"
--                     ],
--                     "type": "object"
--                 }
--             },
--             "required": [
--                 "shipTo",
--                 "items"
--             ],
--             "type": "object"
--         }
--     },
--     "required": [
--         "order"
--     ],
--     "type": "object"
-- }