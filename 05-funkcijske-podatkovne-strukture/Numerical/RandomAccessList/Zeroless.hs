module RandomAccessList.Zeroless
  ( ZerolessList,
  )
where

import RandomAccessList
import RandomAccessList.PowerTwo
import Prelude hiding (head, lookup, tail)

data Digit t a = D1 (t a) | D2 (t a) (t a) deriving (Show)

newtype ZerolessList t a = ZL [Digit t a] deriving (Show)

consDigit :: (PowerTwo t) => t a -> [Digit t a] -> [Digit t a]
consDigit t [] = [D1 t]
consDigit t (D1 t' : ds) = D2 t t' : ds
consDigit t (D2 t1 t2 : ds) = D1 t : consDigit (linkPow2 t1 t2) ds

unconsDigit :: (PowerTwo t) => [Digit t a] -> (t a, [Digit t a])
unconsDigit [D1 t] = (t, [])
unconsDigit (D2 t1 t2 : ds) = (t1, D1 t2 : ds)
unconsDigit (D1 t : ds) = (t, D2 ta tb : ds')
  where
    (t', ds') = unconsDigit ds
    (ta, tb) = splitPow2 t'

appendDigits :: (PowerTwo t) => [Digit t a] -> [Digit t a] -> [Digit t a]
appendDigits [] ds2 = ds2
appendDigits ds1 ds2 =
  let (t, ds1') = unconsDigit ds1
   in consDigit t (appendDigits ds1' ds2)

instance (PowerTwo t) => RandomAccessList (ZerolessList t) where
  nil = ZL []
  cons x (ZL ds) = ZL (consDigit (singleton x) ds)
  head (ZL (D1 t : _)) = lookupPow2 0 t
  head (ZL (D2 t1 _ : _)) = lookupPow2 0 t1
  tail (ZL ds) = ZL ds'
    where
      (_, ds') = unconsDigit ds
  append (ZL ds1) (ZL ds2) = ZL (appendDigits ds1 ds2)
  lookup i (ZL ds) = look i ds
    where
      look j (D1 t : rest)
        | j < sizePow2 t = lookupPow2 j t
        | otherwise = look (j - sizePow2 t) rest
      look j (D2 t1 t2 : rest)
        | j < sizePow2 t1 = lookupPow2 j t1
        | j < sizePow2 t1 + sizePow2 t2 = lookupPow2 (j - sizePow2 t1) t2
        | otherwise = look (j - sizePow2 t1 - sizePow2 t2) rest
  update i y (ZL ds) = ZL (upd i ds)
    where
      upd j (D1 t : rest)
        | j < sizePow2 t = D1 (updatePow2 j y t) : rest
        | otherwise = D1 t : upd (j - sizePow2 t) rest
      upd j (D2 t1 t2 : rest)
        | j < sizePow2 t1 = D2 (updatePow2 j y t1) t2 : rest
        | j < sizePow2 t1 + sizePow2 t2 = D2 t1 (updatePow2 (j - sizePow2 t1) y t2) : rest
        | otherwise = D2 t1 t2 : upd (j - sizePow2 t1 - sizePow2 t2) rest
  size (ZL ds) = sum [sizePow2 t | D1 t <- ds] + sum [sizePow2 t1 + sizePow2 t2 | D2 t1 t2 <- ds]
