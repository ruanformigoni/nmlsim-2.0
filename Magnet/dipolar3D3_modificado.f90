!
!	O programa calcula os coeficientes da energia dipolar 
!	entre duas particulas slanted simples
!   
!	As dimensoes e posicoes das particulas (em nm) sao definidas no arquivo de entrada
!	IN_dipolar3D.dat, que tem 12 linhas com os parametros:
!
!	O arquivo de entrada contem:
!	px_i(1),py_i(1): coordenadas do canto superior esquerdo (nm) da particula i em relacao ao seu centro
!	px_i(2),py_i(2): coordenadas do canto superior direito  (nm) da particula i em relacao ao seu centro
!	px_i(3),py_i(3): coordenadas do canto inferior esquerdo (nm) da particula i em relacao ao seu centro
!	px_i(4),py_i(4): coordenadas do canto inferior direito  (nm) da particula i em relacao ao seu centro
!	t_i	   : espessura (nm) da particula i
!	xyz0_i(1),xyz0_i(2),xyz0_i(3): 	distancia x, y, e z 
!	   do centro da particula i em relacao a origem (0,0,0)
!	px_j(1),py_j(1): coordenadas do canto superior esquerdo (nm) da particula j em relacao ao seu centro
!	px_j(2),py_j(2): coordenadas do canto superior direito  (nm) da particula j em relacao ao seu centro
!	px_j(3),py_j(3): coordenadas do canto inferior esquerdo (nm) da particula j em relacao ao seu centro
!	px_j(4),py_j(4): coordenadas do canto inferior direito  (nm) da particula j em relacao ao seu centro
!	t_j	   : espessura (nm) da particula j
!	xyz0_j(1),xyz0_j(2),xyz0_j(3): 	distancia x, y, e z 
!	   do centro da particula j em relacao a origem (0,0,0)
!	 	        
!
!	O arquivo de saida OUT_dipolar3D.dat contem:
!	Coluna 1: I1
!	Coluna 2: I2,I3,I4
!	Coluna 3: I5,I6,I7
!
!	A energia de acoplamento (eV) deve ser calculada como
!	Uc = K*(
!	        a1*a2*(I1+I2) + b1*b2*(I1+I3) + c1*c2*(I1+I4) +
!	        (a1*b2+a2*b1)*I5 + (a1*c2+a2*c1)*I6 + (b1*c2+b2*c1)*I7
!	       )
!	onde
!	
!	ai = SIN(theta_i)*COS(phi_i)
!	bi = SIN(theta_i)*SIN(phi_i)
!	ci = COS(theta_i)
!	K = mu0*Ms*Ms*JtoeV*ten**(-27)/(four*Pi)
!	JtoeV = 6.242_lg*ten**(18)
!
!	OBS: Arquivo modificado de dipolar3D3.f90 para suportar comunicação com C++

MODULE precision_def
	use iso_c_binding
	IMPLICIT NONE
	INTEGER, PARAMETER :: lg=selected_real_kind(15,397)
	INTEGER, PARAMETER :: nmc=1E6 !define o numero de amostras no metodo MC
        REAL*8,PARAMETER :: zero=0.0000000000000,half=0.50000000000,one=1.0000000000,tres=3.00000000000
END MODULE precision_def
	
MODULE positions_particles
	USE precision_def
	IMPLICIT NONE
	REAL*8  :: xyz0_i(3)
	REAL*8  :: xyz0_j(3)
END MODULE positions_particles

MODULE dimensions_particles
	USE precision_def
	IMPLICIT NONE 
	REAL*8  :: w_i, t_i
	REAL*8  :: w_j, t_j
END MODULE dimensions_particles

MODULE ab
	USE precision_def
	IMPLICIT NONE
	REAL*8  :: au_i,bu_i,ad_i,bd_i
	REAL*8  :: au_j,bu_j,ad_j,bd_j
END MODULE ab



