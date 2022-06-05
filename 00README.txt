sloleks:
več	več	DET	Rgc	Degree=Cmp|PronType=Ind
več	več	NUM	Mlcfpa	Case=Acc|Gender=Fem|Number=Plur|NumForm=Word|NumType=Card
več	več	NUM	Mlcfpn	Case=Nom|Gender=Fem|Number=Plur|NumForm=Word|NumType=Card
več	več	NUM	Mlcmpa	Case=Acc|Gender=Masc|Number=Plur|NumForm=Word|NumType=Card
več	več	NUM	Mlcmpn	Case=Nom|Gender=Masc|Number=Plur|NumForm=Word|NumType=Card
več	več	NUM	Mlcnpa	Case=Acc|Gender=Neut|Number=Plur|NumForm=Word|NumType=Card
več	več	NUM	Mlcnpn	Case=Nom|Gender=Neut|Number=Plur|NumForm=Word|NumType=Card
več	več	PART	Q	_

ssj500k:
več	več	DET	Rgc	PronType=Ind
več	več	PART	Q	_

V ssj500k manjka Degree za naslednje:
ERROR: Feat conflict PronType=Ind četrt	četrt	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind čimveč	čimveč	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind dosti	dosti	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind dovolj	dovolj	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Int koliko	koliko	DET	Rgp	Degree=Pos|PronType=Int vs. PronType=Int
ERROR: Feat conflict PronType=Ind mal	malo	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind malo	malo	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind manj	manj	DET	Rgc	Degree=Cmp|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind mnogo	mnogo	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind največ	največ	DET	Rgs	Degree=Sup|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind nekaj	nekaj	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind nešteto	nešteto	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind ogromno	ogromno	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind par	par	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind pol	pol	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind preveč	preveč	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Dem toliko	toliko	DET	Rgp	Degree=Pos|PronType=Dem vs. PronType=Dem
ERROR: Feat conflict PronType=Ind več	več	DET	Rgc	Degree=Cmp|PronType=Ind vs. PronType=Ind
ERROR: Feat conflict PronType=Ind veliko	veliko	DET	Rgp	Degree=Pos|PronType=Ind vs. PronType=Ind


