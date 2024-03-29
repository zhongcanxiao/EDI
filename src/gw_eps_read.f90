subroutine gw_eps_read(eps_filename_,gw_)
  USE kinds, ONLY: DP,sgl
  USE HDF5
  use edic_mod, only: gw_eps_data
  
  CHARACTER(LEN=256) :: eps_filename_
  type(gw_eps_data),intent (inout) ,target:: gw_
  
  CHARACTER(LEN=256) :: h5filename      ! Dataset name
  CHARACTER(LEN=256) :: h5datasetname = "matrix-diagonal"     ! Dataset name
  INTEGER     ::   h5rank,h5error ! Error flag
  real(dp), allocatable :: h5dataset_data_double(:), data_out(:)
  integer, allocatable :: h5dataset_data_integer(:)
  INTEGER(HSIZE_T), allocatable :: h5dims(:),h5maxdims(:)
  
  integer :: h5dims1(1),h5dims2(2),h5dims3(3),h5dims4(4),h5dims5(5),h5dims6(6)
  integer:: p_rank,p_size,ik
 
  h5filename=trim(eps_filename_)      ! Dataset name
  !!!!
  ! inverse alll dimensions for description
  h5datasetname='/mf_header/crystal/blat'              !f8 
  h5datasetname='/mf_header/crystal/bvec'              !f8 (3,3)
  
  h5datasetname='/mf_header/gspace/components'         !I4 (ng,3) G pts within cutoff
  h5datasetname='/mf_header/gspace/ng'                 !
  h5datasetname='/mf_header/gspace/FFTgrid'            !i4 (3)
  h5datasetname='/mf_header/gspace/ecutrho'            !
  h5datasetname='/eps_header/gspace/gind_eps2rho'      !i4 (nq,ng)
  h5datasetname='/eps_header/gspace/gind_rho2eps'      !i4 (nq,ng)
  h5datasetname='/eps_header/gspace/nmtx_max'          !i4 
  h5datasetname='/eps_header/gspace/nmtx'              !i4 (nq)  G pts for eps
                                                        
  h5datasetname='/eps_header/gspace/vcoul'             !f8 (nq,nmtx_max)
  h5datasetname='/eps_header/qpoints/nq'               !
  h5datasetname='/eps_header/qpoints/qpts'             !f8 (nq,3)
  h5datasetname='/eps_header/qpoints/qgrid'            !i4 (3)
                                                        
                                                        
  h5datasetname='/mats/matrix'                         !f8 (nq, 1,1, nmtx_max,nmtx_max,2)
  h5datasetname='/mats/matrix-diagonal'                         !f8 (nq, 1,1, nmtx_max,nmtx_max,2)



  h5datasetname='/mf_header/gspace/ng'      !i4 (nq,ng)
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=1) then
      write(*,*)  'h5rank error(should be 1)',h5rank 
  else
      h5dims1=h5dims
  
      if ( .not. allocated(gw_%ng_data)) then
          allocate(gw_%ng_data(h5dims1(1)))
      else
          deallocate(gw_%ng_data)
      allocate(gw_%ng_data(h5dims1(1)))
  endif
  
     
      gw_%ng_data=reshape(h5dataset_data_integer,h5dims1)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  h5datasetname='/eps_header/gspace/nmtx_max'      !i4 (nq,ng)
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=1) then
      write(*,*)  'h5rank error(should be 1)',h5rank 
  else
      h5dims1=h5dims
      
      if (  allocated(gw_%nmtx_max_data)) then
          deallocate(gw_%nmtx_max_data)
      endif
      allocate(gw_%nmtx_max_data(h5dims1(1)))
  
     
      gw_%nmtx_max_data=reshape(h5dataset_data_integer,h5dims1)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  
  
  h5datasetname='/eps_header/gspace/nmtx'      !i4 (nq,ng)
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=1) then
      write(*,*)  'h5rank error(should be 1)',h5rank 
  else
      h5dims1=h5dims
      if (  allocated(gw_%nmtx_data)) then
          deallocate(gw_%nmtx_data)
      endif
      allocate(gw_%nmtx_data(h5dims1(1)))
      gw_%nmtx_data=reshape(h5dataset_data_integer,h5dims1)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  
  h5datasetname='/eps_header/gspace/gind_eps2rho'      !i4 (nq,ng)
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=2) then
   write(*,*)  'h5rank error(should be 2)',h5rank 
  else
      h5dims2=h5dims
      if (  allocated(gw_%gind_eps2rho_data)) then
          deallocate(gw_%gind_eps2rho_data)
      endif
      allocate(gw_%gind_eps2rho_data(h5dims2(1),h5dims2(2)))
      gw_%gind_eps2rho_data=reshape(h5dataset_data_integer,h5dims2)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  h5datasetname='/eps_header/gspace/gind_rho2eps'      !i4 (nq,ng)
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=2) then
   write(*,*)  'h5rank error(should be 2)',h5rank 
  else
      h5dims2=h5dims
      if (  allocated(gw_%gind_rho2eps_data)) then
          deallocate(gw_%gind_rho2eps_data)
      endif
      allocate(gw_%gind_rho2eps_data(h5dims2(1),h5dims2(2)))
      gw_%gind_rho2eps_data=reshape(h5dataset_data_integer,h5dims2)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  
  
  h5datasetname='/mf_header/gspace/components'               !
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=2) then
   write(*,*)  'h5rank error(should be 2)',h5rank 
  else
      h5dims2=h5dims
      if (  allocated(gw_%g_components_data)) then
          deallocate(gw_%g_components_data)
      endif
      allocate(gw_%g_components_data(h5dims2(1),h5dims2(2)))
      gw_%g_components_data=reshape(h5dataset_data_integer,h5dims2)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  
  h5datasetname='/mf_header/crystal/bvec'               !
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=2) then
      write(*,*)  'h5rank error(should be 2)',h5rank 
  else
      h5dims2=h5dims
      if (  allocated(gw_%bvec_data)) then
          deallocate(gw_%bvec_data)
      endif
      allocate(gw_%bvec_data(h5dims2(1),h5dims2(2)))
      gw_%bvec_data=reshape(h5dataset_data_double,h5dims2)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  
  h5datasetname='/mf_header/crystal/blat'               !
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=1) then
   write(*,*)  'h5rank error(should be 1)',h5rank 
  else
      h5dims1=h5dims
      if (  allocated(gw_%blat_data)) then
          deallocate(gw_%blat_data)
      endif
      allocate(gw_%blat_data(h5dims1(1)))
      gw_%blat_data=reshape(h5dataset_data_double,h5dims1)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  
  
  h5datasetname='/eps_header/qpoints/qpts'               !
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=2) then
   write(*,*)  'h5rank error(should be 2)',h5rank 
  else
      h5dims2=h5dims
      if (  allocated(gw_%qpts_data)) then
          deallocate(gw_%qpts_data)
      endif
      allocate(gw_%qpts_data(h5dims2(1),h5dims2(2)))
      gw_%qpts_data=reshape(h5dataset_data_double,h5dims2)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  
  h5datasetname='/eps_header/qpoints/nq'               !
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=1) then
      write(*,*)  'h5rank error(should be 3)',h5rank 
  else
      h5dims1=h5dims
      if (  allocated(gw_%nq_data)) then
          deallocate(gw_%nq_data)
      endif
      allocate(gw_%nq_data(h5dims1(1)))
      gw_%nq_data=reshape(h5dataset_data_integer,h5dims1)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  
  h5datasetname='/mats/matrix-diagonal'                         !f8 (nq, 1,1, nmtx_max,nmtx_max,2)
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=3) then
      write(*,*)  'h5rank error(should be 3)',h5rank 
  else
      h5dims3=h5dims
      if (  allocated(gw_%epsmat_diag_data)) then
         deallocate(gw_%epsmat_diag_data)
      endif
      allocate(gw_%epsmat_diag_data(h5dims3(1),h5dims3(2),h5dims3(3)))
      gw_%epsmat_diag_data=reshape(h5dataset_data_double,h5dims3)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
  
  h5datasetname='/mats/matrix'                         !f8 (nq, 1,1, nmtx_max,nmtx_max,2)
  call h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
  if (h5error<0)  write(*,*)  'h5error',h5error
  if (h5rank/=6) then
      write(*,*)  'h5rank error(should be 6)',h5rank 
  else
      h5dims6=h5dims
      if (  allocated(gw_%epsmat_full_data)) then
          deallocate(gw_%epsmat_full_data)
      endif
      allocate(gw_%epsmat_full_data(h5dims6(1),h5dims6(2),h5dims6(3),h5dims6(4),h5dims6(5),h5dims6(6)))
      gw_%epsmat_full_data=reshape(h5dataset_data_double,h5dims6)
      deallocate(h5dims)
      deallocate(h5dataset_Data_integer)
      deallocate(h5dataset_Data_double)
  endif
 
