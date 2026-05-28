module RandomAccessList.Skew
  ( SkewList,
  )
where

import RandomAccessList
import RandomAccessList.PowerTwoMinusOne
import Prelude hiding (head, lookup, tail)

newtype SkewList t a = SL [(Int, t a)] deriving (Show)

consTree :: (PowerTwoMinusOne t) => a -> [(Int, t a)] -> [(Int, t a)]
consTree x ((w1, t1) : (w2, t2) : wts) | w1 == w2 = (w1 + w2 + 1, linkPow2_1 x t1 t2) : wts
consTree x wts = (1, linkPow2_1 x empty empty) : wts

unconsTree :: (PowerTwoMinusOne t) => [(Int, t a)] -> (a, [(Int, t a)])
unconsTree ((1, t) : wts) = (x, wts)
  where
    (x, _, _) = splitPow2_1 t
unconsTree ((w, t) : wts) = (x, (w `div` 2, t1) : (w `div` 2, t2) : wts)
  where
    (x, t1, t2) = splitPow2_1 t

appendTrees :: (PowerTwoMinusOne t) => [(Int, t a)] -> [(Int, t a)] -> [(Int, t a)]
appendTrees [] ds2 = ds2
appendTrees ds1 ds2 =
  let (d, ds1') = unconsTree ds1
   in consTree d (appendTrees ds1' ds2)

instance (PowerTwoMinusOne t) => RandomAccessList (SkewList t) where
  nil = SL []
  cons x (SL wts) = SL (consTree x wts)
  head (SL ((_, t) : _)) = x
    where
      (x, _, _) = splitPow2_1 t
  tail (SL wts) = SL wts'
    where
      (_, wts') = unconsTree wts
  append (SL wts1) (SL wts2) = SL (appendTrees wts1 wts2)
  lookup i (SL wts) = look i wts
    where
      look j ((w, t) : rest)
        | j < w = lookupPow2_1 j t
        | otherwise = look (j - w) rest
  update i y (SL wts) = SL (upd i wts)
    where
      upd j ((w, t) : rest)
        | j < w = (w, updatePow2_1 j y t) : rest
        | otherwise = (w, t) : upd (j - w) rest
  size (SL wts) = sum [w | (w, _) <- wts]
