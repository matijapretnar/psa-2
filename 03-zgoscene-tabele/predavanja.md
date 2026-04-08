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

Ker lokalna injektivnost na splošno ne drži za vse možne podmnožice, moramo upoštevati možnost _trkov_ ($h(x_1) = h(x_2)$ za $x_1 \neq x_2$). Poznamo dva glavna pristopa za reševanje trkov:

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

## Družine zgoščevalnih funkcij

Zgornje analize temeljijo na predpostavkah o enakomernem zgoščevanju, ki pa niso lastnost konkretne funkcije $h$, temveč predpostavka o porazdelitvi ključev ali slučajni izbiri funkcije. V praksi fiksna deterministična $h$ nikoli ne zadosti tem predpostavkam za vse možne vhode — obstaja namreč vhod, ki povzroči $\Theta(n)$ trkov.

Rešitev je, da $h$ **izberemo naključno** iz neke vnaprej določene _družine_ zgoščevalnih funkcij $\mathcal{H}$.

**Definicija.** Družina funkcij $\mathcal{H} = \{ h \colon U \to [m] \}$ je _univerzalna_, če za vsaka ključa $x_1 \neq x_2 \in U$ velja

$$
\#\{h \sim \mathcal{H} \mid (h(x_1) = h(x_2) \} \leq \frac{\# \mathcal{H}}{m}.
$$

Enostavno enakomerno zgoščevanje zahteva, da za vsak $x$ velja $P(h(x) = y) = 1/m$ za vsak $y$. Ključni člen pri dokazu časovne zahtevnosti poizvedb v zgoščenih tabelah z veriženju je bila ocena $E[X_{ij}] = P(h(x_i) = h(x_j)) = 1/m$, ki ga pri univerzalnih družinah lahko ocenimo na $E[X_{ij}] \leq 1/m$, s čimer pričakovani ostanejo $\Theta(1 + \alpha)$.

Univerzalne družine včasih posplošimo na $c$-univerzalne, kjer dobimo verjetnost trka $\leq c/m$ za neko konstanto $c \geq 1$. Pri tem se čas poveča na $\Theta(1 + c \alpha)$. Za **enakomerno zgoščevanje** (predpostavka pri odprtem naslavljanju) zahteva _$k$-neodvisnost_/_krepko $k$-univerzalnost_/… (terminologija ni poenotena):

**Definicija.**  Družina funkcij $\mathcal{H} = \{ h \colon U \to [m] \}$ je _$k$-neodvisna_, če za različne $x_1, \ldots, x_k \in U$ ter $y_1, \ldots, y_k \in [m]$ velja

$$
P_{h \sim \mathcal{H}}(h(x_1) = y_1, \ldots, h(x_k) = y_k) = \frac{1}{m^k}.
$$

Praktičnih univerzalnih družin, ki bi zagotavljale pravo enakomerno zgoščevanje, ni, a dvojno zgoščevanje z $c$-univerzalnima $h_1, h_2$ v praksi dobro aproksimira te lastnosti.

**Trditev.** $2$-neodvisna družina je univerzalna.

_Dokaz._ Za $x_1 \neq x_2$ in naključno $h$ iz $2$-neodvisne družine velja

$$P(h(x_1) = h(x_2)) = P(\bigvee_y (h(x_1) = y \land h(x_2) = y)) \le \sum_y P(h(x_1) = y \land P(h(x_2) = y) = \sum_y \frac{1}{m^2} = \frac{1}{m})$$

∎

### Linearno zgoščevanje po praštevilskem modulu

Vzemimo dovolj veliko praštevilo $p \geq u \geq m$. Definiramo

$$\mathcal{H}_{p,m} = \bigl\{ h_{a,b}(x) = ((ax + b) \bmod p) \bmod m \;\bigm|\; a \in [p] \setminus \{0\},\; b \in [p] \bigr\}.$$

**Izrek.** Družina $\mathcal{H}_{p,m}$ je 1-univerzalna.

