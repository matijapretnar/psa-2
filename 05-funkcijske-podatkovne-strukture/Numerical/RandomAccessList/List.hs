module RandomAccessList.List
  ( List,
  )
where

import RandomAccessList
import Prelude hiding (head, lookup, tail)

data List a = Nil | Cons a (List a) deriving (Show)

instance RandomAccessList List where
  nil = Nil
  cons = Cons
  uncons Nil = Nothing
  uncons (Cons x xs) = Just (x, xs)
  lookup 0 (Cons x _) = x
  lookup i (Cons _ xs) = lookup (i - 1) xs
  update 0 y (Cons _ xs) = Cons y xs
  update i y (Cons x xs) = Cons x (update (i - 1) y xs)
  size Nil = 0
  size (Cons _ xs) = 1 + size xs
