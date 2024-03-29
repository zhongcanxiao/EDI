#from numpy import *
import json
import numpy as np
import pickle
import os
import pickle
import cmath

def get_velocity_angle(vix,viy):
   if vix>eps :
       theta=np.arctan(viy/vix)
   elif vix<-eps :
       theta=np.arctan(viy/vix)+pi
   elif abs(vix)<=eps :
       if viy>0:
           theta=pi/2
       elif viy<0:
           theta=-pi/2
       elif viy==0:
           theta=0
   return theta
 
def calc_gamma(M,Wt,V,withangle):

    gamma={}
    angleterm={}
    theta={}
    summ={}
    summa={}
    Nkf={}
    dos={}

    for ki in M.keys():
        vix=V[ki][0]
        viy=V[ki][1]
        vimod=(vix**2+viy**2)**.5
        _thetai=get_velocity_angle(vix,viy)

        theta[ki]=_thetai
        Nkf[ki]=len(M[ki])
        gamma[ki]=0
        summ[ki]=0
        summa[ki]=0
        dos[ki]=0
        angleterm[ki]={}

        for kf in M[ki].keys():
            vfx=V[kf][0]
            vfy=V[kf][1]
            vfmod=(vfx**2+vfy**2)**.5
            _thetaf=get_velocity_angle(vfx,vfy)
            if theta.get(kf)!=None:
               if abs(theta[kf]-_thetaf)>1e-4:
                 print 'velocity inconsistency, kf, theta[kf],_thetaf', ki,kf, theta[kf],_thetaf
            else:
               theta[kf]=_thetaf

            _angleterm=1
            if withangle:
               _angleterm=1-(vix*vfx+viy*vfy)/vimod/vfmod
               _angletermp=1-np.cos(_thetai-_thetaf)
               if abs(_angleterm-_angletermp)>1e-2:
                   print 'angle term not fit: cos(dtheta)!=vi.vf/|vi||vf|, %f!=%f'%(_angletermp,_angleterm)
            angleterm[ki][kf]=_angleterm
            gamma[ki]=gamma[ki]+abs(M[ki][kf])**2*Wt[ki][kf]*angleterm[ki][kf] 
            summa[ki]=summa[ki]+abs(M[ki][kf])**2*angleterm[ki][kf] 
            summ[ki]=summ[ki]+abs(M[ki][kf])**2
            dos[ki]=dos[ki]+Wt[ki][kf]

        gamma[ki]=gamma[ki]*2/hbar*nat*Cd
    return [gamma, angleterm,theta,summ,summa,Nkf,dos]
   
def calc_mu(gamma,V,f,df,Emin,Emax):
    mu=0
    Nc=0
    Ncounter=0
    for ki in gamma.keys():
      if E[ki]>Emin and E[ki]<Emax:
        mu=mu+np.linalg.norm(V[ki], ord=2)/gamma[ki]*df[ki]
        Nc=Nc+f[ki]
        Ncounter=Ncounter+1
    if Nc>0:
      mu=mu/Nc
      Nc=Nc/Ncounter
    return [mu,Nc,Ncounter]

##################################
##  constant
##################################

eps=1e-16

kbt=0.0256
hbar=6.5821e-16
pi=3.1415926
RytoeV=13.6
persec2perpicosec=1e-12
evinv_a2cminv_s = 1.519267582e7
A2cm = 1e-8
bohr2A=0.529177

nat=3
Cd=1e-3

Ngrid=180
Nbnd=11
iEc=8  #### iband of CBM

Egap=(2.4004-1.5389)
Ef=0.578
Ef=-0.150
Ef=-Egap/2
Ec=0.6779762221

alat=3.0095 ## wannier V file


withangle=True
restart=True
#restart=False

datajsonfilename='data.json'

