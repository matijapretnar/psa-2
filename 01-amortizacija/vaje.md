# Amortizirana časovna zahtevnost

Po definiciji amortizirane časovne zahtevnosti in z računovodsko metodo rešite spodnje naloge.

## 1. naloga

Razširite sklad z operacijo $\mathrm{multipop}_k$, ki odstrani zgornjih $k$ elementov in ima časovno zahtevnost $O(k)$. Dokažite, da je amortizirana časovna zahtevnost vseh operacij (na izbiro imamo $\mathrm{push}, \mathrm{pop}, \mathrm{multipop}_k$) na skladu še vedno $O(1)$.

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

Kolikšne so amortizirane časovne zahtevnosti v teh primerih?

## 3. naloga

Kakšna je amortizirana časovna zahtevnost vrste implementirane z dvema skladoma?
