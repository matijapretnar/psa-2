module RandomAccessList.PowerTwoMinusOne
  ( PowerTwoMinusOne (..),
    NodeTree,
    IncreasingList,
  )
where

class PowerTwoMinusOne t where
  empty :: t a
  linkTree :: a -> t a -> t a -> t a
  sizeTree :: t a -> Int
  splitTree :: t a -> (a, t a, t a)
  lookupTree :: Int -> t a -> a
  updateTree :: Int -> a -> t a -> t a

data NodeTree a = Leaf2 | Node2 Int a (NodeTree a) (NodeTree a) deriving (Show)

instance PowerTwoMinusOne NodeTree where
  empty = Leaf2
  linkTree x t1 t2 = Node2 (sizeTree t1 + sizeTree t2 + 1) x t1 t2
  sizeTree :: NodeTree a -> Int
  sizeTree Leaf2 = 0
  sizeTree (Node2 w _ _ _) = w
  splitTree (Node2 _ x t1 t2) = (x, t1, t2)
  lookupTree 0 (Node2 _ x _ _) = x
  lookupTree i (Node2 w _ t1 t2)
    | i <= w `div` 2 = lookupTree (i - 1) t1
    | otherwise = lookupTree (i - (w `div` 2) - 1) t2
  updateTree 0 y (Node2 w _ t1 t2) = Node2 w y t1 t2
  updateTree i y (Node2 w x t1 t2)
    | i <= w `div` 2 = Node2 w x (updateTree (i - 1) y t1) t2
    | otherwise = Node2 w x t1 (updateTree (i - (w `div` 2) - 1) y t2)

data IncreasingList a = IncEmpty | IncCons a (IncreasingList (a, a))

zipInc :: IncreasingList a -> IncreasingList a -> IncreasingList (a, a)
zipInc IncEmpty IncEmpty = IncEmpty
zipInc (IncCons x xs) (IncCons y ys) = IncCons (x, y) (zipInc xs ys)

unzipInc :: IncreasingList (a, a) -> (IncreasingList a, IncreasingList a)
unzipInc IncEmpty = (IncEmpty, IncEmpty)
unzipInc (IncCons (x, y) t) =
  let (t1, t2) = unzipInc t
   in (IncCons x t1, IncCons y t2)

instance PowerTwoMinusOne IncreasingList where
  empty = IncEmpty
  linkTree x t1 t2 = IncCons x (zipInc t1 t2)
  sizeTree IncEmpty = 0
  sizeTree (IncCons _ t) = 1 + 2 * sizeTree t
  splitTree (IncCons x t) =
    let (t1, t2) = unzipInc t
     in (x, t1, t2)
  lookupTree 0 (IncCons x _) = x
  lookupTree i (IncCons _ ts) =
    let (t1, t2) = unzipInc ts
        w = sizeTree t1
     in if i <= w then lookupTree (i - 1) t1 else lookupTree (i - w - 1) t2
  updateTree 0 y (IncCons _ t) = IncCons y t
  updateTree i y (IncCons x t) =
    let (t1, t2) = unzipInc t
        w = sizeTree t1
     in if i <= w then linkTree x (updateTree (i - 1) y t1) t2 else linkTree x t1 (updateTree (i - w - 1) y t2)