contains
  subroutine h5gw_read(h5filename,h5datasetname,h5dataset_data_double,h5dataset_Data_integer,h5dims,h5rank,h5error)
    USE kinds, ONLY: DP,sgl
    USE HDF5
    CHARACTER(LEN=256) :: h5groupname = "/mats"     ! Dataset name
    CHARACTER(LEN=256) :: h5name_buffer 
    INTEGER(HID_T) :: h5file_id       ! File identifier
    INTEGER(HID_T) :: h5group_id       ! Dataset identifier
    INTEGER(HID_T) :: h5dataset_id       ! Dataset identifier
    INTEGER(HID_T) :: h5datatype_id       ! Dataset identifier
    INTEGER(HID_T) :: h5dataspace_id
  
    INTEGER :: h5dataype       ! Dataset identifier
   
    CHARACTER(LEN=256), intent(in) :: h5filename      ! Dataset name
    CHARACTER(LEN=256) , intent(in) :: h5datasetname      ! Dataset name
    real(dp), allocatable , intent(inout) :: h5dataset_data_double(:)
    real(dp), allocatable :: data_out(:)
    integer, allocatable , intent(inout) :: h5dataset_data_integer(:)
    LOGICAL :: h5flag,h5flag_integer,h5flag_double           ! TRUE/FALSE flag to indicate 
    INTEGER     ::  h5nmembers,i,h5datasize
    INTEGER(HSIZE_T), allocatable :: h5maxdims(:)
    INTEGER(HSIZE_T), allocatable , intent(inout) :: h5dims(:)
    INTEGER  , intent(inout)    ::   h5rank
    INTEGER  , intent(inout)    ::   h5error ! Error flag
    INTEGER(HID_T) :: file_s1_t,h5_file_datatype 
    INTEGER(HID_T) :: mem_s1_t  ,h5_mem_datatype  
    INTEGER(HID_T) :: debugflag=01
    ! if debugflag<=10, not print epsilon data, else, print
    INTEGER(HID_T)                               :: loc_id, attr_id, data_type, mem_type
    integer:: p_rank,p_size,ik

    if (h5error<debugflag) then
        write(*,*)  'h5error',h5error
    elseif (h5error<0) then 
        return(h5error)
    endif
  
    !h5 file
    CALL h5fopen_f (h5filename, H5F_ACC_RDWR_F, h5file_id, h5error)
    if (h5error<debugflag) then
        write(*,*)  'h5error',       h5error,'h5filename',trim(h5filename),'h5file_id', h5file_id
    elseif (h5error<0)  then
        return(h5error)
    endif
      !dataset
      CALL h5dopen_f(h5file_id,   trim(h5datasetname), h5dataset_id, h5error)
      if (h5error<debugflag) then
        write(*,*)  'h5error',       h5error, trim(h5datasetname),'h5dataset_id', h5dataset_id
      elseif (h5error<0)  then
        return(h5error)
      endif
        ! dataspace
        call h5dget_space_f(h5dataset_id, h5dataspace_id,  h5error) 
        if (h5error<debugflag) then
          write(*,*)  'h5error',       h5error,'h5dataspace_id',h5dataspace_id
        elseif (h5error<0)  then
          return(h5error)
        endif
          ! rank and shape
          call h5sget_simple_extent_ndims_f(h5dataspace_id, h5rank, h5error) 
          if (h5error<debugflag) then
            write(*,*)  'h5error',       h5error,'h5rank',h5rank
            !if (h5rank>0) write(*,*)   h5dims,h5maxdims
          elseif (h5error<0)  then
            return(h5error)
          endif

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1111
! rank=0 scalar
          if(h5rank==0) then
            h5rank=1
            allocate(h5maxdims(h5rank))
            allocate(h5dims(h5rank))
            h5maxdims(1)=1
            h5dims(1)=1
            h5datasize=1
            do i =1,h5rank
              h5datasize=h5datasize*h5dims(i)
            enddo
            allocate(h5dataset_data_integer(1))
            allocate(h5dataset_data_double(1))
            call H5Dget_type_f(h5dataset_id, h5_file_datatype, h5error);
            if (h5error<debugflag) then
              write(*,*)  'h5error',       h5error,'h5_file_datatype',h5_file_datatype
            elseif (h5error<0)  then
              return(h5error)
            endif
            call h5tequal_F(h5_file_datatype,H5T_NATIVE_integer,h5flag_integer,h5error)
            call h5tequal_F(h5_file_datatype,H5T_NATIVE_double,h5flag_double,h5error)
            if (h5flag_integer) then
              CALL h5dread_f(h5dataset_id,  h5_file_datatype, h5dataset_Data_integer(1), h5dims, h5error)
              if (h5error<debugflag) then
                write(*,*)  'h5data',h5error,       h5dataset_Data_integer
              elseif (h5error<0)  then
                return(h5error)
              endif
            elseif (h5flag_double) then
              CALL h5dread_f(h5dataset_id,  h5_file_datatype, h5dataset_Data_double(1), h5dims, h5error)
              if (h5error<debugflag) then
                write(*,*)  'h5data',h5error,       h5dataset_Data_double
              elseif (h5error<0)  then
                return(h5error)
              endif
            else
              write(*,*) 'h5 data type not supported'
            endif
            return(h5error)
          endif
