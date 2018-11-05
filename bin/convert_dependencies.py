#!/usr/bin/python3
import sys
import os
import re
import collections

# JOS: Linguistic Annotation in Slovene Scheme (original)
# UD:  Universal Dependencies Scheme (new)

treebank_path = sys.argv[1] #input treebank in conllu (with UD POS tags and features already given and with JOS dependencies as part of MISC column)
treebank_file = os.path.basename(treebank_path)
treebank_name = os.path.splitext(treebank_file)[0]

version_name = sys.argv[2]

output = open("output_{}_{}.conllu".format(treebank_name, version_name), "w", encoding="utf8") #the ssj250k-ud.conllu treebank (i.e. all sentences from ssj250k with automatic conversions, including the non-UD "working" labels)
report = open("report_{}_{}.txt".format(treebank_name, version_name), "w", encoding="utf8") #counts on types of sentences
morpho_changes = open("morpho_changes_report_{}_{}.txt".format(treebank_name, version_name), "w", encoding="utf8")
release = open("release-all_{}_{}.conllu".format(treebank_name, version_name), "w", encoding="utf8", newline='') #the released sl-ud.conllu treebank (i.e. sentences with only one reliable root left, see group p1 and e1 below)

# counts for report
p1_group = [0,0] #only root left
p2_group = [0,0]  #root + punctuation
p3_group = [0,0]  #root + punctuation + known label
e1_group = [0,0]  #only one ellipsis left
e2_group = [0,0]  #one ellipsis + punct
e3_group = [0,0]  # other ellipsis: one + known, many ..
u1_group = [0,0]  #unknown with only verb and punct or other attachment
u2_group = [0,0]  #other unknown
u3_group = [0,0]
overall = [0,0]

# dictionary of sentences
sentences = collections.defaultdict(list)
released_sentences = []

############### token info ######################

#### UD token info ####

def id(token):
    ID = token[0]
    return ID

def form(token):
    FORM = token[1]
    return FORM

def lemma(token):
    LEMMA = token[2]
    return LEMMA

def cpostag(token):
    CPOSTAG = token[3]
    return CPOSTAG

def postag(token): #JOS msd
    POSTAG = token[4]
    return POSTAG

def feats(token):
    FEATS = token[5]
    return FEATS

def head(token):
    HEAD = token[6]
    return HEAD

def deprel(token):
    DEPREL = token[7]
    return DEPREL

def deps(token):
    DEPS = token[8]
    return DEPS

def misc(token):
    MISC = token[9]
    return MISC

#### JOS token info ####

def jos_msd(token):
    return postag(token)

def jos_head(token):
    JOS_head = re.search("Dep=(.*?)\|", misc(token)).group(1) # JOS head
    return JOS_head

def jos_deprel(token):
    JOS_deprel = re.search("Rel=(.*?)\n", misc(token)).group(1) # JOS dependency relation
    return JOS_deprel

### head info ###

def jos_head_lemma(token):
    JOS_head_lemma = sentence[int(jos_head(token))-1][2]
    return JOS_head_lemma

def jos_head_msd(token):
    JOS_head_msd = sentence[int(jos_head(token))-1][4]
    return JOS_head_msd

def jos_head_cpostag(token):
    JOS_head_cpostag = sentence[int(jos_head(token))-1][3]
    return JOS_head_cpostag

def jos_head_head(token):
    JOS_head_head = sentence[int(jos_head(token))-1][6]
    return JOS_head_head

def jos_head_deprel(token):
    JOS_head_deprel = sentence[int(jos_head(token))-1][7]
    return JOS_head_deprel

def jos_head_jos_head(token):
    JOS_head_JOS_head = re.search("Dep=(.*?)\|", sentence[int(jos_head(token))-1][9]).group(1) # JOS head of JOS head
    return JOS_head_JOS_head

def jos_head_jos_deprel(token):
    JOS_head_JOS_deprel = re.search("Rel=(.*?)\n", sentence[int(jos_head(token))-1][9]).group(1)
    return JOS_head_JOS_deprel


#### UD features ####
def features(token):
    if not "_" in feats(token):
        features = dict(item.split("=") for item in feats(token).split("|"))
    else:
        features = {}
    
    return features

#### looking left and right ####
def preceding(token):
    if not id(token) == "1":
        preceding = sentence[int(id(token))-2]
    else:
        preceding = []
    return preceding

def following(token):
    if not int(id(token)) == no_of_tokens:
        following = sentence[int(id(token))]
    else:
        following = []
    return following

######################## process file ##################################################################################
with open(treebank_path, "r", encoding="utf8") as file:

    sentence_open = False #doing the longer, but memory friendly, sentence by sentence processing in order to be able to convert bigger files in the long term

    for line in file:

        if line.startswith("# sent_id"):
            line = line.replace("="," = ")
            sentence_comment_line = line

        elif line.startswith("# text"):
            line = line.replace("="," = ")
            text_comment_line = line

        if sentence_open:
            token = []
            if line[0].isdigit(): #ignore metadata lines starting with a hashtag
                token = line.split("\t")
                sentence.append(token)

            elif line.startswith("#"):
                output.write(line)

            elif line.strip() == '': #we have reached the end of the sentence, so it is time for conversions
                no_of_tokens = len(sentence)


                for token in sentence:

########################## 0.1 CORRECTING MORPHOLOGY MISTAKES ############################################################

                    if cpostag(token) in ["DET"]:
                        if jos_head_cpostag(token) in ["NOUN"]:
                            if int(id(token)) > int(jos_head(token)):
                                morpho_changes.write("Potential non-DET in sentence:{}, token:{}\n".format(sentence_id, id(token)))


# maybe also add determiners (see report)
# maybe also add abbreviations
# maybe also add splitting of fused tokens

