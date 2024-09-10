% 1-d Haar waveket filter:
% x_filtered = Haar_Wavelet_Filter(x, qmf, cutoff)
% x:        is the original 1-D signal
% x_f:      is the filtered 1-D signal
% Cutoff:   is the cutoff = number of wavelet coefficients left.   

function x_filtered = Haar_Wavelet_Filter(x, cutoff)

nmrsignal = x;
QMF8       = MakeONFilter('Haar');
% QMF8       = MakeONFilter('Daubechies',18);
%wcoef  = FWT_PO(x,L,qmf);
wcoef  = FWT_PO( nmrsignal, 0, QMF8 ); % L = 0;

% Take out first cutoff # largest 
[Y,I] = sort(abs(wcoef),'descend');
wcoef_f = wcoef ;
wcoef_f(I(cutoff + 1:end)) = 0;
x_filtered = (IWT_PO(wcoef_f, 0, QMF8 )) ;



