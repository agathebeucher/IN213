# 🎶 IN213

Le but de ce projet est de développer un langage dédié à la représentation de partitions musicales.
Ce langage doit permettre de décrire des notes, des modificateurs de hauteur et de rythme, ainsi que des structures musicales complexes. Il doit également offrir des fonctionnalités pour factoriser des parties de morceaux et pour générer du son à partir de la représentation musicale.

## 🔑 Structure du projet
1. **Analyseurs** (Lexeur et Parseur)
    - Lexeur : *musiclexeur.mll*
    - Parseur : *musicparser.mly*
2. **AST** (Abstract Syntax Tree)
    - AST pour la partition : *musicast.ml*
    - AST pour le son : *sonast.ml*
3. **Tests et Exemples**
    - Exemple de test : *test*
    - Exemples de morceaux : *frere_jacques*
4. **Scripts de Construction**
    - Makefile : *Makefile*
5. **Documentation**
    - Rapport de projet : *IN213.pdf*

## 📝 Synthaxe du langage
Si vous souhaitez écrire votre propre musique, créer un fichier sous la forme suivante : 
```
Title:"VotreTitre"
Composer:"VotreNom"
Tempo:"VotreTempo"
4/4
```
Vous pouvez modifier la signature rythmique (qui est ci-dessus définit comme *4/4*), ou encore rajouter des altérations en ajoutant la ligne optionnelle : 
```
Key_signature:"+1"
```
Le signe "+" indique une altérations "dieze", le signe "-" pour les bémols, suivit du nombre d'altération que l'on souhaite (ici, "+1" signifie un dièze en Fa).
Ensuite, c'est le moment de composer ! Écrivez vos notes séparées par des '|', sous la forme **|A4-1.0|** avec *"A"* le **pitch** (ici La), *"4"* l'**octave** et *"1.0"* la **durée** de la note telle que :  
- 4.0 -> ronde 
- 2.0 -> blanche
- 1.0 -> noire 
- 0.5 -> croche 
- 0.25 -> double croche 

Vous pouvez également rajouter des **altérations accidentelles** optionnelles après l'octave comme **|A4b-1.0|** ou **|A4#-1.0|**. Enfin, les silences sont représentés par "_-1.0" avec dans ce cas, *1.0* la durée du silence.
```
C5#-1.0|D5-1.0|E5-1.0|C5#-2.0|
B4-1.0|F5-1.0|_-2.0|E5-1.0|
```
### Compiler le projet sous LINUX
#### 🎧 Musescore
Pour générer la partition en pdf, on choisit d'utiliser un éditeur de partitions musicales pour Linux qui lit les fichier musicXML. On peut par exemple utiliser musescore : 
```
sudo apt install musescore
```
#### 🎼 Partition
Pour générer une partition en pdf et du son à partir du code de frere_jacques: 
```
$ make
$ ./main frere_jacques
$ ./son frere_jacques
```