%This is a RE-re-rederived model. The wasp finally flies in the first
%quadrant.

function dQ = myODE_3c(t,Q)  %Q -> x,y,theta,phi,xdot,ydot,thetadot,phidot
global L1 L2 L3 rho rhoA muA ahead abutt bhead bbutt K c F alpha tau0 f...
    g thetaR

%Where 
%m1 is the mass of the head-thorax
%m2 is the mass of the abdomen (petiole + gaster)
%I1 is the moment of inertia of the head-thorax
%I2 is the moment of inertia of the abdomen (petiole + gaster)
%K is the torsional spring constant of the thorax-petiole joint
%c is the torsional damping constant of the thorax-petiole joint
%F is the F vector (aerodynamics)
%alpha is the angle of the aerodynamic vectory with respect to the
%head-thorax
%tau is the torque applied
%g is the acceleration due to gravity in cm/(s^2)

%masses and moment of inertias in terms of insect density and eccentricity
%of the head/thorax & gaster
m1 = rho*(4/3)*pi*(bhead^2)*ahead; %m1 is the mass of the head-thorax
m2 = rho*(4/3)*pi*(bbutt^2)*abutt; %m2 is the mass of the abdomen 
    %(petiole + gaster)
echead = ahead/bhead; %Eccentricity of head-thorax (unitless)
ecbutt = abutt/bbutt; %Eccentricity of gaster (unitless)
I1 = (1/5)*m1*(ahead^2)*(1 + echead^2); %Moment of inertia of the 
    %head-thorax
I2 = (1/5)*m2*(abutt^2)*(1 + ecbutt^2); %Moment of inertia of the gaster

S = pi*bhead^2; %This is the surface area of the object experiencing drag.
                %In this case, it is modeled as a sphere.

%Now to handle the Reynolds number stuff:
Rex = rhoA*Q(5)*(2*bhead)/muA; %Reynolds number in the x-direction
Rey = rhoA*Q(6)*(2*bhead)/muA; %Reynolds number in the y-direction

%Coefficient of drag stuff:
Cdx = 24/abs(Rex) + 6/(1 + sqrt(abs(Rex))) + 0.4; %Coefficient of drag in the x-direction
Cdy = 24/abs(Rey) + 6/(1 + sqrt(abs(Rey))) + 0.4; %Coefficient of drag in the y-direction

%dQ = zeros(8, 1);

%These are the coefficients for our acceleration equations imported from
%Mathematica. Careful, this'll get messy.

k1 = m1 + m2;
k2 = (-1).*L1.*m1.*sin(Q(3));
k3 = (-1).*L2.*m2.*sin(Q(4));
k4 = (-1).*F.*cos(alpha+Q(3))+(1/2).*Cdx.*rhoA.*S.*abs(Q(5)).*Q(5)+( ...
    -1).*L1.*m1.*cos(Q(3)).*Q(7).^2+L2.*m2.*cos(Q(4)).*Q(8).^2;
k5 = L1.*m1.*cos(Q(3));
k6 = L2.*m2.*cos(Q(4));
k7 = g.*(m1+m2)+(1/2).*Cdy.*rhoA.*S.*abs(Q(6)).*Q(6)+(-1).*L1.*m1.*Q( ...
    7).^2.*sin(Q(3))+(-1).*F.*sin(alpha+Q(3))+(-1).*L2.*m2.*Q(8).^2.* ...
      sin(Q(4));  %  Tom changed this to a +1/2 before Cd
k8 = I1+L1.^2.*m1;
k9 = K.*((-1).*pi+(-1).*thetaR+(-1).*Q(3)+Q(4))+g.*L1.*m1.*cos(Q(3)).* ...
    Q(7)+(-1).*L1.*m1.*cos(Q(3)).*Q(5).*Q(7)+L1.*m1.*cos(Q(3)).*Q(5).* ...
      Q(7).^2+(-1).*c.*((-1).*Q(7)+Q(8))+(-1).*F.*L3.*sin(alpha)+(-1).* ...
      tau0.*sin(2.*f.*pi.*t)+(-1).*L1.*m1.*Q(6).*Q(7).*sin(Q(3))+L1.* ...
      m1.*Q(6).*Q(7).^2.*sin(Q(3));
