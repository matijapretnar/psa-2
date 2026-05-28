module RandomAccessList.SkewList
  ( SkewList,
  )
where

import RandomAccessList
import Pow2_1
import Prelude hiding (head, lookup, tail)

newtype SkewList t a = SL [a]

instance Pow2_1 t => RandomAccessList (SkewList t) where
  nil = SL []
  cons x (SL xs) = SL (x : xs)
  uncons (SL []) = Nothing
  uncons (SL (x : xs)) = Just (x, SL xs)
  lookup i (SL xs) = xs !! i
  update i y (SL xs) = SL [if j == i then y else z | (j, z) <- zip [0..] xs]
  size (SL xs) = length xs
