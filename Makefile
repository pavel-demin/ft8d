TARGET = ft8d

OBJECTS = \
  timer_module.o crc10.o crc12.o crc.o ft8_downsample.o sync8d.o sync8.o \
  grid2deg.o four2a.o deg2grid.o chkcrc12a.o determ.o fftw3mod.o \
  baseline.o bpdecode144.o geodist.o azdist.o fix_contest_msg.o \
  to_contest_msg.o bpdecode174.o fmtmsg.o packjt.o extractmessage174.o \
  indexx.o shell.o pctile.o polyfit.o twkfreq1.o osd174.o encode174.o \
  genft8.o genft8refsig.o subtractft8.o db.o ft8b.o ft8d.o

CC = gcc
FC = gfortran
LD = gfortran
RM = rm -f

CFLAGS = -O3 -Wall -fbounds-check
FFLAGS = -O3 -Wall -funroll-loops -fno-second-underscore
LDFLAGS = -lfftw3f

all: $(TARGET)

%.o: %.c
	${CC} -c ${CFLAGS} $< -o $@
%.o: %.f90
	${FC} -c ${FFLAGS} $< -o $@

$(TARGET): $(OBJECTS)
	$(LD) $(OBJECTS) $(LDFLAGS) -o $@

clean:
	$(RM) *.o *.mod $(TARGET)
