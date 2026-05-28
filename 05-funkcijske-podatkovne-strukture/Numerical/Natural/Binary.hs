module Natural.Binary
  ( Binary,
  )
where

import Data.List (intercalate)
import Natural

data Bit = O | I

newtype Binary = Bin [Bit]

instance Show Binary where
  show (Bin ds) =
    concatMap showBit (reverse ds)
      ++ "₂"
      ++ " = "
      ++ intercalate " + " (zipWith (\i d -> showBit d ++ "⋅2" ++ powerOfTwo i) [0 ..] ds)
    where
      showBit I = "1"
      showBit O = "0"

incrBits :: [Bit] -> [Bit]
incrBits [] = [I]
incrBits (O : ds) = I : ds
incrBits (I : ds) = O : incrBits ds

decrBits :: [Bit] -> [Bit]
decrBits [I] = []
decrBits (I : ds) = O : ds
decrBits (O : ds) = I : decrBits ds

addBits :: [Bit] -> [Bit] -> [Bit]
addBits [] ds2 = ds2
addBits ds1 [] = ds1
addBits (O : ds1) (d : ds2) = d : addBits ds1 ds2
addBits (d : ds1) (O : ds2) = d : addBits ds1 ds2
addBits (I : ds1) (I : ds2) = O : incrBits (addBits ds1 ds2)

instance Natural Binary where
  zero = Bin []
  incr (Bin ds) = Bin (incrBits ds)
  decr (Bin ds) = Bin (decrBits ds)
  add (Bin ds1) (Bin ds2) = Bin (addBits ds1 ds2)