REAL*8 FUNCTION dipolar3D(px_i, py_i, t_i, xyz0_i, px_j, py_j, t_j, xyz0_j,ints) bind(c, name='dipolar3D3')
	USE precision_def
	!USE positions_particles
	!USE dimensions_particles
	!USE ab
	IMPLICIT NONE
  	REAL*8,INTENT(IN)  	:: px_i(4), py_i(4)
	REAL*8,INTENT(IN)  	:: t_i
	REAL*8,INTENT(IN)   :: xyz0_i(3)
	REAL*8,INTENT(IN)  	:: px_j(4), py_j(4)
	REAL*8,INTENT(IN)  	:: t_j
	REAL*8,INTENT(IN)   :: xyz0_j(3)
	REAL*8,INTENT(OUT)	:: ints(7)
	
	REAL*8  :: au_i,bu_i,ad_i,bd_i
	REAL*8  :: au_j,bu_j,ad_j,bd_j
	REAL*8  :: w_i
	REAL*8  :: w_j
	
	INTERFACE
	
		SUBROUTINE MC_dipolar(px_i,py_i,t_i,xyz0_i,px_j,py_j,t_j,xyz0_j,w_i,au_i,bu_i,ad_i,bd_i,w_j,au_j,bu_j,ad_j,bd_j,int0)
		USE precision_def
		!USE dimensions_particles
		!USE positions_particles
		!USE ab
		IMPLICIT NONE
		REAL*8,INTENT(IN)  	:: px_i(4), py_i(4)
		REAL*8,INTENT(IN)  	:: t_i
		REAL*8,INTENT(IN)   :: xyz0_i(3)
		REAL*8,INTENT(IN)  	:: px_j(4), py_j(4)
		REAL*8,INTENT(IN)  	:: t_j
		REAL*8,INTENT(IN)   :: xyz0_j(3)
		
		REAL*8,INTENT(IN)  :: w_i
		REAL*8,INTENT(IN)  :: au_i,bu_i,ad_i,bd_i
		REAL*8,INTENT(IN)  :: w_j
		REAL*8,INTENT(IN)  :: au_j,bu_j,ad_j,bd_j
		
		REAL*8,INTENT(OUT)  :: int0(7)
		END SUBROUTINE MC_dipolar
		
	END INTERFACE


!	PRINT*,''
!	PRINT*,'---> RUNNING....'
!	PRINT*,''

99	FORMAT(E13.4)
100	FORMAT(E13.4,E13.4,E13.4)

	!OPEN(unit=9,  file='IN_dipolar3D.dat',  status='unknown')
	!OPEN(unit=10, file='OUT_dipolar3D.dat', status='unknown')

	
	!READ(9,*)px_i(1),py_i(1)
	!READ(9,*)px_i(2),py_i(2)
	!READ(9,*)px_i(3),py_i(3)
	!READ(9,*)px_i(4),py_i(4)
	!READ(9,*)t_i
	!READ(9,*)xyz0_i(1),xyz0_i(2),xyz0_i(3)
	!READ(9,*)px_j(1),py_j(1)
	!READ(9,*)px_j(2),py_j(2)
	!READ(9,*)px_j(3),py_j(3)
	!READ(9,*)px_j(4),py_j(4)
	!READ(9,*)t_j
	!READ(9,*)xyz0_j(1),xyz0_j(2),xyz0_j(3)
	!CLOSE(unit=9)


	w_i  =  px_i(2) - px_i(1)
	au_i = (py_i(2) - py_i(1))/w_i	
	bu_i =  py_i(1) - au_i*px_i(1)
	ad_i = (py_i(3) - py_i(4))/w_i	
	bd_i =  py_i(3) - ad_i*px_i(3)

	w_j  =  px_j(2) - px_j(1)
	au_j = (py_j(2) - py_j(1))/w_j	
	bu_j =  py_j(1) - au_j*px_j(1)
	ad_j = (py_j(3) - py_j(4))/w_j	
	bd_j =  py_j(3) - ad_j*px_j(3)


	CALL RANDOM_SEED()
	CALL MC_dipolar(px_i,py_i,t_i,xyz0_i,px_j,py_j,t_j,xyz0_j,w_i,au_i,bu_i,ad_i,bd_i,w_j,au_j,bu_j,ad_j,bd_j,ints)
	
	!WRITE(10,99)ints(1)
	!WRITE(10,100)-tres*ints(2),-tres*ints(3),-tres*ints(4)
	!WRITE(10,100)-tres*ints(5),-tres*ints(6),-tres*ints(7)
	!CLOSE(unit=10)
	
	ints(2) = -tres*ints(2)
	ints(3) = -tres*ints(3)
	ints(4) = -tres*ints(4)
	ints(5) = -tres*ints(5)
	ints(6) = -tres*ints(6)
	ints(7) = -tres*ints(7)


