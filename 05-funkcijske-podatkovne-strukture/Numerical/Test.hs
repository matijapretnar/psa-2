import Natural
import Natural.Binary
import Natural.Peano
import Natural.SkewBinary
import Natural.ZerolessBinary
import RandomAccessList
import RandomAccessList.List
import RandomAccessList.PowerTwo
import RandomAccessList.PowerTwoMinusOne
import RandomAccessList.Sequence
import RandomAccessList.Skew
import RandomAccessList.Zeroless

testNatural :: (Natural n) => [(String, n)]
testNatural =
  let padTo7 s = replicate (7 - length s) ' ' ++ s
   in let testInc = map (\i -> (padTo7 (show i), fromInt i)) [0 .. 13]
          testDec = ("decr 14", decr (fromInt 14))
          testAdd = ("add 6 7", add (fromInt 6) (fromInt 7))
       in testInc ++ [testDec, testAdd]

testList :: (RandomAccessList f) => [(String, f Int)]
testList =
  let xs = fromList [0 .. 6]
      ys = fromList [7 .. 13]
      testAppend = ("append", append xs ys)
      testUpdate = ("update", update 6 6767 (append xs ys))
   in [testAppend, testUpdate]

main :: IO ()
main =
  let printNumTest (s, n) = putStrLn $ "  " ++ s ++ " = " ++ show n
      printListTest (s, xs) = putStrLn $ "  " ++ s ++ " = " ++ show (map (`RandomAccessList.lookup` xs) [0 .. RandomAccessList.size xs - 1])
   in do
        putStrLn "Peanova naravna števila"
        mapM_ printNumTest (testNatural :: [(String, Natural.Peano.Peano)])
        putStrLn "Dvojiški zapis"
        mapM_ printNumTest (testNatural :: [(String, Natural.Binary.Binary)])
        putStrLn "Dvojiški zapis brez ničel"
        mapM_ printNumTest (testNatural :: [(String, Natural.ZerolessBinary.ZerolessBinary)])
        putStrLn "Poševni dvojiški zapis"
        mapM_ printNumTest (testNatural :: [(String, Natural.SkewBinary.SkewBinary)])
        putStrLn "Verižni seznami"
        mapM_ printListTest (testList :: [(String, RandomAccessList.List.List Int)])
        putStrLn "Zaporedja"
        mapM_ printListTest (testList :: [(String, RandomAccessList.Sequence.Sequence Int)])
        putStrLn "Zaporedja brez ničel"
        mapM_ printListTest (testList :: [(String, RandomAccessList.Zeroless.ZerolessList LeafTree Int)])
        putStrLn "Poševni seznami"
        mapM_ printListTest (testList :: [(String, RandomAccessList.Skew.SkewList NodeTree Int)])
        putStrLn "Naraščajoči seznami"
        mapM_ printListTest (testList :: [(String, RandomAccessList.Skew.SkewList IncreasingList Int)])
