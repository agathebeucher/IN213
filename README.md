# 🎶 IN213

Le but de ce projet est de développer un langage dédié à la représentation de partitions musicales.
Ce langage doit permettre de décrire des notes, des modificateurs de hauteur et de rythme, ainsi que des structures musicales complexes. Il doit également offrir des fonctionnalités pour factoriser des parties de morceaux et pour générer du son à partir de la représentation musicale.

## 🔑 Elements clés du projet
- **analyseur synthaxique** : *musiclexeur.mll*
- **analyseur synthaxique** : *musicparser.mly*
- **traducteur en partition** : *musicast.ml*
- **traducteur en son** : *sonast.ml*
- **fichier test** : *test*, *frere_jacques*
- **makefile**
- **Rapport de projet** : *IN213.pdf*

## 📝 Synthaxe du langage
Si vous souhaitez écrire votre propre musique, créer un fichier sous la forme suivante : 
```
Title:"VotreTitre"
Composer:"VotreNom"
Tempo:"VotreTempo"
4/4
```
Vous pouvez modifier la signature rythmique, et rajouter des altérations en ajoutant la ligne optionnelle : 
```
Key_signature:"+1"
```
Ensuite, écrivez vos notes sous la forme **|A4-1.0|** avec *"A"* le pitch (ici La), *"4"* l'octave et *"1.0"* la durée de la note telle que :  
- 4.0 -> ronde 
- 2.0 -> blanche
- 1.0 -> noire 
- 0.5 -> croche 
- 0.25 -> double croche \\
Vous pouvez également rajouter des altérations accidentelles optionnel après l'octave comme **|A4b-1.0|** ou **|A4#-1.0|**. Enfin, les silences sont représentés par "_-1.0" avec *1.0* la durée du silence.
```
C5#-1.0|D5-1.0|E5-1.0|C5#-2.0|
B4-1.0|F5-1.0|_-2.0|E5-1.0|
```
### Compiler le projet sous Linux
#### 🎧 Musescore
Pour générer la partition en pdf, il faut utiliser un éditeur de partitions musicales pour Linux qui lit les fichier musicXML. On peut utiliser musescore
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