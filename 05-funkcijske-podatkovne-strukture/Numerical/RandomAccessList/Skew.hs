module RandomAccessList.Skew
  ( SkewList,
  )
where

import RandomAccessList
import RandomAccessList.PowerTwoMinusOne
import Prelude hiding (head, lookup, tail)

newtype SkewList t a = Weights [(Int, t a)] deriving (Show)

consTrees :: (PowerTwoMinusOne t) => a -> [(Int, t a)] -> [(Int, t a)]
consTrees x ((w1, t1) : (w2, t2) : wts) | w1 == w2 = (w1 + w2 + 1, linkTree x t1 t2) : wts
consTrees x wts = (1, linkTree x empty empty) : wts

unconsTrees :: (PowerTwoMinusOne t) => [(Int, t a)] -> (a, [(Int, t a)])
unconsTrees ((1, t) : wts) = (x, wts)
  where
    (x, _, _) = splitTree t
unconsTrees ((w, t) : wts) = (x, (w `div` 2, t1) : (w `div` 2, t2) : wts)
  where
    (x, t1, t2) = splitTree t

appendTrees :: (PowerTwoMinusOne t) => [(Int, t a)] -> [(Int, t a)] -> [(Int, t a)]
appendTrees [] ds2 = ds2
appendTrees ds1 ds2 =
  let (d, ds1') = unconsTrees ds1
   in consTrees d (appendTrees ds1' ds2)

instance (PowerTwoMinusOne t) => RandomAccessList (SkewList t) where
  nil = Weights []
  cons x (Weights wts) = Weights (consTrees x wts)
  head (Weights ((_, t) : _)) = x
    where
      (x, _, _) = splitTree t
  tail (Weights wts) = Weights wts'
    where
      (_, wts') = unconsTrees wts
  append (Weights wts1) (Weights wts2) = Weights (appendTrees wts1 wts2)
  lookup i (Weights wts) = look i wts
    where
      look j ((w, t) : rest)
        | j < w = lookupTree j t
        | otherwise = look (j - w) rest
  update i y (Weights wts) = Weights (upd i wts)
    where
      upd j ((w, t) : rest)
        | j < w = (w, updateTree j y t) : rest
        | otherwise = (w, t) : upd (j - w) rest
  size (Weights wts) = sum [w | (w, _) <- wts]
