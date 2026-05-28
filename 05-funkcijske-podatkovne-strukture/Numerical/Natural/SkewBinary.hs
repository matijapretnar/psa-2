module Natural.SkewBinary
  ( SkewBinary,
  )
where

import Data.List (intercalate)
import Natural

newtype SkewBinary = Weights [Int]

instance Show SkewBinary where
  show (Weights ws) = intercalate " + " (map show ws)

incrWeights :: [Int] -> [Int]
incrWeights (w1 : w2 : ws) | w1 == w2 = (1 + w1 + w2) : ws
incrWeights ws = 1 : ws

decrWeights :: [Int] -> [Int]
decrWeights (1 : ws) = ws
decrWeights (w : ws) = (w `div` 2) : (w `div` 2) : ws

addWeights :: [Int] -> [Int] -> [Int]
addWeights [] ds2 = ds2
addWeights ds1 ds2 = incrWeights (addWeights (decrWeights ds1) ds2)

instance Natural SkewBinary where
  zero = Weights []
  incr (Weights ds) = Weights (incrWeights ds)
  decr (Weights ds) = Weights (decrWeights ds)
  add (Weights ds1) (Weights ds2) = Weights (addWeights ds1 ds2)
