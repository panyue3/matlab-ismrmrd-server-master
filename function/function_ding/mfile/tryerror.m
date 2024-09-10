ft=30:0.1:31;

j=0;
for i=30:0.1:31,
errd(j+1)=findtestk(testbar(i),i);
j = j+1;
end
 plot((errd-ft)./ft*100,'ro-');
