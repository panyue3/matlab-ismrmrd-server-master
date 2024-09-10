% This is to correct the aliasing of the velocity data
% Aliasing_Fix(v)
% v > 0, velocity too high
% v < 0, velocity too low
% use |v|<2048.


function Aliasing_Fix(v)

mkdir fix

x = [0 5 'd'];
cc = sprintf('%%%d.%d%s',x);

for i=1:100,
    number = sprintf(cc,i);
    name = sprintf('%s%s','Image',number);
    m = dicomread(name);
    info = dicominfo(name);
    if v > 0, m(find(m<v)) = m(find(m<v)) + 4096;end
    if v < 0, m(find(m > 4095+v)) = m(find(find(m > 4095+v))) - 4096;end    
    %fix_name = sprintf('%s%s','Image',number);
    cd fix
    dicomwrite(m, name, info);
    m = 0;
    cd ..
end