########################## 1 RELIABLE RULE-BASED CONVERSIONS ###########################################################

                    #### acl: clausal modifier of noun (adjectival clause) ##################################################

                    if cpostag(token) in ["VERB"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_msd(token)[0] in ["N", "P", "M", "X", "Y"]:
                                token[6] = jos_head(token)
                                token[7] = "acl"
                                # prototypical, e.g. "otrok, ki me je pričakal"

                    if cpostag(token) in ["VERB"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["ADJ"]:
                                for t in sentence:
                                    if jos_head(t) == id(token) and jos_deprel(t) in ["Conj"]:
                                        if not lemma(t) in ["kot", "kakor", "da"]:
                                            token[6] = jos_head(token)
                                            token[7] = "acl"
                                            # to get only nominalized ADJ heads ("mladi, ki ..", exclude "drugačna, kot
                                            # sem je bil vajen" and "dovolj hrapava, da očisti vse"

                    if cpostag(token) in ["VERB"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_msd(token)[0] in ["R"]:
                                token[6] = jos_head(token)
                                token[7] = "acl"
                                # prototypical, e.g. "otrok, ki me je pričakal"

                    if jos_msd(token)[0] in ["A", "P"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                if not jos_head_lemma(token) in ["biti", "ostati", "postati", "izpasti", "ostajati", "postajati",
                                                      "ratovati", "zdeti", "počutiti"]:     # maybe add verbs+za "za" later, if needed (see lists in xcomp)

                                    for t in sentence:
                                        if jos_head(t) == jos_head(token):
                                            if jos_deprel(t) in ["Sb", "Obj"]:
                                                if features(t):#če ima osebek ali predmet katero izmed teh lastnosti, potem se morata v tem ujemati, sicer pa to ni pogoj (e.g. ohrani nas jezusu zveste)
                                                    if "Case" in features(t): #če ima osebek ali predmet katero izmed teh lastnosti, potem se morata v tem ujemati, sicer pa to ni pogoj (e.g. ohrani nas jezusu zveste)
                                                        if "Number" in features(t):
                                                            if "Gender" in features(t):
                                                                if features(token)["Case"] == features(t)["Case"] and features(token)["Number"] == features(t)["Number"]:
                                                                    token[6] = id(t)
                                                                    token[7] = "acl"
                                                            else:
                                                                if features(token)["Case"] == features(t)["Case"] and features(token)["Number"] == features(t)["Number"]:
                                                                    token[6] = id(t)
                                                                    token[7] = "acl"
                                                        else:
                                                            if features(token)["Case"] == features(t)["Case"]:
                                                                token[6] = id(t)
                                                                token[7] = "acl"
                                                    else:
                                                        token[6] = id(t)
                                                        token[7] = "acl"

                                                        # optional depictives with overt nominal heads, e.g. jabolka so stala zloščena, palico držimo iztegnjeno




                    ### advcl: adverbial clause modifier ######################################################3

                    if cpostag(token) in ["VERB"]:
                        if jos_deprel(token) in ["AdvM", "AdvO"]:
                            if jos_head_msd(token)[0] in ["V", "A", "R", "M"]:
                                token[6] = jos_head(token)
                                token[7] = "advcl"
                                # prototypical, e.g. "ko sem prišel domov, sem se usedel"


                    if cpostag(token) in ["VERB"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["ADJ"]:
                                if not deprel(token) in ["acl"]:
                                    token[6] = jos_head(token)
                                    token[7] = "advcl"
                                    # to get constructions "drugačna.ADJ, kot sem je bil vajen" and "dovolj hrapava, da očisti vse" and exclude nominalized adjectives as heads (see acl)

                    if cpostag(token) in ["VERB"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_msd(token)[0] in ["R"]:
                                for t in sentence:
                                    if jos_head(t) == id(token) and jos_deprel(t) in ["Conj"]:
                                        if lemma(t) in ["kot, da, kakor"]:
                                            token[6] = jos_head(token)
                                            token[7] = "advcl"
                                            # comparative constructions, e.g. "toliko, da", "manj, kot", "podobno kot"

                                if not deprel(token) in ["advcl"]: #if this adverb-verb pair has not been covered with the above rule
                                    if jos_head_jos_head(token) not in ["0"]:
                                        token[6] = jos_head_jos_head(token) #the head of the subordinate clause now becomes the main predicate instead of the adverb
                                        # but only in cases where there actually is a predicate verbs, see: , in to celo tedaj, ko samo sebe prezira
                                        token[7] = "advcl"
                                        # e.g. "ponoči, ko je spala", "pozneje, ko je taaval", "nekoč, ko"
                                        #CHANGED the last one to right -attention"


                    if jos_msd(token)[0] in ["A", "P", "M"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                if not jos_head_lemma(token) in ["biti", "ostati", "postati", "izpasti", "ostajati", "postajati",
                                                      "ratovati", "zdeti", "počutiti"]:     # maybe add verbs with "za" later, if needed (see lists in xcomp)
                                    if not deprel(token) in ["acl"]:
                                        token[6] = jos_head(token)
                                        token[7] = "advcl"
                                        #to get constructions like "vozil je vinjen", exclude cases with over nominal head (see acl)

                    # two special cases with optional depictives with biti
                    if cpostag(token) in ["ADJ"] and lemma(token) in ["užiten", "blaten"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                if jos_head_lemma(token) in ["biti"]:
                                    for t in sentence:
                                        if jos_head(t) == jos_head(token) and jos_deprel(t) in ["Atr"] and int(id(token)) < int(id(t)):
                                            if cpostag(t) in ["ADJ"]:
                                                sentence[int(id(t))-1][6] = jos_head(t)
                                                sentence[int(id(t))-1][7] = "advcl"
                                                #užiten je pečen ali kuhan
                                            if cpostag(t) in ["NOUN"]:
                                                token[6] = jos_head(token)
                                                token[7] = "advcl"
                                                #ves blaten sem bil najsrečnejši človek



                    ### advmod: adverbial modifier #############################################

                    if jos_msd(token)[0] in ["R", "Q"]:
                        if jos_deprel(token) in ["Atr", "AdvM", "AdvO"]:
                            token[6] = jos_head(token)
                            token[7] = "advmod"
                            # prototypical, e.g. hitro sem zaspal

                    if cpostag(token) in ["NUM"]:
                        if jos_deprel(token) in ["AdvM", "AdvO"]:
                            token[6] = jos_head(token)
                            token[7] = "advmod"
                            # prototypical, e.g. hitro sem zaspal

                    if lemma(token) in ["naj", "lahko", "ne"]:
                        if jos_deprel(token) in ["PPart"]:
                            token[6] = jos_head(token)
                            token[7] = "advmod"
                            # constructions with "lahko.ADV, naj.PART"


                            if lemma(token) in ["ne"]:
                                old_feats = token[5]
                                token[5] = "Polarity=Neg"
                                morpho_changes.write("Change of features for sentence {}, token {}, from {} to {}\n". format(sentence_id, id(token), old_feats, token[5]))


                    if jos_msd(token)[0] in ["R"]:
                        if jos_deprel(token) in ["Conj"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                if lemma(token) in ["kako", "zakaj", "koliko", "kam", "kje", "kamorkoli", "kadarkoli", "čemu"
                                             , "kjerkoli", "kolikokrat"]:
                                    token[6] = jos_head(token)
                                    token[7] = "advmod"
                                    # JOS-adverb-conjunctions as adverbial modifiers (filling a valency slot)

                    if cpostag(token) in ["SCONJ"] and lemma(token) in ["kadar", "kolikor"]:
                        if jos_deprel(token) in ["Atr"]:
                            token[6] = jos_head(token)
                            token[7] = "advmod"
                            # skup kadar+koli, attribute kolikor in kolkr kaplc

                    if lemma(token) in ["ne"] and jos_deprel(token) in ["PPart"] and not jos_head_cpostag(token) in ["VERB"]:
                        token[6] = jos_head(token)
                        token[7] = "advmod"

                        # politični, ne jezikovni dejavniki; in UDv2, neg is cancelled, so we distinguish between ne-PPart as
                        # TAMVE particle modifying a verb (see the rule udner aux) and ne-PPart as a negation modifier of NPs (this case)

                        old_feats = token[5]
                        token[5] = "Polarity=Neg"
                        morpho_changes.write("Change of features for sentence {}, token {}, from {} to {}\n". format(sentence_id, id(token), old_feats, token[5]))



                    # plus special rules for particles (see 2)


                    ### amod: adjectival modifier ######################################################3
                    if cpostag(token) in ["ADJ"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_msd(token)[0] in ["N", "P", "M", "Q", "X", "I", "Y"]:
                                token[6] = jos_head(token)
                                token[7] = "amod"

                    if cpostag(token) in ["ADJ"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["ADJ"]:
                                # if jos_head_lemma(token) in ["kulturen", "modri", "zaporen", "zaposlen", "dober", "osumljen", "zapisan", "lesen"]:
                                token[6] = jos_head(token)
                                token[7] = "amod"
                                    # this is to account for particular instances of nominalized adjectives as heads
                                # UPDATE: we currently tread all P-dol-P connections as amod


                    ### appos: appositional modifier ######################################################
                    # see below

                    ### aux: auxiliary ######################################################
                    if cpostag(token) in ["AUX", "X"]:
                        if jos_deprel(token) in ["PPart"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                token[6] = jos_head(token)
                                token[7] = "aux"
                                #In UD v2, TAMVE particles (ne,naj,lahko) could also become aux/AUX, but ET&SK were against it

                    ### auxpass: passive auxiliary ######################################################
                    # not used #

                    ### case: case marking ######################################################
                    if cpostag(token) in ["ADP"]:
                        if jos_deprel(token) in ["Atr"]:
                            token[6] = jos_head(token)
                            token[7] = "case"

                    if cpostag(token) in ["ADP"]:
                        if jos_deprel(token) in ["Conj"]:
                            if jos_head_jos_deprel(token) in ["Coord"]:
                                token[6] = jos_head(token)
                                token[7] = "case"

                    if cpostag(token) in ["SCONJ"]:
                        if lemma(token) in ["kot", "kakor", "ko"]:
                            if jos_deprel(token) in ["Conj"]:
                                token[6] = jos_head(token)
                                token[7] = "case"

                    # kot and kakor are always annotated as SCONJ, but in constructions like "the conference was organized as(=kot) a panel discussion
                    # kot is annotated as a case-marker (e.g. like ADP) instead of mark or cc (JOS)+

                    ### cc: coordinating conjunction ######################################################
                    if cpostag(token) in ["CCONJ", "PART", "X", "SCONJ"]:
                        if jos_deprel(token) in ["Conj"]:
                            if jos_head_jos_deprel(token) in ["Coord"]:
                                token[6] = jos_head(token) # In UDv2, the immediately succeeding conjucnt remains the head for cc
                                token[7] = "cc"

                            elif cpostag(token) in ["CCONJ"]:
                                token[6] = jos_head(token) #verbs etc., but their head is determined later on
                                token[7] = "cc"


                    ### cc:preconj: preconjunct ######################################################
                    if cpostag(token) in ["CCONJ", "PART"]:
                        if jos_deprel(token) in ["Conj"]:
                            if jos_head_jos_deprel(token) not in ["Coord"]:
                                if lemma(token)in ["niti", "ne"]:
                                    token[6] = jos_head(token)
                                    token[7] = "cc:preconj"
                                elif lemma(token) in ["tako"] and not lemma(following(token)) in ["da", "kot"]:
                                    token[6] = jos_head(token)
                                    token[7] = "cc:preconj"


                    ### ccomp: clausal complement ######################################################
                    if cpostag(token) in ["VERB"]:
                        if jos_deprel(token) in ["Obj"]:
                            if jos_head_msd(token)[0] in ["V", "A", "R"]:
                                token[6] = jos_head(token)
                                token[7] = "ccomp"

                    ### ex-compounds (v1) changed to flat (dva tisoč) or nummod (dve milijardi) ######################################################
                    if cpostag(token) in ["NUM"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["NUM"]:
                                token[6] = jos_head(token) # rules for head attachment are determined in the end
                                token[7] = "flatx"
                                # dva tisoč, 36 000, tisoč tristo, 6. 11. 2011

                            elif jos_head_lemma(token) in ["milijon", "milijarda", "bilijon"]:
                                token[6] = jos_head(token)
                                token[7] = "nummod"
                                # dve milijardi
                                # changed in UDv2, no special semantic treatment for numerals, the noun is the head


                    ### conj: conjunct ######################################################
                    if jos_deprel(token) in ["Coord"]:
                        token[6] = jos_head(token)
                        token[7] = "conj"

                    ### cop: copula ######################################################
                    ### cop-x: first only change label, not direction #####################################
                    if jos_msd(token)[0] in ["N", "A", "P", "M", "X", "Y"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_lemma(token) in ["biti"]:
                                if not deprel(token) in "advcl": #see two special cases for depicativec in rules for advcl
                                    token[6] = jos_head(token)
                                    token[7] = "copx"

                    ### csubj: clausal subject ######################################################
                    if cpostag(token) in ["VERB"]:
                        if jos_deprel(token) in ["Sb"]:
                            token[6] = jos_head(token)
                            token[7] = "csubj"

                    ### csubjpass: clausal passive subject ######################################################
                    # not used #

                    ### dep: unspecified dependency #############################################################
                    # not used #

                    ### det: determiner #########################################################################

                    ### new rule in UDv2, since the DET category changed significantly
                    #note that only lemmas occurring in the treebank have been considered (just as with the DET-PRON-ADV lists)
                    if jos_msd(token)[0] in ["P"] and lemma(token) in ["ta", "svoj", "ves", "njegov", "njen", "naš", "njihov", "vsak", "moj",
                                            "nekateri", "tisti", "nek", "kakšen", "vaš", "takšen", "tak", "oba", "noben",
                                            "kak", "isti", "enak", "nekakšen", "kateri", "mnog", "njun", "tvoj", "najin",
                                            "neki", "nikakršen", "vajin", "kakršenkoli", "marsikateri", "tolikšen",
                                            "katerikoli", "oni", "vsakršen", "kakršen", "premnog", "nekaj", "tale", "nič",
                                            "tolik", "oboj", "prenekateri", "nekak", "čigar", "malokateri", "un", "čigav",
                                            "kolikšen", "marsikakšen"]:
                        if jos_deprel(token) in ["Atr"] and jos_head_cpostag(token) in ["NOUN", "PROPN"]:
                            if int(id(token)) < int(jos_head(token)):
                                token[6] = jos_head(token)
                                token[7] = "det"

                    elif jos_msd(token)[0] in ["R"] and lemma(token) in ["nekaj", "več", "veliko", "manj", "dovolj",
                                                                               "pol", "malo", "toliko", "največ", "mnogo",
                                                                               "preveč", "par", "koliko", "dosti", "nešteto",
                                                                               "četrt", "ogromno", "čimveč"]:
                        if jos_deprel(token) in ["Atr"] and jos_head_cpostag(token) in ["NOUN", "PROPN"]:
                            if int(id(token)) < int(jos_head(token)):
                                token[6] = jos_head(token)
                                token[7] = "det"

                    ### discourse: discourse element ######################################################
                    # only manual #


                    ### dislocated: dislocated ############################################################
                    # only manual #

                    ### obj: direct object ###############################################################
                    if cpostag(token) not in ["VERB"]:
                        if jos_deprel(token) in ["Obj"]:
                            if jos_head_msd(token)[0] in ["V", "A", "R", "P"]: #verbs
                                token[6] = jos_head(token)
                                token[7] = "obj"
                                for t in sentence:
                                    if head(t) == id(token) and deprel(t) == "case":
                                        token[7] = "obl" #prepositional phrases are marked as nmod (major change)
                                        # NEW! in UD v2, PPs modifying a verb are renamed from nmod to obl (group [1])


                    ### expl: expletive ############################################################
                    if cpostag(token) in ["PRON"]:
                        if jos_deprel(token) in ["PPart"]:
                            if jos_head_msd(token)[0] in ["V", "R"]: #tudi deležja
                                token[6] = jos_head(token)
                                token[7] = "expl"

                    ### foreign: foreign words ############################################################
                    # see below #

                    ### goeswith: goes with ############################################################
                    # not used #

                    ### iobj: indirect object ############################################################
                    # see 3 #

                    ### mark: marker ############################################################
                    if cpostag(token) in ["SCONJ", "PART", "ADP", "X"]:
                        if jos_deprel(token) in ["Conj"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                token[6] = jos_head(token)
                                token[7] = "mark"

                    if jos_msd(token)[0] in ["R"]:
                        if jos_deprel(token) in ["Conj"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                if deprel(token) not in ["advmod"]:
                                    token[6] = jos_head(token)
                                    token[7] = "mark"
                                    # ali, a, adverbs as heads of multiword markers

                    # still need to consider what to do with VERB--Conj--PRON

                    ### mwe: multi-word expression ############################################################
                    if jos_deprel(token) in ["MWU"]:
                        token[7] = "fixed"
                        if jos_head_jos_deprel(token) in ["MWU"]:
                           token[6] = jos_head_head(token)
                        else:
                            token[6] = jos_head(token)

                    if lemma(token) in ["kot", "kakor"]:
                        if sentence[int(id(token))-2][2] in ["več", "manj"]:
                            if jos_head(token) == sentence[int(id(token))-2][6]:
                                token[6] = str(int(id(token))-1)
                                token[7] = "fixed"


                    ### name: name ############################################################

                    list_of_names = [['Aaron','Upinsky'],['Aaron','Wildavsky'],['Abu','Seif'],['Adam','Cauliff'],['Adam','Hammond'],['Adolf','Hitler'],['Adžić','Ursulov'],['Agata','Schwarzkobler'],['Ai','Weiwei'],['Ai','Xue'],['Ajdnik','Korošec'],['Alan','Greenspan'],['Alan','Lyman'],['Alberto','Medina'],['Aldo','Kumar'],['Alejandro','Toledo'],['Aleksander','Blok'],['Aleksander','Geržina'],['Aleksander','Knavs'],['Aleksandra','Mumelj'],['Alenka','Lesjak'],['Aleš','Berger'],['Aleš','Debeljak'],['Aleš','Klinar'],['Aleš','Novak'],['Aleš','Pajovič'],['Aleš','Ulaga'],['Alex','Cross'],['Alex','Cvetkov'],['Alexandra','Stiglmeyer'],['Alfonz','Hostnik'],['Alfonz','Kodrič'],['Ali','Baba'],['Ali','Raner'],['Alija','Izetbegović'],['Aljoša','Sergej'],['Allen','Johnson'],['Alma','Vičar'],['Alojz','Gradnik'],['Alojz','Rebula'],['Alojz','Zalokar'],['Alonzo','Mourning'],['Amelie','Mauresmo'],['Amina','Kolarič'],['Ana','Arh'],['Ana','Černe'],['Ana','Hrvat'],['Ana','Šemrov'],['Anatolij','Zlenko'],['Andraž','Vehovar'],['Andreas','Mölzer'],['Andrej','Babič'],['Andrej','Bajuk'],['Andrej','Brumen'],['Andrej','Fabjan'],['Andrej','Grudnik'],['Andrej','Jelenc'],['Andrej','Kokalj'],['Andrej','Košak'],['Andrej','Logar'],['Andrej','Lovrec'],['Andrej','Nahtigal'],['Andrej','Rant'],['Andrej','Umek'],['Andrej','Urlep'],['Andrej','Zdravič'],['Andreja','Babnik'],['Andreja','Burin'],['Andreja','Pleničar'],['Andreja','Zakonjšek'],['Andrew','Chaiken'],['Andrijana','Starina'],['Angelca','Ribič'],['Angelo','Pagotto'],['Anica','Milanović'],['Anna','Nicole'],['Annarita','Sidoti'],['Annika','Sorenstam'],['Anton','Bonaventura'],['Anton','Drobnič'],['Anton','Jakopič'],['Anton','Martin'],['Anton','Maver'],['Anton','Šteblaj'],['Anton','Tomaž'],['Antonio','Salvadori'],['Archie','Edward'],['Arnold','Rikli'],['Arthur','Clark'],['Arven','Šakti'],['Ato','Boldon'],['August','Strindberg'],['Auguste','Renoir'],['Augusto','Pinochet'],['Augustus','Arnone'],['Aurelio','Juri'],['Axel','Merckx'],['Barbara','Colbert'],['Barbara','Levstik'],['Barbara','Turšič'],['Ben','Curtis'],['Ben','Wallace'],['Benjamin','Bratt'],['Beno','Lapajne'],['Bernarda','Mavrič'],['Berto','Cokoja'],['Bill','Clinton'],['Bill','Gates'],['Billy','Crystal'],['Billy','Kid'],['Biserka','Petak'],['Bjanka','Adžić'],['Blagne','Zaman'],['Blagoje','Adžić'],['Blaž','Arnič'],['Blaž','Resman'],['Blaž','Simič'],['Bogdan','Žolnir'],['Bojan','Dekleva'],['Bojan','Emeršič'],['Bojan','Gasior'],['Bojan','Goljevšček'],['Bojan','Javornik'],['Bojan','Kastelic'],['Bojan','Labovič'],['Bojan','Lučovnik'],['Bojan','Prašnikar'],['Bojan','Stopar'],['Bojan','Šrot'],['Bojan','Tokič'],['Bojan','Velikonja'],['Boljte','Brus'],['Bonaventura','Jeglič'],['Boris','Frlec'],['Boris','Golec'],['Boris','Jelcin'],['Boris','Juh'],['Boris','Lanjšček'],['Boris','Lenič'],['Boris','Mlakar'],['Boris','Pasternak'],['Boris','Podrecca'],['Boris','Premožič'],['Boris','Rižnar'],['Boris','Sovič'],['Boris','Škerbinek'],['Boris','Tomažič'],['Boris','Vovk'],['Boris','Zgrablič'],['Boris','Zrinski'],['Borut','Miklavčič'],['Borut','Peterlin'],['Borut','Šuklje'],['Boštjan','Cesar'],['Boštjan','Gasser'],['Boštjan','Nachbar'],['Boštjan','Pirc'],['Boštjan','Senegačnik'],['Boštjan','Šoba'],['Božena','Zakrajšek'],['Božidar','Jakac'],['Božo','Kolerič'],['Božo','Štor'],['Brane','Grubar'],['Branka','Jovanović'],['Branko','Atanaskovič'],['Branko','Bergant'],['Branko','Djuriš'],['Branko','Grims'],['Branko','Majerič'],['Branko','Meh'],['Branko','Potočan'],['Branko','Šturbej'],['Branko','Zore'],['Breda','Pečan'],['Brumen','Čop'],['Buenos','Dias'],['Cady','Stanton'],['Cameron','Diaz'],['Camilla','Parker'],['Carl','Friedrich'],['Carlos','Checa'],['Carlos','Salcido'],['Catherine','Voisin'],['Catherine','Zeta'],['Cecil','Rhodes'],['Celine','Dion'],['Cesaria','Evora'],['Cezar','Oktavij'],['Chandler','Seagreaves'],['Charles','Eon'],['Charlotte','Oehlschläger'],['Chris','Robinson'],['Christian','Tauch'],['Christine','Arron'],['Christopher','Skase'],['Chryste','Gaines'],['Ciril','Pucko'],['Ciril','Ribičič'],['Claude','Bergeaud'],['Claude','Monet'],['Claudio','Scajola'],['Clive','Donner'],['College','Morehouse'],['Conrad','Röntgen'],['Cvetka','Hojnik'],['Černe','Dražumerič'],['Črt','Rojnik'],['Daijiro','Kato'],['Damijan','Knafelc'],['Damijan','Švajncer'],['Damjan','Kozole'],['Damjan','Trošt'],['Damjana','Golavšek'],['Danica','Simšič'],['Danijel','Malalan'],['Danilo','Luca'],['Danny','Rampling'],['Darja','Kapš'],['Darja','Lavtižar'],['Darko','Končan'],['Darryl','Middleton'],['Daut','Gumeni'],['David','Becker'],['David','Čeh'],['David','Grassi'],['David','Letterman'],['David','Lewis'],['David','Ličen'],['David','Oddsson'],['David','Rijavec'],['David','Robinson'],['Daze','School'],['Dean','Podgornik'],['Dejan','Kralj'],['Dejan','Stevanovič'],['Demi','Moore'],['Desa','Muck'],['Dezider','Baligač'],['Diana','Nakič'],['Diego','Brea'],['Dietmar','Pfleger'],['Dimitrij','Rupel'],['Dimitrios','Joannidis'],['Ditka','Haberl'],['Djabir','Said'],['Djordje','Žebeljan'],['Dolly','Parton'],['Dominik','Kozarič'],['Dominik','Soban'],['Don','Duong'],['Dora','Plestenjak'],['Drago','Balent'],['Drago','Papler'],['Drago','Šalamun'],['Drago','Vuica'],['Dragotin','Deleja'],['Dragotin','Kette'],['Drew','Barrymore'],['Dušan','Božičnik'],['Dušan','Jovanović'],['Dušan','Keber'],['Dušan','Plut'],['Dušan','Silič'],['Dušan','Šešok'],['Dušan','Škedl'],['Dušan','Štefula'],['Džuničiro','Koizumi'],['Edita','Mejač'],['Edna','Barry'],['Edouard','Manet'],['Edward','Bono'],['Egidio','Deiana'],['Ejad','Ismail'],['Elizabeth','Cady'],['Emanuel','Ginobili'],['Emil','Čater'],['Emil','Filipčič'],['Emil','Štukelj'],['Emil','Židan'],['Emilio','ZENI'],['Emmanuel','Davis'],['Emmanuele','Janini'],['Eon','Beaumont'],['Erica','Alfridi'],['Erika','Oblak'],['Erika','Steinbach'],['Erny','Gillen'],['Erwan','Fouere'],['Eugénie','Grandet'],['Eva','Grimmaldi'],['Eva','Hanska'],['Evgenija','Kegl'],['Fan','Wenhu'],['Fanika','Oblak'],['Fateh','Khan'],['Fedja','Marušič'],['Fehmi','Agani'],['Felipe','Palmeira'],['Feng','Jing'],['Filip','Kodrič'],['Filip','Kovačić'],['Florence','Hartmann'],['Florent','Sahiti'],['Forest','Whitaker'],['Fran','Simmons'],['Franc','Avberšek'],['Franc','Borko'],['Franc','But'],['Franc','Drole'],['Franc','Ferdinand'],['Franc','Košir'],['Franc','Lipoglavšek'],['Franc','Premk'],['Franc','Škufca'],['Franc','Štiglic'],['Franc','Umek'],['France','Arhar'],['France','Prešeren'],['France','Stele'],['Francesco','Filelfo'],['Franci','Povše'],['Franci','Rokavec'],['Franci','Slak'],['Francis','Obikwelu'],['Francka','Trobec'],['Francka','Zorman'],['Franco','Foda'],['Francois','Fillon'],['Franček','Knez'],['Frančišek','Ksaver'],['Franjo','Stiplovšek'],['Frank','Zappa'],['Frankie','Knuckles'],['Freddie','Prinze'],['Frenkie','Schinkels'],['Friderik','Baraga'],['Friedrich','Wilhelm'],['Gabriel','Muies'],['Gaetano','Valenti'],['Gail','Devers'],['Gaj','Julij'],['Gaja','Peric'],['Gary','Hume'],['Gary','Oldman'],['Gasoy','Romdal'],['Gavril','Princip'],['Geoff','Hoon'],['George','Brennan'],['George','Bush'],['George','Oldfield'],['Gerhard','Giesemann'],['Gerhard','Schröder'],['Gilberto','Simoni'],['Gilles','Picard'],['Giorgio','Faletti'],['Giuseppe','Tartini'],['Goldie','Hawn'],['Gonzalo','Pineda'],['Goran','Ivanišević'],['Goran','Jurak'],['Goran','Sankovič'],['Gorazd','Bedrač'],['Gorazd','Logar'],['Gorazd','Topolovec'],['Gordon','Brown'],['Gordon','Danby'],['Gottfried','Herder'],['Grand','National'],['Grazia','Toderi'],['Grega','Sevnik'],['Grega','Virant'],['Gregg','Popovich'],['Gregor','Baković'],['Gregor','Cvijić'],['Gregor','Golobič'],['Gregor','Jurak'],['Gričar','Skelendžija'],['Gustav','Januš'],['Guy','Haug'],['Hanna','Slak'],['Hannu','Lepistö'],['Hans','Eichel'],['Hans','Jonas'],['Harry','Potter'],['Havelock','Ellis'],['Heinrich','Brüning'],['Helen','Exley'],['Helena','Bargoltz'],['Helena','Blagne'],['Helmut','Oblinger'],['Henček','Burkat'],['Henry','Meyric'],['Henry','Winkler'],['Herbert','Karajan'],['Hidayet','Turkoglu'],['Hilda','Bregar'],['Hiroši','Masuoka'],['Hojnik','Dorojevič'],['Hong','Tagu'],['Howard','Arkley'],['Howard','Hughes'],['Hugo','Friedrich'],['Ib','Sejersen'],['Ibrahim','Rogova'],['Ibrahim','Rugova'],['Ignazio','Visco'],['Igor','Bavčar'],['Igor','Koršič'],['Igor','Kotnik'],['Igor','Lampret'],['Igor','Modic'],['Igor','Omerza'],['Igor','Prassel'],['Igor','Strmšnik'],['Igor','Šterk'],['Ilija','Puljević'],['Iljič','Čajkovski'],['Imelda','Marcos'],['Irena','Čebulj'],['Irena','Levičnik'],['Irena','Simčič'],['Irena','Šumi'],['Irena','Vrčkovnik'],['Iva','Lapajne'],['Ivan','Bizjak'],['Ivan','Cankar'],['Ivan','Cesar'],['Ivan','Čargo'],['Ivan','Grohar'],['Ivan','Ivankov'],['Ivan','Kebrič'],['Ivan','Klemenčič'],['Ivan','Lenarčič'],['Ivan','Malnar'],['Ivan','Mirt'],['Ivan','Napotnik'],['Ivan','Stambolić'],['Ivana','Leskovec'],['Ivanka','Grobelnik'],['Ivanka','Lazar'],['Ivanka','Mestnik'],['Ivhan','Luyis'],['Ivica','Kovačevič'],['Ivica','Račan'],['Ivo','Bizjak'],['Iztok','Božič'],['Iztok','Mlakar'],['Iztok','Novak'],['Iztok','Zupančič'],['Jack','Frost'],['Jacqueline','Hill'],['Jacques','Klein'],['Jacques','Rogge'],['Jadranka','Matić'],['Jaime','Lozano'],['Jajiro','Cardenas'],['Jaka','Adamič'],['Jaka','Čop'],['Jake','Weber'],['James','Bond'],['James','Powell'],['Jan','Cvitkovič'],['Jan','Juvan'],['Jan','Plestenjak'],['Jan','Vrabec'],['Jana','Kramberger'],['Jana','Logar'],['Jana','Menger'],['Janči','Majzelj'],['Janet','Patzig'],['Janey','Mitchell'],['Janez','Bešter'],['Janez','Bizjak'],['Janez','Bukovec'],['Janez','Burger'],['Janez','Čadež'],['Janez','Drnovšek'],['Janez','Gnidovec'],['Janez','Hočevar'],['Janez','Janša'],['Janez','Kohek'],['Janez','Kopač'],['Janez','Kromar'],['Janez','Lotrič'],['Janez','Matek'],['Janez','Pavel'],['Janez','Pavlin'],['Janez','Pipan'],['Janez','Podobnik'],['Janez','Trdina'],['Janez','Živič'],['Janez','Žnidaršič'],['Jani','Koman'],['Janko','Bukovec'],['Janko','Kosmina'],['Janko','Kraševec'],['Janko','Moder'],['Janko','Veber'],['Jasna','Hribernik'],['Jasna','Markovič'],['Jasna','Vastl'],['Javier','Solana'],['Javier','Sotomayor'],['Jean','Cottret'],['Jean','Greisch'],['Jean','Pierre'],['Jegor','Strojev'],['Jelena','Belder'],['Jelisaveta','Karađorđević'],['Jelko','Kacin'],['Jennifer','Garner'],['Jennifer','Lopez'],['Jeremy','Metters'],['Jernej','Zajec'],['Jerneja','Batič'],['Jerzy','Buzek'],['Jezus','Kristus'],['Jianwei','Mo'],['Jim','Furyk'],['Jim','Hobson'],['Jim','Jarmusch'],['Jiri','Welsch'],['Joao','Costa'],['Johann','Gottfried'],['John','Conheeney'],['John','Cusack'],['John','Daniels'],['John','Dantley'],['John','Deere'],['John','Hopkins'],['John','Howard'],['John','Howett'],['John','Singleton'],['Johnny','Young'],['Joho','António'],['Jörg','Haider'],['Joschka','Fischer'],['Jose','Maria'],['Joseph','Beuys'],['Joseph','Blatter'],['Joseph','Vasquez'],['Josip','Ulčnik'],['Joško','Joras'],['Joško','Štrukelj'],['Jovan','Ćirilov'],['Jože','Avšič'],['Jože','Gale'],['Jože','Jagodnik'],['Jože','Krajnc'],['Jože','Kristan'],['Jože','Lenič'],['Jože','Mihelič'],['Jože','Mikeln'],['Jože','Murko'],['Jože','Perko'],['Jože','Protner'],['Jože','Rozman'],['Jože','Ružič'],['Jože','Simončič'],['Jože','Straub'],['Jože','Strelec'],['Jože','Vild'],['Jože','Zagožen'],['Jože','Zupan'],['Jožef','Školč'],['Jožef','Vespigniani'],['Jožica','Bohak'],['Jožica','Boljte'],['Jožica','Cajhen'],['Jožica','Jaklič'],['Jožko','Čuk'],['Juan','Pablo'],['Julia','Roberts'],['Julij','Barberis'],['Julij','Cezar'],['Julijan','Gomišček'],['Julio','Iglesias'],['Julius','Kugy'],['Julka','Nežič'],['June','Paik'],['Jure','Frank'],['Jurij','Korenjak'],['Jurij','Lah'],['Jurij','Marussig'],['Jurij','Schollmayer'],['Kahlil','Gibran'],['Kalejda','Zia'],['Karel','Grabeljšek'],['Karel','Lipič'],['Karel','Štrekelj'],['Karika','Vrrti'],['Karl','Drake'],['Karmen','Auer'],['Karmen','Potočnik'],['Karpo','Godina'],['Katarina','Marcola'],['Katarina','Srebotnik'],['Katarina','Stegnar'],['Kate','Hudson'],['Kate','Mctiernan'],['Katharina','Frish'],['Katja','Levstik'],['Katja','Plut'],['Kegl','Korošec'],['Kenneth','Warner'],['Klavdija','Kotar'],['Klavdija','Zupan'],['Klemen','Grebenšek'],['Klemen','Lavrič'],['Kondi','Pižorn'],['Kotnik','Dvojmoč'],['Krist','Novoselic'],['Krista','Stadler'],['Krsto','Hegedušić'],['Ksenja','Steblovnik'],['Kyle','Craig'],['Laren','Dorr'],['Larry','Fishburne'],['Laura','Mcewan'],['Lavtižar','Bebler'],['Lawrence','Berkeley'],['Leja','Jurišić'],['Leo','Šešerko'],['Leon','Stipaničev'],['Leonardo','Vinci'],['Leopold','Panjan'],['Leopold','Suhodolčan'],['Leopold','Škotnik'],['Lewis','Goldberg'],['Linh','Bui'],['Lionel','Jospin'],['Lirim','Jakupi'],['Lisa','Ryan'],['Lisl','Cade'],['Liz','Solane'],['Ljuba','Prenner'],['Logar','Povšič'],['Lojze','Slak'],['Lojze','Škabar'],['Loop','Guru'],['Loudon','Trott'],['Louis','Napoleon'],['Louise','Hay'],['Lovrenc','Arnič'],['Luciano','Pavarotti'],['Lucija','Čok'],['Lucija','Nedeljkovič'],['Lucy','Liu'],['Lučka','Winkler'],['Ludvik','Hren'],['Ludvik','Olivej'],['Ludvik','Pliberšek'],['Luis','Figo'],['Luis','Perez'],['Luiz','Felipe'],['Luka','Cjuha'],['Lukan','Klavžer'],['Luyis','Carpio'],['Madhyamika','Karika'],['Magda','Omahen'],['Maja','Sever'],['Maja','Weiss'],['Maja','Zupančič'],['Majda','Kohek'],['Majda','Križaj'],['Majda','Rojc'],['Majda','Širca'],['Maks','Gale'],['Maks','Kunc'],['Malcolm','Bilson'],['Manca','Košir'],['Manca','Šetina'],['Manfred','Attems'],['Manuel','Poggiali'],['Marco','Pantani'],['Maria','Aznar'],['Maria','Mutola'],['Marija','Antoinetta'],['Marija','Markeš'],['Marija','Pomočnica'],['Marija','Sitar'],['Marija','Terezija'],['Marija','Zidanšek'],['Marijan','FARAZIN'],['Marijan','Prosen'],['Marijan','Schiffrer'],['Marilyn','Strathern'],['Marina','Paage'],['Mario','Galunič'],['Mario','Mendez'],['Mario','Pescante'],['Marion','Jones'],['Marisa','Tomei'],['Marjan','Černigoj'],['Marjan','Doler'],['Marjan','Erhatič'],['Marjan','Ernestl'],['Marjan','Grahut'],['Marjan','Hlastec'],['Marjan','Javornik'],['Marjan','Kozina'],['Marjan','Manček'],['Marjan','Podobnik'],['Marjan','Šebenik'],['Marjanca','Pergar'],['Marjeta','Dvornik'],['Marjeta','Kovač'],['Marjeta','Smrekar'],['Mark','Antonij'],['Mark','Serrano'],['Marko','Brecelj'],['Marko','Kmetec'],['Marko','Kociper'],['Marko','Košan'],['Marko','Mlačnik'],['Marko','Notar'],['Marko','Okorn'],['Marko','Tkalec'],['Marko','Vogrič'],['Marko','Žagar'],['Markovič','Jagodič'],['Marks','Wulffing'],['Marta','Sebestyan'],['Martin','Mele'],['Martin','Scorsese'],['Martin','Slomšek'],['Martin','Strel'],['Martin','Šolar'],['Martin','Waldseemüller'],['Martina','Dorak'],['Mary','Douglas'],['Mary','Kingsley'],['Matej','Lahovnik'],['Matej','Povše'],['Matej','Žilavec'],['Mateja','Ajdnik'],['Mateja','Klep'],['Mateja','Kocjan'],['Mateja','Slana'],['Mateja','Špicar'],['Matevž','Hribernik'],['Matevž','Krivic'],['Matevž','Lenarčič'],['Matic','Tasič'],['Matić','Zupančič'],['Matija','Logar'],['Matija','Rozman'],['Matija','Zemljič'],['Matjaž','Bajc'],['Matjaž','Berce'],['Matjaž','Berger'],['Matjaž','Brumen'],['Matjaž','Falkner'],['Matjaž','Hanžek'],['Matjaž','Jankovič'],['Matjaž','Kmecl'],['Matjaž','Leskovar'],['Matjaž','Sekelj'],['Matjaž','Smodiš'],['Matjaž','Sonc'],['Matjaž','Šinkovec'],['Matjaž','Vehovec'],['Matjaž','Zanoškar'],['Matthias','Erzberger'],['Matty','Rich'],['Maurice','Greene'],['Mekhi','Phifer'],['Meta','Hočevar'],['Meta','Krese'],['Meta','Rainer'],['Metka','Karner'],['Metka','Štuhec'],['Metod','Pevec'],['Metoda','Zorčič'],['Meyric','Hughes'],['Michael','Botwin'],['Michael','Heltau'],['Michael','Kelly'],['Michael','Kennedy'],['Michael','Palin'],['Michael','Schumacher'],['Michael','Thompson'],['Michael','Watkins'],['Miguel','Abnellan'],['Miha','Brejc'],['Miha','Hočevar'],['Miha','Klinar'],['Miha','Kovač'],['Miha','Kozinc'],['Miha','Nemec'],['Miha','Štricelj'],['Mihail','Gričar'],['Mihail','Nestruev'],['Mijo','Kurpes'],['Mika','Häkkinen'],['Mika','Kojonkoski'],['Mike','Weir'],['Milan','Jesih'],['Milan','Kučan'],['Milan','Mandarić'],['Milan','Pogačnik'],['Milan','Šercer'],['Milan','Šušteršič'],['Milan','Zorman'],['Milanko','Bilandžič'],['Mile','Korun'],['Milena','Kostanjevec'],['Milko','Šparemblek'],['Milojka','Kolar'],['Miloš','Čirič'],['Mimi','Podkrižnik'],['Minka','Peterka'],['Mira','Mihelič'],['Miran','Cvet'],['Miran','Herzog'],['Miran','Irman'],['Miran','Kert'],['Miran','Kramberger'],['Miran','Lesjak'],['Miran','Šubic'],['Miran','Vodovnik'],['Miran','Zupanič'],['Mirjana','Stantič'],['Mirko','Bandelj'],['Mirko','Bašić'],['Mirko','Kaluža'],['Mirko','Kovač'],['Mirko','Podlesnik'],['Mirko','Zupančič'],['Miro','Hanželj'],['Miro','Požun'],['Miro','Solman'],['Miro','Sotlar'],['Miroslav','Cerar'],['Miroslav','Klun'],['Miroslav','Živadinović'],['Mitja','Bukovec'],['Mitja','Hlastec'],['Mitja','Jančar'],['Mitja','Mahorič'],['Mitja','Vrhovnik'],['Mladen','Dabanovič'],['Mladen','Rudonja'],['Mojca','Jevšnik'],['Monika','Keller'],['Monty','Pyton'],['Moto','Cyozaki'],['Muamer','Vugdalić'],['Muddy','Waters'],['Na','Na'],['Nace','Bratina'],['Nam','June'],['Nani','Roma'],['Naoja','Cukahara'],['Nastasia','Suhadolnik'],['Nastja','Čeh'],['Natacha','Atlas'],['Natalia','Biorro'],['Natasha','Colbert'],['Nataša','Briški'],['Nataša','Jerkovič'],['Nataša','Matjašec'],['Nataša','Pergar'],['Nataša','Pirc'],['Nataša','Prosenc'],['Nataša','Retelj'],['Nejc','Novak'],['Nelson','Mandela'],['Nemec','Nils'],['Neža','Simčič'],['Nicolas','Sarkozy'],['Nicole','Smith'],['Nicoletta','Mantovani'],['Nika','Leben'],['Nikki','Finn'],['Niko','Bevk'],['Niko','Markovič'],['Nikola','Barović'],['Nils','Schumann'],['Nusrat','Fateh'],['Olaf','Tufte'],['Ole','Romer'],['Olesung','Obasanjo'],['Oliver','Marče'],['Oliver','Neuville'],['Oliver','Twist'],['Orest','Jarh'],['Osama','Laden'],['Oswald','Spengler'],['Oswaldo','Sanchez'],['Oton','Župančič'],['Otto','Zidko'],['Pablo','Rodriguez'],['Palmeira','Lampreia'],['Pamela','Collison'],['Pan','Gu'],['Parker','Bowles'],['Patrick','Swayze'],['Paul','Hoffman'],['Paul','Hunt'],['Paul','Ridiker'],['Pauline','Hanson'],['Pauline','Howard'],['Pavel','Glavar'],['Pavel','Pardo'],['Pedro','Rosa'],['Pergar','Kuščer'],['Petar','Dujmović'],['Pete','Conrad'],['Peter','Fister'],['Peter','Florjančič'],['Peter','Iljič'],['Peter','Jambrek'],['Peter','Jančič'],['Peter','Mankoč'],['Peter','Mcgrath'],['Peter','Moszynski'],['Peter','Musevski'],['Peter','O\'Brian'],['Peter','Pavel'],['Peter','Pengal'],['Peter','Srpčič'],['Peter','Tevž'],['Peter','Vesenjak'],['Peter','Vodopivec'],['Peterburg','Sankt'],['Petra','Kolmančič'],['Petra','Škofic'],['Phil','Chartrukian'],['Philip','Matthews'],['Pia','Mlakar'],['Pierce','Brosnan'],['Piero','Focaccia'],['Piero','Franceschi'],['Pierre','Raffarin'],['Pino','Mlakar'],['Plesničar','Gec'],['Poljanka','Pavljetič'],['Polona','Dobrajc'],['Polona','Juh'],['Polona','Kunaver'],['Polona','Reberšak'],['Povše','Baxter'],['Prescott','Bush'],['Primož','Samar'],['Primož','Ulaga'],['Pusar','Jerič'],['Rade','Šerbedžija'],['Rado','Bohinc'],['Radoš','Bolčina'],['Rafko','Vončina'],['Ramon','Morales'],['Ramona','Fras'],['Ramzi','Jusef'],['Raša','Sraka'],['Ratko','Varda'],['Reggio','Emilia'],['Renata','Bohinc'],['Renato','Vugrinec'],['Rene','Glavnik'],['Ricardo','Osorio'],['Riccardo','Circuolo'],['Richard','Monaghan'],['Richard','Serra'],['Rick','Schroder'],['Rita','Washington'],['Rob','Costa'],['Robert','Crnjac'],['Robert','Mracsek'],['Robert','Prosinečki'],['Robert','Superko'],['Roberto','Dipiazza'],['Roberto','Heras'],['Roberto','Maroni'],['Rodrigo','Rato'],['Roe','Tierney'],['Rok','Cvetkov'],['Roland','Waeyaert'],['Roman','Glaser'],['Roman','Molan'],['Romana','Gregorka'],['Romano','Prodi'],['Ron','Mercer'],['Ros','Pesetsky'],['Rozi','Skobe'],['Rudi','Šeligo'],['Rui','Costa'],['Ruth','Rendell'],['Sadam','Husein'],['Sahir','Abdelkbir'],['Said','Guerni'],['Salvador','Dali'],['Sam','Kraus'],['Samo','Dražumerič'],['Sampson','John'],['Samuel','Beckett'],['Sandi','Čolnik'],['Sandra','Poredoš'],['Sarah','Polley'],['Saša','Geržina'],['Saša','Olenjuk'],['Sašo','Jereb'],['Sašo','Kolar'],['Sašo','Kranjc'],['Sašo','Lap'],['Sašo','Podgoršek'],['Sean','Scully'],['Sebastijan','Podobnik'],['Sebastjan','Sovič'],['Sebastjan','Šik'],['Sergej','Mironov'],['Sergej','Rutenka'],['Sergej','Vrišer'],['Sigmund','Freud'],['Silvana','Belcijan'],['Silvester','Gaberšček'],['Silvio','Berlusconi'],['Simon','Petrov'],['Simon','Soklič'],['Simona','Šturm'],['Simona','Vida'],['Siniša','Germovšek'],['Sinja','Ožbolt'],['Slavko','Avsenik'],['Slavko','Gaber'],['Slavko','Gliha'],['Slavko','Podboj'],['Slobodan','Milošević'],['Slobodan','Subotić'],['Sonja','Jamnikar'],['Sonja','Porle'],['Spike','Lee'],['Srečko','Katanec'],['Srečko','Mihelič'],['Stane','Osojnik'],['Stane','Sever'],['Stane','Valant'],['Stanislav','Pušnik'],['Stanislava','Ban'],['Staniša','Slavko'],['Starina','Kosem'],['Stefano','Lusa'],['Stephane','Peterhansel'],['Stephen','Byers'],['Stevan','Stojanović'],['Steve','Jobs'],['Steven','Spielberg'],['Stipe','Mesić'],['Stipe','Modrić'],['Stojan','Ložar'],['Stojan','Spetič'],['Stojan','Žibert'],['Suad','Beširevič'],['Susan','Brownell'],['Susan','Brownmiller'],['Susan','Fletcher'],['Svetlana','Visintin'],['Sylvester','Stallone'],['Sylvia','Lukan'],['Šakti','Kralj'],['Šamil','Basajev'],['Šetina','Miklič'],['Šimon','Peres'],['Špela','Vozel'],['Štefanija','Drolc'],['Štefka','Kučan'],['Tadej','Pavlica'],['Tadej','Valjavec'],['Tajda','Lekše'],['Tanja','Zgonc'],['Tarek','Rashid'],['Tatjana','Jevševar'],['Tatjana','Vonta'],['Tea','Lukan'],['Tea','Petrin'],['Teilhard','Chardin'],['Teodora','Goodman'],['Theorian','O\'Neal'],['Thomas','Bernhard'],['Thomas','Henry'],['Tiger','Woods'],['Tim','Curry'],['Tim','Duncan'],['Tim','Goodehild'],['Tim','Timotej'],['Timotej','Ambrož'],['Tina','Gašperšič'],['Tina','Janežič'],['Tina','Kukec'],['Tina','Pisnik'],['Tom','Cruise'],['Tom','Hutchinson'],['Tomaž','Domicelj'],['Tomaž','Gorjup'],['Tomaž','Grom'],['Tomaž','Hartman'],['Tomaž','Kempčan'],['Tomaž','Lajevec'],['Tomaž','Linhart'],['Tomaž','Marušič'],['Tomaž','Perovič'],['Tomaž','Rojs'],['Tomaž','Skale'],['Tomaž','Šumi'],['Tomaž','Zorko'],['Tomo','Jeseničnik'],['Tomo','Jovanovič'],['Tone','Anderlič'],['Tone','Čufar'],['Tone','Glavan'],['Tone','Homar'],['Tone','Hrovat'],['Tone','Planinc'],['Tone','Rop'],['Tone','Seliškar'],['Tone','Slodnjak'],['Tone','Starc'],['Tone','Tiselj'],['Tone','Vidrih'],['Toni','Gašperič'],['Tony','Blair'],['Tony','Bosch'],['Tony','Dallara'],['Tony','Parker'],['Torquato','Tasso'],['Ty','Burrell'],['Umberto','Angeloni'],['Umberto','Eco'],['Unai','Etxebarria'],['Uroš','Jurišič'],['Uroš','Lajovic'],['Uroš','Zorman'],['Urška','Dolinar'],['Urška','Lunder'],['Urška','Mavri'],['Uwe','Theimer'],['Vaclav','Červeny'],['Vadim','Fiškin'],['Valdas','Adamkus'],['Valentin','Pivovarov'],['Valentin','Vodnik'],['Valentino','Rossi'],['Valerie','Mars'],['Valerie','Oberleithner'],['Valon','Azemi'],['Valter','Bonča'],['Valter','Dragan'],['Vanessa','Mae'],['Vanja','Alič'],['Vannesa','Mae'],['Vasco','Gama'],['Vasilij','Cerar'],['Vatroslav','Lisinski'],['Veronika','Deseniška'],['Veronika','Hauptman'],['Vida','Bukovec'],['Vida','Jan'],['Vija','Singh'],['Vika','Potočnik'],['Viktor','Černomirdin'],['Viktor','Lenče'],['Viktor','Luskovec'],['Viktor','Papler'],['Ving','Rhames'],['Vinko','Globokar'],['Vinko','Kandija'],['Vinko','Möderndorfer'],['Vinko','Ošlak'],['Vinko','Potočnik'],['Virginia','Woolf'],['Vitalij','Osmačko'],['Vitautas','Landsbergis'],['Vitka','Ribičič'],['Vito','Globočnik'],['Vito','Taufer'],['Vjekoslav','Grmič'],['Vladimir','Bahč'],['Vladimir','Becić'],['Vladimir','Gončarov'],['Vladimir','Kevo'],['Vladimir','Kralj'],['Vladimir','Putin'],['Vladimir','Rudl'],['Vladimir','Stepania'],['Vojislav','Bercko'],['Vojka','Štular'],['Vrhovnik','Smrekar'],['Wesley','Clark'],['Wesley','Snipes'],['Wilhelm','Conrad'],['Wilhelm','Groener'],['Will','Rudolph'],['Wolfgang','Bahls'],['Wyatt','Earp'],['Xiang','Huaicheng'],['Yasmina','Reza'],['Yilak','Shilok'],['Yngve','Gasoy'],['Zack','Snyder'],['Zdenka','Cerar'],['Zdenka','Kramar'],['Zdenka','Logar'],['Zdravko','Budna'],['Zdravko','Deleja'],['Zdravko','Tomac'],['Zinedine','Zidane'],['Zlatko','Fras'],['Zlatko','Tomčić'],['Zlato','Zaletel'],['Zmago','Lenardič'],['Zmago','Sagadin'],['Zoran','Arnež'],['Zoran','Benčič'],['Zoran','Gračner'],['Zoran','Lubej'],['Zoran','Mazej'],['Zoran','Thaler'],['Zorica','Fatur'],['Zvezdana','Mlakar'],['Zvone','Hribar'],['Zvone','Šedlbauer'],['Žuži','Jelinek']]

                    if cpostag(token) in ["PROPN"]:
                        if jos_deprel(token) in ["Atr"] and jos_head_cpostag(token) in ["PROPN"]:
                            name = [jos_head_lemma(token), lemma(token)]
                            if name in list_of_names:
                                token[6] = jos_head(token)
                                token[7] = "flat:name"
                                #Bill Clinton

                                if jos_head_deprel(token) in ["flat:name"]:
                                    token[6] = jos_head_head(token)
                                    #Camilla Parker Bowles


                    ### neg: negation modifier ############################################################


                    ### nmod: nominal modifier ############################################################
                    if jos_msd(token)[0] in ["N", "P", "A", "X", "I", "C", "Y"] or cpostag(token) in ["ADJ"]: #INTJ: medmet v vlogi samostalnika, C-SCONJ: skup kakor-koli; cpostag in adjt zato, da vključimo nekatere besedne števnike, ne pa nebesednih
                        if jos_deprel(token) in ["AdvM", "AdvO"]:
                            token[6] = jos_head(token)
                            token[7] = "obl"
                            # NEW! in UD v2, PPs modifying a verb are renamed from nmod to obl (group [2])

                    if jos_msd(token)[0] in ["N", "P", "X", "Y"]:
                        if jos_deprel(token) in ["Atr"] and token[7] in ["root"]:
                            if jos_head_cpostag(token) not in ["VERB"]:
                                token[6] = jos_head(token)
                                token[7] = "nmod"
                                # in UD v2, NPs modifying an NP remain marked as nmod (group [3])


                    ### nsubj: nominal subject ############################################################
                    if cpostag(token) not in ["VERB"]:
                        if jos_deprel(token) in ["Sb"]:
                            token[6] = jos_head(token)
                            token[7] = "nsubj"

                    ### nsubjpass: passive nominal subject #################################################
                    # not used #

                    ### nummod: numeric modifier ############################################################
                    if cpostag(token) in ["NUM"] and token[6] in ["0"]: #if it hasn't been covered by the compound rule
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) not in ["VERB", "AUX"]:
                                token[6] = jos_head(token)
                                token[7] = "nummod"

                    ### parataxis: parataxis ############################################################
                    # only manual #

                    ### punct: punctuation ############################################################
                    if cpostag(token) in ["PUNCT"]:
                        if jos_deprel(token) in ["Conj"]:
                            if jos_head_jos_deprel(token) in ["Coord"]:
                                token[6] = jos_head(token) #UD v2
                                token[7] = "punct"

                    if cpostag(token) in ["PUNCT"]:
                        if jos_deprel(token) in ["Conj"]:
                            if jos_head_cpostag(token) in ["ADJ", "VERB"]:
                                if jos_head_jos_deprel(token) in ["Atr"]:
                                    token[6] = jos_head(token)
                                    token[7] = "punct"
                                    #impulzov, oblikovanih v ...

                    if cpostag(token) in ["PUNCT"]:
                        if jos_deprel(token) in ["Conj"]:
                            if preceding(token) and jos_head(token) == jos_head(preceding(token)):
                                token[6] = jos_head(token) #UD v2
                                token[7] = "punct"
                                # e.g. 50-letnica, narko-kralj

                    if cpostag(token) in ["PUNCT"]:
                        if form(token) in ["-"]:
                            if jos_deprel(token) in ["Conj"]:
                                if token[7] in ["root"]:
                                    token[6] = jos_head_jos_head(token)
                                    token[7] = "punct"
                                    # ekipa Šmartno - Factor

                    if cpostag(token) in ["PUNCT"]:
                        if jos_deprel(token) in ["Root"] and deprel(token) in ["root"]:
                            token[7] = "attach_punct"

                    if cpostag(token) in ["PUNCT"]:
                        if form(token) in [","] and int(id(token)) < no_of_tokens:
                            if token[7] in ["root"]:
                                if sentence[int(id(token))][3] in ["ADP"]:
                                    if sentence[int(id(token))+1][3] in ["DET"]:
                                        token[6] = jos_head(token)
                                        token[7] = "punct"
                                        # vprašal, za kakšno bolezen gre


                    ### remnant: remnant in ellipsis ############################################################
                    # not currently used #

                    ### reparandrum: overriden disfluency ############################################################
                    # not currently used #

                    ### vocative: vocative ############################################################
                    # see below #

                    ### xcomp: open clausal complement ######################################################
                    if features(token).get("VerbForm") in ["Inf", "Sup"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                token[6] = jos_head(token)
                                token[7] = "xcomp"

                                for t in sentence:
                                    if head(t) == id(token) and "subj" in deprel(t):
                                        sentence[int(id(t))-1][6] = jos_head(token) #changes in v29
                                # xcomp nima svojega osebka, osebek je vedno povezan s povedkom nadrejenega stavka

                    # for attachment of other (non-subj) arguments, we follow the attachments of the original treebank,
                    # however, these should be checked for consistency sometime in the future, as they should always
                    # be linked to the predicate they modify (either the finite or the infinitive)

                    if jos_msd(token)[0] in ["N", "P", "X", "Y"]: #changed from cpostag(token) in ["NOUN", "PROPN", "PRON", "X"]
                        if jos_deprel(token) in ["Obj"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                if jos_head_lemma(token) in ["ostati", "postati", "izpasti", "ostajati", "postajati",
                                                      "ratovati", "zdeti", "počutiti", "izkazati"]:
                                    if "Case" in features(token) and not features(token)["Case"] in ["Dat"]: #added to UD_v1.3 (exclude se *mi* je zdela, *mu* je ostalo)
                                        token[6] = jos_head(token)
                                        token[7] = "xcomp"

                                #čutiti se zaenkrat pri samostalnikih  izpuščen
                                elif jos_head_lemma(token) in ["šteti", "imeti", "veljati", "imenovati", "izbrati", "izvoliti",
                                    "narediti", "oklicati", "označiti", "označevati", "postaviti",
                                    "potrditi", "predlagati", "razglasiti", "smatrati", "spoznati", "sprejeti", "vzeti",
                                    "želeti","proglasiti"]:
                                    for t in sentence:
                                        if lemma(t) == "za" and jos_head(t) == id(token):
                                            token[6] = jos_head(token)
                                            token[7] = "xcomp"

                    if jos_msd(token)[0] in ["A", "P", "X", "Y"]:
                        if jos_deprel(token) in ["Atr"]:
                            if jos_head_cpostag(token) in ["VERB"]:
                                if jos_head_lemma(token) in ["ostati", "postati", "izpasti", "ostajati", "postajati",
                                                      "ratovati", "čutiti", "zdeti", "počutiti", "izkazati", "narediti"]:
                                    token[6] = jos_head(token)
                                    token[7] = "xcomp"

                                elif jos_head_lemma(token) in ["šteti", "imeti", "veljati", "imenovati", "izbrati", "izvoliti",
                                    "narediti", "oklicati", "označiti", "označevati", "postaviti",
                                    "potrditi", "predlagati", "razglasiti", "smatrati", "spoznati", "sprejeti", "vzeti",
                                    "želeti", "proglasiti"]:
                                    for t in sentence:
                                        if lemma(t) == "za" and jos_head(t) == id(token):
                                            token[6] = jos_head(token)
                                            token[7] = "xcomp"


################################### 2 SPECIAL RULES FOR PRONOUNS INTRODUCING A SUBORDINATE CLAUSE #################################
# this is a very interesting topic for further discussions

                    if jos_msd(token)[0] in ["P"]:
                        if jos_deprel(token) in ["Conj"]:

                            if preceding(token) and cpostag(preceding(token)) == "ADP" and head(preceding(token)) == id(token): #predložne zveze
                                token[6] = jos_head(token)
                                token[7] = "obl"
                                # vsi predložni so nmod, tudi pridevnniški, e.g. brez katerega, v kakršnih, iz koga etc.
                                # NEW! in UD v2, PPs modifying a verb are renamed from nmod to obl (group [4])

                            elif lemma(token) in ["kaj", "kdo", "kar", "kdor", "karkoli"]:
                                if not "Case=Nom" in feats(token):
                                    token[6] = jos_head(token)
                                    token[7] = "obj"
                                    #Zdaj pa čakamo, kaj bodo pokazali.

                                else:
                                    if not jos_head_lemma(token) in ["biti"]:
                                        token[6] = jos_head(token)
                                        token[7] = "nsubj"
                                        #Kaj se je zgodilo, sem izvedel šele včeraj.
                                    else:
                                        subject = 0
                                        for t in sentence:
                                            if jos_head(t) == jos_head(token) and "Sb" in jos_deprel(t): #if there already is a subject within the subordinate clause
                                                token[6] = jos_head(token)
                                                token[7] = "copx"
                                                #ne vem, kaj je bilo to
                                                subject = 1

                                        if not subject:
                                            token[6] = jos_head(token)
                                            token[7] = "nsubj"
                                            #..., kar pomeni

                            elif lemma(token) in ["kateri", "čigar", "kakršen", "kolikšen", "kakšen"]:
                                if "Case=Nom" in feats(token):
                                    subject = 0
                                    for t in sentence:
                                        if "Sb" in jos_deprel(t) and jos_head(t) == jos_head(token):
                                            if int(id(t)) < int(jos_head(token)): #if the subject is left of the head verb
                                                token[6] = id(t)
                                                token[7] = "det"
                                                # Naj pove, katera spojina je to.

                                                subject = 1

                                            else:
                                                token[6] = jos_head(token)
                                                token[7] = "copx"
                                                subject = 1
                                                #nakazuje, kateri je njegov prevladujoči element
                                                #Velikan, kakršen je Siemens.
                                                #future work: should these be heads of copulas or subjects?
                                    if not subject:
                                        token[6] = jos_head(token)
                                        token[7] = "nsubj"
                                        #vedeti, kateri so na voljo ...

                                else: #for all other cases of pronouns katero, čigar, kakršen, kolikšen in kakšen marked as Conj-JOS but not Nominative

                                    ### special cases first ###############################################################
                                    ### SC1: partitive/negated subjects ###
                                    if form(token) in ["kakršne", "kakršnih"] and features(token)["Case"] == "Gen":
                                        token[6] = jos_head(token)
                                        token[7] = "nsubj"
                                        # kakršne v zgodovini še ni bilo
                                        # kakršnih je okrog 70

                                    ### SC2: adjuncted insterted between object and VP ###
                                    elif lemma(token) in ["kakršen"] and form(following(token)) in "na":
                                        token[6] = jos_head(token)
                                        token[7] = "obj"
                                        # kakršnemu na tem turnirju še nismo ...


                                    ### pronoun marked as vez of hoče, oglase marked as obj of videti
                                    elif form(token) in ["katere"] and form(following(token)) in ["oglase"] and not (jos_head(token) ==  jos_head(following(token))):
                                        token[6] = id(following(token))
                                        token[7] = "det"
                                        # katere oglase hoče videti
                                        # I did not correct this one in JOS



                                    ### other, general cases ############################################################
                                    else:
                                        if form(preceding(token)) in [",", "-"]: #if the token preceding the pronoun is a comma
                                            for t in sentence:
                                                if int(id(t)) > int(id(token)):

                                                    if cpostag(t) in ["AUX", "VERB"]:
                                                        token[6] = jos_head(token)
                                                        token[7] = "obj"
                                                        # na navadi, kateri daje eksplicitno dimenzijo
                                                        # o izgredih, kakršne smo lahko videli nazadnje v Kranju
                                                        break

                                                    else:
                                                        if cpostag(t) in ["NOUN"] and jos_head(token) == jos_head(t): #čigar does not have gender in features
                                                            if "Gender" in features(token) and features(token)["Gender"] == features(t)["Gender"] and features(token)["Case"] == features(t)["Case"] and features(token)["Number"] == features(t)["Number"]:
                                                                token[6] = id(t)
                                                                token[7] = "det"
                                                                # imamo večno dilemo, katero puško bi uporabili
                                                                break

                                                            else:
                                                                token[6] = id(t)
                                                                token[7] = "nmod"
                                                                # oboroženi z dleti, katerih sledovi so tu in tam še zdaj vidni
                                                                break

                                        elif cpostag(preceding(token)) in ["NOUN"]:
                                            if jos_head(token) == jos_head(preceding(token)): #JOS solution no. 1, e.g. po vijugah katerega
                                                token[6] = id(preceding(token))
                                                token[7] = "nmod"

                                            elif id(token) == jos_head(preceding(token)): #JOS solution no. 2, e.g. s pomočjo katerih
                                                token[6] = id(preceding(token))
                                                token[7] = "nmod"
                                                sentence[int(id(token))-2][6] = jos_head(token)
                                                sentence[int(id(token))-2][7] = "obl"


######################################## 3 SORTING OBJ AND IOBJ #####################################################

                number_of_objects = collections.defaultdict(list)

                for token in sentence:
                    if deprel(token) in ["obj", "ccomp"]:
                        predicate = head(token)
                        number_of_objects[predicate].append(id(token))

                for predicate in number_of_objects:
                    if len(number_of_objects[predicate]) > 1:
                        for object in number_of_objects[predicate]:
                            if "Case=Dat" in sentence[int(object)-1][5]:
                                sentence[int(object)-1][7] = "iobj"
                                number_of_objects[predicate].remove(object)

                        if len(number_of_objects[predicate]) > 1:
                            if len(number_of_objects[predicate]) == 2: #prosili so me.obj, naj govorim.ccomp z njim; razbremeniti sodišče.obj obravnave.obj
                                if sentence[int(number_of_objects[predicate][0])-1][7] == "obj":
                                    sentence[int(number_of_objects[predicate][0])-1][7] = "iobj" #prvi predmet postane indirektni (če je samostalniški)
                                else:
                                    report.write("ccommp is first in: {}\n".format(sentence_id))
                            else:
                                report.write("A sentence with more than two objects: {}\n".format(sentence_id))


######################################## 4 MOSTLY RELIABLE HEURISTICS FOR FLATNESS #####################################################

                            # Mistakes possible!

                            #label: we know the label and the head
                            #attach_root_label: we know the label and we know it attaches to the root predicate, but identifying the root comes later
                            #attach_POS_label: we know the label and the POS of the node it attaches to, but identifying which one comes later
                            #attach_label: we know the label, but it can attach to different types of head


                for token in sentence:

                #### PART, INTJ  #####

                    ### discourse
                    if cpostag(token) in ["PART", "INTJ"]:
                        if deprel(token) in ["root"]:
                            if preceding(token) == [] or cpostag(preceding(token)) in ["PUNCT"]:
                                if following(token) == [] or cpostag(following(token)) in ["PUNCT"]:
                                    token[7] = "attach_root_discourse"
                                    # če ujet med dve ločili oz. začetek/konec stavka

                                    if preceding(token) and form(preceding(token)) in [","]:
                                        sentence[int(id(token))-2][6] = id(token)
                                        sentence[int(id(token))-2][7] = "punct"

                                    if following(token) and form(following(token)) in [","]:
                                        sentence[int(id(token))][6] = id(token)
                                        sentence[int(id(token))][7] = "punct"
                                        # Ja, vem.; Vem, ha!; ..., seveda, ..."

                            if lemma(token)in ["jooj", "oh", "adijo", "zbogom"]:
                                token[7] = "attach_root_discourse"
                                #Oh Marija"
                                #CHANGED the elif to if

                    ### advmod
                    if cpostag(token) in ["PART"]:
                        if deprel(token) in ["root"]:
                            token[7] = "attach_predicate_advmod"
                            #tega mi verjetno ni treba posebej poudarjati
                            # vsi členki so torej povezani na glagol

                ##### ADV

                    if deprel(token) in ["root"]:
                        if jos_msd(token)[0] in ["R"]:
                            if lemma(token) in ["ali", "mar"]:
                                token[7] = "attach_predicate_advmod"
                                #zanimiv pojav v slovenščini

                            elif lemma(token) in ["skratka"]:
                                if following(token) and cpostag(following(token)) in ["PUNCT"]:
                                    token[7] = "attach_root_advmod"
                                     #lahko pa bi bil tudi discourse, glej nedoslednost v angleščini


                            elif lemma(token) in ["posebej","posebno"]:
                                if preceding(token) and lemma(preceding(token)) in ["še"]:
                                    token[6] = id(preceding(token))
                                    token[7] = "fixed"


                            elif lemma(token) in ["kaj"]:
                                if following(token) and lemma(following(token)) in ["šele"]:
                                    sentence[int(id(token))][6] = id(token)
                                    sentence[int(id(token))][7] = "fixed"
                                    token[7] = "attach_predicate_advmod"
                            else:
                                token[7] = "attach_predicate_advmod"
                                #vsi prislovi pa ne ...

                    #CONJ

                    if deprel(token) in ["root"]:
                        if cpostag(token) in ["CCONJ"]:
                            #group that is always cc
                            if lemma(token) in ["in", "ali", "torej", "vendar", "ter", "temveč", "a", "toda", "sicer",
                                         "oziroma", "ampak", "zato", "razen", "zato", "niti", "marveč", "bodisi",
                                         "tako", "saj", "kajti"]:
                                token[7] = "attach_cc"
                                #always cc, but write rules for head attachment
                                #if the function is not cc, it means that he POS tag is wrong (e.g. CONJ instead of ADV)

                            #group that is always advmod
                            elif lemma(token) in ["vendarle"]:
                                token[7] = "attach_predicate_advmod"
                                #always advmod, but write rules for head attachment
                                #this definitely proves it is more a particle or adverb than a conjunction

                            #group with special cases after a comma or at the beginning of a sentence that need special rules
                            elif lemma(token) in ["pa", "namreč"]:
                                token[7] = "attach_predicate_advmod"
                                #mostly advmod, but write rules for other functions
                                #write rules for head attachment
                                #zelo razmisli, da bi pa + veznike/členke združila v mwe (npr. pa čeprav)

                        elif cpostag(token) in ["SCONJ"]:
                            #group that is always mark
                            if lemma(token) in ["kot", "čeprav", "če", "da", "kakor", "četudi", "ki", "ker",
                                         "kamor", "ko", "kjer"]: #== these are actually all SCONJs with blue
                                token[7] = "attach_predicate_mark"
                                #always mark, but write rules for head attachment

                        elif cpostag(token) in ["ADP"]:
                            if lemma(token) in ["na"] and following(token) and lemma(following(token)) in ["primer", "pr."] and deprel(following(token)) in ["fixed"]: #change the compositional analysis
                                #go through the list of na_primer and think whether it should even be a mwe (for example is not mwe in english),
                                if preceding(token) and following(token) and form(preceding(token)) in [","] and form(following(token)) in [","]: #če je na primer stisnjen med dve vejici
                                    for n in range(int(id(token))+1, no_of_tokens):
                                        if sentence[n][3] in ["VERB"]:
                                            token[6] = sentence[n][0]
                                            token[7] ="nmod"
                                            # In UD v2, na primer remains marked as nmod (group [6])
                                            sentence[int(id(token))-2][6] = sentence[n][0]
                                            sentence[int(id(token))-2][7] = "punct"
                                            break
                                else:
                                    nearest = 10000
                                    nearest_id = 0
                                    for t in sentence:
                                        if cpostag(t) in ["VERB"]:
                                            v_id = id(t)
                                            distance = abs(int(id(token))-int(v_id))
                                            intermediate_tokens = distance - 1
                                            punctuation = 0
                                            first = id(token)
                                            second = v_id
                                            if int(v_id) < int(id(token)):
                                                first = v_id
                                                second = id(token)

                                            for n in range(int(first), int(second)-1):
                                                if sentence[n][1] in [","]:
                                                    punctuation += 1

                                            if not punctuation:
                                                if distance < nearest:
                                                    nearest_id = v_id
                                                    nearest = distance

                                    if nearest_id:
                                        token[6] = nearest_id
                                        token[7] = "nmod"
                                        # In UD v2, na primer remains marked as nmod (group [6])

                                    elif sentence[int(id(token))+1][3] in ["NOUN"]:
                                        token[6] = sentence[int(id(token))+1][0]
                                        token[7] = "nmod"
                                        # In UD v2, na primer remains marked as nmod (group [6])

                                        jos_head_of_next = jos_head(sentence[int(id(token))])

                                        if int(jos_head_of_next):
                                            if sentence[int(jos_head_of_next)-1][3] in ["NOUN"]:
                                                token[6] = sentence[int(head_of_next)-1][0]
                                                token[7] = "nmod"
                                                # In UD v2, na primer remains marked as nmod (group [6])


                            elif lemma(token) in ["brez"] and preceding(token) and lemma(preceding(token)) in ["ali"]:
                                sentence[int(id(token))-2][6] = id(token) #in UDv2, the succeeding coordinated preposition remains the head
                                sentence[int(id(token))-2][7] = "cc" #ali

                                token[6] = sentence[int(id(token))-3][6]
                                token[7] = "conj" #brez
                                #this is an interesting case of elipsis

                            elif not following(token):
                                token[7] = "attach_dep" #sentences that have been cut off, maybe this is not the best label, we'll see

                            else:
                                first_hit = 0
                                for n in range(int(id(token)),no_of_tokens):
                                    if first_hit < 1:
                                        if not sentence[n][1] in ["PUNCT"]: #attach as case to the first token that is not PUNCT == usually holds, very few mistakes
                                            token[6] = sentence[n][0] #this first element to the right that is not PUNCT becomes the head of the ADP
                                            token[7] = "case"
                                            first_hit = 1

                ##### SYM

                        elif cpostag(token) in ["SYM"]:
                            token[7] = "attach_symbol"
                            # write rules for <>% (notebook)
                            # other examples by hand (48)


                 ### NUM-conj #####

                    if cpostag(token) in ["NUM"]:
                        if int(id(token)) < no_of_tokens-1:
                            if following(token) and form(following(token)) in ["-", "/"]:
                                if cpostag(following(following(token))) in ["NUM"] and head(following(following(token))) in ["0"]:
                                    sentence[int(id(token))][6] = id(following(following(token)))
                                    sentence[int(id(token))][7] = "punct"

                                    sentence[int(id(token))+1][6] = id(token)
                                    sentence[int(id(token))+1][7] = "conj"
                                    # v letih 1975-1981

                    if cpostag(token) in ["NUM"]:
                        if deprel(token) in ["root"]:
                            if id(token) in ["1"]:
                                if int(id(token)) < no_of_tokens:
                                    if sentence[int(id(token))][1][0].isupper():
                                       token[7] = "attach_root_dep"
                            elif sentence[int(id(token))-2][3] in ["NUM"]:
                                    token[6] = sentence[int(id(token))-2][0]
                                    token[7] = "flat"
                                    #ex-compount in UDv1 (but no output in released data)


                 ### PROPN-conj #####

                    if cpostag(token) in ["PROPN"]:
                        if int(id(token)) < no_of_tokens-1:
                            if form(following(token)) in ["-", "/"]:
                                if cpostag(following(following(token))) in ["PROPN"] and head(following(following(token))) in ["0"]:
                                    sentence[int(id(token))][6] = id(following(following(token)))
                                    sentence[int(id(token))][7] = "punct"

                                    sentence[int(id(token))+1][6] = id(token)
                                    sentence[int(id(token))+1][7] = "conj"
                                    # VO-KA

                ### connect strings of foreign tokens, e.g. Billy the kid
                    if postag(token) in ["Xf"] and no_of_tokens > 1 and int(id(token)) < no_of_tokens:
                        if deprel(token) in ["root"]:
                            for n in range(int(id(token)), no_of_tokens):
                                if sentence[n][4] in ["Xf"] and sentence[n][7] in ["root"]:
                                    sentence[n][6] = id(token)
                                    sentence[n][7] = "flat:foreign"
                                else:
                                    break
                                    #if sequence of Xf is broken ..., stop checking


                        #### specific rules for Xf exceptions #####
                        #some special cases of JOS constructions with tokens marked as Xf, annotated very inconsistently
                        if int(id(token)) > 1 and deprel(token) in ["root"]:
                            if lemma(preceding(token)) in ["komisija", "časnik", "stopnja", "roman", "uspešnica", "beseda"]:
                                token[6] = id(preceding(token))
                                token[7] = "nmod"
                                #komisije The role of ....

                            elif id(preceding(token)) == head(following(token)):
                                token[6] = id(following(token))
                                token[7] = "nmod"
                                # madame de Berny, film the Life of Brian, v mestu de Doornsu



                 ### X: Y (abbreviations) #####
                # labels for abbreviations should be further revised, as well as their POS labels, see issues

                    if cpostag(token) in ["X"] and no_of_tokens > 1 and int(id(token)) < no_of_tokens:
                        if postag(token) in ["Y"] and deprel(token) in ["root"]:
                            if lemma(token) in ["dr.", "mag.", "prof.", "inž."]:

                                #dr. Janez Novak
                                if int(id(token)) < no_of_nodes and sentence[int(id(token))][3] in ["PROPN", "ADJ"]:
                                    token[6] = sentence[int(id(token))][0]
                                    token[7] = "nmod"
                                    # In UD v2, abbreviations and their inner relations remain marked as nmod (group [8])

                                #dr. med.
                                elif sentence[int(id(token))][2] in ["med.", "dr."]:
                                    sentence[int(id(token))][6] = id(token)
                                    sentence[int(id(token))][7] = "nmod"
                                    # In UD v2, abbreviations and their inner relations remain marked as nmod (group [8])

                                 #Janez Novak, dr. med.
                                    if sentence[int(id(token))-3][3] in ["PROPN"]:
                                        token[7] = "appos"
                                        #comma introducing an apposition
                                        if sentence[int(id(token))-2][3] in ["PUNCT"]:
                                            sentence[int(id(token))-2][6] = id(token)
                                            sentence[int(id(token))-2][7] = "punct"


                                        if sentence[int(id(token))-3][7] in ["flat"]:
                                            token[6] = sentence[int(id(token))-3][6]
                                        else:
                                            token[6] = sentence[int(id(token))-3][0]


                            elif lemma(token) in ["št.", "tč."] and not int(id(token)) == no_of_tokens:
                                if sentence[int(id(token))][3] in ["NUM"]:
                                    sentence[int(id(token))][6] = id(token)
                                    sentence[int(id(token))][7] = "nummod"
                                    # št. 7
                                    if sentence[int(id(token))-2][3] in ["NOUN", "PROPN"]:
                                        token[6] = sentence[int(id(token))-2][0]
                                        token[7] = "nmod"
                                        #uradni list št. 7
                                        # In UD v2, abbreviations and their inner relations remain marked as nmod (group [8])


                            # ust. 1986
                            elif lemma(token) in ["ust.", "prev."]:
                                if sentence[int(id(token))][3] in ["NUM"] and sentence[int(id(token))][6] in "0":
                                    sentence[int(id(token))][6] = id(token)
                                    sentence[int(id(token))][7] = "nummod"


                            # ok. 1986
                            elif lemma(token) in ["ok."]:
                                if sentence[int(id(token))][3] in ["NUM"]:
                                    token[6] = sentence[int(id(token))][0]
                                    token[7] = "advmod"

                            #angl. criss-cross
                            elif lemma(token) in ["it.", "angl."]:
                                if sentence[int(id(token))][3] in ["NOUN", "PROPN", "X"]:
                                    token[6] = sentence[int(id(token))][0]
                                    token[7] = "advmod"

                            #50 odst.
                            elif lemma(token) in ["odst.", "sek."]:
                                if sentence[int(id(token))-2][3] in ["NUM"]:
                                    if jos_head(token) == sentence[int(id(token))-2][0]:
                                        token[6] = sentence[int(id(token))-2][6]
                                        token[7] = sentence[int(id(token))-2][7]
                                        sentence[int(id(token))-2][6] = id(token)
                                        sentence[int(id(token))-2][7] = "nummod"

                            elif lemma(token) in ["gl.", "prim.", "cf."]:
                                if sentence[int(id(token))][3] in ["NOUN"] and sentence[int(id(token))][6] in "0":
                                    token[6] = sentence[int(id(token))][0]
                                    token[7] = "advmod" #unsure about whether they should considered predicates

                            elif lemma(token) in ["str."]:
                                if sentence[int(id(token))-2][3] in ["NUM"]:
                                    sentence[int(id(token))-2][6] = id(token)
                                    sentence[int(id(token))-2][7] = "nummod"
                                    # 1 str.
                                elif sentence[int(id(token))][3] in ["NUM"]:
                                    sentence[int(id(token))][6] = id(token)
                                    sentence[int(id(token))][7] = "nummod"
                                    # str. 1

                            elif lemma(token) in ["npr."]:
                                if sentence[int(id(token))-2][2] in ["kot"]:
                                    token[6] = sentence[int(id(token))-2][0]
                                    token[7] = "fixed"
                                    #kot npr.
                                else:
                                    if sentence[int(id(token))][3] in ["VERB"]:
                                        token[6] = sentence[int(id(token))][0]
                                        token[7] = "advmod"
                                        #npr. povzeli
                                    else:
                                        head_of_next = sentence[int(id(token))][6]
                                        if sentence[int(head_of_next)-1][3] in ["NOUN"]:
                                            token[6] = sentence[int(head_of_next)-1][0]
                                            token[7] = "advmod"
                                            #npr. kmetijska zbornica
                                        else:
                                            token[6] = sentence[int(id(token))][0]
                                            token[7] = "advmod"
                                            #npr. nekaj,

                            elif lemma(token) in ["tj."]:
                                head_of_next = sentence[int(id(token))][6]
                                if sentence[int(head_of_next)-1][3] in ["NOUN"]:
                                    token[6] = sentence[int(head_of_next)-1][0]
                                    token[7] = "advmod"
                                    #npr. kmetijska zbornica
                                else:
                                    token[6] = sentence[int(id(token))][0]
                                    token[7] = "advmod"
                                    #npr. nekaj,


                            elif lemma(token) in ["itd.", "itn.", "ipd."]:
                                if sentence[int(id(token))-2][7] in ["conj"]:
                                    token[6] = sentence[int(id(token))-2][6]
                                    token[7] = "conj"
                                    # mama, oče, sin itd.
                                else:
                                    token[7] = "attach_predicate_advmod"
                                    # sodelovali pri projektih itd,

                            elif lemma(token) in ["oz."]:
                                if cpostag(following(token)) in ["NOUN", "PROPN", "SYM"]:
                                    if cpostag(preceding(token)) in ["NOUN", "PROPN"]:
                                        token[6] = id(following(token))
                                        token[7] = "cc"
                                        sentence[int(id(token))][6] = id(preceding(token))
                                        sentence[int(id(token))][7] = "conj"
                                elif cpostag(following(following(token))) in ["NOUN", "PROPN", "SYM"]:
                                    if cpostag(preceding(token)) in ["NOUN", "PROPN"]:
                                        token[6] = id(following(following(token)))
                                        token[7] = "cc"
                                        sentence[int(id(token))+1][6] = id(preceding(token))
                                        sentence[int(id(token))+1][7] = "conj"
                                else:
                                    first_verb_to_right = 0
                                    for n in range(int(id(token)), no_of_tokens):
                                        if sentence[n][3] in ["VERB", "AUX"]:
                                            first_verb_to_right = sentence[n][0]
                                            break
                                    first_verb_to_left = 0
                                    for n in reversed(range(1,int(id(token))-1)):
                                        if sentence[n][3] in ["VERB", "AUX"]:
                                            first_verb_to_left = sentence[n][0]
                                            break
                                    if first_verb_to_left and first_verb_to_right:
                                        token[6] = first_verb_to_right
                                        token[7] = "cc"
                                        sentence[int(first_verb_to_right)-1][6] = sentence[int(first_verb_to_left)-1][0]
                                        sentence[int(first_verb_to_right)-1][7] = "conj"


                            elif lemma(token) in ["sv.", "spec."]:
                                if sentence[int(id(token))][3] in ["NOUN", "PROPN"]:
                                    token[6] = sentence[int(id(token))][0]
                                    token[7] = "amod"

                            elif lemma(token) in ["pr."]:
                                if sentence[int(id(token))][2] in ["n."]:
                                    if sentence[int(id(token))+1][2] in ["š.", "št."]:
                                        sentence[int(id(token))][6] = id(token)
                                        sentence[int(id(token))][7] = "fixed"
                                        sentence[int(id(token))+1][6] = id(token)
                                        sentence[int(id(token))+1][7] = "fixed"

                                        if sentence[int(id(token))-2][3] in ["NUM", "NOUN"]:
                                            token[6] = sentence[int(id(token))-2][0]
                                            token[7] = "advmod"


                            # t.i. pretvorbena pravila
                            elif lemma(token)in ["t."]:
                                if sentence[int(id(token))][2] in ["i."]:
                                    phrase_beginning = int(id(token))+1
                                    for n in range(phrase_beginning, no_of_tokens):
                                        if sentence[n][3] in ["NOUN", "PROPN", "X"]:
                                            token[6] = sentence[n][0]
                                            token[7] = "amod"
                                if sentence[int(id(token))][2] in ["j."]:
                                    head_of_next = sentence[int(id(token))+1][6]
                                    if sentence[int(head_of_next)-1][3] in ["NOUN"]:
                                        token[6] = head_of_next
                                        token[7] = "advmod"
                                        #npr. kmetijska zbornica
                                    else:
                                        token[6] = sentence[int(id(token)+1)][0]
                                        token[7] = "advmod"
                                        #npr. nekaj,

                            elif lemma(token)in ["k."]:
                                if sentence[int(id(token))][2] in ["g."]:
                                    sentence[int(id(token))][6] = id(token)
                                    sentence[int(id(token))][7] ="fixed"

                                    if sentence[int(id(token))-2][3] in ["PROPN"]:
                                        if sentence[int(id(token))-2][7] in ["flat"]:
                                            token[6] = sentence[int(id(token))-2][6]
                                            token[7] = "amod"

                            elif lemma(token)in ["et."]:
                                if sentence[int(id(token))][2] in ["al."]:
                                    sentence[int(id(token))][6] = id(token)
                                    sentence[int(id(token))][7] ="fixed"

                                    if sentence[int(id(token))-2][3] in ["PROPN"]:
                                        if sentence[int(id(token))-2][7] in ["flat"]:
                                            token[6] = sentence[int(id(token))-2][6]
                                            token[7] = "amod"
                                        else:
                                            token[6] = sentence[int(id(token))][0]
                                            token[7] = "amod"

                            elif lemma(token)in ["d."]:
                                if sentence[int(id(token))][2] in ["o.", "d."]:
                                    if sentence[int(id(token))-2][3][0].isupper():
                                        token[6] = sentence[int(id(token))-2][0]
                                        token[7] = "nmod"
                                        # In UD v2, abbreviations and their inner relations remain marked as nmod (group [8])

                            elif lemma(token)in ["v."]:
                                if sentence[int(id(token))][2] in ["d."]:
                                    for n in range(int(id(token)), no_of_tokens-1):
                                        if sentence[n][3] in ["NOUN"]:
                                            if "Case=Gen" in sentence[n][5]:
                                                token[6] = sentence[n][0]
                                                token[7] = "nmod"
                                                # In UD v2, abbreviations and their inner relations remain marked as nmod (group [8])
                                                break

                            #Georga W. H. Busha, R. Damijan; H. Carnaseius
                            elif lemma(token)[0].isupper() and no_of_tokens > 1 and int(id(token)) < no_of_tokens:
                                if sentence[int(id(token))-2][3] in ["PROPN"]:
                                    token[6] = sentence[int(id(token))-2][0]
                                    token[7] = "flat"
                                elif sentence[int(id(token))][3] in ["PROPN", "X"] and not sentence[int(id(token))][6] == id(token):
                                    token[6] = sentence[int(id(token))][0]
                                    token[7] = "flat"


                 #### NOUN and PROPN ##############

                    ### parataxis (could also be dep?)

                    # Morfolofija: ...; Piran - ....; Ravne na Koroškem: ; Škofja Loka:
                    if deprel(token)in ["root"] and jos_deprel(token) in ["Root"]:
                        if cpostag(token) in ["PROPN", "NOUN"]:

                            following_punctuation = [":", "-"]
                            following_punctuation_id = 0

                            for n in range(int(id(token)), no_of_tokens):
                                if sentence[int(n)][1] in following_punctuation:
                                    following_punctuation_id = sentence[int(n)][0]
                                    break


                            if following_punctuation_id:
                                no_of_nodes = int(following_punctuation_id)-1
                                nodes_as_dependents = 0
                                for n in range(0, int(following_punctuation_id)-1):

                                    if n == int(id(token))-1 or "attach" in sentence[n][7] or 0 < int(sentence[n][6]) < int(following_punctuation_id):
                                        nodes_as_dependents += 1


                                if no_of_nodes == nodes_as_dependents:

                                    token[7] = "attach_root_parataxis" #or maybe just attach it to the first verb on the right, we'll see

                    #NOVA GORICA Včeraj so protestniki ...
                    if deprel(token)in ["root"] and jos_deprel(token) in ["Root"]:
                        if cpostag(token) in ["PROPN", "NOUN"]:
                            if form(token).isupper():
                                following_normalcase_id = 0

                                for n in range(int(id(token)), no_of_tokens):
                                    if not sentence[int(n)][1].isupper():
                                        following_normalcase_id = sentence[int(n)][0]
                                        break

                                if following_normalcase_id:
                                    no_of_nodes = int(following_normalcase_id)-1
                                    nodes_as_dependents = 0
                                    for n in range(0, int(following_normalcase_id)-1):
                                        if n == int(id(token))-1 or "attach" in sentence[n][7] or 0 < int(sentence[n][6]) < int(following_normalcase_id):
                                            nodes_as_dependents += 1

                                    if no_of_nodes == nodes_as_dependents:
                                        token[7] = "attach_root_parataxis" #

                    ### parataxis

                    #Ljubljana, 25.; Slovenj Gradec, 1.
                    if jos_deprel(token) in ["Root"]:
                        if cpostag(token) in ["PROPN"]:
                            if id(token) in ["1", "2"]:
                                if no_of_tokens > 2: #to avoid sentences with only one word
                                    if sentence[int(id(token))][1] in [","]:
                                        if "NumForm=Digit|NumType=Ord" in sentence[int(id(token))+1][5]:
                                            token[7] = "attach_root_parataxis"
                                            sentence[int(id(token))+1][7] = "attach_root_parataxis"
                                            sentence[int(id(token))][7] = "attach_root_punct"


                    ### appos (this should be always in the end)

                    #roke položite na trebuh (središče telesa); but beware, we attach the apposition to the first noun
                    #governing noun on the left, so mistakes are possible, e.g. član slovenske demokratske stranke (SDS) - there is
                    # no way of telling whether the SDS is an apposition of član or stranka, but in most cases it is the first noun

                    if deprel(token)in ["root"] and jos_deprel(token) in ["Root"]:
                        if cpostag(token) in ["PROPN", "NOUN", "X"]: #to limit the appos relation to nominal phrases with the same referential head, we excluded NUM and moved them to "nummod"
                            if id(token) not in ["1", str(no_of_tokens)]:


                                punctuation = [["(",")"], [",",","], ["-","-"], [",", "."]]

                                for pair in punctuation:
                                    first_bracket_on_the_left = 0
                                    first_bracket_on_the_right = 0
                                    for n in reversed(range(1,int(id(token)))): #go to left and find first bracket
                                        if sentence[int(n)-1][1] in pair[0]:
                                            first_bracket_on_the_left = sentence[int(n)-1][0]
                                            break
                                    for n in range(int(id(token)), no_of_tokens): #go to the right and find first bracket
                                        if sentence[int(n)][1] in pair[1]:
                                            first_bracket_on_the_right = sentence[int(n)][0]
                                            break

                                    if first_bracket_on_the_right and first_bracket_on_the_left:
                                        no_of_nodes = int(first_bracket_on_the_right) - int(first_bracket_on_the_left) - 1
                                        nodes_as_dependents = 0
                                        for n in range(int(first_bracket_on_the_left), int(first_bracket_on_the_right)-1):
                                            if n == int(id(token))-1 or int(first_bracket_on_the_left) < int(sentence[n][6]) < int(first_bracket_on_the_right):
                                                nodes_as_dependents += 1

                                        if nodes_as_dependents == no_of_nodes:
                                            for n in reversed(range(1,int(first_bracket_on_the_left)-1)):
                                                if sentence[n][3] in ["PUNCT", "VERB", "AUX", "ADJ"]:
                                                    break
                                                elif sentence[n][3] in ["NOUN", "PROPN", "X", "ADV"]: #to limit the appos relation to nominal phrases with the nominal referential head, we excluded adverbs as heads of appositions nad moved them to "nmod", see below
                                                    appos_found = 0
                                                    if pair in [["(",")"],["-","-"]]: # attach both punctuations to the head of apposition
                                                        sentence[int(first_bracket_on_the_left)-1][6] = token[0]
                                                        sentence[int(first_bracket_on_the_left)-1][7] = "punct"
                                                        sentence[int(first_bracket_on_the_right)-1][6] = token[0]
                                                        sentence[int(first_bracket_on_the_right)-1][7] = "punct"

                                                    else: #only attach the comma introducing the apposition
                                                        sentence[int(first_bracket_on_the_left)-1][6] = token[0]
                                                        sentence[int(first_bracket_on_the_left)-1][7] = "punct"

                                                    # kasneje, v svojih zrelih letih, ...
                                                    if sentence[n][3] in ["ADV"]:
                                                        token[6] = sentence[n][0]
                                                        token[7] = "nmod_appos"
                                                        # In UD v2, this relation remains marked as nmod (group [10])
                                                        appos_found = 1
                                                    else:
                                                        token[7] = "appos"

                                                        head_head = sentence[n][6]

                                                        head_head_feats = 0
                                                        if not "_" in sentence[int(head_head)-1][5]:
                                                            head_head_feats = dict(item.split("=") for item in sentence[int(head_head)-1][5].split("|"))

                                                        if features(token) and head_head_feats:
                                                            if "Case" in features(token) and "Case" in head_head_feats:
                                                                if features(token)["Case"] == head_head_feats["Case"]:
                                                                    token[6] = sentence[n][6]
                                                                    appos_found = 1
                                                                    break

                                                    if not appos_found:
                                                        token[6] = sentence[n][0]
                                                        break

                                                # kasneje, v svojih zrelih letih, ...


                        if cpostag(token) in ["NUM"]: #to limit the appos relation to nominal phrases with the same referential head, we excluded NUM and moved them to "nummod"
                            if id(token) not in ["1", str(no_of_tokens)]:
                                punctuation = [["(",")"], [",",","], ["-","-"], [",", "."]]

                                for pair in punctuation:
                                    first_bracket_on_the_left = 0
                                    first_bracket_on_the_right = 0
                                    for n in reversed(range(1,int(id(token)))): #go to left and find first bracket
                                        if sentence[int(n)-1][1] in pair[0]:
                                            first_bracket_on_the_left = sentence[int(n)-1][0]
                                            break
                                    for n in range(int(id(token)), no_of_tokens): #go to the right and find first bracket
                                        if sentence[int(n)][1] in pair[1]:
                                            first_bracket_on_the_right = sentence[int(n)][0]
                                            break

                                    if first_bracket_on_the_right and first_bracket_on_the_left:
                                        no_of_nodes = int(first_bracket_on_the_right) - int(first_bracket_on_the_left) - 1
                                        nodes_as_dependents = 0
                                        for n in range(int(first_bracket_on_the_left), int(first_bracket_on_the_right)-1):
                                            if n == int(id(token))-1 or int(first_bracket_on_the_left) < int(sentence[n][6]) < int(first_bracket_on_the_right):
                                                nodes_as_dependents += 1

                                        if nodes_as_dependents == no_of_nodes:
                                            for n in reversed(range(1,int(first_bracket_on_the_left)-1)):
                                                if sentence[n][3] in ["PUNCT", "VERB", "AUX", "ADJ"]:
                                                    break
                                                elif sentence[n][3] in ["NOUN", "PROPN", "X"]: #to limit the appos relation to nominal phrases with the nominal referential head, we excluded adverbs as heads of appositions nad moved them to "nmod", see below
                                                    appos_found = 0
                                                    if pair in [["(",")"],["-","-"]]: # attach both punctuations to the head of apposition
                                                        sentence[int(first_bracket_on_the_left)-1][6] = token[0]
                                                        sentence[int(first_bracket_on_the_left)-1][7] = "punct"
                                                        sentence[int(first_bracket_on_the_right)-1][6] = token[0]
                                                        sentence[int(first_bracket_on_the_right)-1][7] = "punct"

                                                    else: #only attach the comma introducing the apposition
                                                        sentence[int(first_bracket_on_the_left)-1][6] = token[0]
                                                        sentence[int(first_bracket_on_the_left)-1][7] = "punct"

                                                    token[7] = "nummod_appos"
                                                    token[6] = sentence[n][0]
                                                    # v petek, 5. 9. 2013; Julia Roberts, 33; po rojstvu (1998)
                                                    # note that these constructions are not consistently annotated accross languages, cf. dep, appos etc.

######################## 5 ATTACHMENT TO NEAREST PREDICATE ###############################################################
                for token in sentence:

                    if "attach_predicate_" in deprel(token):
                        nearest = 10000
                        nearest_id = 0
                        for t in sentence:
                            if t[3] in ["VERB"] and not t[6] == id(token):
                                v_id = t[0]
                                distance = abs(int(id(token))-int(v_id))
                                intermediate_tokens = distance - 1
                                punctuation = 0
                                first = id(token)
                                second = v_id
                                if int(v_id) < int(id(token)):
                                    first = v_id
                                    second = id(token)

                                for n in range(int(first), int(second)-1):
                                    if sentence[n][1] in [","]:
                                        punctuation += 1
                                        break

                                if not punctuation:
                                    if distance < nearest:
                                        nearest_id = v_id
                                        nearest = distance

                        if nearest_id:
                            token[6] = nearest_id
                            token[7] = token[7].replace("attach_predicate_","")


######################## 6 HEURISTICS FOR LONELY VERBS #########################################################################

                potential_verbal_roots = []
                attach = []
                zero = []

                for token in sentence:
                    if deprel(token)in ["root"] and cpostag(token) in ["VERB", "AUX"]:
                        potential_verbal_roots.append(id(token))
                    if "attach" in deprel(token):
                        attach.append(id(token))
                    if head(token) in ["0"]:
                        zero.append(id(token))


                if len(potential_verbal_roots) == 0:
                    for token in sentence:
                        if no_of_tokens > 1:
                            if deprel(token)in ["root"] or "attach" in deprel(token):
                                if not "attach_punct" in deprel(token): #s tem povozimo attach, ki smo ga naredili prej, kar je škoda, ampak zaenkrat naj bo tako za stavke, ki so čudni, kot so eliptični
                                    token[7] = "root_ellipsis"
                        else:
                            token[7] = "root_ellipsis"

                elif len(potential_verbal_roots) == 2:
                    for token in sentence:
                        if cpostag(token) in ["CCONJ"] and jos_deprel(token) in ["Conj"]:
                            if jos_head(token) == potential_verbal_roots[0]:
                                for t in reversed(range(0,int(id(token))-1)):
                                    if sentence[t][3] in ["VERB"]:
                                        sentence[int(potential_verbal_roots[0])-1][6] = sentence[t][0]
                                        sentence[int(potential_verbal_roots[0])-1][7] = "conj"
                                        token[6] = sentence[int(potential_verbal_roots[0])-1][0]
                                        token[7] = "cc" #UDv2 ok
                                        break
                                    elif sentence[t][3] in [","]:
                                        break
                            elif jos_head(token) == potential_verbal_roots[1]:
                                for t in reversed(range(0,int(id(token))-1)):
                                    if sentence[t][3] in ["VERB"]:
                                        sentence[int(potential_verbal_roots[1])-1][6] = sentence[t][0]
                                        sentence[int(potential_verbal_roots[1])-1][7] = "conj"
                                        token[6] = sentence[int(potential_verbal_roots[1])-1][0]
                                        token[7] = "cc" #UDv2 ok
                                        break
                                    elif sentence[t][3] in [","]:
                                        break


                elif len(potential_verbal_roots) > 2:
                    if len(zero) == len(potential_verbal_roots) + len(attach):
                        for token in sentence:
                            if id(token) in potential_verbal_roots:
                                for t in sentence:
                                    if jos_head(t) == id(token):
                                        if jos_deprel(t) in ["Conj"] and cpostag(t) in ["CCONJ"]:
                                            for n in reversed(range(0,int(id(t))-1)):
                                                if sentence[n][3] in ["VERB"]:
                                                    token[6] = sentence[n][0]
                                                    token[7] = "conj"
                                                    #CHANGED FROM t[6] = sentence[n][0] to t[6] = id(token)
                                                    sentence[int(id(t))-1][6] = id(token) #and the conjunction also becomes dependent on this first verb on the left #changed in v29
                                                    break
                                                elif sentence[n][3] in ["PUNCT"]: #don't continue if there is a comma in between
                                                    break

                potential_verbal_roots = []

                for token in sentence:
                    if deprel(token)in ["root"] and cpostag(token) in ["VERB", "AUX"]:
                        potential_verbal_roots.append(id(token))


                if len(potential_verbal_roots) == 2: #if length is still two, then apply parataxis
                    for token in sentence:
                        if id(token) == potential_verbal_roots[0]:
                            if token[7] in ["root"]: #if the second verb has not been annotated as coord withing previous condition
                                for t in sentence:
                                    if t[2] in ["kot"] and t[3] in ["SCONJ"] and t[6] == id(token) and t[7] in ["mark"]:
                                        token[6] = potential_verbal_roots[1]
                                        token[7] = "advcl" #or parataxis?
                                        break
                                        #Kot je povedal x, nananana
                                if token[7] in ["root"]:
                                    sentence[int(potential_verbal_roots[1])-1][6] = potential_verbal_roots[0]
                                    sentence[int(potential_verbal_roots[1])-1][7] = "parataxis" # to be evolved further



################################### 7 HEURISTICS FOR ROOT IDENTIFICATION ####################################################

# count how many verbal unknowns are left: if 1, it is the root; if 2, see if you can write some rules to connect them as
                    # coordination, parataxis, anything else; if more than 2, we'll just have to have a look

                number_of_potential_roots = 0
                for token in sentence:
                    if deprel(token)== "root":
                        if jos_deprel(token) == "Root":
                            number_of_potential_roots += 1
                            token[7] = "unknown"
                        else:
                            number_of_potential_roots += 1
                            token[7] = "unknown"
                            report.write("ex-{} in {}".format(jos_deprel(token), sentence_id))
                            # this signals that we have overlooked something in the automatic conversion

                if number_of_potential_roots == 1:
                    for token in sentence:
                        if head(token) == "0" and deprel(token)in ["unknown"]:
                            token[7] = "root_true" #this is the only remaining root which will be used to signal the head predicate
                            for t in sentence:
                                if "attach_root" in deprel(t): #so all other nodes that are supposed to attach to the head, now have a HEAD
                                    sentence[int(id(t))-1][6] = id(token) #changed in v29
                                    sentence[int(id(t))-1][7] = t[7].replace("attach_root_","") #changed in v29


################################### 8 HEURISTICS FOR PUNCTUATION ATTACHMENT ####################################################


                number_of_roots = []
                number_of_ellipsis = []
                number_of_punct = []
                number_of_comma = []

                for token in sentence:
                    if token[7] in ["root_true"]:
                        number_of_roots.append(token[0])
                    elif token[7] in ["root_ellipsis"]:
                        number_of_ellipsis.append(token[0])
                    if token[7] in ["attach_punct"] and token[1] in [","]:
                        number_of_comma.append(token[0])
                    if token[7] in ["attach_punct"]:
                        number_of_punct.append(token[0])

                if number_of_comma:
                    for comma in number_of_comma:
                        if int(comma) < no_of_tokens:
                            if sentence[int(comma)][7] in "fixed":
                                sentence[int(comma)-1][6] = sentence[int(comma)][6]
                                sentence[int(comma)-1][7] = "punct"
                                number_of_comma.remove(comma)


                #if a sentence beginns with a lonely symbol, attach it too root (segmentation problems)
                if number_of_roots and number_of_punct:
                    if number_of_punct[0] == "1" and not sentence[int(number_of_punct[0])-1][1] in ['"','(', '“', '»']:
                        sentence[int(number_of_punct[0])-1][6] = sentence[int(number_of_roots[0])-1][0]
                        sentence[int(number_of_punct[0])-1][7] = "punct"


                #always attach the last punctuation to the predicate or the elliptical root
                if number_of_roots and number_of_punct:
                    if int(number_of_punct[-1]) == no_of_tokens:
                        sentence[int(number_of_punct[-1])-1][6] = sentence[int(number_of_roots[0])-1][0]
                        sentence[int(number_of_punct[-1])-1][7] = "punct"

                        if len(number_of_punct) > 1:
                            if int(number_of_punct[-2]) == no_of_tokens - 1:
                                if not sentence[int(number_of_punct[-2])][1] in ['"', '«', ")", '”', '<']:
                                    sentence[int(number_of_punct[-2])-1][6] = sentence[int(number_of_roots[0])-1][0]
                                    sentence[int(number_of_punct[-2])-1][7] = "punct"
                                    if len(number_of_punct) > 2:
                                        if not sentence[int(number_of_punct[-3])][1] in ['"', '«', ")", '”', '<']:
                                            sentence[int(number_of_punct[-3])-1][6] = sentence[int(number_of_roots[0])-1][0]
                                            sentence[int(number_of_punct[-3])-1][7] = "punct"


                elif len(number_of_ellipsis) == 1 and number_of_punct:
                    if int(number_of_punct[-1]) == no_of_tokens:
                        sentence[int(number_of_punct[-1])-1][6] = sentence[int(number_of_ellipsis[0])-1][0]
                        sentence[int(number_of_punct[-1])-1][7] = "punct"


                # brackets and quotes are attached to the head of the construction they surround
                for punctuation in number_of_punct:
                    for pair in [['-','-'], ['(', ')'], ['"', '"'], ['»','«'], ['>','<'], ['“', '”']]:
                        first = 0
                        next = 0
                        if sentence[int(punctuation)-1][1] in pair[0]:
                            first = punctuation
                            first_index = number_of_punct.index(punctuation)
                            next_index = first_index + 1
                            for next_punctuation in number_of_punct[next_index:]:
                                if sentence[int(next_punctuation)-1][1] in pair[1]:
                                    next = next_punctuation
                                    break
                            potential_heads = []

                            if first and next:
                                for node in range(int(first), int(next)-1):
                                    if not int(first) < int(sentence[node][6]) < int(next) and not "_punct" in sentence[node][7]: #if head of the node is not inside the bracket
                                        potential_heads.append(sentence[node][0])

                                if len(potential_heads) == 1:
                                    sentence[int(first)-1][6] = potential_heads[0]
                                    sentence[int(first)-1][7] = "punct"
                                    sentence[int(next)-1][6] = potential_heads[0]
                                    sentence[int(next)-1][7] = "punct"

                # then come the subordinate clauses if right of their head (left comma attachment)
                if number_of_roots and number_of_comma:
                    #we only deal with complete sentences
                    for comma in number_of_comma:
                        clause_head = 0
                        if int(comma) < no_of_tokens:
                            if sentence[int(comma)][7] in ["mark"]: #..., ki ...
                                clause_head = sentence[int(comma)][6]
                            elif "Conj" in sentence[int(comma)][9] and not sentence[int(comma)][3] in ["CCONJ"]: #..., katera
                                #clause_head = sentence[int(comma)][6] #POZOR
                                clause_head = jos_head(sentence[int(comma)])
                            elif int(comma)+1 < no_of_tokens:
                                if "Conj" in sentence[int(comma)+1][9] and not sentence[int(comma)+1][3] in ["CCONJ"]: # ..., brez katerih ...
                                    clause_head = sentence[int(comma)+1][6]
                            if clause_head:
                                if sentence[int(clause_head)-1][3] in ["VERB"]:
                                    sentence[int(comma)-1][6] = clause_head
                                    sentence[int(comma)-1][7] = "punct"
                                    #number_of_comma.remove(comma)
                                    for p in range(int(clause_head), no_of_tokens-1):
                                        if sentence[p][0] in number_of_comma:
                                            sentence[p][6] = clause_head
                                            sentence[p][7] = "punct"
                                            break


                                        #number_of_comma.remove(sentence[p][0])

                number_of_comma = []
                number_of_punct = []

                for token in sentence:
                    if token[7] in ["attach_punct"] and token[1] in [","]:
                        number_of_comma.append(token[0])
                    if token[7] in ["attach_punct"]:
                        number_of_punct.append(token[0])

                # subordinate clauses with head on right and right oppositions
                if number_of_roots and number_of_comma:
                    for comma in number_of_comma:
                        for node in reversed(range(0,int(comma)-1)):
                            if sentence[node][7] in ["ccomp", "acl", "advcl", "csubj"]:
                                if int(sentence[node][6]) > int(comma):
                                    sentence[int(comma)-1][6] = sentence[node][0]
                                    sentence[int(comma)-1][7] = "punct"
                                    break
                            elif sentence[node][7] in ["appos"]:
                                sentence[int(comma)-1][6] = sentence[node][0]
                                sentence[int(comma)-1][7] = "punct"
                                break

                            elif sentence[node][7] in ["nmod_appos", "nummod_appos"]:
                                sentence[int(comma)-1][6] = sentence[node][0]
                                sentence[int(comma)-1][7] = "punct"
                                break

                number_of_comma = []
                number_of_punct = []

                for token in sentence:

                    if "_appos" in token[7]:
                        token[7] = token[7].replace("_appos","") #just getting rid of the previous helping label
                    if token[7] in ["attach_punct"] and token[1] in [","]:
                        number_of_comma.append(token[0])
                    if token[7] in ["attach_punct"]:
                        number_of_punct.append(token[0])

                #### coordinate clause conjunction
                # odstranila pogoj, da mora biti dolžina 1

                for punctuation in number_of_punct:
                    if sentence[int(punctuation)-1][1] in [",",":","-",";"]:
                        found = 0
                        for node in range(int(punctuation),no_of_tokens-1):
                            if sentence[node][7] in ["parataxis"]:
                                if int(sentence[node][6]) < int(punctuation):
                                    sentence[int(punctuation)-1][6] = sentence[node][0]
                                    sentence[int(punctuation)-1][7] = "punct"
                                    found = 1
                                    break
                            if sentence[node][7] in ["conj"]:
                                if int(sentence[node][6]) < int(punctuation):
                                    sentence[int(punctuation)-1][6] = sentence[node][0]
                                    sentence[int(punctuation)-1][7] = "punct"
                                    found = 1
                                    break

                        if not found:
                            for node in reversed(range(0, int(punctuation)-1)):
                                if sentence[node][7] in ["parataxis"]:
                                    if int(sentence[node][6]) > int(punctuation):
                                        sentence[int(punctuation)-1][6] = sentence[node][0]
                                        sentence[int(punctuation)-1][7] = "punct"
                                        break

                number_of_punct = []

                for token in sentence:
                    if token[7] in ["attach_punct"]:
                        number_of_punct.append(token[0])



                ### lonely riders: attach to nearest predicate
                if len(number_of_punct) == 1:
                    for punctuation in number_of_punct:
                        if sentence[int(punctuation)-1][1] in ['-','(',')','"','»','«','>','<','“','!','”']:
                            if number_of_roots:
                                nearest = 10000
                                nearest_id = 0
                                for t in sentence:
                                    if t[3] in ["VERB"] and not t[6] == punctuation:
                                        v_id = t[0]
                                        distance = abs(int(punctuation)-int(v_id))
                                        intermediate_tokens = distance - 1
                                        first = punctuation
                                        second = v_id
                                        if int(v_id) < int(punctuation):
                                            first = v_id
                                            second = punctuation

                                        # mogoče dodaj še pogoj, da ne sme biti drugih ločil vmes (glej attach_predicatE)
                                        if distance < nearest:
                                            nearest_id = v_id
                                            nearest = distance

                                if nearest_id:
                                    sentence[int(punctuation)-1][6] = nearest_id
                                    sentence[int(punctuation)-1][7] = "punct"

                            elif number_of_ellipsis == 1:
                                sentence[int(punctuation)-1][6] = sentence[int(number_of_ellipsis[0])-1][0]
                                sentence[int(punctuation)-1][7] = "punct"





###################################### 9 CHANGE HEAD IN COPULA AND OTHER CONSTRUCTIONS ##############################################

                ### 3 cop-2, change head for all dependents of the copula verb
                ### + (UDv2) change CPOSTAG for copula (VERB --> AUX)
                for token in sentence:
                    if deprel(token)in ["copx"]:
                        for t in sentence:
                            if id(t) == head(token): #change head of the copula verb to nominal predicate
                                copulas_head = head(t)
                                copulas_deprel = deprel(t)
                                sentence[int(jos_head(token))-1][6] = id(token)
                                sentence[int(jos_head(token))-1][7] = "cop"

                                old_POS = sentence[int(jos_head(token))-1][3]
                                sentence[int(jos_head(token))-1][3] = "AUX"
                                morpho_changes.write("Change of POS for sentence {}, token {}, from {} to {}\n". format(sentence_id, id(token), old_POS, sentence[int(jos_head(token))-1][3]))

                            elif head(t) == jos_head(token) and not deprel(t) in ["copx"]:
                                    sentence[int(id(t))-1][6] = id(token)
                                    #dependents of biti now become dependends of the predicative (copx)

                        token[6] = copulas_head
                        token[7] = copulas_deprel


                ########## LESS IMPORTANT ########################################
                ### for combinations with numerals, marked as flat in UDv2 (e.g. dva tisoč), the first element becomes the head and inherits info of its dependent
                # e.g. 1: 11. <-- flatx -- 5. -- flatx --> 2016 should go to 11 --flat--> 5. and 11. --flat--> 2016
                # e.g. 2: dva <--flatx-- tisoč should go to dva --flat--> tisoč
                for token in sentence:
                    if deprel(token) in ["flatx"]:
                        for t in sentence:
                            if id(t) > id(token) and id(t) == head(token): #e.g. 11. <-- flatx -- 5., i.e. THE LARGE MAJORITY
                                flatx_head = head(t)
                                flatx_deprel = deprel(t)
                                sentence[int(head(token))-1][6] = id(token) #the head of flatx now becomes the dependent
                                sentence[int(head(token))-1][7] = "flat" #and is renamed from flat to flatx

                                token[6] = flatx_head
                                token[7] = flatx_deprel
                                break

                            elif id(t) < id(token) and id(t) == head(token): #e.g. 5. -- flatx --> 2016, i.e. A FEW EXCEPTIONS
                                if sentence[int(head(token))-1][7] in ["flat"]: #if the head is already marked as flat due to previous rule
                                    token[6] = sentence[int(head(token))-1][6] #the second flatx gets the same head, ie. the first element in a string
                                    token[7] = "flat"

                # one more iteration over sentence if several flatx; ugly solution, but it works
                for token in sentence:
                    if deprel(token) in ["flatx"]:
                        for t in sentence:
                            if id(t) > id(token) and id(t) == head(token): #e.g. 11. <-- flatx -- 5., i.e. THE LARGE MAJORITY
                                flatx_head = head(t)
                                flatx_deprel = deprel(t)
                                sentence[int(head(token))-1][6] = id(token) #the head of flatx now becomes the dependent
                                sentence[int(head(token))-1][7] = "flat" #and is renamed from flat to flatx

                                token[6] = flatx_head
                                token[7] = flatx_deprel
                                break

                            elif id(t) < id(token) and id(t) == head(token): #e.g. 5. -- flatx --> 2016, i.e. A FEW EXCEPTIONS
                                if sentence[int(head(token))-1][7] in ["flat"]: #if the head is already marked as flat due to previous rule
                                    token[6] = sentence[int(head(token))-1][6] #the second flatx gets the same head, ie. the first element in a string
                                    token[7] = "flat"

                                # some exceptions below
                                elif lemma(token) in ["en"] and lemma(sentence[int(head(token))-1]) in ["en"]:
                                    token[7] = "nmod"
                                    #eno po eno, ena na ena
                                elif lemma(token) in ["000"]:
                                    token[7] = "flat"
                                elif lemma(token) in ["285"]:
                                    token[6] = "11"
                                    token[7] = "nummod"
                                    #tisoč
                                    sentence[9][6] = "9"
                                    sentence[9][7] = "flat"

                                    #I DO NOT KNOW WHY THIS IS NOT CAPTURED BY THE FIRST flatx RULE, LIKE ALL OTHER COMBINATIONS OF X TISOČ

######################################### 9.1 CORRECT INCONSISTENCIES FOUND IN DATA VALIDATION #####################
# all corrections should preferably be done on the individual deprel rule, if possible, otherwise here

                for token in sentence:
                    #ERROR TYPE: name should be right-headed (correct "P. < Habič" to "P. > Habič")
                    if deprel(token) in ["flat"]:
                        if int(head(token)) > int(id(token)):
                            for t in sentence:
                                if id(t) == head(token):
                                    second_names_head = head(t)
                                    second_names_deprel = deprel(t)
                                    sentence[int(head(token))-1][6] = id(token)
                                    sentence[int(head(token))-1][7] = "flat"
                            token[6] = second_names_head
                            token[7] = second_names_deprel


                    #ERROR TYPE: Apposition dependencies should not be chained.
                    # Either all depend on the first one, or there is coordination of dependents.
                    if deprel(token) in ["appos"]:
                        if sentence[int(head(token))-1][7] in ["appos"]:
                            token[6] = sentence[int(head(token))-1][6]
                            #as an ad-hoc solution, we attach all as dependents on the first in the string of two


                    #ERROR TYPE: maximum one subject. No predicate can have more than one subject.
                    if jos_deprel(token) in ["Conj"] and deprel(token) in ["nsubj"] and form(sentence[int(id(token))]) in ["vse", "drug"] and deprel(sentence[int(id(token))]) in ["nsubj"]:
                        sentence[int(id(token))][6] = id(token)
                        sentence[int(id(token))][7] = "obl"
                        # kaj vse, kdo vse, kar vse, kdo drug ... = temporary solution to avoid double nsubj
                        # NEW! In UD v2, nmods modifying a verb become obl (group [9])

                    if jos_deprel(token) in ["Sb"] and deprel(token) in ["csubj"] and form(token) in ["pričakujejo"]:
                        token[7] = "xcomp"
                        # želijo tistega, kar se jim zdi, da od življenja lahko pričakujejo ... = temporary solution to avoid double nsubj

                    if jos_deprel(token) in ["Conj"] and deprel(token) in ["nsubj"] and form(token) in ["kakšne"] and id(token) in ["13"]:
                        token[6] = "14"
                        token[7] = "det"
                        # želijo tistega, kar se jim zdi, da od življenja lahko pričakujejo ... = temporary solution to avoid double nsubj


                    # ERROR TYPE: maximum obe object. No predicate can have more than one direct object.
                    # treated as a one-off solution to preserve the overall number of converted sentences
                    if sentence_id in ["ssj287.1760.6252"] and form(token) in ["dišijo"]:
                        token[6] = "7"
                        token[7] = "conj" #asyndetic coordination

                    #### two format validation errors before UD release 2.2
                    # ERROR TYPE: flat:name should be right-headed.
                    if deprel(token) in ["flat:name"] and int(id(token)) < int(head(token)):
                        if lemma(token) in ["Sankt"]: #sent_id=ssj76.493.1844
                            token[6] = "20"
                            token[7] = "conj"
                            # Peterburg
                            sentence[int(id(token))][6] = "22"
                            sentence[int(id(token))][7] = "flat:name"
                            # in
                            sentence[int(id(token))-2][6] = "22"


                        if lemma(token) in ["John"]: #sent_id=ssj193.1268.4587
                            token[6] = "7"
                            token[7] = "obl"
                            # Sampsonom
                            sentence[int(id(token))][6] = "2"
                            sentence[int(id(token))][7] = "flat:name"
                            # z
                            sentence[int(id(token))-2][6] = "2"


########################### 9.2. CHANGE JOS LOGIC FOR SPECIAL CONSTRUCTIONS ##############################################################################

                    ##### find constructions eden izmed njih where the pronominal word (eden) becomes the head (neustrezno v JOS)
                    if jos_msd(token)[0] in ["P", "M", "A"]:
                        if jos_msd(sentence[int(head(token))-1])[0] in ["N", "P"]:

                            if features(sentence[int(head(token))-1])["Case"] in ["Gen"]:
                                if int(id(token)) < no_of_tokens:
                                    if lemma(following(token)) in ["od", "izmed"] and features(following(token))["Case"] in ["Gen"]:

                                        old_head_id = id(sentence[int(head(token))-1])
                                        old_head_head = head(sentence[int(head(token))-1])
                                        old_head_deprel = deprel(sentence[int(head(token))-1])


                                        token[6] = old_head_head
                                        token[7] = old_head_deprel

                                        sentence[int(old_head_id)-1][6] = id(token)
                                        sentence[int(old_head_id)-1][7] = "nmod"

                                        for t in sentence: #
                                            if head(t) == old_head_id and cpostag(t) in ["ADP"] and int(id(t)) < int(id(token)):
                                                sentence[int(id(t))-1][6] = id(token)
                                                # v eno izmed vrst


                    ########## "več kot x" constructions (neustrezno v JOS)
                    if lemma(token) in ["več"] and lemma(following(token)) in ["kot"] and deprel(following(token)) in ["fixed"]:
                        if cpostag(following(token)) in ["NUM"]:
                            token[6] = id(following(token))
                            token[7] = "advmod"
                        else:
                            token[7] = "advmod"

                            #več kot sto ljudi; in UD, the več-kot modifies



################################## 10 WRITE TO FILES ######################################################################

                sentences[sentence_id] = [0,0,0,0,0,0,0,0,0,0] #0:tokens, 1:non-punct-tokens, 2:zeros, 3:root_true, 4:root_ellipsis, 5:attach, 6:unknown
                                                 #7:attach_punct, 8:attach_other, 9:unknown_verb
                sentences[sentence_id][0] = len(sentence)

                for token in sentence:

                    output.write("{}".format("\t".join(token)))

                    if not token[3] in ["PUNCT"]:
                        sentences[sentence_id][1] += 1
                    if token[6] in ["0"]:
                        sentences[sentence_id][2] += 1
                    if token[7] in ["root_true"]:
                        sentences[sentence_id][3] += 1
                    if token[7] in ["root_ellipsis"]:
                        sentences[sentence_id][4] += 1
                    if "attach" in token[7]:
                        sentences[sentence_id][5] += 1
                        if token[7] in ["attach_punct"]:
                            sentences[sentence_id][7] += 1
                        else:
                            sentences[sentence_id][8] += 1
                    if token[7] in ["unknown"]:
                        sentences[sentence_id][6] += 1
                        if token[3] in ["VERB"]:
                            sentences[sentence_id][9] += 1


                tokens = sentences[sentence_id][0]
                zeros = sentences[sentence_id][2]
                root_true = sentences[sentence_id][3]
                root_ellipsis = sentences[sentence_id][4]
                attach = sentences[sentence_id][5]
                unknown = sentences[sentence_id][6]
                attach_punct = sentences[sentence_id][7]
                attach_other = sentences[sentence_id][8]
                unknown_VERB = sentences[sentence_id][9]

                overall[0] += 1
                overall[1] += tokens


                if zeros >= 1:
                    if unknown == 0:
                        if root_true == 1:
                            if root_true == zeros:
                                p1_group[0]  += 1
                                p1_group[1] += tokens
                                release.write("{}{}".format(sentence_comment_line, text_comment_line))
                                released_sentences.append(sentence_id)
                                for token in sentence:
                                    if token[7] in ["root_true"]:
                                        token[7] = token[7].replace("_true","")
                                    release.write("{}".format("\t".join(token)))
                                release.write("\n")
                            elif root_true + attach_punct == zeros:
                                p2_group[0]  += 1
                                p2_group[1] += tokens
                            elif root_true + attach_punct + attach_other == zeros:
                                p3_group[0] += 1
                                p3_group[1] += tokens
                            else:
                                report.write("Too many zeros in: {}\n".format(sentence_id))
                        elif root_ellipsis == 1:
                            if root_ellipsis == zeros:
                                e1_group[0]  += 1
                                e1_group[1] += tokens
                                release.write("{}{}".format(sentence_comment_line, text_comment_line))
                                released_sentences.append(sentence_id)
                                for token in sentence:
                                    if token[7] in ["root_ellipsis"]:
                                        token[7] = token[7].replace("_ellipsis","")
                                    release.write("{}".format("\t".join(token)))
                                release.write("\n")
                            elif root_ellipsis + attach_punct == zeros:
                                e2_group[0]  += 1
                                e2_group[1] += tokens
                            elif root_true + attach_punct + attach_other == zeros:
                                e3_group[0] += 1
                                e3_group[1] += tokens
                            else:
                                report.write("Too many zeros in: {}\n".format(sentence_id))
                        elif root_ellipsis > 1:
                            e3_group[0] += 1
                            e3_group[1] += tokens
                    else:
                        if unknown == unknown_VERB:
                            if unknown + attach_punct == zeros:
                                u1_group[0]  += 1
                                u1_group[1] += tokens
                            elif unknown + attach_punct + attach_other == zeros:
                                u2_group[0]  += 1
                                u2_group[1] += tokens
                            else:
                                report.write("Too many zeros in: {}\n".format(sentence_id))
                        else:
                            u3_group[0] += 1
                            u3_group[1] += tokens

                else:
                    report.write("We don't have a zero in: {}\n".format(sentence_id))

                print("Finished with sentence", sentence_id)
                output.write(line)
                sentence_open = False #close the sentence


        if not sentence_open:
            sentence = []
            if line.startswith("#"):
                sentence_id = line.split("=")[1].strip("\n")
                output.write(line)
                sentence_open = True

    released_tokens = p1_group[1] + e1_group[1]
    print("Released: ", len(released_sentences), "sentences", released_tokens, "tokens")
    print("Writing to report ...")
    report.write("p1 group:{}\t{}\n".format(p1_group[0], p1_group[1]))
    report.write("p2 group:{}\t{}\n".format(p2_group[0], p2_group[1]))
    report.write("p3 group:{}\t{}\n".format(p3_group[0], p3_group[1]))
    report.write("e1 group:{}\t{}\n".format(e1_group[0], e1_group[1]))
    report.write("e2 group:{}\t{}\n".format(e2_group[0], e2_group[1]))
    report.write("e3 group:{}\t{}\n".format(e3_group[0], e3_group[1]))
    report.write("u1 group:{}\t{}\n".format(u1_group[0], u1_group[1]))
    report.write("u2 group:{}\t{}\n".format(u2_group[0], u2_group[1]))
    report.write("u3 group:{}\t{}\n".format(u3_group[0], u3_group[1]))
    report.write("TOTAL:{}\t{}\n".format(overall[0], overall[1]))

    report.write("{}\n".format("\t".join(["sentence_id", "all_tokens", "non_punct_tokens", "zeros", "root_true", "root_ellipsis",
                                    "attach", "unknown", "attach_punct", "attach_other", "unknown_verb"])))

    for sentence_id in sentences:
        report.write("{}\t{}\n".format(sentence_id, "\t".join(str(count) for count in sentences[sentence_id])))

    print("Splitting into train-dev-test ...")
    release.close()
    output.close()


    with open("release-all_{}_{}.conllu".format(treebank_name, version_name), "r", encoding="utf8") as file:
        data = file.read()
        split_data = data.split("\n\n")
        if '' in split_data:
            split_data.remove('')
        train = open("sl_ssj-ud-train.conllu", "w", encoding="utf8", newline='')
        dev = open("sl_ssj-ud-dev.conllu", "w", encoding="utf8", newline='')
        test = open("sl_ssj-ud-test.conllu", "w", encoding="utf8", newline='')

        training = [0,0] # 80%
        development = [0,0] # 10%
        testing = [0,0] # 10%
        tokens = 0

        included = []
        for sentence in split_data:
            split_sentence = sentence.split("\n")
            if '' in split_sentence:
                split_sentence.remove('')
            s_tokens = len(split_sentence) - 2 #two comment lines in UD2
            tokens += s_tokens

            if tokens / released_tokens < 0.8:
                train.write("{}\n\n".format(sentence))
                training[0] += 1
                training[1] += s_tokens
            elif tokens / released_tokens < 0.9:
                dev.write("{}\n\n".format(sentence))
                development[0] += 1
                development[1] += s_tokens
            else:
                test.write("{}\n\n".format(sentence))
                testing[0] += 1
                testing[1] += s_tokens

            for sentence_id in released_sentences:
                if sentence_id in split_sentence[0]:
                    included.append(sentence_id)

        for sentence_id in released_sentences:
            if sentence_id not in included:
                print(sentence_id)

        report.write("sentences: {}, tokens: {}\ntrain: {}, dev: {}, test: {}".format(len(released_sentences), released_tokens, training, development, testing))
        report.close()

        print(training, development, testing)

