% function res = ifft2c(x)
% s = size(x);
% fctr = size(x,1)*size(x,2);
% if ( numel(s) == 2 ) % Nfe Npe
%     res = sqrt(fctr)*fftshift(ifft2(ifftshift(x)));
% end
% if ( numel(s) == 3 ) % Nfe Npe Frame   
%     for n=1:size(x,3)
%         res(:,:,n) = sqrt(fctr)*fftshift(ifft2(ifftshift(x(:,:,n))));
%     end
% end
% if ( numel(s) == 4 ) % Nfe Npe Cha Frame
%     for n=1:size(x,4)
%         for c=1:size(x,3)
%             res(:,:,c,n) = sqrt(fctr)*fftshift(ifft2(ifftshift(x(:,:,c,n))));
%         end
%     end
% end

function res = ifft2c(x)
fctr = size(x,1)*size(x,2);
s_0 = size(x);
x = reshape(x, [size(x,1), size(x, 2), prod(size(x(1,1,:)))]);
res = zeros(size(x));
for l3 = 1:size(x,3)
    for l4 =1:size(x,4)
        res(:,:,l3,l4) = sqrt(fctr)*fftshift(ifft2(ifftshift(x(:,:,l3,l4))));
    end
end
res = reshape(res, s_0);
end


