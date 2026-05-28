module Natural.ZerolessBinary
  ( ZerolessBinary,
  )
where

import Data.List (intercalate)
import Natural

data Bit = One | Two

newtype ZerolessBinary = Bits [Bit]

instance Show ZerolessBinary where
  show (Bits ds) =
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

instance Natural ZerolessBinary where
  zero = Bits []
  incr (Bits ds) = Bits (incrBits ds)
  decr (Bits ds) = Bits (decrBits ds)
  add (Bits ds1) (Bits ds2) = Bits (addBits ds1 ds2)
