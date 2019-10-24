#!/usr/bin/python3
# -*- coding: utf-8 -*-
import sys
import os
import re
import collections

# JOS: Linguistic Annotation in Slovene Scheme (original)
# UD: Universal Dependencies Scheme (new)

treebank_path = sys.argv[1] #input treebank in conllu (typically sl_ssj-ud.conllu and similar)
treebank_file = os.path.basename(treebank_path)
treebank_name = os.path.splitext(treebank_file)[0]

version_name = sys.argv[2]

output = open("manually-corrected_{}_{}.conllu".format(treebank_name, version_name), "w", newline='\n', encoding="utf8")


with open(treebank_path, "r", encoding="utf8") as file:

    sentences = file.read()
    for sentence in sentences.split('\n\n'):
        if sentence:
            sentence_id = re.search("# sent_id = (.*)", sentence.split('\n')[0]).group(1)

            if sentence_id == "ssj6.32.114":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "19":
                        token[6] = "15"

                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj9.40.191":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "23":
                        token[6] = "19"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj10.41.193":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "15"
                    if token[0] == "17":
                        token[6] = "15"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj18.75.289":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "25":
                        token[6] = "4"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj27.143.581":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "16":
                        token[6] = "17"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj29.178.714":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "17"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj30.185.747":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "19":
                        token[6] = "20"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj36.213.874":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "16": #napaka v jos jug-dol
                        token[6] = "9"
                    if token[0] == "26": #napačno pravilo?
                        token[6] = "3"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj37.217.893":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "23":
                        token[6] = "27"
                    if token[0] == "27":
                        token[7] = "conj"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj38.225.908":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "19":
                        token[6] = "13"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj42.257.1026":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "13":
                        token[6] = "9"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj59.361.1457":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "5":
                        token[6] = "7"
                    if token[0] == "8":
                        token[6] = "7"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj59.365.1470":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "31":
                        token[6] = "34"
                    if token[0] == "46":
                        token[6] = "34"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj61.369.1478":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "17"
                    if token[0] == "26":
                        token[6] = "17"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj61.373.1494":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "15"
                    if token[0] == "12":
                        token[6] = "15"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")


            elif sentence_id == "ssj69.431.1644":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "30":
                        token[6] = "32"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj69.434.1657":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "19"
                    if token[0] == "19":
                        token[7] = "conj"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")


            elif sentence_id == "ssj69.437.1668":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "22":
                        token[6] = "13"
                        token[7] = "parataxis"
                    if token[0] == "28":
                        token[6] = "0"
                        token[7] = "root"
                    if token[0] == "36":
                        token[6] = "28"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")


            elif sentence_id == "ssj70.440.1682":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "8":
                        token[6] = "9"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj76.495.1853":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "12":
                        token[6] = "14"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj78.510.1923":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "24":
                        token[6] = "27"
                    if token[0] == "27":
                        token[6] = "14"
                    if token[0] == "28":
                        token[6] = "27"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj79.516.1946":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "1":
                        token[6] = "16"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj80.521.1969":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "4":
                        token[6] = "1"
                    if token[0] == "3":
                        token[6] = "4"
                    if token[0] == "11":
                        token[6] = "4"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj82.539.2056":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "9":
                        token[6] = "22"
                        token[7] = "advcl"
                    if token[0] == "22":
                        token[7] = "csubj"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj82.542.2064":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "17"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj82.543.2067":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "13":
                        token[6] = "18"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj88.585.2205":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "23":
                        token[6] = "21"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj90.596.2252":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "13":
                        token[6] = "14"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj100.642.2468":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "11":
                        token[6] = "10"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj102.654.2497":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "25"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj110.691.2608":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "16":
                        token[6] = "4"
                        token[7] = "conj"
                    if token[0] == "10":
                        token[6] = "16"
                    if token[0] == "26":
                        token[6] = "0"
                        token[7] = "root"
                    if token[0] == "29":
                        token[6] = "26"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj111.704.2649":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "32":
                        token[6] = "23"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj115.719.2701":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "17":
                        token[6] = "22"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj118.766.2903":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "12"
                    if token[0] == "16":
                        token[6] = "12"
                        token[7] = "vocative"
                    if token[0] == "18":
                        token[6] = "12"
                    if token[0] == "19":
                        token[6] = "12"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj121.777.2934":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "5":
                        token[6] = "7"
                    if token[0] == "39":
                        token[6] = "37"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj121.779.2951":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "15":
                        token[6] = "17"
                    if token[0] == "17":
                        token[6] = "12"
                        token[7] = "conj"
                    if token[0] == "19":
                        token[6] = "12"
                    if token[0] == "25":
                        token[6] = "0"
                        token[7] = "root"
                    if token[0] == "35":
                        token[6] = "25"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj131.838.3206":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "2":
                        token[6] = "0"
                        token[7] = "root"
                    if token[0] == "3":
                        token[6] = "2"
                    if token[0] == "6":
                        token[6] = "2"
                        token[7] = "parataxis"
                    if token[0] == "7":
                        token[6] = "2"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj133.862.3301":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "6"
                        token[7] = "conj"
                    if token[0] == "23":
                        token[6] = "0"
                        token[7] = "root"
                    if token[0] == "30":
                        token[6] = "23"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj141.906.3476":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "11"
                    if token[0] == "21":
                        token[6] = "11"
                    if token[0] == "11":
                        token[6] = "5"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj141.909.3481":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "13":
                        token[6] = "14"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj142.923.3524":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "6":
                        token[6] = "7"
                    if token[0] == "7":
                        token[6] = "14"
                        token[7] = "parataxis"
                    if token[0] == "21":
                        token[6] = "0"
                        token[7] = "root"
                    if token[0] == "22":
                        token[6] = "21"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj152.1035.3871":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "17":
                        token[6] = "15"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj154.1049.3930":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "25":
                        token[6] = "20"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj154.1052.3943":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "5":
                        token[6] = "11"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj161.1108.4094":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "24":
                        token[6] = "26"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj164.1130.4159":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "9":
                        token[6] = "12"
                    if token[0] == "23":
                        token[6] = "12"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj165.1133.4177":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "13":
                        token[6] = "6"
                        token[7] = "parataxis"
                    if token[0] == "25":
                        token[6] = "6"
                    if token[0] == "26":
                        token[6] = "0"
                        token[7] = "root"
                    if token[0] == "40":
                        token[6] = "26"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj173.1184.4327":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "18"
                    if token[0] == "32":
                        token[6] = "6"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj176.1192.4338":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "9":
                        token[6] = "11"
                    if token[0] == "20":
                        token[6] = "11"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj177.1198.4375":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "15":
                        token[6] = "20"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj185.1230.4464":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "41":
                        token[6] = "43"
                    if token[0] == "42":
                        token[6] = "43"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj187.1237.4498":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "42":
                        token[6] = "43"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj189.1239.4512":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "16":
                        token[6] = "18"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj193.1282.4633":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "2":
                        token[6] = "6"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj195.1316.4751":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "4":
                        token[6] = "3"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj216.1434.5195":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "5":
                        token[6] = "8"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj234.1555.5625":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "17":
                        token[6] = "7"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj243.1592.5773":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "17":
                        token[6] = "18"
                    if token[0] == "21":
                        token[6] = "22"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj260.1659.5960":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "15":
                        token[6] = "18"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj260.1661.5974":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "8":
                        token[6] = "9"
                    if token[0] == "13":
                        token[6] = "9"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj267.1691.6040":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "6":
                        token[6] = "4"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj268.1699.6059":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "13":
                        token[6] = "16"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj284.1753.6235": #napaka s ki v jos
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "17":
                        token[6] = "25"
                    if token[0] == "18":
                        token[6] = "25"
                    if token[0] == "32":
                        token[6] = "25"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj292.1781.6325": #potencialna napaka v JOS
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "13":
                        token[6] = "16"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj294.1796.6360":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "15":
                        token[6] = "5"
                    if token[0] == "23":
                        token[6] = "24"
                    if token[0] == "28":
                        token[6] = "24"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj300.1826.6470":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "21":
                        token[6] = "36"
                    if token[0] == "33":
                        token[6] = "29"
                    if token[0] == "38":
                        token[6] = "36"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj310.1871.6636":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "11":
                        token[6] = "20"
                    if token[0] == "23":
                        token[6] = "20"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj311.1874.6645":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "15":
                        token[6] = "24"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj322.1913.6826":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "7":
                        token[6] = "10"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj324.1920.6841": # le-ta neustrezno rešen nasploh
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "3":
                        token[6] = "5"
                    if token[0] == "4":
                        token[6] = "5"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj328.1968.7001":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "16"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj336.1982.7044":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "24":
                        token[6] = "25"
                    if token[0] == "25":
                        token[6] = "23"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj345.2013.7149":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "15"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj350.2042.7221":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "20":
                        token[6] = "23"
                    if token[0] == "21":
                        token[6] = "23"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj360.2081.7375":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "11":
                        token[6] = "19"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj367.2098.7443":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "23":
                        token[6] = "29"
                        token[7] = "advcl"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj369.2107.7486":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "12"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj370.2112.7505":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "22":
                        token[6] = "24"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj370.2113.7509":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "4":
                        token[6] = "6"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj370.2124.7555":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "6":
                        token[6] = "11"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj373.2139.7609":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "26":
                        token[6] = "27"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj375.2158.7664":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "12"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj378.2170.7702":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "18":
                        token[6] = "23"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj385.2213.7839":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "16":
                        token[6] = "21"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj394.2232.7889":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "19":
                        token[6] = "20"
                    if token[0] == "20":
                        token[6] = "23"
                        token[7] ="parataxis"
                    if token[0] == "21":
                        token[6] = "20"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj417.2328.8204": #denimo/recimo in general
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "19":
                        token[6] = "20"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj422.2348.8267":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "25":
                        token[6] = "30"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj443.2422.8502":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "35":
                        token[6] = "37"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj469.2543.9028":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "1":
                        token[6] = "17"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj469.2547.9052":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "1":
                        token[6] = "24"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj469.2547.9058":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "1":
                        token[6] = "17"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj474.2567.9145":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "26":
                        token[6] = "28"
                    if token[0] == "27":
                        token[6] = "28"
                    if token[0] == "29":
                        token[6] = "28"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj477.2578.9193":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "12":
                        token[6] = "14"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj489.2625.9356":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "39":
                        token[6] = "42"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj493.2632.9392": #napaka v JOS - nadzoru ni prir
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "21":
                        token[7] = "nmod"
                    if token[0] == "23":
                        token[6] = "18"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj506.2696.9600":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "7":
                        token[6] = "15"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj512.2711.9656":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "26":
                        token[6] = "28"
                        token[7] = "advmod"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj513.2718.9701":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "21":
                        token[6] = "27"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj517.2736.9768":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "27":
                        token[6] = "18"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj531.2797.9965":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "9":
                        token[6] = "15"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj533.2814.10018":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "17"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj534.2820.10040":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "25":
                        token[6] = "27"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj537.2836.10089":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "19":
                        token[6] = "21"
                        token[7] = "advcl"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj540.2848.10125":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "21":
                        token[6] = "14"
                        token[7] = "advcl"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj543.2853.10139":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "3":
                        token[6] = "2"
                    if token[0] == "11":
                        token[7] = "advcl"
                    if token[0] == "18":
                        token[6] = "6"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj554.2894.10255":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "14":
                        token[6] = "10"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj554.2896.10264": #napaka v jos - tako x kot y kot tri in ne prir?
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "8":
                        token[6] = "10"
                    if token[0] == "12":
                        token[7] = "conj"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj557.2902.10283":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "18":
                        token[6] = "23"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj562.2923.10350":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "8":
                        token[6] = "9"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj562.2923.10351":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "4":
                        token[6] = "5"
                    if token[0] == "6":
                        token[6] = "5"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj579.2970.10536":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "30":
                        token[6] = "11"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj579.2987.10582":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "33":
                        token[6] = "36"
                    if token[0] == "36":
                        token[7] = "appos"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj585.3014.10660":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "7":
                        token[6] = "9"
                    if token[0] == "10":
                        token[6] = "9"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj593.3037.10754":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "16"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj594.3052.10813": #še rešiti discourse vs. parataxis
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "3":
                        token[6] = "2"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj603.3095.10955":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "13"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj607.3129.11118":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "23":
                        token[6] = "41"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj610.3157.11220":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "10":
                        token[6] = "14"
                    if token[0] == "20":
                        token[6] = "6"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            elif sentence_id == "ssj614.3178.11297":
                meta = sentence.split("\n")[:2]
                output.write(("\n").join(meta))
                output.write("\n")

                tokens = sentence.split("\n")[2:]
                for token in tokens:
                    token = token.split("\t")
                    if token[0] == "5":
                        token[6] = "3"
                    if token[0] == "6":
                        token[6] = "3"
                    output.write("{}\n".format("\t".join(token)))
                output.write("\n")

            else:
                output.write(sentence)
                output.write("\n\n")