! rank=0 scalar
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1111


          allocate(h5dims(h5rank))
          allocate(h5maxdims(h5rank))
          if (h5error<debugflag) then
            write(*,*)  'h5error',       h5error,'h5rank'
          endif 
          call h5sget_simple_extent_dims_f(h5dataspace_id, h5dims, h5maxdims,h5error ) 
          if (h5error<debugflag) then
            write(*,*)  'h5error',       h5error, 'h5dims', h5dims,'h5maxdims',h5maxdims
          elseif (h5error<0)  then
            return(h5error)
          endif
          h5datasize=1
          do i =1,h5rank
            h5datasize=h5datasize*h5dims(i)
          enddo
          allocate(h5dataset_data_double(h5datasize))
          allocate(h5dataset_data_integer(h5datasize))
        ! datatype of dataset
        call H5Dget_type_f(h5dataset_id, h5_file_datatype, h5error);
          if (h5error<debugflag) then
            write(*,*)  'h5error',       h5error,'h5_file_datatype',h5_file_datatype
          elseif (h5error<0)  then
            return(h5error)
          endif
          ! datatype of memory data, test datatype
          call H5Tget_native_type_f(h5_file_datatype,H5T_DIR_ASCEND_F, h5_mem_datatype,h5error)
          if (h5error<debugflag) then
            write(*,*)  'h5error',       h5error,'h5_mem_datatype',h5_mem_datatype
          elseif (h5error<0)  then
            return(h5error)
          endif
          call h5tequal_F(h5_mem_datatype,H5T_NATIVE_DOUBLE,h5flag,h5error)
            write(*,*)  'h5error',       h5error,'h5_mem_datatype',h5_mem_datatype,h5flag
          if (h5error<debugflag) then
            write(*,*)  'h5error',       h5error,'h5_mem_datatype',h5_mem_datatype,h5flag
          elseif (h5error<0)  then
            return(h5error)
          endif
          call h5tequal_F(h5_file_datatype,H5T_NATIVE_DOUBLE,h5flag,h5error)
            write(*,*)  'h5error',       h5error,'h5_file_datatype',h5_file_datatype,h5flag
          if (h5error<debugflag) then
            write(*,*)  'h5error',       h5error,'h5_file_datatype',h5_file_datatype,h5flag
          elseif (h5error<0)  then
            return(h5error)
          endif
