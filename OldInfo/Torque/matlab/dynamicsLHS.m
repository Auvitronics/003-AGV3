%% Definitions:

% define frames:
% x0y0z0: Origin wheels-mid, z0 always up, x0 always along heading
% x1y1z1: Origin on wheels-mid, x1 along wheels-connect (L->R), y1 along
% the base (at angle -q_imu from the x0 axis)

clear all
syms x psii dpsi dx ddpsi ddx L g mw mb real
syms XXw XYw XZw YYw YZw ZZw real
syms XXb XYb XZb YYb YZb ZZb real
syms tau_R tau_L R real
syms MXb MYb MZb real

syms t X(t) PSI(t) dX dPSI ddX ddPSI real
dX=diff(X,t);dPSI=diff(PSI,t);
ddX=diff(dX,t);ddPSI=diff(dPSI,t);
q = [x psii]'; dq = [dx dpsi]'; ddq = [ddx ddpsi]';

mydiff = @(H) formula(subs(diff(symfun(subs(H,...
    [x,psii,dx,dpsi,ddx,ddpsi],...
    [X, PSI,dX,dPSI,ddX,ddPSI]),t),t),...
    [X, PSI,dX,dPSI,ddX,ddPSI],...
    [x,psii,dx,dpsi,ddx,ddpsi]));


%% Left Wheel


thetaL = x/R - psii*L/(2*R);
dthetaL = dx/R - dpsi*L/(2*R);
iL = [1 0 0]'; jL = [0 1 0]'; kL = [0 0 1]';
i0 = [cos(thetaL) 0 sin(thetaL)]'; j0 = [0 1 0]'; k0 = [-sin(thetaL) 0 cos(thetaL)]';
w0 = dpsi*k0;
v0 = dx*i0;
alpha0 = ddpsi*k0;
a0 = ddx*i0 + dx*(cross(dpsi*k0,i0));
rOL = (L/2)*j0;
Iw=[ZZw 0 0;0 YYw 0;0 0 ZZw];
wL = w0 + dthetaL*j0;
vGL = v0 + cross(w0, rOL);
aGL = a0 + cross(alpha0, rOL) + cross(w0, cross(w0, rOL));
HGL = Iw*wL;
p = mydiff(HGL);
dHGL = p + cross(wL,HGL);

% %% Right Wheel


thetaR = x/R + psii*L/(2*R);
dthetaR = dx/R + dpsi*L/(2*R);
iR = [1 0 0]'; jR = [0 1 0]'; kR = [0 0 1]';
i0 = [cos(thetaR) 0 sin(thetaR)]'; j0 = [0 1 0]'; k0 = [-sin(thetaR) 0 cos(thetaR)]';
w0 = dpsi*k0;
v0 = dx*i0;
alpha0 = ddpsi*k0;
a0 = ddx*i0 + dx*(cross(dpsi*k0,i0));
rOR = -(L/2)*j0;
wR = w0 + dthetaR*j0;
vGR = v0 + cross(w0, rOR);
aGR = a0 + cross(alpha0, rOR) + cross(w0, cross(w0, rOR));
HGR = Iw*wR;
dHGR = mydiff(HGR)+cross(wR,HGR);


%% Body

i0 = [1 0 0]'; j0 = [0 1 0]'; k0 = [0 0 1]';
w0 = dpsi*k0;
v0 = dx*i0;
a0 = ddx*i0 + dx*(cross(dpsi*k0,i0));
IB=[XXb XYb XZb;XYb YYb YZb; XZb YZb ZZb];
wB = w0;
alphaB = ddpsi*k0;
rOB = [MXb MYb MZb]'/mb;
vGB = v0 + cross(wB,rOB);
aGB = a0 + cross(alphaB, rOB) + cross(wB, cross(wB, rOB));
HGB = IB*wB;
dHGB = mydiff(HGB)+cross(wB,HGB);

%% Kanes LHS

KL = sym(zeros(3,1)); KR = sym(zeros(3,1)); KB = sym(zeros(3,1));
for i=1:2
    KL(i)=mw*aGL'*diff(vGL,dq(i))+dHGL'*diff(wL,dq(i));
    KR(i)=mw*aGR'*diff(vGR,dq(i))+dHGR'*diff(wR,dq(i));
    KB(i)=mb*aGB'*diff(vGB,dq(i))+dHGB'*diff(wB,dq(i));
end
Kw = KL + KR;
K = Kw + KB;

%% Equations

AA = sym(zeros(2,2)); CC = sym(zeros(2,2)); 
for i=1:2
    for j=1:2
        AA(i,j)=getcoeff(K(i),ddq(j),1);
        % This divides the coefficient of (dqj)(dqk) equally in all column
        % j and k 
        CC(i,j)=getcoeff(K(i), dq(j),2)*dq(j);
        ccc = getcoeff(K(i),dq(j),1); 
        CC(i,j) = CC(i,j)+ccc;
        for k=1:2
            CC(i,j) = CC(i,j) - 0.5*(getcoeff(ccc,dq(k),1))*dq(k);
        end
    end
end

AA=simplify(AA);
CC=simplify(CC);

