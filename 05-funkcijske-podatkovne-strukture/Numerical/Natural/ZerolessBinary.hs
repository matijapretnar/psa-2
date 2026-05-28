module Natural.ZerolessBinary
  ( ZerolessBinary,
  )
where

import Data.List (intercalate)
import Natural

data Digit = One | Two

newtype ZerolessBinary = Digits [Digit]

instance Show ZerolessBinary where
  show (Digits ds) =
    concatMap showBit (reverse ds)
      ++ "₂"
      ++ " = "
      ++ intercalate " + " (zipWith (\i d -> showBit d ++ "⋅2" ++ powerOfTwo i) [0 ..] ds)
    where
      showBit One = "1"
      showBit Two = "2"

incrDigits :: [Digit] -> [Digit]
incrDigits [] = [One]
incrDigits (One : ds) = Two : ds
incrDigits (Two : ds) = One : incrDigits ds

decrDigits :: [Digit] -> [Digit]
decrDigits [One] = []
decrDigits (Two : ds) = One : ds
decrDigits (One : ds) = Two : decrDigits ds

addDigits :: [Digit] -> [Digit] -> [Digit]
addDigits [] ds2 = ds2
addDigits ds1 [] = ds1
addDigits (One : ds1) (One : ds2) = Two : addDigits ds1 ds2
addDigits (One : ds1) (Two : ds2) = One : incrDigits (addDigits ds1 ds2)
addDigits (Two : ds1) (One : ds2) = One : incrDigits (addDigits ds1 ds2)
addDigits (Two : ds1) (Two : ds2) = Two : incrDigits (addDigits ds1 ds2)

instance Natural ZerolessBinary where
  zero = Digits []
  incr (Digits ds) = Digits (incrDigits ds)
  decr (Digits ds) = Digits (decrDigits ds)
  add (Digits ds1) (Digits ds2) = Digits (addDigits ds1 ds2)
