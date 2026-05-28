module Natural.SkewBinary
  ( SkewBinary,
  )
where

import Data.List (intercalate)
import Natural

newtype SkewBinary = Bits [Int]

instance Show SkewBinary where
  show (Bits ws) = intercalate " + " (map show ws)

incrBits :: [Int] -> [Int]
incrBits (w1 : w2 : ws) | w1 == w2 = (1 + w1 + w2) : ws
incrBits ws = 1 : ws

decrBits :: [Int] -> [Int]
decrBits (1 : ws) = ws
decrBits (w : ws) = (w `div` 2) : (w `div` 2) : ws

addBits :: [Int] -> [Int] -> [Int]
addBits [] ds2 = ds2
addBits ds1 ds2 = incrBits (addBits (decrBits ds1) ds2)

instance Natural SkewBinary where
  zero = Bits []
  incr (Bits ds) = Bits (incrBits ds)
  decr (Bits ds) = Bits (decrBits ds)
  add (Bits ds1) (Bits ds2) = Bits (addBits ds1 ds2)
