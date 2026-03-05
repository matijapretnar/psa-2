# Amortizirana časovna zahtevnost

## 1. domača naloga

Cilj naloge je preizkusiti dve različni strategiji povečevanja kapacitete poldinamične tabele, ki podpira operacijo dodajanja elementov:

- ko zmanjka prostora, tabelo podaljšamo za faktor $\alpha$;
- ko zmanjka prostora, tabelo podaljšamo za $k$ mest.

1. V enem od jezikov: _Mathematica_, Python, OCaml ali Rust implementirajte tabelo ter obe strategiji povečevanja.
2. Obe strategiji preizkusite pri različnih parametrih. Prvo pri $\alpha = 1.2, 1.5, 2, 4$, drugo pa pri $k = 100, 1\,000, 10\,000$. Pri obeh v vsakem poskusu v prazno tabelo zaporedoma dodajajte $n = 100\,000, 200\,000, \dots, 10\,000\,000$ elementov. Ko je pri danem $n$ najboljši čas ene strategije desetkrat počasnejši od najslabšega časa druge strategije, poskusov pri tej strategiji ni več treba izvajati. Izmerjene čase predstavite z grafom.
3. Za obe strategiji izračunajte amortizirano časovno zahtevnost posamezne operacije.
4. **Če za več kot 3 dni zamudite rok za oddajo naloge:** Imejmo tabelo, iz katere lahko s konca odstranjujemo elemente, pri čemer podatke premaknemo v $\alpha$-krat manjšo tabelo, ko delež zasedene kapacitete pade pod dano mejo. Implementirajte take vrste tabelo in utemeljite (s poskusi ali teoretično), na kakšno vrednost mora biti nastavljena ta meja v odvisnosti od $\alpha$, da dosežete amortizirano časovno zahtevnost $O(1)$.

Rezultate naloge predstavite v pregledni obliki (npr. Jupyter notebook, program & PDF, …) ter oddajte prek spletne učilnice.
