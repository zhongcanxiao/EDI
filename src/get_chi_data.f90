subroutine get_chi_data()
    use kinds,    only: dp
    use edic_mod,   only: chi_data  ,nchilines 
    use edic_mod,   only:  nqxofchi,nqyofchi,nqzofchi 
    USE cell_base, ONLY: omega, alat, tpiba2, at, bg, tpiba
    USE clib_wrappers,     ONLY: md5_from_file
    CHARACTER(len=32)::chif_md5_cksum="NA"
    CHARACTER(LEN=256) :: chi_filename='chi.dat'
    iunpot_perturb=99 
    open (unit = iunpot_perturb, file = chi_filename, form = 'formatted', &
         status = 'old', err = 99, iostat = ios_perturb)
    99 call errore ('mloc', 'opening file '//TRIM(chi_filename), abs (ios_perturb) )
    nchilines=0
    DO
      READ (iunpot_perturb,*,end=10)
      nchilines = nchilines + 1
    END DO
    10 CLOSE (1)
    REwind (iunpot_perturb)
 
    READ (iunpot_perturb,*)
    read (iunpot_perturb, *) nqxofchi,nqyofchi,nqzofchi
    if (nqxofchi*nqyofchi*nqzofchi/=nchilines-1) then
       write(*,*) 'chi data file corrupt'
    endif
    
    allocate(chi_data(4,nqxofchi*nqyofchi*nqzofchi))
    do ig= 1, nqxofchi*nqyofchi*nqzofchi
         read (iunpot_perturb, * ) chi_data(1,ig),chi_data(2,ig),chi_data(3,ig),chi_data(4,ig)
    enddo
    
    CALL md5_from_file(chi_filename, chif_md5_cksum)
    write (*,*) 'chi files:',trim(chi_filename),'  MD5 sum:',chif_md5_cksum
 
end subroutine get_chi_data
