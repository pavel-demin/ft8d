program ft8d

! Decode FT8 data read from *.c2 files.

  include 'ft8_params.f90'
  character infile*80,date*6,time*4
  character msgcall*6,msggrid*4
  real s(NFFT1,NHSYM)
  real sbase(NFFT1)
  real candidate(3,200)
  real*8 dialfreq
  complex dd(NMAX,4)
  logical newdat
  integer apsym(KK)

  nargs=iargc()
  if(nargs.ne.1) then
    print*,'Usage: ft8d file'
    go to 999
  endif

  twopi=8.0*atan(1.0)
  fs=4000.0                              !Sample rate
  dt=1.0/fs                              !Sample interval (s)
  tt=NSPS*dt                             !Duration of "itone" symbols (s)
  ts=2*NSPS*dt                           !Duration of OQPSK symbols (s)
  baud=1.0/tt                            !Keying rate (baud)
  txt=NZ*dt                              !Transmission length (s)
  nfa=-1600
  nfb=+1600
  nfqso=0

  call getarg(1,infile)
  open(10,file=infile,status='old',access='stream')
  read(10,end=999) dialfreq,dd
  close(10)
  j2=index(infile,'.c2')
  date=infile(j2-11:j2-6)
  time=infile(j2-4:j2-1)
  do ipart=1,4
    ndecodes=0
    ndepth=1
    newdat=.true.
    syncmin=1.5
    call sync8(dd(1:NMAX,ipart),nfa+2000,nfb+2000,syncmin, &
        nfqso+2000,s,candidate,ncand,sbase)
    do icand=1,ncand
      sync=candidate(3,icand)
      f1=candidate(1,icand)
      xdt=candidate(2,icand)
      xbase=10.0**(0.1*(sbase(nint(f1/3.125))-40.0))
      call ft8b(dd(1:NMAX,ipart),newdat,nQSOProgress,nfqso+2000, &
          nftx,ndepth,lft8apon,lapcqonly,napwid,nagain,iaptype,  &
          f1,xdt,xbase,apsym,nharderrors,dmin,nbadcrc,iappass,   &
          msgcall,msggrid,xsnr)
      nsnr=nint(xsnr)
      xdt=xdt-0.5
      hd=nharderrors+dmin
      if(nbadcrc.eq.0) then
        write(*,1004) date,time,15*(ipart-1),min(sync,999.0),nint(xsnr), &
            xdt,nint(f1-2000+dialfreq),msgcall,msggrid
1004      format(a6,1x,a4,i2.2,f6.1,i4,f6.2,i9,1x,a6,1x,a4)
      endif
    enddo
  enddo ! ipart loop

999 end program ft8d

