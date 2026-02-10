# Amortizirana časovna zahtevnost

## 1. domača naloga

Cilj naloge je preizkusiti dve različni strategiji povečevanje kapacitete poldinamične tabele, ki podpira operacijo dodajanja elementov:

- ko zmanjka prostora, tabelo podaljšamo za faktor $\alpha$;
- ko zmanjka prostora, tabelo podaljšamo za $k$ mest.

1. V enem od jezikov: _Mathematica_, Python, OCaml ali Rust implementirajte tabelo ter obe strategiji povečevanja.
2. Obe strategiji preizkusite pri različnih parametrih. Prvo pri $\alpha = 1.2, 1.5, 2, 4$, drugo pa pri $k = 100, 1\,000, 10\,000$. Pri vsakem poskusu v prazno tabelo zaporedoma dodajajte $n = 100\,000, 200\,000, \dots, 10\,000\,000$ elementov. Izmerjene čase predstavite z grafom.
3. Za obe strategiji izračunajte amortizirano časovno zahtevnost posamezne operacije.

