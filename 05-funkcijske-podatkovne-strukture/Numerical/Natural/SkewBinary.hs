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

instance Natural SkewBinary where
  zero = Weights []
  incr (Weights ds) = Weights (incrWeights ds)
  decr (Weights []) = Nothing
  decr (Weights ds) = Just (Weights (decrWeights ds))