wt_filename='kq%d.dat'%Ngrid
Evfilename='tt_geninterp.dat'
if not restart:
    ##################################
    ##  read files
    ##################################
    
    wt_flhndl=open(wt_filename,'r')
    wt_lines=wt_flhndl.readlines()
    
    ki_old=0
    kcounter=0
    #Ninput=0
    Wt={}
    M={}
    Mnl={}
    Mcharge={}
    Kxyz={}
    
    print 'read wt M start'
    for l in wt_lines[2:]:
        kdatl=l.split()
        ki=kdatl[0]
        kixyz=kdatl[2:4]
        kf=kdatl[6]
        kfxyz=kdatl[8:10]
        wt=kdatl[11]

        fmln='out/'+'k'+ki+'.ml'
        fml=open(fmln,'r')
        mllists=fml.readlines()

        fmnln='out/'+'k'+ki+'.mnl'
        fmnl=open(fmnln,'r')
        mnllists=fmnl.readlines()

        if ki!=ki_old:
            kcounter=1
            Wt[ki]={}
            Ml[ki]={}
            Mnl[ki]={}
            M[ki]={}
        mll=mllists[kcounter]
        mnll=mnllists[kcounter]
        kcounter=kcounter+1
        ki_old=ki

        mt1=mll.split()[4]
        mt2=mt1[1:-1].split(',')
        ml=float(mt2[0])+float(mt2[1])*1j
        Ml[ki][kf]=complex(ml)

        mt1=mnll.split()[4]
        mt2=mt1[1:-1].split(',')
        mnl=float(mt2[0])+float(mt2[1])*1j
        Mnl[ki][kf]=complex(mnl)
 
        M[ki][kf]=complex(ml+mnl)

        Wt[ki][kf]=float(wt)

        if Kxyz.get(ki)!=None:
            if Kxyz[ki]!=[float (i) for  i in kixyz]:
                 print 'kxyz inconsistence:',ki, Kxyz[ki],[float (i) for  i in kixyz]
        if Kxyz.get(kf)!=None:
            if Kxyz[kf]!=[float (i) for  i in kfxyz]:
                 print 'kxyz inconsistence:',kf, Kxyz[kf],[float (i) for  i in kfxyz]

        Kxyz[ki]=[float (i) for  i in kixyz]
        Kxyz[kf]=[float (i) for  i in kfxyz]
    print 'read wt M done'

    print 'read E v start'
    V={}
    E={}
    Ev_filehandle=open(Evfilename,'r')
    Ev_lines=Ev_filehandle.readlines()
    allkikf=set()
    for ki in Wt.keys():
        allkikf.add(ki)
        for kf in Wt[ki].keys():
          allkikf.add(kf)
    for ki in allkikf:
        idx=(eval(ki))*Nbnd+3+iEc -1   #### tt_interp file and wt file index of k is different by 1 index_wt=index_v-1
        v=Ev_lines[idx]
        vn=v.split()
        kx_onebyA=eval(vn[1])
        ky_onebyA=eval(vn[2])
        kz_onebyA=eval(vn[2])
        energy=eval(vn[4])
        vix=eval(vn[5])*evinv_a2cminv_s
        viy=eval(vn[6])*evinv_a2cminv_s
        viz=eval(vn[7])*evinv_a2cminv_s
        V[ki]=np.array([vix,viy])
        E[ki]=energy
        

        ####################debug v distortion####################
        [ki1,ki2]=Kxyz[ki]
        if abs(eval(vn[1])/eval(vn[2])-(ki1*3**.5/2)/(ki2+ki1/2))>1e-4:
            print 'ki vi distort'
            print ki, ki1,ki2
            #print ki, ki1-ki2/2,ki2*3**.5/2
            print ki,ki1*3**.5/2, ki2+ki1/2
            print ki,ki1*3**.5/2*3.9454, (ki2+ki1/2)*3.9454
            print v
        ####################debug v distortion####################

        ####################debug k point inconsistency####################
        k12_to_kxy=2*pi/alat/bohr2A/3**.5
        if abs((ki1*3**.5/2)-kx_onebyA/k12_to_kxy)>1e-4 or abs((ki2+ki1/2)-ky_onebyA/k12_to_kxy)>1e-4:
            print 'ki mismatch from V Wt files', ki
            print (ki1*3**.5/2),ki2+ki1/2, kx_onebyA/k12_to_kxy,ky_onebyA/k12_to_kxy
            print ki1,ki2, kx_onebyA,ky_onebyA
        ####################debug k point inconsistency####################
    print 'read v, E, done'

    print 'calculate gamma start'
    [gamma, angleterm,theta,summ,summa,Nkf,dos]=calc_gamma(M,Wt,V,withangle)
    
    print 'calculate gamma done'

    f={}
    df={}
    for ki in E.keys():
        f[ki]=1/(1+np.exp((E[ki]-Ec-Ef)/kbt))
        df[ki]=f[ki]*(1-f[ki])/kbt

#################################################################################################
#data:      ki-kf                                 ki
#      M[ki][kf], Wt[ki][kf],      |          V,E,f,df,Kxyz, 
#      angleterm[ki][kf],          |          gamma,theta,summ,summa,Nkf,dos
#################################################################################################
    
    ##################################
    ##   save data
    ##################################
    data=[M,Ml,Mnl,Wt,angleterm,V,E,f,df,Kxyz,gamma,theta,summ,summa,Nkf,dos]
   
    #datajson=json.dumps(data)
    #with open(datajsonfilename,'w') as fp:
    #    fp.write(datajson)
    #fp.close()
    ####pickle bug
    datapicklefilename='data.pickle'
    datapicklefilehanle=open(datapicklefilename,'w')
    pickle.dump(data,datapicklefilehanle)
    datapicklefilehanle.close()
    print 'save data done'
