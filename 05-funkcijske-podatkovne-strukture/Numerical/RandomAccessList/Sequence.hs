module RandomAccessList.Sequence
  ( Sequence,
  )
where

import RandomAccessList
import Prelude hiding (head, lookup, tail)

newtype Sequence a = Sequence (Int, Int -> a)

instance RandomAccessList Sequence where
  nil = Sequence (0, \_ -> error "empty")
  head (Sequence (_, f)) = f 0
  cons x (Sequence (n, f)) = Sequence (n + 1, \i -> if i == 0 then x else f (i - 1))
  tail (Sequence (n, f)) = Sequence (n - 1, \i -> f (i + 1))
  append (Sequence (m, f)) (Sequence (n, g)) =
    Sequence (m + n, \i -> if i < m then f i else g (i - m))
  lookup i (Sequence (_, f)) = f i
  update i y (Sequence (n, f)) = Sequence (n, \j -> if i == j then y else f j)
  size (Sequence (n, _)) = n
