! LDPC (174,87) code
parameter (KK=87)                     !Information bits (75 + CRC12)
parameter (ND=58)                     !Data symbols
parameter (NS=21)                     !Sync symbols (3 @ Costas 7x7)
parameter (NN=NS+ND)                  !Total channel symbols (79)
parameter (NSPS=640)                  !Samples per symbol at 4000 S/s
parameter (NZ=NSPS*NN)                !Samples in full 15 s waveform (50,560)
parameter (NMAX=15*4000)              !Samples in iwave (60,000)
parameter (NFFT1=2*NSPS, NH1=NFFT1/2) !Length of FFTs for symbol spectra
parameter (NSTEP=NSPS/4)              !Rough time-sync step size
parameter (NHSYM=NMAX/NSTEP-3)        !Number of symbol spectra (1/4-sym steps)
parameter (NDOWN=20)                  !Downsample factor
