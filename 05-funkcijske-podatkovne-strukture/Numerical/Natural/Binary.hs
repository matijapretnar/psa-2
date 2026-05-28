module Natural.Binary
  ( Binary,
  )
where

import Data.List (intercalate)
import Natural

data Digit = Zero | One

newtype Binary = Digits [Digit]

instance Show Binary where
  show (Digits ds) =
    concatMap showBit (reverse ds)
      ++ "₂"
      ++ " = "
      ++ intercalate " + " (zipWith (\i d -> showBit d ++ "⋅2" ++ powerOfTwo i) [0 ..] ds)
    where
      showBit Zero = "0"
      showBit One = "1"

incrDigits :: [Digit] -> [Digit]
incrDigits [] = [One]
incrDigits (Zero : ds) = One : ds
incrDigits (One : ds) = Zero : incrDigits ds

decrDigits :: [Digit] -> [Digit]
decrDigits [One] = []
decrDigits (One : ds) = Zero : ds
decrDigits (Zero : ds) = One : decrDigits ds

addDigits :: [Digit] -> [Digit] -> [Digit]
addDigits [] ds2 = ds2
addDigits ds1 [] = ds1
addDigits (Zero : ds1) (d : ds2) = d : addDigits ds1 ds2
addDigits (d : ds1) (Zero : ds2) = d : addDigits ds1 ds2
addDigits (One : ds1) (One : ds2) = Zero : incrDigits (addDigits ds1 ds2)

instance Natural Binary where
  zero = Digits []
  incr (Digits ds) = Digits (incrDigits ds)
  decr (Digits []) = Nothing
  decr (Digits ds) = Just (Digits (decrDigits ds))
  add (Digits ds1) (Digits ds2) = Digits (addDigits ds1 ds2)