k10 = I2+L2.^2.*m2;
k11 = (-1).*K.*((-1).*pi+(-1).*thetaR+(-1).*Q(3)+Q(4))+g.*L2.*m2.*cos(Q( ...
    4)).*Q(8)+(-1).*L2.*m2.*cos(Q(4)).*Q(5).*Q(8)+L2.*m2.*cos(Q(4)).* ...
      Q(5).*Q(8).^2+c.*((-1).*Q(7)+Q(8))+tau0.*sin(2.*f.*pi.*t)+(-1).* ...
      L2.*m2.*Q(6).*Q(8).*sin(Q(4))+L2.*m2.*Q(6).*Q(8).^2.*sin(Q(4));

dQ(1,1) = Q(5); %This is x dot
dQ(2,1) = Q(6); %This is y dot
dQ(3,1) = Q(7); %This is theta dot
dQ(4,1) = Q(8); %This is phi dot
%  everywhere you have a captheta -- that is Q(7), capphi is Q(8)
%  every xdot is Q(5) and ydot is Q(6);
%  every theta is Q(3) and phi is Q(4)
%  there are no x or y alone...   

%x double dot
dQ(5,1) = (-1).*((-1).*k10.*k1.*k2.^2+(-1).*k10.*k1.*k5.^2+k3.^2.* ...
    k5.^2+(-2).*k2.*k3.*k5.*k6+k2.^2.*k6.^2+k10.*k1.^2.*k8+( ...
    -1).*k1.*k3.^2.*k8+(-1).*k1.*k6.^2.*k8).^(-1).*(k11.*k3.* ...
      k5.^2+(-1).*k10.*k4.*k5.^2+(-1).*k11.*k2.*k5.*k6+k10.* ...
      k2.*k5.*k7+(-1).*k11.*k1.*k3.*k8+k10.*k1.*k4.*k8+(-1).* ...
      k4.*k6.^2.*k8+k3.*k6.*k7.*k8+(-1).*k10.*k1.*k2.*k9+(-1) ...
      .*k3.*k5.*k6.*k9+k2.*k6.^2.*k9);
  
%y double dot
dQ(6,1) = (-1).*(k10.*k1.*k2.^2+k10.*k1.*k5.^2+(-1).*k3.^2.*k5.^2+ ...
    2.*k2.*k3.*k5.*k6+(-1).*k2.^2.*k6.^2+(-1).*k10.*k1.^2.* ...
     k8+k1.*k3.^2.*k8+k1.*k6.^2.*k8).^(-1).*(k11.*k2.*k3.* ...
     k5+(-1).*k10.*k2.*k4.*k5+(-1).*k11.*k2.^2.*k6+k10.* ...
     k2.^2.*k7+k11.*k1.*k6.*k8+(-1).*k3.*k4.*k6.*k8+(-1).* ...
    k10.*k1.*k7.*k8+k3.^2.*k7.*k8+k10.*k1.*k5.*k9+(-1).* ...
    k3.^2.*k5.*k9+k2.*k3.*k6.*k9);

%Theta double dot
dQ(7,1) = (-1).*(k10.*k1.*k2.^2+k10.*k1.*k5.^2+(-1).*k3.^2.*k5.^2+ ...
    2.*k2.*k3.*k5.*k6+(-1).*k2.^2.*k6.^2+(-1).*k10.*k1.^2.* ...
     k8+k1.*k3.^2.*k8+k1.*k6.^2.*k8).^(-1).*((-1).*k11.*k1.* ...
     k2.*k3+k10.*k1.*k2.*k4+(-1).*k11.*k1.*k5.*k6+k3.*k4.* ...
      k5.*k6+(-1).*k2.*k4.*k6.^2+k10.*k1.*k5.*k7+(-1).*k3.^2.* ...
      k5.*k7+k2.*k3.*k6.*k7+(-1).*k10.*k1.^2.*k9+k1.*k3.^2.* ...
      k9+k1.*k6.^2.*k9);

%Phi double dot
dQ(8,1) = (-1).*(k10.*k1.*k2.^2+k10.*k1.*k5.^2+(-1).*k3.^2.*k5.^2+ ...
    2.*k2.*k3.*k5.*k6+(-1).*k2.^2.*k6.^2+(-1).*k10.*k1.^2.* ...
     k8+k1.*k3.^2.*k8+k1.*k6.^2.*k8).^(-1).*(k11.*k1.*k2.^2+ ...
     k11.*k1.*k5.^2+(-1).*k3.*k4.*k5.^2+k2.*k4.*k5.*k6+k2.* ...
      k3.*k5.*k7+(-1).*k2.^2.*k6.*k7+(-1).*k11.*k1.^2.*k8+k1.* ...
      k3.*k4.*k8+k1.*k6.*k7.*k8+(-1).*k1.*k2.*k3.*k9+(-1).* ...
      k1.*k5.*k6.*k9);

end