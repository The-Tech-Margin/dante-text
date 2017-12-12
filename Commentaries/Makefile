#
# Top-level Makefile for the Dartmouth Dante Project
#

#
# For targets "dat" and "clean", usages is "make TARGET=dat" etc.
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


.PHONY:	all poem $(commentaries)

all:	poem $(commentaries)

dat:	poem $(commentaries)

$(commentaries) poem:
	$(MAKE) --directory=$@ $(TARGET)