_Dokaz._ Izberimo morebitni trk $h_{a,b}(x) = h_{a,b}(y)$. Označimo $r = ax + b \bmod p$ in $s = ay + b \bmod p$. Tedaj je $r - s = a(x - y) \bmod p$, torej je $r \neq s$, zato do trka lahko pride le, če $r$ in $s$ padeta v isti razred po modulu $m$. Še več, dobimo bijekcijo med pari $(a, b)$, kjer je $a \ne 0$ in pari $(r, s)$, kjer je $r \ne s$. Zato je za poljuben par $(x, y)$ ob naključni izbiri $a, b$ verjetnost trka enaka verjetnosti, da naključno izbrana $(r, s)$ padeta v isti razred po modulu $m$. Za dani $r$ je takih $s$ manj kot $(p - 1)/m$ in verjetnost trka je kvečjemu $((p - 1)/m) / (p - 1) = 1/m$. ∎

## Popolno zgoščevanje

Veriženje in odprto naslavljanje zagotavljata le pričakovani čas $O(1)$, najslabši primer pa je $\Theta(n)$. Za _statične_ množice pa je mogoče doseči $O(1)$ tudi v najslabšem primeru. Taki shemi pravimo **popolno zgoščevanje** (angl. _perfect hashing_).

Opazimo, da iz univerzalnosti družine $\mathcal{H}$ sledi

