function c = getcoeff(P, x, a)

[C, T] = coeffs(P, x); 
n=length(C); 
exists = 0; 
for i=1:n 
    if(isequal(T(i),x^a)); 
        exists = 1; 
        break; 
    end
end

if(exists) 
    c = C(i); 
else
    c = 0;
end
