module Natural.Peano
  ( Peano,
  )
where

import Natural

data Peano = Zero | Succ Peano

instance Show Peano where
  show Zero = "0"
  show (Succ n) = "1+" ++ show n

instance Natural Peano where
  zero = Zero
  incr = Succ
  decr Zero = Nothing
  decr (Succ n) = Just n
