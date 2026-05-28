module RandomAccessList.PowerTwo
  ( PowerTwo (..),
    LeafTree,
  )
where

class PowerTwo t where
  singleton :: a -> t a
  linkPow2 :: t a -> t a -> t a
  sizePow2 :: t a -> Int
  splitPow2 :: t a -> (t a, t a)
  lookupPow2 :: Int -> t a -> a
  updatePow2 :: Int -> a -> t a -> t a

data LeafTree a = Leaf a | Node Int (LeafTree a) (LeafTree a) deriving (Show)

instance PowerTwo LeafTree where
  singleton = Leaf
  linkPow2 t1 t2 = Node (sizePow2 t1 + sizePow2 t2) t1 t2
  sizePow2 (Leaf _) = 1
  sizePow2 (Node w _ _) = w
  splitPow2 (Node _ t1 t2) = (t1, t2)
  lookupPow2 0 (Leaf x) = x
  lookupPow2 i (Node w t1 t2)
    | i < w `div` 2 = lookupPow2 i t1
    | otherwise = lookupPow2 (i - w `div` 2) t2
  updatePow2 0 y (Leaf _) = Leaf y
  updatePow2 i y (Node w t1 t2)
    | i < w `div` 2 = Node w (updatePow2 i y t1) t2
    | otherwise = Node w t1 (updatePow2 (i - w `div` 2) y t2)
