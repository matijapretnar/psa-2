# Zgoščene tabele

Želimo naslednje operacije na množici elementov:

- `insert(x)`: vstavi element $x$,
- `lookup(x)`: preveri, ali je element $x$ prisoten,
- `delete(x)`: odstrani element $x$.

Zaradi enostavnosti predpostavimo, da delamo samo s ključi (brez pridruženih vrednosti) in da so vsi ključi iz univerzuma $U = \{0, 1, \ldots, u - 1\} \subseteq \mathbb{N}$.

Če je velikost univerzuma $u$ primerljiva s številom shranjenih elementov $n$, lahko ključ $x$ shranimo kar na mestu $x$ v tabeli velikosti $u$. Vse tri operacije tedaj tečejo v času $O(1)$.

Običajno pa je $n \ll u$, zato bi bila taka tabela nerazumno velika. Namesto tega iščemo _zgoščevalno funkcijo_ $h \colon U \to {0, 1, \ldots, m - 1}$, ki ključe preslika v tabelo velikosti $m$. Želimo, da je:

1. **hitra**: izračunljiva v času $O(1)$,
2. **lokalno injektivna**: za ustrezno majhne podmnožice $U' \subseteq U$ z $|U'| \leq m$ je zožitev $h|_{U'}$ injektivna.

Ker lokalna injektivnost na splošno ne drži za vse možne podmnožice, moramo upoštevati možnost _trkov_ ($h(x) = h(y)$ za $x \neq y$). Poznamo dva glavna pristopa za reševanje trkov:

## Reševanje trkov z veriženjem

Pri veriženju vzdržujemo tabelo $T$, kjer je za $0 ≤ j < m$ vsak $T[j]$ (zaradi brisanja dvojno) povezan seznam vseh elementov $x$ z $h(x) = j$.

- `insert(x)`: element $x$ vstavimo na začetek seznama $T[h(x)]$; čas $O(1)$.
- `lookup(x)`: preiščemo seznam $T[h(x)]$; čas sorazmeren z dolžino seznama.
- `delete(x)`: element $x$ poiščemo in odstranimo iz $T[h(x)]$.

Za analizo predpostavimo _enostavno enakomerno zgoščevanje_ (angl. _simple uniform hashing_): za vsak ključ $x$ in vsak $k \in [m]$ velja

$$P(h(x) = k) = \frac{1}{m}$$

Označimo s $\alpha = n / m$ _faktor zasedenosti_ (angl. _load factor_), ki pove, koliko elementov v povprečju vsebuje posamezen seznam.

### Neuspešno iskanje

**Izrek.** Pričakovani čas neuspešnega iskanja (ključ ni v tabeli) je $\Theta(1 + \alpha)$.

_Dokaz._ Iskanje ključa $x$ zahteva pregled celotnega seznama $T[h(x)]$. Izračun $h(x)$ vzame čas $O(1)$. Označimo z $n_j = |T[j]|$ dolžino seznama z indeksom $j$. Pod predpostavko enostavnega enakomernega zgoščevanja je pričakovana dolžina seznama enaka

$$E[n_{h(x)}] = \frac{n}{m} = \alpha.$$

Skupni pričakovani čas neuspešnega iskanja je torej

$$1 + E[n_{h(x)}] = 1 + \alpha = \Theta(1 + \alpha).$$

∎

### Uspešno iskanje

**Izrek.** Pričakovani čas uspešnega iskanja (ključ je v tabeli) je $\Theta(1 + \alpha)$.

_Dokaz._ Predpostavimo, da so bili elementi vstavljeni v zaporedju $x_1, x_2, \ldots, x_n$, vsak na začetek ustreznega seznama. Ko iščemo element $x_i$, moramo prečkati vse elemente, ki so bili v isti seznam vstavljeni _po_ $x_i$. Za $i < j$ definiramo indikatorsko slučajno spremenljivko

$$X_{ij} = [h(x_i) = h(x_j)],$$

za katero velja $E[X_{ij}] = 1/m$. Pričakovani čas iskanja naključno izbranega elementa je

$$
E\left[\frac{1}{n} \sum_{i=1}^{n} \left(1 + \sum_{j=i+1}^{n} X_{ij}\right)\right]
= 1 + \frac{1}{n} \sum_{i=1}^{n} \sum_{j=i+1}^{n} \frac{1}{m}
= 1 + \frac{1}{nm} \sum_{i=1}^{n} (n - i)
= 1 + \frac{1}{nm} (\sum_{i=1}^{n} n - \sum_{i=1}^{n} i)
= 1 + \frac{1}{nm} (n^2 - \frac{n(n + 1)}{2})
= 1 + \frac{\alpha}{2} - \frac{\alpha}{2n}
= \Theta(1 + \alpha).
$$

∎

Če je $m = \Theta(n)$, tj. $\alpha = O(1)$, so vse tri operacije v pričakovanem času $O(1)$.

## Reševanje trkov z odprtim naslavljanjem

Pri _odprtem naslavljanju_ (angl. _open addressing_) vsi elementi ležijo neposredno v tabeli. Za vsak ključ $x$ definiramo _zaporedje poizvedovanja_ (angl. _probe sequence_)

$$h(x, 0),\; h(x, 1),\; \ldots,\; h(x, m - 1),$$

ki je permutacija množice $\{0, 1, \ldots, m - 1\}$. Ob vstavljanju element $x$ postavimo na prvo prosto mesto v tem zaporedju, ob iskanju pa pregledujemo mesta, dokler ne najdemo $x$ ali ne naletimo na prazno mesto.

Pri brisanju elementa $x$ označimo mesto $h(x, i)$ kot _izbrisano_ (angl. _deleted_), da ne bi prekinili zaporedja poizvedovanja za druge elemente, ki so se tam morda zatekli zaradi trkov. Ko je označenih mest preveč, tabelo ponovno zgradimo.

### Načini poizvedovanja

Poznamo tri pogoste metode za konstrukcijo zaporedja poizvedovanja:

- **Linearno poizvedovanje**: $h(x, i) = (h'(x) + i) \bmod m$.
  Enostavno, a dovzetno za gručenje, saj se zaporedna zasedena mesta vedno bolj kopičijo.

- **Kvadratno poizvedovanje**: $h(x, i) = (h'(x) + a \cdot i + b \cdot i^2) \bmod m$
  za ustrezni konstanti $a, b$. Zmanjša gručenje, a vseeno imajo ključi z istim $h'(x)$ isto zaporedje poizvedovanja.

- **Dvojno zgoščevanje**: $h(x, i) = (h_1(x) + i \cdot h_2(x)) \bmod m$.
  Najučinkovitejša metoda med navedenimi. Različna ključa z istim $h_1(x)$ imata na splošno različna $h_2(x)$, s čimer se izognemo gručenju. Potrebujemo $\gcd(h_2(x), m) = 1$ za vse $x$, kar zagotovimo npr. z izborom praštevilskega $m$.

### Predpostavka enakomernega zgoščevanja

Za analizo odprtega naslavljanja predpostavimo _enakomerno zgoščevanje_ (angl. _uniform hashing_): za vsako permutacijo $\pi$ množice $\{0, 1, \ldots, m - 1\}$ velja

$$P\big((h(x, 0), h(x, 1), \ldots, h(x, m-1)) = \pi\big) = \frac{1}{m!}.$$

To je močnejša predpostavka od enostavnega enakomernega zgoščevanja in v splošnem ne drži popolnoma za nobeno od zgoraj navedenih metod, a je uporabna za analizo.

### Neuspešno iskanje

**Izrek.** Ob predpostavljenem enakomernem zgoščevanju je pričakovano število poizvedb pri neuspešnem iskanju kvečjemu $\frac{1}{1 - \alpha}$, kjer je $\alpha = n/m < 1$.

_Dokaz._ Naj bo $X$ slučajna spremenljivka, ki šteje število poizvedb. V $i$-ti poizvedbi naletimo na zasedeno mesto z verjetnostjo kvečjemu $\frac{n - i + 1}{m - i + 1} \leq \frac{n}{m} = \alpha$. Zato je

$$
E[X] = \sum_{i=0}^{\infty} P(X > i) \leq \sum_{i=0}^{\infty} \alpha^i = \frac{1}{1 - \alpha}.
$$

∎

### Uspešno iskanje

**Izrek.** Ob predpostavljenem enakomernem zgoščevanju je pričakovano število poizvedb pri uspešnem iskanju kvečjemu $\frac{1}{\alpha} \ln \frac{1}{1 - \alpha}$.

_Dokaz._ Iskanje ključa $x_i$, ki je bil vstavljen kot $i$-ti element, zahteva prav toliko poizvedb, kot bi jih zahtevalo neuspešno iskanje v tabeli, ki je vsebovala prvih $i - 1$ elementov. Takrat je bil faktor zasedenosti enak $\alpha_i = (i - 1)/m$, torej pričakovano število poizvedb za $x_i$ ocenimo z $\frac{1}{1 - \alpha_i} = \frac{m}{m - i + 1}$.

Pričakovano število poizvedb pri iskanju naključno izbranega elementa je

$$
\frac{1}{n} \sum_{i=1}^{n} \frac{m}{m - i + 1}
= \frac{m}{n} \sum_{i=1}^{n} \frac{1}{m - i + 1}
= \frac{1}{\alpha} \sum_{j=m-n+1}^{m} \frac{1}{j}
= \frac{1}{\alpha} (H_m - H_{m - n})
\leq \frac{1}{\alpha} \ln \frac{m}{m - n}
= \frac{1}{\alpha} \ln \frac{1}{1 - \alpha}.
$$

∎