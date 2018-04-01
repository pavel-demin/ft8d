subroutine ft8_downsample(dd,newdat,f0,c1)

! Downconvert to complex data sampled at 200 Hz ==> 32 samples/symbol

  parameter (NMAX=15*6000,NSPS=960)
  parameter (NFFT1=96000,NFFT2=3200)       !96000/30 = 3200

  logical newdat
  complex c1(0:NFFT2-1)
  complex cx(0:NFFT1)
  complex dd(NMAX),x(NFFT1)
  equivalence (x,cx)
  save cx

  if(newdat) then
! Data in dd have changed, recompute the long FFT
     x(1:NMAX)=dd
     x(NMAX+1:NFFT1)=0.                       !Zero-pad the x array
     call four2a(cx,NFFT1,1,-1,1)             !c2c FFT to freq domain
     newdat=.false.
  endif

  if(f0.lt.3000.0) then
    f=f0+3000.0
  else
    f=f0-3000.0
  endif
  df=6000.0/NFFT1
  baud=6000.0/NSPS
  i0=nint(f/df)
  ft=f+8.0*baud
  it=min(nint(ft/df),NFFT1)
  fb=f-1.0*baud
  ib=max(1,nint(fb/df))
  k=0
  c1=0.
  do i=ib,it
   c1(k)=cx(i)
   k=k+1
  enddo
  c1=cshift(c1,i0-ib)
  call four2a(c1,NFFT2,1,1,1)            !c2c FFT back to time domain
  fac=1.0/sqrt(float(NFFT1)*NFFT2)
  c1=fac*c1

  return
end subroutine ft8_downsample
