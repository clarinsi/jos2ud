# JOS2UD

Conversion between JOS-style annotations and UD focused on:

1. Training corpus ssj500k 2.1 in TEI format, http://hdl.handle.net/11356/1181

2. Morphological lexicon Sloleks 1.2 in tabular format (PoS tags in English), http://hdl.handle.net/11356/1039

The Makefile specifies how to directly download the source data and covert them to UD.

In short:

1. `tei2ud.xsl`: stylesheet to convert ssj500k treebank with Slovene
  JOS tags and deps, to tabular CONLL-U format but English JOS tags,
  features and deps.

2. `jos2ud.pl`: conversion from CONLL-U with JOS features to UD PoS and features. The program has two modes "corpus" and "lexicon", depending on what we are converting. It also makes use of two rule files, as explained below. 

3. `add-biti-*.pl`: this set of scripts addresses the word-forms of lemma "biti", which is the only case where syntactic structure must be taken into account for determining the UD PoS (either AUX or VERB). 

4. `convert_dependencies.py`: conversion of JOS syntactic dependencies to UD ones.

5. `correct_dependencies.py`: final manual-like correction of dependency conversion errors in specific sentences.

6. `ud-data-split.py`: splits the UD treebank into train (80%), test (10%) and dev (10%) files. 

NB: `jos2ud.pl` takes two mapping files as parameters, one for PoS mapping (`jos2ud-pos.tbl`), and the other for feature mapping (`jos2ud-features.tbl`). The files have tab-separated lines with the following characteristics:

* The first field gives the priority of the mapping, lower number means higher priority. The mappings are thus semi-ordered, and special cases are treated first, then general ones.

* The conditions (like Lemma, Category) can use the * as the wildcard that matches anything; combining * with a string makes sense only for Lemma.

* The PoS mapping checks, for each token, all the mappings in (semi)order, and applies the first one whose conditions match the token annotations. If no mapping matches, this is an error.

* The Feature mapping goes through the semiordered mapping table only once; when a mapping matches then the corresponding JOS features is removed, and a UD features can be output. If all the mappings have been tried, but JOS features still remain, this is an error. Note that this means that JOS features that map to nothing also have to be included in the table.

**Citing**

If you use this tool, please cite the following paper:
```
@inproceedings{dobrovoljc-etal-2017-universal,
    title = "The {U}niversal {D}ependencies Treebank for {S}lovenian",
    author = "Dobrovoljc, Kaja  and
      Erjavec, Toma{\v{z}}  and
      Krek, Simon",
    booktitle = "Proceedings of the 6th Workshop on {B}alto-{S}lavic Natural Language Processing",
    month = apr,
    year = "2017",
    address = "Valencia, Spain",
    publisher = "Association for Computational Linguistics",
    url = "https://www.aclweb.org/anthology/W17-1406",
    doi = "10.18653/v1/W17-1406",
    pages = "33--38",
}
```
