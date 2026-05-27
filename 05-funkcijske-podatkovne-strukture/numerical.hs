import Prelude hiding (head, tail, lookup)
import Data.List (intercalate)

data Peano = Zero | Succ Peano

instance Show Peano where
    show Zero     = "0"
    show (Succ n) = "1+" ++ show n

decrPeano (Succ n) = n

addPeano Zero     m = m
addPeano (Succ n) m = Succ (addPeano n m)

---

data List a = Nil | Cons a (List a) deriving Show

tailList Nil         = Nil
tailList (Cons _ xs) = xs

appendList Nil         ys = ys
appendList (Cons x xs) ys = Cons x (appendList xs ys)

---

data Bit = O | I
newtype Binary = Bin [Bit]

powerOfTwo :: Int -> String
powerOfTwo 0 = "⁰"
powerOfTwo n =
    map ("⁰¹²³⁴⁵⁶⁷⁸⁹" !!) (digits n)
      where
        digits 0 = []
        digits n = digits (n `div` 10) ++ [n `mod` 10]

instance Show Binary where
    show (Bin ds) =
       concatMap showBit (reverse ds) ++ "₂"
       ++ " = " ++
       intercalate " + " (zipWith (\i d -> showBit d ++ "⋅2" ++ powerOfTwo i) [0..] ds)
       where
        showBit I = "1"
        showBit O = "0"

incBits :: [Bit] -> [Bit]
incBits []     = [I]
incBits (O:ds) = I : ds
incBits (I:ds) = O : incBits ds

decBits :: [Bit] -> [Bit]
decBits [I]    = []
decBits (I:ds) = O : ds
decBits (O:ds) = I : decBits ds

addBits :: [Bit] -> [Bit] -> [Bit]
addBits []      ds2     = ds2
addBits ds1     []      = ds1
addBits (O:ds1) (d:ds2) = d : addBits ds1 ds2
addBits (d:ds1) (O:ds2) = d : addBits ds1 ds2
addBits (I:ds1) (I:ds2) = O : incBits (addBits ds1 ds2)

---

class Natural n where
    zero :: n
    incr :: n -> n
    decr :: n -> n
    add  :: n -> n -> n

fromInt :: Natural n => Integer -> n
fromInt 0 = zero
fromInt n = incr (fromInt (n - 1))

testNatural :: Natural n => [(String, n)]
testNatural =
    let padTo7 s = replicate (7 - length s) ' ' ++ s in
    let testInc = map (\i -> (padTo7 (show i), fromInt i)) [0..13]
        testDec = ("decr 14", decr (fromInt 14))
        testAdd = ("add 6 7", add (fromInt 6) (fromInt 7))
    in
        testInc ++ [testDec, testAdd]

instance Natural Peano where
    zero = Zero
    incr = Succ
    decr = decrPeano
    add  = addPeano

testPeano :: [(String, Peano)]
testPeano = testNatural

instance Natural Binary where
    zero                    = Bin []
    incr (Bin ds)           = Bin (incBits ds)
    decr (Bin ds)           = Bin (decBits ds)
    add (Bin ds1) (Bin ds2) = Bin (addBits ds1 ds2)

testBinary :: [(String, Binary)]
testBinary = testNatural

---

class RandomAccessList f where
    nil     :: f a
    cons    :: a -> f a -> f a
    head    :: f a -> a
    tail    :: f a -> f a
    append  :: f a -> f a -> f a
    ---
    lookup  :: Int -> f a -> a
    update  :: Int -> a -> f a -> f a
    size    :: f a -> Int

fromList :: RandomAccessList f => [a] -> f a
fromList [] = nil
fromList (x:xs) = cons x (fromList xs)

testRandomAccessList :: RandomAccessList f => [(String, f Int)]
testRandomAccessList =
    let xs = fromList [0 .. 6]
        ys = fromList [7 .. 13]
        testAppend = ("append", append xs ys)
        testUpdate = ("update", update 6 6767 (append xs ys))
    in
        [testAppend, testUpdate]

