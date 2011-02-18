module mod_pos
  USE mod_param
  USE mod_grid
  USE mod_vel
  USE mod_loopvars
#ifdef streamxy
  USE mod_streamxy
#endif
#ifdef streamv
  USE mod_streamv
#endif
#ifdef streamr
  USE mod_streamr
#endif
  USE mod_psi
    
  IMPLICIT none
  
contains
  
  subroutine  pos(ia,iam,ja,ka,ib,jb,kb,x0,y0,z0,x1,y1,z1)
    
    INTEGER                                    :: mra,mta,msa
    REAL                                       :: uu
    INTEGER                                    :: ia, iam, ja, ka
    INTEGER                                    :: ib, jb, kb
    REAL                                       :: temp,salt,dens
    REAL*8, INTENT(IN)                         :: x0, y0, z0
    REAL*8, INTENT(OUT)                        :: x1, y1, z1
        
    ! === calculate the new positions ===
    ! === of the trajectory           ===    
    if(ds.eq.dse) then ! eastward grid-cell exit 
       scrivi=.false.
       uu=(rbg*uflux(ia,ja,ka,NST)+rb*uflux(ia ,ja,ka,1))*ff
#ifdef turb    
       ! uu=1%uu+upr(1,2)
#endif /*turb*/
       if(uu.gt.0.d0) then
          ib=ia+1
          if(ib.gt.IMT) ib=ib-IMT 
       endif
       x1=dble(ia)
#if defined timeanalyt
       call pos_time(2,ia,ja,ka,y0,y1,ts,tt,dsmin,dxyz,ss0,ds,rr)
       call pos_time(3,ia,ja,ka,z0,z1,ts,tt,dsmin,dxyz,ss0,ds,rr)
#else
       call pos_orgn(2,ia,ja,ka,y0,y1,ds,rr) 
       call pos_orgn(3,ia,ja,ka,z0,z1,ds,rr)
#endif /*timeanalyt*/
       scrivi=.true.
#ifdef streamr
       call interp(ib,jb,kb,x1,y1,z1,temp,salt,dens,1)
       mra=nint((dens-rmin)/dr)+1
       if(mra.lt.1 ) mra=1
       if(mra.gt.MR) mra=MR
#ifdef streamts
       mta=(temp-tmin)/dtemp+1
       if(mta.lt.1 ) mta=1
       if(mta.gt.MR) mta=MR
       msa=(salt-smin)/dsalt+1
       if(msa.lt.1 ) msa=1
       if(msa.gt.MR) msa=MR
#endif /*streamts*/
#endif /*streamr*/
       call savepsi(ia,ja,ka,mra,mta,msa,1,1,real(subvol*ff))
        
    elseif(ds.eq.dsw) then ! westward grid-cell exit
       scrivi=.false.
       uu=(rbg*uflux(iam,ja,ka,NST)+rb*uflux(iam,ja,ka,1))*ff
#ifdef turb    
       ! uu=uu+upr(2,2)
#endif
       if(uu.lt.0.d0) then
          ib=iam
       endif
       x1=dble(iam)
#if defined timeanalyt
       call pos_time(2,ia,ja,ka,y0,y1,ts,tt,dsmin,dxyz,ss0,ds,rr)
       call pos_time(3,ia,ja,ka,z0,z1,ts,tt,dsmin,dxyz,ss0,ds,rr)
#else
       call pos_orgn(2,ia,ja,ka,y0,y1,ds,rr) ! meridional position
       call pos_orgn(3,ia,ja,ka,z0,z1,ds,rr) ! vertical position
#endif
       scrivi=.true.      
#ifdef streamr
       call interp(ib,jb,kb,x1,y1,z1,temp,salt,dens,1)
       mra=nint((dens-rmin)/dr)+1
       if(mra.lt.1) mra=1
       if(mra.gt.MR) mra=MR
#ifdef streamts
       mta=nint((temp-tmin)/dtemp)+1
       if(mta.lt.1 ) mta=1
       if(mta.gt.MR) mta=MR
       msa=nint((salt-smin)/dsalt)+1
       if(msa.lt.1 ) msa=1
       if(msa.gt.MR) msa=MR
