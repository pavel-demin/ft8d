program ft8d

! Decode FT8 data read from *.wav files.

  include 'ft8_params.f90'
  character infile*80,datetime*13,message*22,msg37*37
  character*22 allmessages(100)
  character*12 mycall12,hiscall12
  character*6 mygrid6,hisgrid6
  real s(NH1,NHSYM)
  real sbase(NH1)
  real candidate(3,200)
  real dd(NMAX)
  logical newdat,lsubtract,ldupe,bcontest
  integer apsym(KK)
  integer ihdr(11)
  integer*2 iwave(NMAX)
  integer allsnrs(100)
  save s,dd

  nargs=iargc()
  if(nargs.lt.1) then
    print*,'Usage: ft8d file1 [file2 ...]'
    go to 999
  endif
  nfiles=nargs

  twopi=8.0*atan(1.0)
  fs=12000.0                             !Sample rate
  dt=1.0/fs                              !Sample interval (s)
  tt=NSPS*dt                             !Duration of "itone" symbols (s)
  ts=2*NSPS*dt                           !Duration of OQPSK symbols (s)
  baud=1.0/tt                            !Keying rate (baud)
  txt=NZ*dt                              !Transmission length (s)
  nfa=100
  nfb=3000
  nfqso=1500

  do ifile=1,nfiles
    call getarg(ifile,infile)
    open(10,file=infile,status='old',access='stream')
    read(10,end=999) ihdr,iwave
    close(10)
    j2=index(infile,'.wav')
    read(infile(j2-6:j2-1),*) nutc
    datetime=infile(j2-13:j2-1)
    dd=iwave
    ndecodes=0
    allmessages='                      '
    allsnrs=0
    ndepth=1
    npass=1
    do ipass=1,npass
      newdat=.true.
      syncmin=1.5
      if(ipass.eq.1) then
        lsubtract=.true.
        if(ndepth.eq.1) lsubtract=.false.
      elseif(ipass.eq.2) then
        n2=ndecodes
        if(ndecodes.eq.0) cycle
        lsubtract=.true.
      elseif(ipass.eq.3) then
        if((ndecodes-n2).eq.0) cycle
        lsubtract=.false.
      endif
      call sync8(dd,nfa,nfb,syncmin,nfqso,s,candidate,ncand,sbase)
      do icand=1,ncand
        sync=candidate(3,icand)
        f1=candidate(1,icand)
        xdt=candidate(2,icand)
        xbase=10.0**(0.1*(sbase(nint(f1/3.125))-40.0))
        nsnr0=min(99,nint(10.0*log10(sync) - 25.5)) ! ### empirical ###
        call ft8b(dd,newdat,nQSOProgress,nfqso,nftx,ndepth,lft8apon,      &
            lapcqonly,napwid,lsubtract,nagain,iaptype,mycall12,mygrid6,   &
            hiscall12,bcontest,sync,f1,xdt,xbase,apsym,nharderrors,dmin,  &
            nbadcrc,iappass,iera,msg37,xsnr)
        message=msg37(1:22)
        nsnr=nint(xsnr)
        xdt=xdt-0.5
        hd=nharderrors+dmin
        if(nbadcrc.eq.0) then
          if(bcontest) then
            call fix_contest_msg(mygrid6,message)
            msg37(1:22)=message
          endif
          ldupe=.false.
          do id=1,ndecodes
            if(message.eq.allmessages(id).and.nsnr.le.allsnrs(id)) ldupe=.true.
          enddo
          if(.not.ldupe) then
            ndecodes=ndecodes+1
            allmessages(ndecodes)=message
            allsnrs(ndecodes)=nsnr
          endif
          write(*,1004) nutc,ncand,icand,ipass,iaptype,iappass,        &
              nharderrors,dmin,hd,min(sync,999.0),nint(xsnr),          &
              xdt,nint(f1),message
1004      format(i6.6,2i4,3i2,i3,3f6.1,i4,f6.2,i5,2x,a22)
        endif
      enddo
    enddo
  enddo ! ifile loop

999 end program ft8d

