module Natural.ZerolessBinary
  ( ZLBinary,
  )
where

import Data.List (intercalate)
import Natural

data Bit = One | Two

newtype ZLBinary = ZBin [Bit]

instance Show ZLBinary where
  show (ZBin ds) =
    concatMap showBit (reverse ds)
      ++ "₂"
      ++ " = "
      ++ intercalate " + " (zipWith (\i d -> showBit d ++ "⋅2" ++ powerOfTwo i) [0 ..] ds)
    where
      showBit One = "1"
      showBit Two = "2"

incrBits :: [Bit] -> [Bit]
incrBits [] = [One]
incrBits (One : ds) = Two : ds
incrBits (Two : ds) = One : incrBits ds

decrBits :: [Bit] -> [Bit]
decrBits [One] = []
decrBits (Two : ds) = One : ds
decrBits (One : ds) = Two : decrBits ds

addBits :: [Bit] -> [Bit] -> [Bit]
addBits [] ds2 = ds2
addBits ds1 [] = ds1
addBits (One : ds1) (One : ds2) = Two : addBits ds1 ds2
addBits (One : ds1) (Two : ds2) = One : incrBits (addBits ds1 ds2)
addBits (Two : ds1) (One : ds2) = One : incrBits (addBits ds1 ds2)
addBits (Two : ds1) (Two : ds2) = Two : incrBits (addBits ds1 ds2)

instance Natural ZLBinary where
  zero = ZBin []
  incr (ZBin ds) = ZBin (incrBits ds)
  decr (ZBin ds) = ZBin (decrBits ds)
  add (ZBin ds1) (ZBin ds2) = ZBin (addBits ds1 ds2)
