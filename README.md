
<p align="center"><img align="center" width="350" src="https://raw.githubusercontent.com/drkameleon/complete-hsk-vocabulary/main/logo.png"/></p>

---

<p align="center">
  <h3>Complete HSK Vocabulary</h3>
</p>

<!--ts-->

* [Example](#example)
* [Reference](#reference)
    * [Levels](#levels)
    * [Parts of Speech](#parts-of-speech)
* [Sources](#sources)
* [License](#license)
     
 <!--te-->   

---

This project is an attempt to provide complete vocabulary lists for the HSK tests ([Hanyu Shuiping Kaoshi](https://en.wikipedia.org/wiki/Hanyu_Shuiping_Kaoshi) - 汉语水平考试) for the Chinese language, both the previous version (2.0) and the newer one (3.0).

The data is presented in different files. 

The main file - `complete.json` - features ALL words appearing in any level, either of the HSK 2.0 tests or the HSK 3.0 ones - thus, it's the complete list.

Each entry includes different types of information:

#### Example
```json
  { "word"      : "爱好",
    "radical"   : "爫",
    "level"     : [ "new-1", "old-3" ],
    "frequency" : 4902,
    "pos"       : [ "n", "v" ],
    "forms"     : [ { "traditional"    : "愛好",
                      "transcriptions" : { "pinyin"   : "ài hào",
                                           "numeric"  : "ai4 hao4",
                                           "bopomofo" : "ㄞˋ ㄏㄠˋ",
                                           "romatzyh" : "ay haw" },
                      "meanings"       : [ "to like; to be fond of; to take pleasure in; to be keen on",
                                           "interest; hobby" ],
                      "classifiers"    : [ "个" ] } ] },
```

- **word:** (*w*) corresponds to the main word/entry in Simplified Chinese characters (简化字)
- **radical:** (*r*) the main [radical](https://en.wikipedia.org/wiki/Radical_(Chinese_characters)) (部首)
- **level:** (*l*) includes information about the HSK levels in which the word in question appears (in the above example, it's new HSK 1, and the old HSK 3) - see below for reference. 📖
- **frequency:** (*q*) the word's relative "frequency" ranking (the lower this number, the more common the word)
- **pos:** (*p*) the different parts of speech the word corresponds to (if available) - see below for reference. 📖
- **forms:** (*f*) the different "forms" of the word
    - **traditional:** (*t*) corresponds to the main word in Traditional Chinese characters (正體字)
    - **transcriptions:** (*i*) different transliterations/transcriptions
        - **pinyin:** (*y*) the [Hanyu Pinyin](https://en.wikipedia.org/wiki/Pinyin) (汉语拼音) romanization with tone marks
        - **numeric:** (*n*) same as above, only with numeric notation for the tones
        - **bopomofo:** (*b*) transliteration of the word in [Bopomofo/Zhuyin](https://en.wikipedia.org/wiki/Bopomofo) (注音)
        - **romatzyh:** (*g*) transliteration of the word in [Gwoyeu Romatzyh](https://en.wikipedia.org/wiki/Gwoyeu_Romatzyh) (国语罗马字)
    - **meanings:** (*m*) a list of dictionary definitions for the current words (all meanings have been cleaned and sanitized - as much as possible - with the possible classifier annotations extracted and presented as a separate entry)
    - **classifiers:** (*c*) the list of [measure words](https://en.wikipedia.org/wiki/Chinese_classifier) (classifiers) associated with the word form in question (if any)

> ℹ️ The exact same data exists in the minified/compressed `complete.min.json`, only without pretty-printing and with the above abbreviations used instead of the full field names (e.g `w` for `word`, etc).
> 
> ##### Words by level
> 
> The same data has been divided by HSK level (different sets for the new and old ones), so for finding the complete list for the new (HSK 3.0) level 1, you would go to: `by-level/new/1.json` (with the minified version located at `/by-level/new/1.min.json`)

---

### Reference

#### Levels

| Level  | HSK 2.0  | HSK 3.0  |
|---|---|---|
| **1**  | `old-1` (*o1*) | `new-1` (*n1*) |
| **2**  | `old-2` (*o2*) | `new-2` (*n2*) |
| **3**  | `old-3` (*o3*) | `new-3` (*n3*) |
| **4**  | `old-4` (*o4*) | `new-4` (*n4*) |
| **5**  | `old-5` (*o5*) | `new-5` (*n5*) |
| **6**  | `old-6` (*o6*) | `new-6` (*n6*) |
| **7-9**  | X  | `new-7+` (*n7+*) |

#### Parts of Speech

|**Code**| **Meaning** | **Code** | **Meaning** |
|---|---|---|---|
|**a**|         adjective                         |**ns**|         place name |
|**ad**|        adjective as adverbial            |**nt**|          organization name
|**ag**|        adjective morpheme                |**nx**|         nominal character string
|**an**|        adjective with nominal function   |**nz**|         other proper noun
|**b**|          non-predicate adjective          |**o**|           onomatopoeia
|**c**|           conjunction                     |**p**|           preposition
|**d**|           adverb                          |**q**|           classifier
|**dg**|         adverb morpheme                  |**r**|            pronoun
|**e**|           interjection                    |**rg**|          pronoun morpheme
|**f**|            directional locality           |**s**|           space word
|**g**|           morpheme                        |**t**|            time word
|**h**|           prefix                          |**tg**|          time word morpheme
|**i**|            idiom                          |**u**|           auxiliary
|**j**|            abbreviation                   |**v**|           verb
|**k**|           suffix                          |**vd**|         verb as adverbial
|**l**|            fixed expressions              |**vg**|         verb morpheme
|**m**|         numeral                           |**vn**|         verb with nominal function
|**mg**|       numeric morpheme                   |**w**|          symbol and non-sentential punctuation
|**n**|           common noun                     |**x**|           unclassified items
|**ng**|         noun morpheme                    |**y**|           modal particle |
|**nr**|          personal name                   |**z**|           descriptive

---

### Sources

- Old HSK wordlists: https://github.com/clem109/hsk-vocabulary
- New HSK wordlists: https://github.com/elkmovie/hsk30
- Dictionary definitions: https://www.mdbg.net/chinese/dictionary (CC-CEDICT)
- Radicals: https://github.com/skishore/makemeahanzi (dictionary.txt)
- Frequency data: https://github.com/krmanik/HSK-3.0-words-list
- Parts of speech analysis:
    - http://crr.ugent.be/programs-data/subtitle-frequencies/subtlex-ch (SUBTLEX-CH)
    - https://github.com/hankcs/HanLP (HanLP)

---

### License

MIT License

Copyright (c) 2023 Yanis Zafirópulos (aka Dr.Kameleon)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