END FUNCTION dipolar3D
	


	SUBROUTINE MC_dipolar(px_i,py_i,t_i,xyz0_i,px_j,py_j,t_j,xyz0_j,w_i,au_i,bu_i,ad_i,bd_i,w_j,au_j,bu_j,ad_j,bd_j,int0)
	USE precision_def
	!USE dimensions_particles
	!USE positions_particles
	!USE ab
	IMPLICIT NONE
	REAL*8,INTENT(IN)  	:: px_i(4), py_i(4)
	REAL*8,INTENT(IN)  	:: t_i
	REAL*8,INTENT(IN)   :: xyz0_i(3)
	REAL*8,INTENT(IN)  	:: px_j(4), py_j(4)
	REAL*8,INTENT(IN)  	:: t_j
	REAL*8,INTENT(IN)   :: xyz0_j(3)
		
	REAL*8,INTENT(IN)  :: w_i
	REAL*8,INTENT(IN)  :: au_i,bu_i,ad_i,bd_i
	REAL*8,INTENT(IN)  :: w_j
	REAL*8,INTENT(IN)  :: au_j,bu_j,ad_j,bd_j
	
	REAL*8,INTENT(OUT)  :: int0(7)
	REAL*8 :: x_i(3), x_j(3)
	REAL*8 :: f0(7), int_ij(7)
	REAL*8 :: vi, ymin_i, ymax_i
	REAL*8 :: vj, ymin_j, ymax_j
	INTEGER  :: i0
	

	vi = w_i*t_i
	vj = w_j*t_j

	f0 = zero

	DO i0=1,nmc
		
!		VOLUME i
		CALL xyz_i(x_i, ymin_i, ymax_i)
!		VOLUME j
		CALL xyz_j(x_j, ymin_j, ymax_j)
		
		CALL fu(x_i, x_j, int_ij)
		f0 = f0 + (ymax_i - ymin_i)*(ymax_j - ymin_j)*int_ij
	
	ENDDO

	int0 = vi*vj*f0/(REAL(nmc))
	
	
	CONTAINS


		FUNCTION frand(kmin, kmax)
		USE precision_def
		IMPLICIT NONE
		REAL*8,INTENT(IN)  :: kmin,kmax
		REAL*8	     :: rnd0,frand
		   CALL RANDOM_NUMBER(rnd0)
		   frand = kmin*(one - rnd0) + rnd0*kmax
		END FUNCTION frand


		SUBROUTINE xyz_i(x_0i, ymin0i, ymax0i)
		USE precision_def
		IMPLICIT NONE
		REAL*8,INTENT(OUT) :: x_0i(3), ymin0i, ymax0i
		   x_0i(1) = frand(-half*w_i, half*w_i)
		   ymin0i  = ad_i*x_0i(1)+bd_i
		   ymax0i  = au_i*x_0i(1)+bu_i
		   x_0i(2) = frand(ymin0i, ymax0i)
		   x_0i(3) = frand(-half*t_i, half*t_i)
		END SUBROUTINE xyz_i


		SUBROUTINE xyz_j(x_0j, ymin0j, ymax0j)
		USE precision_def
		IMPLICIT NONE
		REAL*8,INTENT(OUT) :: x_0j(3), ymin0j, ymax0j
		   x_0j(1) = frand(-half*w_j, half*w_j)
		   ymin0j  = ad_j*x_0j(1)+bd_j
		   ymax0j  = au_j*x_0j(1)+bu_j
		   x_0j(2) = frand(ymin0j, ymax0j)
		   x_0j(3) = frand(-half*t_j, half*t_j)
		END SUBROUTINE xyz_j


		SUBROUTINE fu(x0_i, x0_j, int_0)
		USE precision_def
		IMPLICIT NONE
		REAL*8,INTENT(IN)  :: x0_i(3),x0_j(3)
		REAL*8,INTENT(OUT) :: int_0(7)
		REAL*8	     :: eta,csi,kap
		REAL*8	     :: eta2,csi2,kap2
		REAL*8	     :: den1,den2

		   eta  = xyz0_j(1)+x0_j(1)-xyz0_i(1)-x0_i(1)
		   csi  = xyz0_j(2)+x0_j(2)-xyz0_i(2)-x0_i(2)
		   kap  = xyz0_j(3)+x0_j(3)-xyz0_i(3)-x0_i(3)
		   eta2 = eta*eta
		   csi2 = csi*csi
		   kap2 = kap*kap
		   den1 = SQRT(eta2 + csi2 + kap2)
		   den2 = den1**(-5)

		   int_0(1) = den1**(-3)
		   int_0(2) = eta2*den2
		   int_0(3) = csi2*den2
		   int_0(4) = kap2*den2
		   int_0(5) = eta*csi*den2
		   int_0(6) = eta*kap*den2
		   int_0(7) = csi*kap*den2

		END SUBROUTINE fu
		
		
		
	END SUBROUTINE MC_dipolar


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
