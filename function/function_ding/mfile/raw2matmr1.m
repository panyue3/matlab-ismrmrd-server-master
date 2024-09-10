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
rawdata = zeros(RowNum, ColNum);
begin_reading = clock,
for k = 1:RowNum,     fseek(fid, 128, 0);k,
    temp(1:2*ColNum) = fread(fid,2*ColNum,'single');
%   cr(k,1:ColNum) = temp(1:2:end);    ci(k,1:ColNum) = temp(2:2:end);
    rawdata(k,1:ColNum) = complex(temp(1:2:end),temp(2:2:end) ) ;
end;
%size(cr)
fclose(fid);
%rawdata= complex(cr,ci);
finish_reading = clock, MatName
save (MatName, 'rawdata')
finish_saving = clock,

