module packjt

! These variables are accessible from outside via "use packjt":
  integer jt_itype,jt_nc1,jt_nc2,jt_ng,jt_k1,jt_k2
  character*6 jt_c1,jt_c2,jt_c3

  contains

 subroutine unpackbits(sym,nsymd,m0,dbits)

 ! Unpack bits from sym() into dbits(), one bit per byte.
 ! NB: nsymd is the number of input words, and m0 their length.
 ! there will be m0*nsymd output bytes, each 0 or 1.

   integer sym(:)
   integer*1 dbits(:)

   k=0
   do i=1,nsymd
      mask=ishft(1,m0-1)
      do j=1,m0
         k=k+1
         dbits(k)=0
         if(iand(mask,sym(i)).ne.0) dbits(k)=1
         mask=ishft(mask,-1)
      enddo
   enddo

   return
 end subroutine unpackbits

 subroutine unpackcall(ncall,word,iv2,psfx)

   parameter (NBASE=37*36*10*27*27*27)
   character word*12,c*37,psfx*4

   data c/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ '/

   word='......'
   psfx='    '
   n=ncall
   iv2=0
   if(n.ge.262177560) go to 20
   word='......'
 !  if(n.ge.262177560) go to 999            !Plain text message ...
   i=mod(n,27)+11
   word(6:6)=c(i:i)
   n=n/27
   i=mod(n,27)+11
   word(5:5)=c(i:i)
   n=n/27
   i=mod(n,27)+11
   word(4:4)=c(i:i)
   n=n/27
   i=mod(n,10)+1
   word(3:3)=c(i:i)
   n=n/10
   i=mod(n,36)+1
   word(2:2)=c(i:i)
   n=n/36
   i=n+1
   word(1:1)=c(i:i)
   do i=1,4
      if(word(i:i).ne.' ') go to 10
   enddo
   go to 999
 10 word=word(i:)
   go to 999

 20 if(n.ge.267796946) go to 999

 ! We have a JT65v2 message
   if((n.ge.262178563) .and. (n.le.264002071)) then
 ! CQ with prefix
      iv2=1
      n=n-262178563
      i=mod(n,37)+1
      psfx(4:4)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(3:3)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(2:2)=c(i:i)
      n=n/37
      i=n+1
      psfx(1:1)=c(i:i)

   else if((n.ge.264002072) .and. (n.le.265825580)) then
 ! QRZ with prefix
      iv2=2
      n=n-264002072
      i=mod(n,37)+1
      psfx(4:4)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(3:3)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(2:2)=c(i:i)
      n=n/37
      i=n+1
      psfx(1:1)=c(i:i)

   else if((n.ge.265825581) .and. (n.le.267649089)) then
 ! DE with prefix
      iv2=3
      n=n-265825581
      i=mod(n,37)+1
      psfx(4:4)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(3:3)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(2:2)=c(i:i)
      n=n/37
      i=n+1
      psfx(1:1)=c(i:i)

   else if((n.ge.267649090) .and. (n.le.267698374)) then
 ! CQ with suffix
      iv2=4
      n=n-267649090
      i=mod(n,37)+1
      psfx(3:3)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(2:2)=c(i:i)
      n=n/37
      i=n+1
      psfx(1:1)=c(i:i)

   else if((n.ge.267698375) .and. (n.le.267747659)) then
 ! QRZ with suffix
      iv2=5
      n=n-267698375
      i=mod(n,37)+1
      psfx(3:3)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(2:2)=c(i:i)
      n=n/37
      i=n+1
      psfx(1:1)=c(i:i)

   else if((n.ge.267747660) .and. (n.le.267796944)) then
 ! DE with suffix
      iv2=6
      n=n-267747660
      i=mod(n,37)+1
      psfx(3:3)=c(i:i)
      n=n/37
      i=mod(n,37)+1
      psfx(2:2)=c(i:i)
      n=n/37
      i=n+1
      psfx(1:1)=c(i:i)

   else if(n.eq.267796945) then
 ! DE with no prefix or suffix
      iv2=7
      psfx = '    '
   endif

999 if(word(1:3).eq.'3D0') word='3DA0'//word(4:)
   if(word(1:1).eq.'Q' .and. word(2:2).ge.'A' .and.                 &
        word(2:2).le.'Z') word='3X'//word(2:)

   return
 end subroutine unpackcall

 subroutine unpackmsg(dat,lhasgrid,msgcall,msggrid)

   parameter (NBASE=37*36*10*27*27*27)
   parameter (NGBASE=180*180)
   integer dat(:)
   character msgcall*12,msggrid*4,grid6*6,junk2*4
   logical lhasgrid

   nc1=ishft(dat(1),22) + ishft(dat(2),16) + ishft(dat(3),10)+         &
        ishft(dat(4),4) + iand(ishft(dat(5),-2),15)

   nc2=ishft(iand(dat(5),3),26) + ishft(dat(6),20) +                   &
        ishft(dat(7),14) + ishft(dat(8),8) + ishft(dat(9),2) +         &
        iand(ishft(dat(10),-4),3)

   ng=ishft(iand(dat(10),15),12) + ishft(dat(11),6) + dat(12)

   lhasgrid=.false.
   msggrid='    '
   if(ng.lt.32400 .and. ng.ne.533) then
      call unpackcall(nc2,msgcall,junk1,junk2)
      dlat=mod(ng,180)-90
      dlong=(ng/180)*2 - 180 + 2
      call deg2grid(dlong,dlat,grid6)
      msggrid=grid6(:4)
      lhasgrid=msggrid(1:2).ne.'KA' .and. msggrid(1:2).ne.'KA'
   endif

   return
 end subroutine unpackmsg

 function nchar(c)

 ! Convert ascii number, letter, or space to 0-36 for callsign packing.

   character c*1

   n=0                                    !Silence compiler warning
   if(c.ge.'0' .and. c.le.'9') then
      n=ichar(c)-ichar('0')
   else if(c.ge.'A' .and. c.le.'Z') then
      n=ichar(c)-ichar('A') + 10
   else if(c.ge.'a' .and. c.le.'z') then
      n=ichar(c)-ichar('a') + 10
   else if(c.ge.' ') then
      n=36
   else
      Print*,'Invalid character in callsign ',c,' ',ichar(c)
      stop
   endif
   nchar=n

   return
 end function nchar

end module packjt
