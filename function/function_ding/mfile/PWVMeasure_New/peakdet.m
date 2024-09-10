function [M I]=peakdet(v)
% M is the vector of local maximas
% I is the vector of indices of local maximas

M=[];
I=[];

%first element may be a maxima
if v(1)>v(2)
    M = [M v(1)];
    I = [I 1];
end

for i=2:length(v)-1
    if ((v(i+1)<v(i)) & (v(i-1)<v(i)))
        M = [M v(i)];
        I = [I i];
    end
end


%last element may be a maxima
if v(length(v))>v(length(v)-1)
    M = [M v(length(v))];
    I = [I length(v)];
end

I = int16(I);