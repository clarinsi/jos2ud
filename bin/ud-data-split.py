#!/usr/bin/python3
import sys
import os

released_treebank = sys.argv[1]

with open(released_treebank, "r", encoding="utf8") as file:
    data = file.read()
    split_data = data.split("\n\n")
    if '' in split_data:
        split_data.remove('')

    released_tokens = 0
    released_sentences = 0
    for sentence in split_data:
        split_sentence = sentence.split("\n")
        if '' in split_sentence:
            split_sentence.remove('')
        s_tokens = len(split_sentence) - 2  # two comment lines in UD2
        released_tokens += s_tokens
        released_sentences += 1

    train = open("sl_ssj-ud-train.conllu", "w", encoding="utf8", newline='')
    dev = open("sl_ssj-ud-dev.conllu", "w", encoding="utf8", newline='')
    test = open("sl_ssj-ud-test.conllu", "w", encoding="utf8", newline='')

    training = [0, 0]  # 80%
    development = [0, 0]  # 10%
    testing = [0, 0]  # 10%
    tokens = 0

    included = []
    for sentence in split_data:
        split_sentence = sentence.split("\n")
        if '' in split_sentence:
            split_sentence.remove('')
        s_tokens = len(split_sentence) - 2  # two comment lines in UD2
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

    print("released sentences:", released_sentences, "\nreleased tokens:", released_tokens,
    "\ntraining: ", training, "\ndevelopment: ", development, "\ntesting: ", testing)
