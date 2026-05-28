module RandomAccessList.PowerTwoMinusOne
  ( PowerTwoMinusOne (..),
    NodeTree,
    IncreasingList,
  )
where

class PowerTwoMinusOne t where
  empty :: t a
  linkPow2_1 :: a -> t a -> t a -> t a
  sizePow2_1 :: t a -> Int
  splitPow2_1 :: t a -> (a, t a, t a)
  lookupPow2_1 :: Int -> t a -> a
  updatePow2_1 :: Int -> a -> t a -> t a

data NodeTree a = Leaf2 | Node2 Int a (NodeTree a) (NodeTree a) deriving (Show)

instance PowerTwoMinusOne NodeTree where
  empty = Leaf2
  linkPow2_1 x t1 t2 = Node2 (sizePow2_1 t1 + sizePow2_1 t2 + 1) x t1 t2
  sizePow2_1 Leaf2 = 0
  sizePow2_1 (Node2 w _ _ _) = w
  splitPow2_1 (Node2 _ x t1 t2) = (x, t1, t2)
  lookupPow2_1 0 (Node2 _ x _ _) = x
  lookupPow2_1 i (Node2 w _ t1 t2)
    | i <= w `div` 2 = lookupPow2_1 (i - 1) t1
    | otherwise = lookupPow2_1 (i - (w `div` 2) - 1) t2
  updatePow2_1 0 y (Node2 w _ t1 t2) = Node2 w y t1 t2
  updatePow2_1 i y (Node2 w x t1 t2)
    | i <= w `div` 2 = Node2 w x (updatePow2_1 (i - 1) y t1) t2
    | otherwise = Node2 w x t1 (updatePow2_1 (i - (w `div` 2) - 1) y t2)

data IncreasingList a = IncEmpty | IncCons a (IncreasingList (a, a))

zipIncreasing :: IncreasingList a -> IncreasingList a -> IncreasingList (a, a)
zipIncreasing IncEmpty IncEmpty = IncEmpty
zipIncreasing (IncCons x xs) (IncCons y ys) = IncCons (x, y) (zipIncreasing xs ys)

unzipInc :: IncreasingList (a, a) -> (IncreasingList a, IncreasingList a)
unzipInc IncEmpty = (IncEmpty, IncEmpty)
unzipInc (IncCons (x, y) t) =
  let (t1, t2) = unzipInc t
   in (IncCons x t1, IncCons y t2)

instance PowerTwoMinusOne IncreasingList where
  empty = IncEmpty
  linkPow2_1 x t1 t2 = IncCons x (zipIncreasing t1 t2)
  sizePow2_1 IncEmpty = 0
  sizePow2_1 (IncCons _ t) = 1 + 2 * sizePow2_1 t
  splitPow2_1 (IncCons x t) =
    let (t1, t2) = unzipInc t
     in (x, t1, t2)
  lookupPow2_1 0 (IncCons x _) = x
  lookupPow2_1 i (IncCons _ ts) =
    let (t1, t2) = unzipInc ts
        w = sizePow2_1 t1
     in if i <= w then lookupPow2_1 (i - 1) t1 else lookupPow2_1 (i - w - 1) t2
  updatePow2_1 0 y (IncCons _ t) = IncCons y t
  updatePow2_1 i y (IncCons x t) =
    let (t1, t2) = unzipInc t
        w = sizePow2_1 t1
     in if i <= w then linkPow2_1 x (updatePow2_1 (i - 1) y t1) t2 else linkPow2_1 x t1 (updatePow2_1 (i - w - 1) y t2)
