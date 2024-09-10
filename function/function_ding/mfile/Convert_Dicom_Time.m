


function T0 = Convert_Dicom_Time(t_in)

t_hour = str2num( t_in(1:2) )  ;
t_min  = str2num( t_in(3:4) )  ;
t_sec  = str2num( t_in(5:end) );

T0 = t_hour*3600 + t_min*60 + t_sec ;









