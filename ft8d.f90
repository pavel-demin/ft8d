program ft8d

! Decode FT8 data read from *.c2 files.

  include 'ft8_params.f90'
  character infile*80,msg37*37,date*6,time*4
  character msgcall*13,msggrid*4
  character*37 allmessages(100)
  real s(NFFT1,NHSYM)
  real sbase(NFFT1)
  real candidate(3,MAXCAND)
  real*8 dialfreq
  complex dd(NMAX,4)
  logical newdat,lft8apon,lsubtract,ldupe
  integer allsnrs(100)
  integer apsym(KK)

  nargs=iargc()
  if(nargs.ne.1) then
    print*,'Usage: ft8d file'
    go to 999
  endif

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
    nQSOProgress=0
    ndecodes=0
    n2=0
    allmessages='                                     '
    allsnrs=0
    ncontest=0
    lft8apon=.false.
    ndepth=1
    if(ndepth.eq.1) npass=1
    if(ndepth.ge.2) npass=3
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
      call sync8(dd(1:NMAX,ipart),nfa+2000,nfb+2000,syncmin, &
          nfqso+2000,s,candidate,ncand,sbase)
      do icand=1,ncand
        sync=candidate(3,icand)
        f1=candidate(1,icand)
        xdt=candidate(2,icand)
        xbase=10.0**(0.1*(sbase(nint(f1/3.125))-40.0))
        call ft8b(dd(1:NMAX,ipart),newdat,nQSOProgress,nfqso+2000, &
            nftx,ndepth,lft8apon,lapcqonly,napwid,lsubtract,nagain, &
            ncontest,iaptype,f1,xdt,xbase,apsym,nharderrors,dmin, &
            nbadcrc,iappass,msg37,msgcall,msggrid,xsnr)
        nsnr=nint(xsnr)
        xdt=xdt-0.5
        hd=nharderrors+dmin
        if(nbadcrc.eq.0.and.msgcall(1:1).ne.'<') then
          ldupe=.false.
          do id=1,ndecodes
            if(msg37.eq.allmessages(id).and.nsnr.le.allsnrs(id)) ldupe=.true.
          enddo
          if(.not.ldupe) then
            ndecodes=ndecodes+1
            allmessages(ndecodes)=msg37
            allsnrs(ndecodes)=nsnr
          endif
          write(*,1004) date,time,15*(ipart-1),min(sync,999.0),nint(xsnr), &
              xdt,nint(f1-2000+dialfreq),msgcall,msggrid
1004      format(a6,1x,a4,i2.2,f6.1,i4,f6.2,i9,1x,a13,1x,a4)
        endif
      enddo
    enddo
  enddo ! ipart loop

999 end program ft8d