#endif /*streamts*/
#endif /*streamr*/
       call savepsi(iam,ja,ka,mra,mta,msa,1,-1,real(subvol*ff))

    elseif(ds.eq.dsn) then ! northward grid-cell exit
       
       scrivi=.false.
       uu=(rbg*vflux(ia,ja,ka,NST)+rb*vflux(ia,ja,ka,1))*ff
#ifdef turb    
       ! uu=uu+upr(3,2)
#endif /*turb*/
       if(uu.gt.0.d0) then
          jb=ja+1
       endif
       y1=dble(ja)
#if defined timeanalyt
       call pos_time(1,ia,ja,ka,x0,x1,ts,tt,dsmin,dxyz,ss0,ds,rr)
       call pos_time(3,ia,ja,ka,z0,z1,ts,tt,dsmin,dxyz,ss0,ds,rr)
#else
       call pos_orgn(1,ia,ja,ka,x0,x1,ds,rr) ! zonal position
       call pos_orgn(3,ia,ja,ka,z0,z1,ds,rr) ! vertical position
#endif
#ifdef streamr
       call interp(ib,jb,kb,x1,y1,z1,temp,salt,dens,1)
       mra=nint((dens-rmin)/dr)+1
       if(mra.lt.1) mra=1
       if(mra.gt.MR) mra=MR
#ifdef streamts
       mta=nint((temp-tmin)/dtemp)+1
       if(mta.lt.1 ) mta=1
       if(mta.gt.MR) mta=MR
       msa=nint((salt-smin)/dsalt)+1
       if(msa.lt.1 ) msa=1
       if(msa.gt.MR) msa=MR
#endif /*streamts*/
#endif /*streamr*/
       call savepsi(ia,ja,ka,mra,mta,msa,2,1,real(subvol*ff))

    elseif(ds.eq.dss) then ! southward grid-cell exit
       
       scrivi=.false.
       uu=(rbg*vflux(ia,ja-1,ka,NST)+rb*vflux(ia,ja-1,ka,1))*ff
#ifdef turb    
       ! uu=uu+upr(4,2)
#endif
       if(uu.lt.0.d0) then
          jb=ja-1
#ifndef ifs 
        if(jb.eq.0) stop 34578
#endif
       endif
       y1=dble(ja-1)
#if defined timeanalyt
       call pos_time(1,ia,ja,ka,x0,x1,ts,tt,dsmin,dxyz,ss0,ds,rr)
       call pos_time(3,ia,ja,ka,z0,z1,ts,tt,dsmin,dxyz,ss0,ds,rr)
#else
       call pos_orgn(1,ia,ja,ka,x0,x1,ds,rr) ! zonal position
       call pos_orgn(3,ia,ja,ka,z0,z1,ds,rr) ! vertical position
#endif
#ifdef streamr
       call interp(ib,jb,kb,x1,y1,z1,temp,salt,dens,1)
       mra=nint((dens-rmin)/dr)+1
       if(mra.lt.1) mra=1
       if(mra.gt.MR) mra=MR
#ifdef streamts
       mta=nint((temp-tmin)/dtemp)+1
       if(mta.lt.1 ) mta=1
       if(mta.gt.MR) mta=MR
       msa=nint((salt-smin)/dsalt)+1
       if(msa.lt.1 ) msa=1
       if(msa.gt.MR) msa=MR
#endif /*streamts*/
#endif /*streamr*/
       call savepsi(ia,ja-1,ka,mra,mta,msa,2,-1,real(subvol*ff))
       
    elseif(ds.eq.dsu) then ! upward grid-cell exit
       
       scrivi=.false.
       call vertvel(rb,ia,iam,ja,ka)
#ifdef full_wflux
       uu=wflux(ia,ja,ka,1)
#else
       uu=rbg*wflux(ka,NST)+rb*wflux(ka,1)
#endif
#ifdef turb    
       ! uu=uu+upr(5,2)
#endif
       if(uu.gt.0.d0) then
          kb=ka+1
       endif
       z1=dble(ka)
       if(kb.eq.KM+1) then  ! prevent "evaporation"
          !                 nev=nev+1
          kb=KM
          z1=dble(KM)-0.5d0
       endif
