module RandomAccessList.Bootstrapping
  ( Bootstrapping,
  )
where

import RandomAccessList

data Bootstrapping a = Nil | Zero (Bootstrapping (a, a)) | One a (Bootstrapping (a, a))

uncons :: Bootstrapping a -> (a, Bootstrapping a)
uncons (Zero ps) = (x, One y ps') where ((x, y), ps') = uncons ps
uncons (One x Nil) = (x, Nil)
uncons (One x ps) = (x, Zero ps)

instance RandomAccessList Bootstrapping where
  nil = Nil
  head ps = x where (x, _) = uncons ps
  cons x Nil = One x Nil
  cons x (Zero ps) = One x ps
  cons x (One y ps) = Zero (cons (x, y) ps)
  tail ps = ps' where (_, ps') = uncons ps
  append Nil qs = qs
  append ps qs = cons x (append ps' qs) where (x, ps') = uncons ps
  lookup i ps = look i ps
    where
      look :: Int -> Bootstrapping a -> a
      look 0 (One x _) = x
      look i (One _ ps) = look (i - 1) (Zero ps)
      look i (Zero ps) =
          let (j, o) = i `divMod` 2
              (x, y) = look j ps in
          if o == 0 then x else y
  update i y ps =
    -- upd i y ps
    upd' i (\_ -> y) ps
    where
      upd :: Int -> a -> Bootstrapping a -> Bootstrapping a
      upd 0 y (One _ ps) = One y ps
      upd i y (One x ps) = cons x (upd (i - 1) y (Zero ps))
      upd i y (Zero ps) =
          let (j, o) = i `divMod` 2
              (x1, x2) = RandomAccessList.lookup j ps in
          Zero (if o == 0 then upd j (y, x2) ps else upd j (x1, y) ps)
      ---
      upd' :: Int -> (a -> a) -> Bootstrapping a -> Bootstrapping a
      upd' 0 f (One x ps) = One (f x) ps
      upd' i f (One x ps) = cons x (upd' (i - 1) f (Zero ps))
      upd' i f (Zero ps) =
          let (j, o) = i `divMod` 2
              f' (x1, x2) = if o == 0 then (f x1, x2) else (x1, f x2) in
          Zero (upd' j f' ps)

  size Nil = 0
  size (Zero ps) = 2 * size ps
  size (One _ ps) = 1 + 2 * size ps
