# JOS2UD

Conversion between TEI/JOS style treebank and UD treebank.

The Makefile gives details how access the original ssj500k treebank and covert it to UD.

In short:

1 `tei2ud.xsl`: stylesheet to convert ssj500k treebank with Slovene
  JOS tags and deps, to tabular UD format but English JOS tags,
  features and deps; retains only sentences with synt. annotations. 

2`jos2ud.pl`: conversion from tabular file with JOS features to UD PoS and features

3 `convert_dependencies.py`: conversion of JOS syntactic dependencies to UD ones. Also splits the output into train, test and dev files.


`jos2ud.pl` takes two mapping files as parameters, one for PoS mapping (`jos2ud-pos.tbl`), and the other for feature mapping (`jos2ud-features.tbl`). The files have tab-separated lines with the following characteristics:

* The first field gives the priority of the mapping, lower number means higher priority. The mappings are thus semi-ordered, and special cases are treated first, then general ones.

* The conditions (like Lemma, Category) can use the * as the wildcard that matches anything; combining * with a string makes sense only for Lemma.

* The PoS mapping checks, for each token, all the mappings in (semi)order, and applies the first one whose conditions match the token annotations. If no mapping matches, this is an error.

* The Feature mapping goes through the semiordered mapping table only once; when a mapping matches then the corresponding JOS features is removed, and a UD features can be output. If all the mappings have been tried, but JOS features still remain, this is an error. Note that this means that JOS features that map to nothing also have to be included in the table.
