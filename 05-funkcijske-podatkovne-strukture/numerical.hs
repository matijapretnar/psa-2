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

test :: Natural n => [(String, n)]
test =
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
testPeano = test

instance Natural Binary where
    zero                    = Bin []
    incr (Bin ds)           = Bin (incBits ds)
    decr (Bin ds)           = Bin (decBits ds)
    add (Bin ds1) (Bin ds2) = Bin (addBits ds1 ds2)

testBinary :: [(String, Binary)]
testBinary = test

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
appendPow2 ds1     []       = ds1
appendPow2 (D0:ds1) (d:ds2) = d : appendPow2 ds1 ds2
appendPow2 (d:ds1) (D0:ds2) = d : appendPow2 ds1 ds2
appendPow2 (D1 d1:ds1) (D1 d2:ds2)  = D0 : (consPow2 (linkPow2 d1 d2) (appendPow2 ds1 ds2))

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

instance Natural ZLBinary where
    zero           = ZBin []
    incr (ZBin ds) = ZBin (incZLBits ds)
    decr _         = error "za na vaje"
    add _ _        = error "za na vaje"

testZLBinary :: [(String, ZLBinary)]
testZLBinary = test

---

data ZerolessDigit t a = ZD1 (t a) | ZD2 (t a) (t a) deriving Show
newtype ZerolessList t a = ZL [ZerolessDigit t a] deriving Show

instance PowerTwo t => RandomAccessList (ZerolessList t) where
    nil            = ZL []
    cons x (ZL ds) = ZL (consZeroless (singleton x) ds)
      where
        consZeroless t [] = [ZD1 t]
        consZeroless t (ZD1 t' : ds) = ZD2 t t' : ds
        consZeroless t (ZD2 t1 t2 : ds) = ZD1 t : consZeroless (linkPow2 t1 t2) ds
    head (ZL (ZD1 t : _)) = lookupPow2 0 t
    head (ZL (ZD2 t1 _ : _)) = lookupPow2 0 t1
    tail _          = error "za na vaje"
    append _ _       = error "za na vaje"
    lookup _ _       = error "za na vaje"
    update _ _ _     = error "za na vaje"

---

main =
    let printTest (s, n) = putStrLn $ "  " ++ s ++ " = " ++ show n
     in do
        putStrLn "Peanova naravna števila"
        mapM_ printTest testPeano
        putStrLn "Dvojiški zapis"
        mapM_ printTest testBinary
        putStrLn "Dvojiški zapis brez ničel"
        mapM_ printTest testZLBinary
