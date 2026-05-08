import Data.Ratio (Rational)

type PowerSeries = [Rational]

-- type Ime = String
-- type Priimek = String
-- oz. v OCamlu
-- type ime = string
-- type priimek = string
-- težava je, da sta tipa zamenljiva

-- data Ime = Ime String
-- data Priimek = Priimek String
-- oz. v OCamlu
-- type ime = Ime of string
-- type priimek = Priimek of string
-- težava 1: vedno je treba pisati še konstruktor
-- resnična težava: več prostora in morda celo indirektni kazalec

newtype Ime = Ime String
newtype Priimek = Priimek String

instance Num PowerSeries where
    fs + gs = zipWith (+) fs gs

    -- F G
    -- = (f₀ + x F₁) (g₀ + x G₁)
    -- = f₀ g₀ + x (F₁ (g₀ + x G₁) + f₀ G₁)
    -- = f₀ g₀ + x (F₁ G + f₀ G₁)
    (f0:fs1) * gs@(g0:gs1) = f0 * g0 : (map (* f0) gs1 + fs1 * gs)

    negate = map negate
    abs    = map abs
    signum = map signum

    fromInteger n = fromInteger n : repeat 0

instance Fractional PowerSeries where
    --   F = G Q
    --   f₀ + x F₁ = (g₀ + x G₁) (q₀ + x Q₁)
    --   ⟹
    --   f₀ = q₀ g₀  ∧  F₁ = g₀ Q₁ + G₁ (q₀ + x Q₁)
    --   ⟹
    --   f₀ = q₀ g₀  ∧  F₁ = g₀ Q₁ + G₁ Q
    --   ⟹ 
    --   q₀ = f₀/g₀  ∧  Q₁ = (F₁ - G₁ Q) / g₀
    (f0:fs1) / (g0:gs1) = q0 : qs1
      where
        q0  = f0 / g0
        qs1 = map (/ g0) (fs1 - gs1 * (q0 : qs1))
    fromRational r = fromRational r : repeat 0

--   F(G) = (f₀ + x F₁)(G) = f₀ + G · F₁(G)  (če g₀ = 0)
compose :: PowerSeries -> PowerSeries -> PowerSeries
compose (f0:fs1) gs@(0:_) = fromRational f0 + gs * compose fs1 gs



--   D(f₀ + f₁ x + f₂ x² + ...) = f₁ + 2 f₂ x + 3 f₃ x² + ...
odvod :: PowerSeries -> PowerSeries
odvod (_:fs1) = zipWith (*) (map fromIntegral [1..]) fs1

--   ∫(f₀ + f₁ x + f₂ x² + ...) = f₀ x + ½ f₁ x² + ⅓ f₂ x³ + ...
integral :: PowerSeries -> PowerSeries
integral fs = 0 : zipWith (/) fs (map fromIntegral [1..])

--   F(R) = x
--   ⟹
--   F'(R) · R' = 1
--   ⟹
--   R' = 1 / (F' ∘ R)
--   ⟹
--   R = ∫ 1 / (F' ∘ R)
inverse :: PowerSeries -> PowerSeries
inverse fs = rs
  where rs = integral (1 / compose (odvod fs) rs)

x :: PowerSeries
x = 0 : 1 : repeat 0

--   E' = E,  E(0) = 1  ⟹  E = 1 + ∫E
eksponentna :: PowerSeries
-- eksponentna = odvod eksponentna
eksponentna = 1 + integral eksponentna

--   S' = C,  S(0) = 0  ⟹  S = ∫C
sinus :: PowerSeries
sinus = integral kosinus

--   C' = -S,  C(0) = 1  ⟹  C = 1 - ∫S
kosinus :: PowerSeries
kosinus = 1 - integral sinus

--   tan = sin / cos
tangens :: PowerSeries
tangens = sinus / kosinus

--   1/(1-x) = 1 + x + x² + x³ + ...
geometrijska :: PowerSeries
geometrijska = 1 / (1 - x)

--   log(1+x) = ∫ 1/(1+x)
logaritem :: PowerSeries
logaritem = integral (1 / (1 + x))

--   arctan x = ∫ 1/(1+x²)
arctan :: PowerSeries
arctan = integral (1 / (1 + x * x))
