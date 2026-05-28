module RandomAccessList.Binary
  ( BinaryList,
  )
where

import RandomAccessList
import RandomAccessList.PowerTwo
import Prelude hiding (head, lookup, tail)

data Digit t a = D0 | D1 (t a) deriving (Show)

newtype BinaryList t a = BL [Digit t a] deriving (Show)

consDigit :: (PowerTwo t) => t a -> [Digit t a] -> [Digit t a]
consDigit t [] = [D1 t]
consDigit t (D0 : ds) = D1 t : ds
consDigit t (D1 t' : ds) = D0 : consDigit (linkPow2 t t') ds

unconsDigit :: (PowerTwo t) => [Digit t a] -> (t a, [Digit t a])
unconsDigit [D1 t] = (t, [])
unconsDigit (D1 t : ds) = (t, D0 : ds)
unconsDigit (D0 : ds) = (t1, D1 t2 : ds')
  where
    (t', ds') = unconsDigit ds
    (t1, t2) = splitPow2 t'

appendDigits :: (PowerTwo t) => [Digit t a] -> [Digit t a] -> [Digit t a]
appendDigits [] ds2 = ds2
appendDigits ds1 ds2 =
  let (d, ds1') = unconsDigit ds1
   in consDigit d (appendDigits ds1' ds2)

instance (PowerTwo t) => RandomAccessList (BinaryList t) where
  nil = BL []
  cons x (BL ds) = BL (consDigit (singleton x) ds)
  head (BL (D1 d : _)) = lookupPow2 0 d
  head (BL (D0 : ds)) = head (BL ds)
  tail (BL ds) = BL ds'
    where
      (_, ds') = unconsDigit ds
  append (BL ds1) (BL ds2) = BL (appendDigits ds1 ds2)
  lookup i (BL ds) = look i ds
    where
      look j (D0 : rest) = look j rest
      look j (D1 t : rest)
        | j < sizePow2 t = lookupPow2 j t
        | otherwise = look (j - sizePow2 t) rest
  update i y (BL ds) = BL (upd i ds)
    where
      upd j (D0 : rest) = D0 : upd j rest
      upd j (D1 t : rest)
        | j < sizePow2 t = D1 (updatePow2 j y t) : rest
        | otherwise = D1 t : upd (j - sizePow2 t) rest
  size (BL ds) = sum [sizePow2 t | D1 t <- ds]
