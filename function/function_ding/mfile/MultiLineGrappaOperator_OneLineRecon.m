
function a_0 = MultiLineGrappaOperator_OneLineRecon(Grappa_Kern, N_lines, Kspace, N_x, N_y )

Kern_u = Grappa_Kern(:,:,1) ; 
Kern_d = Grappa_Kern(:,:,2) ;

K_C = Kspace ;
s_0 = size(Kspace);
a_I = zeros( s_0(1), 2*N_lines*(2*N_x + 1)*s_0(3) );
a_0 = zeros(s_0(1), 2*N_y+N_lines, s_0(3));
a_0(:,N_y+1:N_y+N_lines,:) = K_C;

for index_i = -N_x:N_x
    x_0 = circshift(K_C, [index_i, 0, 0]);
    a_I( :, s_0(3)*N_lines*(N_x+index_i)+1: s_0(3)*N_lines*(N_x+index_i+1) ) = reshape(x_0, s_0(1), N_lines*s_0(3));
    x_0 = circshift(conj(K_C(end:-1:1,:,:)), [index_i, 0, 0]);
    %x_0 = circshift(conj(K_C(end:-1:1,end:-1:1,:)), [index_i, 0, 0]);
    a_I( :, s_0(3)*N_lines*(3*N_x+index_i+1)+1: s_0(3)*N_lines*(3*N_x+index_i+2) ) = reshape(x_0, s_0(1), N_lines*s_0(3));
end

K_C = a_I*Kern_d;
a_0( :, N_y:-1:1, :) = reshape( K_C, s_0(1), N_y, s_0(3) );

K_C = a_I*Kern_u; 
a_0( :, N_y+N_lines+1:2*N_y+N_lines, :) = reshape( K_C, s_0(1), N_y, s_0(3) );