#if defined timeanalyt
       call pos_time(1,ia,ja,ka,x0,x1,ts,tt,dsmin,dxyz,ss0,ds,rr)
       call pos_time(2,ia,ja,ka,y0,y1,ts,tt,dsmin,dxyz,ss0,ds,rr)
#else
       call pos_orgn(1,ia,ja,ka,x0,x1,ds,rr)
       call pos_orgn(2,ia,ja,ka,y0,y1,ds,rr)
#endif
    elseif(ds.eq.dsd) then ! downward grid-cell exit
       scrivi=.false.
       call vertvel(rb,ia,iam,ja,ka)
       
#ifdef full_wflux
       if(wflux(ia,ja,ka-1,1).lt.0.d0) kb=ka-1
#else
       if(rbg*wflux(ka-1,NST)+rb*wflux(ka-1,1).lt.0.d0) kb=ka-1
#endif              
       z1=dble(ka-1)
#if defined timeanalyt
       call pos_time(1,ia,ja,ka,x0,x1,ts,tt,dsmin,dxyz,ss0,ds,rr)
       call pos_time(2,ia,ja,ka,y0,y1,ts,tt,dsmin,dxyz,ss0,ds,rr)
#else
       call pos_orgn(1,ia,ja,ka,x0,x1,ds,rr)
       call pos_orgn(2,ia,ja,ka,y0,y1,ds,rr)
#endif
#ifdef sediment
       if(kb.eq.KM-kmt(ia,ja)) then
          nsed=nsed+1
          nrj(ntrac,6)=2
          trj(ntrac,1)=x1
          trj(ntrac,2)=y1
          trj(ntrac,3)=z1
          trj(ntrac,4)=tt
          trj(ntrac,5)=subvol
          trj(ntrac,6)=arct
          nrj(ntrac,1)=ib
          nrj(ntrac,2)=jb
          nrj(ntrac,3)=ka
          nrj(ntrac,4)=niter
          nrj(ntrac,5)=idint(ts)
          nrj(ntrac,7)=1
          !call writedata(13)
          !cycle ntracLoop
       endif
#endif
       
    elseif( ds.eq.dsc .or. ds.eq.dsmin) then  
       ! shortest time is the time-steping 
       scrivi=.true.
#ifdef timeanalyt
       call pos_time(1,ia,ja,ka,x0,x1,ts,tt,dsmin,dxyz,ss0,ds,rr)
       call pos_time(2,ia,ja,ka,y0,y1,ts,tt,dsmin,dxyz,ss0,ds,rr)
       call pos_time(3,ia,ja,ka,z0,z1,ts,tt,dsmin,dxyz,ss0,ds,rr)
#else           
       ! If there is no spatial solution, 
       ! which should correspond to a convergence zone
       if(dse.eq.UNDEF .and. dsw.eq.UNDEF .and. dsn.eq.UNDEF .and. & 
            dss.eq.UNDEF .and. dsu.eq.UNDEF .and. dsd.eq.UNDEF ) then
          
          ! move if atmosphere, freeze if ocean
          ib=ia ; jb=ja ; kb=ka
#ifdef ifs
          call pos_orgn(1,ia,ja,ka,x0,x1,ds,rr) ! zonal crossing 
          call pos_orgn(2,ia,ja,ka,y0,y1,ds,rr) ! merid. crossing 
          call pos_orgn(3,ia,ja,ka,z0,z1,ds,rr) ! vert. crossing 
#else
          x1=x0 ; y1=y0 ; z1=z0 
#endif  
          ! If there is at least one spatial solution 
          ! but the shortest cross time is the time step
       else
          call pos_orgn(1,ia,ja,ka,x0,x1,ds,rr) ! zonal crossing 
          call pos_orgn(2,ia,ja,ka,y0,y1,ds,rr) ! merid. crossing 
          call pos_orgn(3,ia,ja,ka,z0,z1,ds,rr) ! vert. crossing 
       endif
#endif
    endif
    
  end subroutine pos
  

end module mod_pos