else:
    ####################################
    ##    load data
    ####################################
    datapicklefilename='data.pickle'
    with open(datapicklefilename,'r') as fp:
        data=pickle.load(fp)
    [M,Ml,Mnl,Wt,angleterm,V,E,f,df,Kxyz,gamma,theta,summ,summa,Nkf,dos]=data
    print 'load data done'


#################################################################################################
#data:      ki-kf                                 ki
#      M[ki][kf], Wt[ki][kf],      |          V,E,f,df,Kxyz, 
#      angleterm[ki][kf],          |          gamma,theta,summ,summa,Nkf,dos
#################################################################################################
    

##########################################################################################################
##    calculate energy limited mu,
##########################################################################################################
print 'calculate mu start'
Elimit=np.arange(6)*0.01
Ncounterh=[0]*6
Ncounterl=[0]*6
Nch=[0]*6
Ncl=[0]*6
muh=[0]*6
mul=[0]*6


for i  in range(len(Elimit)):
    Emin=-10
    Emax=Elimit[i]+Ec
    [mu,Nc,Ncounter]=calc_mu(gamma,V,f,df,Emin,Emax)
    mul[i]=mu
    Ncl[i]=Nc
    Ncounterl[i]=Ncounter
    Emin=Elimit[i]+Ec
    Emax=10
    [mu,Nc,Ncounter]=calc_mu(gamma,V,f,df,Emin,Emax)
    muh[i]=mu
    Nch[i]=Nc
    Ncounterh[i]=Ncounter

mupl='#Elimit: muh Nch Ncounterh; mul Ncl Ncounterl \n'
for i  in range(len(Elimit)):
    mupl=mupl+'%f:  %f    %e %d;  %f %e  %d \n'%(Elimit[i],muh[i],  Nch[i], Ncounterh[i],  mul[i],Ncl[i],Ncounterl[i])


mufilename='muvsElimit.plt'
with open(mufilename,'w') as fp:
   fp.write(mupl)

print 'calculate mu done'

##########################################################################################################
##    debug:           print ki property: 
##########################################################################################################


pl= '#ki: kxyz(crystal), gamma (s^-1), E(eV) ,  vx vy(cm/s),vx vy(au), f, df(eV^-1), dos, sum m, sum m*angleterm,   Nkf\n'
for ki in M.keys():
   lp=tuple([ki,Kxyz[ki][0],Kxyz[ki][1],gamma[ki],E[ki],V[ki][0]*evinv_a2cminv_s,V[ki][1]*evinv_a2cminv_s,V[ki][0],V[ki][1],f[ki],df[ki],dos[ki],summ[ki],summa[ki],Nkf[ki]])
   pl=pl+'%s  %10.14e %10.14e  %10.14e %10.14e %10.14e %10.14e %10.14e %10.14e  %10.14e   %10.14e  %10.14e     %10.14e   %10.14e   %d \n'%lp


file_plotki_name='ki.plt'
file_plotki_handle=open(file_plotki_name,'w')
file_plotki_handle.write(pl)


##########################################################################################################
##    debug:           print ki-kf property: 
##########################################################################################################

kfdir='kf-kis/'
if not os.path.exists(kfdir):
   os.mkdir(kfdir)

for ki in M.keys():
    pl= '#ki: kxyz(crystal), gamma (s^-1), E(eV) ,  vx vy(cm/s),vx vy(au), f, df(eV^-1), dos, sum m, sum m*angleterm,   Nkf\n'
    lp=tuple([ki,Kxyz[ki][0],Kxyz[ki][1],gamma[ki],E[ki],V[ki][0]*evinv_a2cminv_s,V[ki][1]*evinv_a2cminv_s,V[ki][0],V[ki][1],f[ki],df[ki],dos[ki],summ[ki],summa[ki],Nkf[ki]])
    pl=pl+'# %s: %10.14e %10.14e  %10.14e %10.14e %10.14e %10.14e %10.14e %10.14e  %10.14e   %10.14e  %10.14e     %10.14e   %10.14e   %d \n'%lp
    pl=pl+'#kf: kfx, kfy(crystal), Wt, M1 M2, |M|, arg(M),vf1,vf2, E(eV), angleterm(1-cos(theta)), thetai, thetaf\n'
    for kf in M[ki].keys():
       lp=tuple([ kf, Kxyz[kf][0],Kxyz[kf][1],Wt[ki][kf],M[ki][kf].real,M[ki][kf].imag,abs(M[ki][kf]),cmath.phase(M[ki][kf]), V[kf][0],V[kf][1],E[kf],angleterm[ki][kf],theta[ki],theta[kf]])
       pl=pl+'%s %10.14e %10.14e     %10.14e    %10.14e %10.14e  %10.14e %10.14e     %10.14e %10.14e     %10.14e   %10.14e %10.14e  %10.14e \n'%lp
       
    file_plotkf_name=kfdir+'/k%s.plt'%ki
    file_plotkf_handle=open(file_plotkf_name,'w')
    file_plotkf_handle.write(pl)
