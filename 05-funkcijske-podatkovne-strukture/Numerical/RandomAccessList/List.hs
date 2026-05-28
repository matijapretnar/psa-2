module RandomAccessList.List
  ( List,
  )
where

import RandomAccessList
import Prelude hiding (head, lookup, tail)

data List a = Nil | Cons a (List a) deriving (Show)

tailList :: List a -> List a
tailList Nil = Nil
tailList (Cons _ xs) = xs

appendList :: List a -> List a -> List a
appendList Nil ys = ys
appendList (Cons x xs) ys = Cons x (appendList xs ys)

instance RandomAccessList List where
  nil = Nil
  cons = Cons
  head (Cons x _) = x
  tail = tailList
  append = appendList
  lookup 0 (Cons x _) = x
  lookup i (Cons _ xs) = lookup (i - 1) xs
  update 0 y (Cons _ xs) = Cons y xs
  update i y (Cons x xs) = Cons x (update (i - 1) y xs)
  size Nil = 0
  size (Cons _ xs) = 1 + size xs
