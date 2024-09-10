
for i=1:4
    a1 = a0(:,:,i);
    a = imresize(a1,0.5,'bicubic');
    a = (a>0.1*max(a(:))).*a/max(a(:)); %imagesc(a)
%    a_size = size(a); N = a_size(1);%pause
    clock 
    chirality(i) = try_chiral_1(a),  i,pause(1)
end