Sedaj:
tomaz@new-tantra jos2ud$ diff Origin/sloleks.ud.tbl.old Origin/sloleks.ud.tbl
248885c248885
< četrt	četrt	Rgp	0.013878		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> četrt	četrt	Rgp	0.013878		Adverb Type=general Degree=positive	DET PronType=Ind
251596c251596
< čimmanj	čimmanj	Rgp	0.000648		Adverb Type=general Degree=positive	DET Degree=Pos
---
> čimmanj	čimmanj	Rgp	0.000648		Adverb Type=general Degree=positive	DET
251653c251653
< čimveč	čimveč	Rgp	0.005764		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> čimveč	čimveč	Rgp	0.005764		Adverb Type=general Degree=positive	DET PronType=Ind
357241c357241
< dosti	dosti	Rgp	0.052006		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> dosti	dosti	Rgp	0.052006		Adverb Type=general Degree=positive	DET PronType=Ind
359942c359942
< dovolj	dovolj	Rgp	0.351425		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> dovolj	dovolj	Rgp	0.351425		Adverb Type=general Degree=positive	DET PronType=Ind
431205c431205
< enormno	enormno	Rgp	0.000620		Adverb Type=general Degree=positive	DET Degree=Pos
---
> enormno	enormno	Rgp	0.000620		Adverb Type=general Degree=positive	DET
835540c835540
< koliko	koliko	Rgp	0.186709		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Int
---
> koliko	koliko	Rgp	0.186709		Adverb Type=general Degree=positive	DET PronType=Int
1009297c1009297
< majčkeno	majčkeno	Rgp	0.000796		Adverb Type=general Degree=positive	DET Degree=Pos
---
> majčkeno	majčkeno	Rgp	0.000796		Adverb Type=general Degree=positive	DET
1015670c1015670
< mal	malo	Rgp	0.016154	*	Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> mal	malo	Rgp	0.016154	*	Adverb Type=general Degree=positive	DET PronType=Ind
1016378c1016378
< malo	malo	Rgp	0.425715		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> malo	malo	Rgp	0.425715		Adverb Type=general Degree=positive	DET PronType=Ind
1022645c1022645
< manj	manj	Rgc	0.506294		Adverb Type=general Degree=comparative	DET Degree=Cmp PronType=Ind
---
> manj	manj	Rgc	0.506294		Adverb Type=general Degree=comparative	DET PronType=Ind
1100445c1100445
< mnogo	mnogo	Rgp	0.087132		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> mnogo	mnogo	Rgp	0.087132		Adverb Type=general Degree=positive	DET PronType=Ind
1201365c1201365
< največ	največ	Rgs	0.243010		Adverb Type=general Degree=superlative	DET Degree=Sup PronType=Ind
---
> največ	največ	Rgs	0.243010		Adverb Type=general Degree=superlative	DET PronType=Ind
1272924c1272924
< nekaj	nekaj	Rgp	1.358641		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> nekaj	nekaj	Rgp	1.358641		Adverb Type=general Degree=positive	DET PronType=Ind
1333312c1333312
< nešteto	nešteto	Rgp	0.008159		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> nešteto	nešteto	Rgp	0.008159		Adverb Type=general Degree=positive	DET PronType=Ind
1355717c1355717
< ničkoliko	ničkoliko	Rgp	0.000886		Adverb Type=general Degree=positive	DET Degree=Pos
---
> ničkoliko	ničkoliko	Rgp	0.000886		Adverb Type=general Degree=positive	DET
1382765c1382765
< obilo	obilo	Rgp	0.012003		Adverb Type=general Degree=positive	DET Degree=Pos
---
> obilo	obilo	Rgp	0.012003		Adverb Type=general Degree=positive	DET
1454406c1454406
< ogromno	ogromno	Rgp	0.047553		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> ogromno	ogromno	Rgp	0.047553		Adverb Type=general Degree=positive	DET PronType=Ind
1558796c1558796
< par	par	Rgp	0.019851		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> par	par	Rgp	0.019851		Adverb Type=general Degree=positive	DET PronType=Ind
1705146c1705146
< pol	pol	Rgp	0.253681		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> pol	pol	Rgp	0.253681		Adverb Type=general Degree=positive	DET PronType=Ind
1843858c1843858
< premnogo	premnogo	Rgp	0.000141		Adverb Type=general Degree=positive	DET Degree=Pos
---
> premnogo	premnogo	Rgp	0.000141		Adverb Type=general Degree=positive	DET
1885500c1885500
< preveč	preveč	Rgp	0.265916		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> preveč	preveč	Rgp	0.265916		Adverb Type=general Degree=positive	DET PronType=Ind
2426307c2426307
< toliko	toliko	Rgp	0.299178		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Dem
---
> toliko	toliko	Rgp	0.299178		Adverb Type=general Degree=positive	DET PronType=Dem
2546198c2546198
< več	več	Rgc	1.484233		Adverb Type=general Degree=comparative	DET Degree=Cmp PronType=Ind
---
> več	več	Rgc	1.484233		Adverb Type=general Degree=comparative	DET PronType=Ind
2552695c2552695
< veliko	veliko	Rgp	0.865507		Adverb Type=general Degree=positive	DET Degree=Pos PronType=Ind
---
> veliko	veliko	Rgp	0.865507		Adverb Type=general Degree=positive	DET PronType=Ind

Vse ok, samo
1843858c1843858
< premnogo	premnogo	Rgp	0.000141		Adverb Type=general Degree=positive	DET Degree=Pos
---
> premnogo	premnogo	Rgp	0.000141		Adverb Type=general Degree=positive	DET

se pojavi tudi v ssj500k z Degree=Pos!
