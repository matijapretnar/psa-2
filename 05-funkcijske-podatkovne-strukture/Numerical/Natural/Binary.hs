module Natural.Binary
  ( Binary,
  )
where

import Data.List (intercalate)
import Natural

data Bit = Zero | One

newtype Binary = Bin [Bit]

instance Show Binary where
  show (Bin ds) =
    concatMap showBit (reverse ds)
      ++ "₂"
      ++ " = "
      ++ intercalate " + " (zipWith (\i d -> showBit d ++ "⋅2" ++ powerOfTwo i) [0 ..] ds)
    where
      showBit Zero = "0"
      showBit One = "1"

incrBits :: [Bit] -> [Bit]
incrBits [] = [One]
incrBits (Zero : ds) = One : ds
incrBits (One : ds) = Zero : incrBits ds

decrBits :: [Bit] -> [Bit]
decrBits [One] = []
decrBits (One : ds) = Zero : ds
decrBits (Zero : ds) = One : decrBits ds

addBits :: [Bit] -> [Bit] -> [Bit]
addBits [] ds2 = ds2
addBits ds1 [] = ds1
addBits (Zero : ds1) (d : ds2) = d : addBits ds1 ds2
addBits (d : ds1) (Zero : ds2) = d : addBits ds1 ds2
addBits (One : ds1) (One : ds2) = Zero : incrBits (addBits ds1 ds2)

instance Natural Binary where
  zero = Bin []
  incr (Bin ds) = Bin (incrBits ds)
  decr (Bin ds) = Bin (decrBits ds)
  add (Bin ds1) (Bin ds2) = Bin (addBits ds1 ds2)