!!!!!!!!!!!!!!!!!!!!!!!!
! read matrix 
            call h5tequal_F(h5_file_datatype,H5T_NATIVE_integer,h5flag_integer,h5error)
            call h5tequal_F(h5_file_datatype,H5T_NATIVE_double,h5flag_double,h5error)
            if (h5flag_integer) then
              CALL h5dread_f(h5dataset_id,  h5_file_datatype, h5dataset_Data_integer, h5dims, h5error)
              if (h5error<debugflag-10) then
                write(*,*)  'h5data',h5error,       h5dataset_Data_integer
              elseif (h5error<0)  then
                return(h5error)
              endif
            elseif (h5flag_double) then
              CALL h5dread_f(h5dataset_id,  h5_file_datatype, h5dataset_Data_double, h5dims, h5error)
              if (h5error<debugflag-10) then
                write(*,*)  'h5data',h5error,       h5dataset_Data_double
              elseif (h5error<0)  then
                return(h5error)
              endif
            else
              write(*,*) 'h5 data type not supported'
            endif
 
! read matrix 
!!!!!!!!!!!!!!!!!!!!!!!!

      CALL h5dclose_f(h5dataset_id, h5error)
    CALL h5fclose_f(h5file_id, h5error)

  end subroutine h5gw_read
end subroutine gw_eps_read


