$title AGPE Dispatch - Industry 2

Set
   t 'hours'         / t1*t48 /;

Table data(t,*)
    lambda  Pl1u    Pl2u    Ppvu
t1  0.0740  0.6800  0.9400  0.0000
t2  0.0722  0.7000  0.9500  0.0000
t3  0.0768  0.6800  0.9200  0.0000
t4  0.0771  0.6800  0.9200  0.0000
t5  0.0798  0.6800  0.9800  0.0000
t6  0.0810  0.7200  1.0000  0.0000
t7  0.0965  0.8500  1.0000  0.0556
t8  0.1168  0.9000  0.9600  0.1667
t9  0.1211  0.9700  0.9100  0.3333
t10 0.1080  0.9700  0.8200  0.5556
t11 0.1010  0.9700  0.7300  0.7778
t12 0.0872  0.9900  0.6300  0.8889
t13 0.0968  0.9800  0.6700  1.0000
t14 0.0846  0.9100  0.6300  0.8889
t15 0.0988  0.8900  0.5900  0.7778
t16 0.0884  0.9500  0.5900  0.5556
t17 0.1161  0.9400  0.5800  0.3333
t18 0.0946  1.0000  0.5900  0.1667
t19 0.0937  0.9500  0.7300  0.0556
t20 0.0969  0.9400  0.8500  0.0000
t21 0.1026  0.8100  0.9500  0.0000
t22 0.0968  0.7700  0.9500  0.0000
t23 0.1006  0.7600  0.9600  0.0000
t24 0.0846  0.7100  0.9400  0.0000
t25 0.0769  0.6700  0.9400  0.0000
t26 0.0769  0.7000  0.9400  0.0000
t27 0.0828  0.6800  0.9200  0.0000
t28 0.0825  0.6700  0.9200  0.0000
t29 0.0844  0.6800  0.9900  0.0000
t30 0.0816  0.7200  0.9900  0.0000
t31 0.1038  0.8500  1.0000  0.0556
t32 0.1095  0.8900  0.9500  0.1667
t33 0.1170  0.9700  0.9000  0.3333
t34 0.1028  0.9600  0.8300  0.5556
t35 0.1057  0.9700  0.7300  0.7778
t36 0.0854  1.0000  0.6300  0.8889
t37 0.0902  0.9800  0.6600  1.0000
t38 0.0877  0.9200  0.6200  0.8889
t39 0.0942  0.9000  0.6000  0.7778
t40 0.0878  0.9500  0.5800  0.5556
t41 0.1207  0.9400  0.5800  0.3333
t42 0.0900  1.0000  0.6000  0.1667
t43 0.0985  0.9500  0.7400  0.0556
t44 0.0937  0.9300  0.8500  0.0000
t45 0.0993  0.8100  0.9500  0.0000
t46 0.0971  0.7600  0.9500  0.0000
t47 0.1018  0.7500  0.9600  0.0000
t48 0.0817  0.7100  0.9400  0.0000;   
* -----------------------------------------------------
* -----------------------------------------------------

Variable
   AGPE        'AGPE BENEFIT $/yr'
   SOC(t)      'State of Charge kWh'
   Pd(t)       'Power discharge kW'
   Pch(t)      'Power Charge kW' 
   Pb(t)       'Power bought from the public grid kW'
   Ps(t)       'Power sold to the public grid kW'
   Ppv(t)      'Power produced by PV plant kW'
   Pl1(t)      'Power demand kW'
   Exc1        'Surplus type 1'
   Exc2        'Surplus type 2'
   Imp         'imports';  
      
Binary Variable
   w(t)     
   u(t)   

Scalar

   Plmax     / 110 /
   C         / 355  /
   Ppvmax    / 220 /
   eff_c     / 0.95 /
   eff_d     / 0.92 /
   CR_c      / 0.3 /
   CR_d      / 0.2 /
   Pmax      /220/
   kappa     /400/
   DoD       /0.8/  
   cunog      /0.18/    
   SOC0      /177.5/
   cu        /0.25/;
   
 
SOC.up(t)     = ((1-DoD)/2+DoD)*C;
SOC.lo(t)     = ((1-DoD)/2)*C;
Pch.lo(t) = 0;
Pd.lo(t) = 0;
Pb.lo(t) = 0;
Ps.lo(t) = 0;

Equation SWcalc, balance2, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10;

SWcalc..        AGPE =e= -kappa*Pmax+(Exc1-Imp)*cu-Exc1*cunog+(365/2)*sum((t), (data(t,'lambda')*Exc2(t)));
balance2(t)..   Pd(t) + Pb(t) + Ppv(t) =e= Pch(t) + Ps(t) + Pl1(t); 
r1(t)..         SOC(t) =e= SOC0$(ord(t)=1) + SOC(t-1)$(ord(t)>1) + Pch(t)*eff_c  - Pd(t)/eff_d;
r2(t)..         Pch(t)  =l= CR_c*C*w(t);
r3(t)..         Pd(t) =l= CR_d*C*(1-w(t));
r4(t)..         Pb(t) =l= Pmax*u(t);
r5(t)..         Ps(t) =l= Pmax*(1-u(t));
r6(t)..         Ppv(t) =e= Ppvmax*data(t,'Ppvu');
r7(t)..         Pl1(t) =e= Plmax*data(t,'Pl1u');
r8..            Exc1=e=(365/2)*sum((t), ps(t));
r9..            Imp=e=(365/2)*sum((t), pb(t));
r10(t)..        Exc2(t)=e=Ps(t);  

*option mip=gurobi;
Model industry1 / all /;
solve industry1 using MIP maximizing AGPE;

execute_unload 'industry1.gdx';