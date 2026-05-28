import Natural
import Natural.Binary (Binary)
import Natural.Peano (Peano)
import Natural.SkewBinary (SkewBinary)
import Natural.ZerolessBinary (ZerolessBinary)
import RandomAccessList
import RandomAccessList.List (List)
import Pow2.LeafTree (LeafTree)
import Pow2_1.NodeTree (NodeTree)
import Pow2_1.IncreasingList (IncreasingList)
import RandomAccessList.Sequence (Sequence)
import RandomAccessList.Skew (SkewList)
import RandomAccessList.Zeroless (ZerolessList)
import RandomAccessList.Bootstrapping (Bootstrapping)

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
        mapM_ printNumTest (testNatural :: [(String, Peano)])
        putStrLn "Dvojiški zapis"
        mapM_ printNumTest (testNatural :: [(String, Binary)])
        putStrLn "Dvojiški zapis brez ničel"
        mapM_ printNumTest (testNatural :: [(String, ZerolessBinary)])
        putStrLn "Poševni dvojiški zapis"
        mapM_ printNumTest (testNatural :: [(String, SkewBinary)])
        putStrLn "Verižni seznami"
        mapM_ printListTest (testList :: [(String, List Int)])
        putStrLn "Zaporedja"
        mapM_ printListTest (testList :: [(String, Sequence Int)])
        putStrLn "Zaporedja brez ničel"
        mapM_ printListTest (testList :: [(String, ZerolessList LeafTree Int)])
        putStrLn "Poševni seznami"
        mapM_ printListTest (testList :: [(String, SkewList NodeTree Int)])
        putStrLn "Naraščajoči seznami"
        mapM_ printListTest (testList :: [(String, SkewList IncreasingList Int)])
        putStrLn "Naraščajoči seznami"
        mapM_ printListTest (testList :: [(String, Bootstrapping Int)])
