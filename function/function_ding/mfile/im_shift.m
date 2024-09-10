% Shift images in two direction

function  a_o = im_shift(a_in, a, b)

L = size(a_in);
a_out = zeros(size(a_in));

c = ceil(a); cr = c - a;
d = ceil(b); dr = d - b;

[x,y] = meshgrid(1:L(2), 1:L(1));

switch (length(L))

    case 1
        msgbox('The input image should be either 2-D or 3-D')
    case 2
        a_out = a_in( mod((1:L(1))-(c+1),L(1))+1, mod((1:L(2))-(d+1),L(2))+1);
        a_o = a_out;
end

if (cr>0.01)|(cd>0.01)
    [x0,y0] = meshgrid(1:L(2)+1, 1:L(1)+1); %size(x0)
    a_out(L(1)+1,:) = a_out(L(1),:); % add one line one each x, y direction
    a_out(:, L(2)+1) = a_out(:, L(2)); %size(a_out), size(x),cr=cr, dr=dr
    x =0; y = 0;
    [x,y] = meshgrid(1+dr:L(2)+dr, 1+cr:L(1)+cr);
    a_o = interp2(x0,y0,a_out,x,y ,'bicubic');
end


