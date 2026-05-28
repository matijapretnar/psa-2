module RandomAccessList.Zeroless
  ( ZerolessList,
  )
where

import RandomAccessList
import RandomAccessList.PowerTwo
import Prelude hiding (head, lookup, tail)

data Digit t a = One (t a) | Two (t a) (t a) deriving (Show)

newtype ZerolessList t a = Digits [Digit t a] deriving (Show)

consDigits :: (PowerTwo t) => t a -> [Digit t a] -> [Digit t a]
consDigits t [] = [One t]
consDigits t (One t' : ds) = Two t t' : ds
consDigits t (Two t1 t2 : ds) = One t : consDigits (linkTree t1 t2) ds

unconsDigits :: (PowerTwo t) => [Digit t a] -> (t a, [Digit t a])
unconsDigits [One t] = (t, [])
unconsDigits (Two t1 t2 : ds) = (t1, One t2 : ds)
unconsDigits (One t : ds) = (t, Two ta tb : ds')
  where
    (t', ds') = unconsDigits ds
    (ta, tb) = splitTree t'

appendDigits :: (PowerTwo t) => [Digit t a] -> [Digit t a] -> [Digit t a]
appendDigits [] ds2 = ds2
appendDigits ds1 ds2 =
  let (t, ds1') = unconsDigits ds1
   in consDigits t (appendDigits ds1' ds2)

instance (PowerTwo t) => RandomAccessList (ZerolessList t) where
  nil = Digits []
  cons x (Digits ds) = Digits (consDigits (singleton x) ds)
  head (Digits (One t : _)) = lookupTree 0 t
  head (Digits (Two t1 _ : _)) = lookupTree 0 t1
  tail (Digits ds) = Digits ds'
    where
      (_, ds') = unconsDigits ds
  append (Digits ds1) (Digits ds2) = Digits (appendDigits ds1 ds2)
  lookup i (Digits ds) = look i ds
    where
      look j (One t : rest)
        | j < sizeTree t = lookupTree j t
        | otherwise = look (j - sizeTree t) rest
      look j (Two t1 t2 : rest)
        | j < sizeTree t1 = lookupTree j t1
        | j < sizeTree t1 + sizeTree t2 = lookupTree (j - sizeTree t1) t2
        | otherwise = look (j - sizeTree t1 - sizeTree t2) rest
  update i y (Digits ds) = Digits (upd i ds)
    where
      upd j (One t : rest)
        | j < sizeTree t = One (updateTree j y t) : rest
        | otherwise = One t : upd (j - sizeTree t) rest
      upd j (Two t1 t2 : rest)
        | j < sizeTree t1 = Two (updateTree j y t1) t2 : rest
        | j < sizeTree t1 + sizeTree t2 = Two t1 (updateTree (j - sizeTree t1) y t2) : rest
        | otherwise = Two t1 t2 : upd (j - sizeTree t1 - sizeTree t2) rest
  size (Digits ds) = sum [sizeTree t | One t <- ds] + sum [sizeTree t1 + sizeTree t2 | Two t1 t2 <- ds]
