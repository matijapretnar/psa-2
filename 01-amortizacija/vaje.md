# Amortizirana časovna zahtevnost

## 1. naloga

Razširite sklad z operacijo $\mathrm{multipop}_k$, ki odstrani zgornjih $k$ elementov in ima časovno zahtevnost $O(k)$. Z agregacijsko in računovodsko metodo dokažite, da je amortizirana časovna zahtevnost vseh operacij (na izbiro imamo $\mathrm{push}, \mathrm{pop}, \mathrm{multipop}_k$) na skladu še vedno $O(1)$.

## 2. naloga

Denimo, da imamo strukturo, kjer izvajamo $n$ zaporednih operacij $a_i$ s ceno:

1. $$T(a_i) = \begin{cases}
    i & \text{$i$ je oblike $2^k$ za nek $k \in \mathbb{N}$} \\
    1 & \text{sicer}
    \end{cases}$$
2. $$T(a_i) = \begin{cases}
    \log i & \text{$i$ je sod} \\
    1 & \text{sicer}
    \end{cases}$$
3. $$T(a_i) = \begin{cases}
    2^{k^2} & \text{$i$ je oblike $2^k$ za nek $k \in \mathbb{N}$} \\
    1 & \text{sicer}
    \end{cases}$$

Kolikšne so amortizirane časovne zahtevnosti (z agregacijsko in z računovodsko metodo) v teh primerih?

## 3. naloga

Kakšna je amortizirana časovna zahtevnost vrste implementirane z dvema skladoma?
Nalogo rešite na dva načina, z agregacijsko in z računovodsko metodo.

## 4. naloga

Razširljiva tabela je podatkovna struktura, ki shranjuje zaporedje elementov, in podpira naslednje operacije.

1. $\mathrm{addToFront}$ doda element na začetek tabele,
2. $\mathrm{addToEnd}$ doda element na konec tabele,
3. $\mathrm{lookup}$ vrne $k$-ti element zaporedja oz. `null`, če je trenutna dolžina zaporedja manjša od $k$.

Opišite preprosto podatkovno strukturo, ki implementira razširljivo tabelo, tako da imata operaciji $\mathrm{addToFront}$ in $\mathrm{addToEnd}$ amortizirano časovno zahtevnost $O(1)$, časovna zahtevnost $\mathrm{lookup}$ pa je $O(1)$ v najslabšem primeru.
