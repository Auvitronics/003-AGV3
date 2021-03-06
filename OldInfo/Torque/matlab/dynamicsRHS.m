syms mB g dx dpsi dphi MXb MYb MZb real 
syms tau_l tau_r R L qimu real
syms Fx Fy Fz Ex Ey Ez real

dq = [dx dpsi]';
a = sym(zeros(2,1)); b = sym(zeros(2,1)); 
c = sym(zeros(2,1));


% Torques at point R

wR = dpsi*k0 + (dx/R + (L*dpsi)/(2*R))*j0;

Tau_r = [0 tau_r 0]';
for i=1:2
    a(i) = Tau_r'*diff(wR,dq(i));
end

% Torques at point L
wL = dpsi*k0 + (dx/R - (L*dpsi)/(2*R))*j0;
Tau_l = [0 tau_l 0]';

for i=1:2
    b(i) = Tau_l'*diff(wL,dq(i));
end

% Force F
F = [Fx Fy Fz]';
rOE = [-Ex 0 Ez];
vE = dx*i0 - Ex*dpsi*j0; 

for i=1:2
    c(i) = F'*diff(vE,dq(i));
end