instance RandomAccessList List where
    nil                    = Nil
    cons                   = Cons
    head (Cons x _)        = x
    tail                   = tailList
    append                 = appendList
    ---
    lookup 0 (Cons x _)    = x
    lookup i (Cons _ xs)   = lookup (i-1) xs
    update 0 y (Cons _ xs) = Cons y xs
    update i y (Cons x xs) = Cons x (update (i-1) y xs)
    size Nil         = 0
    size (Cons _ xs) = 1 + size xs

testList :: [(String, List Int)]
testList = testRandomAccessList

newtype Sequence a = Sequence (Int, Int -> a)

instance RandomAccessList Sequence where
    nil = Sequence (0, \i -> error "empty")
    head (Sequence (_, f)) = f 0
    cons x (Sequence (n, f)) = Sequence (n + 1, \i -> if i == 0 then x else f (i - 1))
    tail (Sequence (n, f)) = Sequence (n - 1, \i -> f (i + 1))
    append (Sequence (m, f)) (Sequence (n, g)) =
        Sequence (m + n, \i -> if i < m then f i else g (i - m))
    lookup i (Sequence (_, f)) = f i
    update i y (Sequence (n, f)) = Sequence (n, \j -> if i == j then y else f j)
    size (Sequence (n, _)) = n

testSequence :: [(String, Sequence Int)]
testSequence = testRandomAccessList

---

class PowerTwo t where
    singleton  :: a -> t a
    linkPow2   :: t a -> t a -> t a
    sizePow2   :: t a -> Int
    splitPow2  :: t a -> (t a, t a)
    lookupPow2 :: Int -> t a -> a
    updatePow2 :: Int -> a -> t a -> t a

data LeafTree a = Leaf a | Node Int (LeafTree a) (LeafTree a) deriving Show

instance PowerTwo LeafTree where
    singleton                = Leaf
    linkPow2 t1 t2           = Node (sizePow2 t1 + sizePow2 t2) t1 t2
    sizePow2 (Leaf _)        = 1
    sizePow2 (Node w _ _)    = w
    splitPow2 (Node _ t1 t2) = (t1, t2)
    lookupPow2 0 (Leaf x)    = x
    lookupPow2 i (Node w t1 t2)
        | i < w `div` 2      = lookupPow2 i t1
        | otherwise          = lookupPow2 (i - w `div` 2) t2
    updatePow2 0 y (Leaf _)  = Leaf y
    updatePow2 i y (Node w t1 t2)
        | i < w `div` 2      = Node w (updatePow2 i y t1) t2
        | otherwise          = Node w t1 (updatePow2 (i - w `div` 2) y t2)

---

data Digit t a = D0 | D1 (t a) deriving Show
newtype BinaryList t a = BL [Digit t a] deriving Show

consPow2 :: PowerTwo t => t a -> [Digit t a] -> [Digit t a]
consPow2 t []           = [D1 t]
consPow2 t (D0    : ds) = D1 t : ds
consPow2 t (D1 t' : ds) = D0   : consPow2 (linkPow2 t t') ds

