% b = my_medfilt2(a,w)

function b = my_medfilt2(a,w)

s = size(a);
switch length(s)
    case 1 % 1-D data
        'Error! Can not filter 1-D data!'
    case 2 % 2-D data
        if isreal(a)
            b =  medfilt2( a,[w,w]); 
        else
            a_real = medfilt2(real(a),[w,w]);
            a_real(find(a_real==0)) = median(a_real(:));
            a_imag = medfilt2(imag(a),[w,w]);
            a_imag(find(a_imag==0)) = median(a_imag(:));
            b = complex(a_real, a_imag);
        end
    case 3 % 3-D data
        %'3-D data'
        b = zeros(s(1),s(2),s(3)) ;
        if isreal(a)
            for i=1:s(3), 
                a_real = medfilt2( a(:,:,i),[w,w]);
                a_real(find(a_real==0)) = median(a_real(:));
                b(:,:,i) = a_real; 
            end
        else, %'complex data'
            for i=1:s(3), 
                a_real = medfilt2(real(a(:,:,i)),[w,w]);
                a_real(find(a_real==0)) = median(a_real(:));
                a_imag = medfilt2(imag(a(:,:,i)),[w,w]);
                a_imag(find(a_imag==0)) = median(a_imag(:));
                b(:,:,i) = complex(a_real, a_imag );
            end
        end
    otherwise  % Other-D data
        'Data Dimension does not Match!'
end
            

