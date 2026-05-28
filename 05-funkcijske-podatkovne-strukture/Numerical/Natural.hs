module Natural
  ( Natural (..),
    fromInt,
    powerOfTwo,
  )
where

class Natural n where
  zero :: n
  incr :: n -> n
  decr :: n -> n
  add :: n -> n -> n

fromInt :: (Natural n) => Integer -> n
fromInt 0 = zero
fromInt n = incr (fromInt (n - 1))

powerOfTwo :: Int -> String
powerOfTwo 0 = "⁰"
powerOfTwo n =
  map ("⁰¹²³⁴⁵⁶⁷⁸⁹" !!) (digits n)
  where
    digits 0 = []
    digits k = digits (k `div` 10) ++ [k `mod` 10]
