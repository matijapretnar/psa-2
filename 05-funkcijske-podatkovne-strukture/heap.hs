import Debug.Trace

class Ord a => Heap h a where
    empty     :: h a
    isEmpty   :: h a -> Bool
    insert    :: a -> h a -> h a
    merge     :: h a -> h a -> h a
    findMin   :: h a -> a
    deleteMin :: h a -> h a

data LeftistHeap a = E | T Int a (LeftistHeap a) (LeftistHeap a)

rank :: LeftistHeap a -> Int
rank E           = 0
rank (T r _ _ _) = r

makeT :: a -> LeftistHeap a -> LeftistHeap a -> LeftistHeap a
makeT x a b
    | rank a >= rank b = T (rank b + 1) x a b
    | otherwise        = T (rank a + 1) x b a

instance Ord a => Heap LeftistHeap a where
    empty = E

    isEmpty E = True
    isEmpty _ = False

    insert x h = merge (T 1 x E E) h

    merge h E = h
    merge E h = h
    merge h1@(T _ x a1 b1) h2@(T _ y a2 b2)
        | x <= y    = makeT x a1 (merge b1 h2)
        | otherwise = makeT y a2 (merge h1 b2)

    findMin (T _ x _ _) = x

    deleteMin (T _ _ a b) = merge a b


data BinomialTree a = NODE Int a [BinomialTree a]
newtype BinomialHeap a = BH [BinomialTree a]

rankT :: BinomialTree a -> Int
rankT (NODE r _ _) = r

root :: BinomialTree a -> a
root (NODE _ x _) = x

link :: Ord a => BinomialTree a -> BinomialTree a -> BinomialTree a
link t1@(NODE r x1 c1) t2@(NODE _ x2 c2)
    | x1 <= x2  = NODE (r + 1) x1 (t2 : c1)
    | otherwise = NODE (r + 1) x2 (t1 : c2)

insTree :: Ord a => BinomialTree a -> [BinomialTree a] -> [BinomialTree a]
insTree t []             = [t]
insTree t ts@(t' : ts')
    | rankT t < rankT t' = trace "insTree" $ t : ts
    | otherwise          = trace "insTree" $ insTree (link t t') ts'

mrg :: Ord a => [BinomialTree a] -> [BinomialTree a] -> [BinomialTree a]
mrg ts1 []  = ts1
mrg []  ts2 = ts2
mrg ts1@(t1 : ts1') ts2@(t2 : ts2')
    | rankT t1 < rankT t2 = trace "mrg" $ t1 : mrg ts1' ts2
    | rankT t2 < rankT t1 = trace "mrg" $ t2 : mrg ts1  ts2'
    | otherwise           = trace "mrg" $ insTree (link t1 t2) (mrg ts1' ts2')

removeMinTree :: Ord a => [BinomialTree a] -> (BinomialTree a, [BinomialTree a])
removeMinTree [t]  = (t, [])
removeMinTree (t : ts)
    | root t < root t' = (t, ts)
    | otherwise        = (t', t : ts')
  where (t', ts') = removeMinTree ts

treeLines :: Show a => BinomialTree a -> [String]
treeLines (NODE _ x cs) = show x : childLines cs

childLines :: Show a => [BinomialTree a] -> [String]
childLines []     = []
childLines [c]    = indented "└─ " "   " (treeLines c)
childLines (c:cs) = indented "├─ " "│  " (treeLines c) ++ childLines cs

indented :: String -> String -> [String] -> [String]
indented _     _    []     = []
indented first rest (l:ls) = (first ++ l) : map (rest ++) ls

instance Show a => Show (BinomialTree a) where
    show = unlines . treeLines

instance Show a => Show (BinomialHeap a) where
    show (BH ts) = concatMap (\t -> show t ++ "\n") ts

instance Ord a => Heap BinomialHeap a where
    empty = BH []

    isEmpty (BH ts) = null ts

    insert x (BH ts) = BH (insTree (NODE 0 x []) ts)

    merge (BH ts1) (BH ts2) = BH (mrg ts1 ts2)

    findMin (BH ts) = root t
      where (t, _) = removeMinTree ts

    deleteMin (BH ts) = BH (mrg (reverse ts1) ts2)
      where (NODE _ _ ts1, ts2) = removeMinTree ts

example = foldr insert (empty :: BinomialHeap Int) [1..42]