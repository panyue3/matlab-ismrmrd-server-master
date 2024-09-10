function raw2matmr1(RawName,MatName, RowNum, ColNum)

%RawName = 'test'
%MatName = 'rawdata'
RowNum   
ColNum 

[RawName '.out']
fid=fopen([RawName '.out'],'r');
	if fid == (-1)
		error(['raw2mat: Could not open file ' RawName '.out']);
	end

% header=fread(fid,32,'char');    % header file
 header=fseek(fid,32,-1);    % header file

%cr = zeros(RowNum, ColNum); ci = zeros(RowNum, ColNum);
%for k = 1:RowNum,     fseek(fid, 128, 0);
%   for m = 1:ColNum,  cr(k,m) = fread(fid,1,'single');    ci(k,m) = fread(fid,1,'single'); end;
%end;

N = RowNum*(2*ColNum+4);
c = fread(fid,N,'single');

fclose(fid);
clock
% Now I have to manually separate cr and ci. But it is doable.
for k = 1:RowNum, cr(k,1:ColNum) = c((k-1)*(2*ColNum+4)+5:2:k*(2*ColNum+4) ) ; ci(k,1:ColNum) = c((k-1)*(2*ColNum+4)+6:2:k*(2*ColNum+4)) ; end
clock
rawdata= cr + sqrt(-1)*ci;
MatName
save (MatName, 'rawdata')


