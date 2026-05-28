module RandomAccessList
  ( RandomAccessList (..),
    fromList,
  )
where

import Prelude hiding (head, lookup, tail)

class RandomAccessList f where
  nil :: f a
  cons :: a -> f a -> f a
  head :: f a -> a
  tail :: f a -> f a
  append :: f a -> f a -> f a
  lookup :: Int -> f a -> a
  update :: Int -> a -> f a -> f a
  size :: f a -> Int

fromList :: (RandomAccessList f) => [a] -> f a
fromList [] = nil
fromList (x : xs) = cons x (fromList xs)
