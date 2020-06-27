TARGET = ft8d

OBJECTS = \
  crc14.o crc.o ft8_downsample.o sync8d.o sync8.o grid2deg.o pffft.o \
  four2a.o deg2grid.o determ.o baseline.o platanh.o bpdecode174_91.o \
  fmtmsg.o packjt.o chkcrc14a.o indexx.o shell.o pctile.o polyfit.o \
  twkfreq1.o osd174_91.o encode174_91.o chkcall.o packjt77.o genft8.o \
  gfsk_pulse.o gen_ft8wave.o subtractft8.o ft8b.o ft8d.o

CC = gcc
FC = gfortran
LD = gfortran
RM = rm -f

CFLAGS = -Wall -O3 -funroll-loops
FFLAGS = -Wall -O3 -funroll-loops

all: $(TARGET)

%.o: %.c
	${CC} -c ${CFLAGS} $< -o $@
%.o: %.f90
	${FC} -c ${FFLAGS} $< -o $@

$(TARGET): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@

clean:
	$(RM) *.o *.mod $(TARGET)
