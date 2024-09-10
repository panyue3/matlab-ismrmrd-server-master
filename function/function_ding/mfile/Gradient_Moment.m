% Calculate the Gradient Moment
% function [Time, M0, M1] = Gradient_Moment(G)
% G: Gradient waveform such as : G = [9.68  60  710  60  ;  -20.02 170  570
% 170  ; 13.98 170  570 170  ]; 

function [Time, M0, M1] = Gradient_Moment(G);

s = size(G);
if s(2)~=4
    G = G';
end
s = size(G);
N = s(1) ; % Number of waveform sections
Dur = 0.5*(G(1,3)+G(1,4))+sum(G(2:end,3)) + sum(G(2:end,4)) ; % Duration time in 0.01 ms
M0 = zeros(1,Dur*100);
M1 = M0; 
%M2 = M0; % initialize three moments
Time = (0.01:0.01:Dur) ; % Temporal grids in ms.

T0 = 0;
T0(1) = 1; T0(2) = 100*( 0.5*(G(1,3)-G(1,2))+G(1,4) ); 
for i=3:N % time point
    T0(i) = T0(i-1) + 100*sum( G(i-1,3:4 ) ) ;
end
T0(N+1) = Dur*100; % All temporal point for each segment

% First Lobe
M0( T0(1):T0(2) ) = cumsum( [ ones(size( 0.01:0.01:0.5*(G(1,3)-G(1,2))))*G(1,1), (G(1,4):-0.01:0.01)*G(1,1)/G(1,4) ] ) * (1/100) ;
M1( T0(1):T0(2) ) = cumsum( [ ( 0.01:0.01:0.5*(G(1,3)-G(1,2)))*G(1,1), (0.5*(G(1,3)-G(1,2))+0.01:0.01:T0(2)/100).*(G(1,4):-0.01:0.01)*G(1,1)/G(1,4) ] ) * (1/100) ; ;
%M2( T0(1):T0(2) ) =  ;
for i=2:N
    M0( T0(i)+1:T0(i+1) ) = M0(T0(i))+cumsum( [ (0.01:0.01:G(i,2))*G(i,1)/G(i,2), ones(size(0.01:0.01:(G(i,3)-G(i,2))))*G(i,1), (G(i,4):-0.01:0.01)*G(i,1)/G(i,4) ] ) * (1/100) ;
    M1( T0(i)+1:T0(i+1) ) = M1(T0(i))+cumsum( [ (T0(i)/100+0.01:0.01:T0(i)/100+G(i,2)).*(0.01:0.01:G(i,2))*G(i,1)/G(i,2), (T0(i)/100+G(i,2)+0.01:0.01:T0(i)/100+G(i,3))*G(i,1), (T0(i)/100+G(i,3)+0.01:0.01:T0(i+1)/100).*(G(i,4):-0.01:0.01)*G(i,1)/G(i,4) ] ) * (1/100) ;
%    M2( T0(i)+1:T0(i+1) ) =  ;
end

%figure(1), plot(M0)
%figure(2), plot(M1)
%M1(end)
%710*9.68/2 + (570)*(-20.02) + (570)*13.98