$$E\big[\#\text{trkov}\big] = E\left[\sum_{\{x, y\} \subseteq S} [h(x) = h(y)]\right] = \binom{n}{2} \cdot \frac{1}{m} < \frac{n^2}{2m}.$$

Če torej izberemo $m = n^2$, po neenakosti Markova ($P(X \geq k) \leq E[X]/k$) velja, da je pričakovano število trkov manjše od $1/2$, kar vodi do poizvedb v času $O(1)$. Slabost je poraba $O(n^2)$ prostora.

Za doseganje $O(1)$ najslabšega časa in $O(n)$ prostora hkrati uporabimo **dvonivojsko shemo**:

- **Prva raven**: funkcija $h_1$ iz 1-univerzalne družine preslika $n$ ključev v tabelo $T$ z $n$ mesti.

- **Druga raven**: za vsako režo $j$ z $n_j \geq 1$ elementi zgradimo sekundarno tabelo $T_j$ velikosti $n_j^2$ z naključno izbrano funkcijo $h \in \mathcal{H}_{p, m_j}$. Izbiro funkcije $h$ ponavljamo toliko časa, dokler znotraj $T_j$ ni nobenega trka. Po zgornjem vidimo, da je pričakovano število trkov manjše od $1/2$, zato je pričakovano število poizkusov $O(1)$.

**Trditev.** Pričakovana skupna velikost vseh sekundarnih tabel je $O(n)$.

_Dokaz._ V splošnem velja $n^2 = n + 2 \binom{n}{2}$, zato je skupni prostor, ki ga potrebujemo, enak

$$E\big[\sum_{j=0}^{m-1} n_j^2\big] = E\Big[\sum_{j=0}^{m-1} (n_j + 2 \binom{n_j}{2})\Big] = n + 2 E\Big[\sum_{j=0}^{m-1} \binom{n_j}{2}\Big].$$

Toda vsota $\sum_{j=0}^{m-1} \binom{n_j}{2}$ je ravno število trkov $n$ elementov na prvi ravni, ki pa je zaradi univeralnosti manj kot

$$\binom{n}{2} \cdot \frac{1}{m} = \frac{n - 1}{2}$$

Zato je

$$E\big[\sum_{j=0}^{m-1} n_j^2\big] \le n + 2 \frac{n - 1}{2} < 2 n$$

∎

Še več, po neenakosti Markova lahko ocenimo, da je verjetnost, da skupna velikost sekundarnih tabel preseže $4n$, manjša od $1/2$. Zato lahko shemo zgradimo v pričakovanem času $O(n)$, pri čemer bo poraba prostora $O(n)$ in čas poizvedbe $O(1)$ v najslabšem primeru.

## Bloomovi filtri

Bloomov filter je naključnostna podatkovna struktura za učinkovito predstavitev množic, ki v zameno za manjšo porabo prostora dopušla **lažno pozitivne** odgovore, a nikoli **lažno negativnih** (angl. _false negatives_). Natančneje:

- `lookup(x)` vrne DA: $x$ je v množici **z veliko verjetnostjo**, a obstaja majhna možnost napake.
- `lookup(x)` vrne NE: $x$ **zagotovo ni** v množici,

Filtri so uporabni za hitro preverjanje prisotnosti elementov, na primer pri velikih bazah podatkov. Brskalniki na primer vzdržujejo lokalne Bloomove filtre znanih zlonamernih URL-jev: ob vsakem obisku najprej preverijo lokalni filter in le ob pozitivnem odgovoru poizvedejo centralno bazo (kjer se lažno pozitivni odgovori zavrnejo). Podobno CDN-ji z Bloomovimi filtri ugotavljajo, ali je bil neka stran že zahtevana, preden se odločijo za njeno shranjevanje v predpomnilnik.

Bloomov filter sestoji iz:

- bitne tabele $B$ dolžine $m$ z vsemi biti sprva nastavljenimi na $0$,
- $k$ neodvisnih zgoščevalnih funkcij $h_1, \ldots, h_k \colon U \to [m]$.

**Vstavljanje** za vsak $i = 1, \ldots, k$ postavimo $B[h_i(x)]$ na $1$.

**Iskanje** vrne DA natanko takrat, ko $B[h_i(x)] = 1$ za vse $i = 1, \ldots, k$.

Brisanje ni podprto, saj ponastavitev bita $B[h_i(x)]$ morda uniči informacijo o drugem elementu, ki je nastavil isti bit.

Po vstavljanju $n$ elementov je vsak bit v $B$ neodvisno postavljen na $1$ z verjetnostjo

$$
p = 1 - \left(1 - \frac{1}{m}\right)^{kn} \approx 1 - e^{-kn/m}.
$$

Ob iskanju neobstoječega ključa tako dobimo lažno pozitiven odgovor z verjetnostjo $\varepsilon \approx \left(1 - e^{-kn/m}\right)^k = p^k$.

Pri danih $m$ in $n$ želimo izbrati $k$, ki minimizira $\varepsilon$ oz. $\ln \varepsilon = k \ln p$. Odvajajmo po $k$:

$$
(k \ln p)'
= \ln p + k \cdot \frac{p'}{p}
= \ln p + k \cdot \frac{n/m \cdot e^{-kn/m}}{p}
= \ln p + \ln (1 - p) \cdot \frac{(1 - p)}{p} 
$$

kar je enako $0$, ko je $p \ln p = (1 - p) \ln (1 - p)$ oz. ko je $p = 1/2$.
To je tudi smiselno: informacija je največja, ko ob iskanju neobstoječega ključa vsaka funkcija z enako verjetnostjo vrne $0$ ali $1$. Iz tega tudi izračunamo optimalno število zgoščevalnih funkcij $k^* = \lfloor \frac{m}{n} \ln 2 \rfloor$ (zaradi učinkovitosti raje zaokrožimo navzdol).

Pti optimalnem $p = 1/2$ torej velja

$$
\varepsilon \approx \left(\frac{1}{2}\right)^{\frac{m}{n} \ln 2} = e^{-\frac{m}{n} (\ln 2)^2} \approx (0{,}6185)^{m/n}
$$

oziroma

$$m \approx -\frac{n \ln \varepsilon}{(\ln 2)^2} \approx 2{,}08 \, n \ln \frac{1}{\varepsilon} = 1{,}44 \, n \log_2 \frac{1}{\varepsilon}$$

Za vsak element torej potrebujemo približno $1{,}44 \log_2(1/\varepsilon)$ bitov. Teoretična spodnja meja je $\log_2(1/\varepsilon)$ bitov.