unconsPow2 :: PowerTwo t => [Digit t a] -> (t a, [Digit t a])
unconsPow2 [D1 t]       = (t, [])
unconsPow2 (D1 t  : ds) = (t, D0 : ds)
unconsPow2 (D0    : ds) = (t1, D1 t2 : ds')
  where (t', ds')       = unconsPow2 ds
        (t1, t2)        = splitPow2 t'

appendPow2 :: PowerTwo t => [Digit t a] -> [Digit t a] -> [Digit t a]
appendPow2 []      ds2      = ds2
appendPow2 ds1     ds2      = let (d, ds1') = unconsPow2 ds1
                              in  consPow2 d (appendPow2 ds1' ds2)

instance PowerTwo t => RandomAccessList (BinaryList t) where
    nil                      = BL []
    cons x (BL ds)           = BL (consPow2 (singleton x) ds)
    head (BL (D1 d : _))     = lookupPow2 0 d
    head (BL (D0 : ds))      = head (BL ds)
    tail (BL ds)             = BL ds'       where (_, ds') = unconsPow2 ds
    append (BL ds1) (BL ds2) = BL (appendPow2 ds1 ds2)

    lookup i (BL ds) = look i ds
      where
        look i (D0   : ds) = look i ds
        look i (D1 t : ds)
            | i < sizePow2 t  = lookupPow2 i t
            | otherwise       = look (i - sizePow2 t) ds
    update i y (BL ds) = BL (upd i ds)
      where
        upd i (D0   : ds) = D0 : upd i ds
        upd i (D1 t : ds)
            | i < sizePow2 t  = D1 (updatePow2 i y t) : ds
            | otherwise       = D1 t : upd (i - sizePow2 t) ds
    size (BL ds) = sum [sizePow2 t | D1 t <- ds]

---

data ZLBit = One | Two
newtype ZLBinary = ZBin [ZLBit]

instance Show ZLBinary where
    show (ZBin ds) =
       concatMap showZLBit (reverse ds) ++ "₂"
       ++ " = " ++
       intercalate " + " (zipWith (\i d -> showZLBit d ++ "⋅2" ++ powerOfTwo i) [0..] ds)
      where
        showZLBit One = "1"
        showZLBit Two = "2"

incZLBits :: [ZLBit] -> [ZLBit]
incZLBits []     = [One]
incZLBits (One:ds) = Two : ds
incZLBits (Two:ds) = One : incZLBits ds

-- rešitev za na vaje (Okasaki, naloga 9.4)
decZLBits :: [ZLBit] -> [ZLBit]
decZLBits [One]    = []
decZLBits (Two:ds) = One : ds
decZLBits (One:ds) = Two : decZLBits ds

-- rešitev za na vaje (Okasaki, naloga 9.4)
addZLBits :: [ZLBit] -> [ZLBit] -> [ZLBit]
addZLBits []        ds2       = ds2
addZLBits ds1       []        = ds1
addZLBits (One:ds1) (One:ds2) = Two : addZLBits ds1 ds2
addZLBits (One:ds1) (Two:ds2) = One : incZLBits (addZLBits ds1 ds2)
addZLBits (Two:ds1) (One:ds2) = One : incZLBits (addZLBits ds1 ds2)
addZLBits (Two:ds1) (Two:ds2) = Two : incZLBits (addZLBits ds1 ds2)

instance Natural ZLBinary where
    zero                      = ZBin []
    incr (ZBin ds)            = ZBin (incZLBits ds)
    decr (ZBin ds)            = ZBin (decZLBits ds)
    add (ZBin ds1) (ZBin ds2) = ZBin (addZLBits ds1 ds2)

testZLBinary :: [(String, ZLBinary)]
testZLBinary = testNatural

---

data ZerolessDigit t a = ZD1 (t a) | ZD2 (t a) (t a) deriving Show
newtype ZerolessList t a = ZL [ZerolessDigit t a] deriving Show

consZeroless :: PowerTwo t => t a -> [ZerolessDigit t a] -> [ZerolessDigit t a]
consZeroless t []               = [ZD1 t]
consZeroless t (ZD1 t' : ds)    = ZD2 t t' : ds
consZeroless t (ZD2 t1 t2 : ds) = ZD1 t : consZeroless (linkPow2 t1 t2) ds

-- rešitev za na vaje (Okasaki, naloga 9.5): pomožna funkcija za tail.
--
-- Naloga 9.5 zahteva implementacijo preostalih funkcij iz RANDOMACCESSLIST
-- (Okasaki, slika 9.4) razen head, ki ga obravnava že knjiga: torej cons,
-- tail, lookup in update. Te uporabljajo naslednje funkcije razreda PowerTwo:
--   cons    -> singleton, linkPow2
--   tail    -> splitPow2  (preko unconsZeroless)
--   lookup  -> sizePow2, lookupPow2
--   update  -> sizePow2, updatePow2
-- (Funkcije append Okasakijev podpis ne vključuje.)
--
-- V tretji vrstici si izposodimo prvo drevo z naslednjega položaja
-- in ga s splitPow2 razpolovimo na dve drevesi velikosti 1.
unconsZeroless :: PowerTwo t => [ZerolessDigit t a] -> (t a, [ZerolessDigit t a])
unconsZeroless [ZD1 t]            = (t, [])
unconsZeroless (ZD2 t1 t2 : ds)   = (t1, ZD1 t2 : ds)
unconsZeroless (ZD1 t : ds)       = (t, ZD2 ta tb : ds')
  where (t', ds') = unconsZeroless ds
        (ta, tb)  = splitPow2 t'

-- rešitev za na vaje (Okasaki, naloga 9.5): pomožna funkcija za append.
--
appendZeroless :: PowerTwo t => [ZerolessDigit t a] -> [ZerolessDigit t a] -> [ZerolessDigit t a]
appendZeroless []  ds2 = ds2
appendZeroless ds1 ds2 =
    let (t, ds1') = unconsZeroless ds1
    in  consZeroless t (appendZeroless ds1' ds2)

instance PowerTwo t => RandomAccessList (ZerolessList t) where
    nil                      = ZL []
    cons x (ZL ds)           = ZL (consZeroless (singleton x) ds)
    head (ZL (ZD1 t : _))    = lookupPow2 0 t
    head (ZL (ZD2 t1 _ : _)) = lookupPow2 0 t1
    tail (ZL ds)             = ZL ds' where (_, ds') = unconsZeroless ds
    append (ZL ds1) (ZL ds2) = ZL (appendZeroless ds1 ds2)

    -- Strukturno enako kot pri BinaryList, le da imamo namesto D0/D1 dva primera
    -- ZD1/ZD2; pri ZD2 indeks lahko pade v prvo ali drugo drevo na istem položaju.
    lookup i (ZL ds) = look i ds
      where
        look i (ZD1 t : ds)
            | i < sizePow2 t                  = lookupPow2 i t
            | otherwise                       = look (i - sizePow2 t) ds
        look i (ZD2 t1 t2 : ds)
            | i < sizePow2 t1                 = lookupPow2 i t1
            | i < sizePow2 t1 + sizePow2 t2   = lookupPow2 (i - sizePow2 t1) t2
            | otherwise                       = look (i - sizePow2 t1 - sizePow2 t2) ds
    update i y (ZL ds) = ZL (upd i ds)
      where
        upd i (ZD1 t : ds)
            | i < sizePow2 t                  = ZD1 (updatePow2 i y t) : ds
            | otherwise                       = ZD1 t : upd (i - sizePow2 t) ds
        upd i (ZD2 t1 t2 : ds)
            | i < sizePow2 t1                 = ZD2 (updatePow2 i y t1) t2 : ds
            | i < sizePow2 t1 + sizePow2 t2   = ZD2 t1 (updatePow2 (i - sizePow2 t1) y t2) : ds
            | otherwise                       = ZD2 t1 t2 : upd (i - sizePow2 t1 - sizePow2 t2) ds
    size (ZL ds) = sum [sizePow2 t | ZD1 t <- ds] + sum [sizePow2 t1 + sizePow2 t2 | ZD2 t1 t2 <- ds]

testZerolessList :: [(String, ZerolessList LeafTree Int)]
testZerolessList = testRandomAccessList

---

newtype SkewBinary = SBin [Int]

instance Show SkewBinary where
    show (SBin ws) =
       intercalate " + " (map show ws)
       

incSkewBits :: [Int] -> [Int]
incSkewBits (w1:w2:ws) | w1 == w2 = (1 + w1 + w2):ws
incSkewBits ws = 1:ws

decSkewBits :: [Int] -> [Int]
decSkewBits (1:ws) = ws
decSkewBits (w:ws) = (w `div` 2) : (w `div` 2) : ws

addSkewBits :: [Int] -> [Int] -> [Int]
addSkewBits []        ds2       = ds2
addSkewBits ds1       ds2       = incSkewBits (addSkewBits (decSkewBits ds1) ds2)

instance Natural SkewBinary where
    zero                      = SBin []
    incr (SBin ds)            = SBin (incSkewBits ds)
    decr (SBin ds)            = SBin (decSkewBits ds)
    add (SBin ds1) (SBin ds2) = SBin (addSkewBits ds1 ds2)

testSkewBinary :: [(String, SkewBinary)]
testSkewBinary = testNatural

---

class PowerTwoMinusOne t where
    empty        :: t a
    linkPow2_1   :: a -> t a -> t a -> t a
    sizePow2_1   :: t a -> Int
    splitPow2_1  :: t a -> (a, t a, t a)
    lookupPow2_1 :: Int -> t a -> a
    updatePow2_1 :: Int -> a -> t a -> t a

data NodeTree a = Leaf2 | Node2 Int a (NodeTree a) (NodeTree a) deriving Show

instance PowerTwoMinusOne NodeTree where
    empty                             = Leaf2
    linkPow2_1 x t1 t2                = Node2 (sizePow2_1 t1 + sizePow2_1 t2 + 1) x t1 t2
    sizePow2_1 (Leaf2)                 = 0
    sizePow2_1 (Node2 w _ _ _)         = w
    splitPow2_1 (Node2 _ x t1 t2)      = (x, t1, t2)
    lookupPow2_1 0 (Node2 w x _ _)     = x
    lookupPow2_1 i (Node2 w _ t1 t2)
        | i <= w `div` 2               = lookupPow2_1 (i - 1) t1
        | otherwise                    = lookupPow2_1 (i - (w `div` 2) - 1) t2
    updatePow2_1 0 y (Node2 w x t1 t2) = Node2 w y t1 t2
    updatePow2_1 i y (Node2 w x t1 t2)
        | i <= w `div` 2               = Node2 w x (updatePow2_1 (i - 1) y t1) t2
        | otherwise                    = Node2 w x t1 (updatePow2_1 (i - (w `div` 2) - 1) y t2)

---

newtype SkewList t a = SL [(Int, t a)] deriving Show

consSparsePow :: PowerTwoMinusOne t => a -> [(Int, t a)] -> [(Int, t a)]
consSparsePow x ((w1, t1) : (w2, t2) : wts) | w1 == w2 = (w1 + w2 + 1, linkPow2_1 x t1 t2) : wts
consSparsePow x wts = (1, linkPow2_1 x empty empty) : wts

unconsSparsePow :: PowerTwoMinusOne t => [(Int, t a)] -> (a, [(Int, t a)])
unconsSparsePow ((1, t) : wts) = (x, wts) where (x, _, _) = splitPow2_1 t
unconsSparsePow ((w, t) : wts) = (x, (w `div` 2, t1) : (w `div` 2, t2) : wts) where (x, t1, t2) = splitPow2_1 t

appendSparsePow :: PowerTwoMinusOne t => [(Int, t a)] -> [(Int, t a)] -> [(Int, t a)]
appendSparsePow []      ds2      = ds2
appendSparsePow ds1     ds2      = let (d, ds1') = unconsSparsePow ds1
                                   in  consSparsePow d (appendSparsePow ds1' ds2)

instance PowerTwoMinusOne t => RandomAccessList (SkewList t) where
    nil                      = SL []
    cons x (SL wts)           = SL (consSparsePow x wts)
    head (SL ((_, t) : _))   = x where (x, _, _) = splitPow2_1 t
    tail (SL wts)             = SL wts'       where (_, wts') = unconsSparsePow wts
    append (SL wts1) (SL wts2) = SL (appendSparsePow wts1 wts2)

    lookup i (SL wts) = look i wts
      where
        look i ((w, t) : wts)
            | i < w = lookupPow2_1 i t
            | otherwise       = look (i - w) wts
    update i y (SL wts) = SL (upd i wts)
      where
        upd i ((w, t) : wts)
            | i < w = (w, updatePow2_1 i y t) : wts
            | otherwise = (w, t) : upd (i - w) wts
    size (SL wts) = sum [w | (w, _) <- wts]

testSkewList :: [(String, SkewList NodeTree Int)]
testSkewList = testRandomAccessList

---

data IncreasingList a = IncEmpty | IncCons a (IncreasingList (a, a))

zipIncreasing :: IncreasingList a -> IncreasingList a -> IncreasingList (a, a)
zipIncreasing IncEmpty IncEmpty = IncEmpty
zipIncreasing (IncCons x xs) (IncCons y ys) = IncCons (x, y) (zipIncreasing xs ys)

unzipInc :: IncreasingList (a, a) -> (IncreasingList a, IncreasingList a)
unzipInc IncEmpty = (IncEmpty, IncEmpty)
unzipInc (IncCons (x, y) t) =
    let (t1, t2) = unzipInc t in (IncCons x t1, IncCons y t2)

instance PowerTwoMinusOne IncreasingList where
    empty                             = IncEmpty
    linkPow2_1 x t1 t2                = IncCons x (zipIncreasing t1 t2)
    sizePow2_1 IncEmpty                   = 0
    sizePow2_1 (IncCons _ t)              = 1 + 2 * sizePow2_1 t
    splitPow2_1 (IncCons x t)             = let (t1, t2) = unzipInc t in (x, t1, t2)
    lookupPow2_1 0 (IncCons x _)     = x
    lookupPow2_1 i (IncCons _ ts)    =
        let (t1, t2) = unzipInc ts in
        let w = sizePow2_1 t1 in
        if i <= w then lookupPow2_1 (i - 1) t1 else lookupPow2_1 (i - w - 1) t2
    updatePow2_1 0 y (IncCons x t) = IncCons y t
    updatePow2_1 i y (IncCons x t) =
        let (t1, t2) = unzipInc t in
        let w = sizePow2_1 t1 in
        if i <= w then linkPow2_1 y (updatePow2_1 (i - 1) y t1) t2 else linkPow2_1 x t1 (updatePow2_1 (i - w - 1) y t2)

testIncreasingList :: [(String, SkewList IncreasingList Int)]
testIncreasingList = testRandomAccessList

---

main =
    let printNumTest (s, n) = putStrLn $ "  " ++ s ++ " = " ++ show n
        printListTest (s, xs) = putStrLn $ "  " ++ s ++ " = " ++ show (map (`lookup` xs) [0 .. size xs - 1])
     in do
        putStrLn "Peanova naravna števila"
        mapM_ printNumTest testPeano
        putStrLn "Dvojiški zapis"
        mapM_ printNumTest testBinary
        putStrLn "Dvojiški zapis brez ničel"
        mapM_ printNumTest testZLBinary
        putStrLn "Poševni dvojiški zapis"
        mapM_ printNumTest testSkewBinary
        putStrLn "Verižni seznami"
        mapM_ printListTest testList
        putStrLn "Zaporedja"
        mapM_ printListTest testSequence
        putStrLn "Zaporedja brez ničel"
        mapM_ printListTest testZerolessList
        putStrLn "Poševni seznami"
        mapM_ printListTest testSkewList
        putStrLn "Naraščajoči seznami"
        mapM_ printListTest testIncreasingList
