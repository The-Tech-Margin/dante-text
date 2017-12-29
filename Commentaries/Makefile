#
# Top-level Makefile for the Dartmouth Dante Project
#
# Targets you may use:
#
# all (or none):		cause all modified text files (*.e) to be preprocessed and loaded into Oracle
# Poem or commentary name:	cause all modified text files (*.e) in that commentary to be preprocessed and loaded
# dat:				generate any *.dat files from modified text (*.e) files
# up-to-date:			make it appear that all text files have been loaded into Oracle
# clean:			make it appear that NO text files have been loaded into Oracle
#

commentaries := ambrosiane andreoli bennassuti benvenuto berthier bianchi boccaccio bosco buti \
	cagliaritane campi carroll casini cassinese castelvetro chiavacci chimenz costa \
	daniello dellungo disiena fallani fiorentino fosca gabriele gelli giacalone \
	giambullari grabher grandgent graziolo guido guiniforto hollander jacopo lana \
	landino lombardi lombardus longfellow maramauro mattalia mazzoni mestica momigliano \
	oelsner ottimo ottimo3 padoan pasquini pietro1 pietro2 pietro3 pietrobono poletto \
	porena portirelli provenzal rossetti ruskin sapegno scartazzini selmiano serravalle \
	singleton steiner tasso tommaseo torraca tozer trucchi vandelli varchi \
	vellutello venturi vernon villani

include		Userid.mk

.PHONY:		all poem $(commentaries) dat up-to-date clean reindex

all:		poem $(commentaries)

poem $(commentaries):
	$(MAKE) --directory=$@ all

dat up-to-date clean:
	for d in poem $(commentaries);			\
	do						\
		$(MAKE) --directory=$$d $@;		\
	done
    
#   
# To regenerate the full text index, such as after loading updates
#   
reindex:
	sqlplus $(USERID) @reindex

