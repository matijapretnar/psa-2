module RandomAccessList.BinaryList
  ( BinaryList,
  )
where

import RandomAccessList
import Pow2
import Prelude hiding (head, lookup, tail)

data Digit t a = Zero | One (t a) deriving (Show)

newtype BinaryList t a = BL [Digit t a] deriving (Show)

consDigit :: (Pow2 t) => t a -> [Digit t a] -> [Digit t a]
consDigit t [] = [One t]
consDigit t (Zero : ds) = One t : ds
consDigit t (One t' : ds) = Zero : consDigit (linkTree t t') ds

unconsDigit :: (Pow2 t) => [Digit t a] -> (t a, [Digit t a])
unconsDigit [One t] = (t, [])
unconsDigit (One t : ds) = (t, Zero : ds)
unconsDigit (Zero : ds) = (t1, One t2 : ds')
  where
    (t', ds') = unconsDigit ds
    (t1, t2) = splitTree t'

instance Pow2 t => RandomAccessList (BinaryList t) where
  nil = BL []
  cons x (BL ds) = BL (consDigit (singleton x) ds)
  uncons (BL []) = Nothing
  -- t ima samo en element, zato lahko varno vzamemo samo prvega
  uncons (BL ds) = Just (lookupTree 0 t, BL ds')
    where (t, ds') = unconsDigit ds

  lookup i (BL ds) = look i ds
    where
      look j (Zero : rest) = look j rest
      look j (One t : rest)
        | j < sizeTree t = lookupTree j t
        | otherwise = look (j - sizeTree t) rest
  update i y (BL ds) = BL (upd i ds)
    where
      upd j (Zero : rest) = Zero : upd j rest
      upd j (One t : rest)
        | j < sizeTree t = One (updateTree j y t) : rest
        | otherwise = One t : upd (j - sizeTree t) rest
  size (BL ds) = sum [sizeTree t | One t <- ds]
