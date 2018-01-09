SYSTEM = x86-64_sles10_4.1
LIBFORMAT = static_pic

CCC = g++

# System/lib-format specific compile/link flags
CSYSFLAGS  = -std=c++11 -fPIC -DIL_STD

# Compilation and linking flags enabling Multi-threading
CMTFLAGS = -DILOUSEMT -D_REENTRANT
LDMTFLAGS = -lpthread

# Code optimization/debugging option
DEBUG = -O3 -fomit-frame-pointer -DNDEBUG

SOLVERDIR=/opt/ibm/ILOG/CP17/solver
CONCERTDIR=$(SOLVERDIR)/../concert

SOLVERIncDir=$(SOLVERDIR)/include
CONCERTIncDir=$(CONCERTDIR)/include

CFLAGS=$(CSYSFLAGS) $(DEBUG) $(OPTIONS) -I$(SOLVERIncDir) -I$(CONCERTIncDir) -I$(EXINC) $(CMTFLAGS)
LDFLAGS=-L$(SOLVERDIR)/lib/$(SYSTEM)/$(LIBFORMAT) -lsolver -lsolverfloat -L$(CONCERTDIR)/lib/$(SYSTEM)/$(LIBFORMAT) -lconcert $(LDSYSFLAGS) $(LDMTFLAGS) $(LIBS)

PROGRAM=ms-opt-cp

all:
	$(CCC) $(CFLAGS) $(PROGRAM).cpp -c
	$(CCC) $(CFLAGS) $(PROGRAM).o -o $(PROGRAM) $(LDFLAGS)

clean:
	rm -f $(PROGRAM) $(PROGRAM).o
