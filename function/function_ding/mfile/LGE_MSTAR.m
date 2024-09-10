
function [a_r, a_0, t_info] = LGE_MSTAR(a_0, t_info, varargin)

% function [a_r, a_0, t_info] = LGE_MSTAR(a_0, t_info, option)
% MSTAR: Multiple Slice Transport Average Registration
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Case 1: a_0 is a 3-D array
% Step 1: Sorting Images
% Step 2: Rigid pre-registration
% Step 3: Non-rigid registration + transport average
% Step 4: Slice direction median filter
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Case 2: a_0 is a 4-D array, spatial-temporal data, 2-D 

a_max = max(a_0(:)); 
a_max_1 = a_max;
if a_max > 3000
    a_0 = a_0 - 2048;
    a_max_1 = max(a_0(:));
end
a_min = min(a_0(:));
a_scale = 200/a_max_1;
a_0 = a_0*a_scale;
N_sw = 4;
if nargin == 3
    option = varargin{1};
    if isfield(option, 'Window') % Temporal window
        N_sw = option.Window;
        if mod(N_sw, 2) == 1 % if it is an odd number, change it to even 
            N_sw = N_sw-1;
        end
    end
end
s_0 = size(a_0);
[y,x] = meshgrid(-s_0(2)/2:s_0(2)/2-1, -s_0(1)/2:s_0(1)/2-1);

if ndims(a_0) == 3

    num_slices = s_0(3);
    a_r = zeros(s_0);
    SL = [];

    if ~isempty(t_info)
        if isstruct(t_info)
            for i=1:length(t_info), SL(i) = t_info(i).SliceLocation; end
        elseif iscell(t_info)
            for i=1:length(t_info), SL(i) = t_info{i}.SliceLocation; end
        else
            disp('t_info is neither a structure array nor a cell array.');
            return
        end

        [~, J] = sort(SL);
        a_0 = a_0(:,:,J);
    end

    a_r = LGE_preregistration(a_0);
    a_r = a_r(:,:,[ones(1, N_sw/2), 1:s_0(3), s_0(3)*ones(1, N_sw/2)]);
    LGE_img_register = a_r; 
    
    %T1 = clock;
    parfor i = 1+N_sw/2:num_slices+N_sw/2
        Imoving = a_r(:,:,i);
        Bx = zeros(s_0(1), s_0(2), N_sw+1);
        By = Bx; Fx = Bx; Fy = Bx;
        a_sw = a_r(:,:,i+[-N_sw/2:1:-1,1:N_sw/2]);
        %clock,
        for j=1:N_sw
            Istatic = a_sw(:,:,j);
            [~,dy, dx, dyInv, dxInv] = PerformMoCo(Istatic, Imoving, 1*[32 32 48], 12);
            Fx(:,:,j) = x + dx;
            Fy(:,:,j) = y + dy;
            Bx(:,:,j) = x + dxInv;
            By(:,:,j) = y + dyInv;
        end
        Fx(:,:,N_sw+1) = x;
        Fy(:,:,N_sw+1) = y;
        %clock,
        %pause interp2( y, x, Imoving, Fy(:,:,i), Fx(:,:,i),'spline');
        %LGE_img_register(:,:,i) = interp2( y, x, Imoving, mean(Fy,3), mean(Fx,3),'spline');
        LGE_img_register(:,:,i) = interp2( y, x, Imoving, sum(Fy,3)/(N_sw+1), sum(Fx,3)/(N_sw+1),'spline');
    end
    %T2 = clock
    %disp(T2-T1)

    %LGE_img_register = LGE_img_register(:,:,1+N_sw/2:num_slices+N_sw/2);
    LGE_img_register(LGE_img_register<a_min) = a_min;
    LGE_img_register(LGE_img_register>a_max_1) = a_max_1;
    LGE_img_register = medfilt1(LGE_img_register, 3, [], 3);
    LGE_TA = LGE_img_register( :, :, 1+N_sw/2:num_slices+N_sw/2); % 20240815 Ding


elseif ndims(a_0) == 4
    num_s1 = s_0(3);
    num_s2 = s_0(4);
    % a_r = zeros(s_0);
    a_r = LGE_preregistration(a_0);
    a_r = a_r(:,:,[ones(1, N_sw/2), 1:s_0(3), s_0(3)*ones(1, N_sw/2)],[ones(1, N_sw/2), 1:s_0(4), s_0(4)*ones(1, N_sw/2)]);
    LGE_img_register = a_r;
    parfor i = 1+N_sw/2:num_s1+N_sw/2
        for i2 = 1+N_sw/2:num_s2+N_sw/2
            Imoving = a_r(:,:,i,i2);
            Fx = zeros(s_0(1), s_0(2), N_sw+1, N_sw+1);
            Fy = Fx; 
            a_sw = a_r(:,:,i+[-N_sw/2:1:-1,1:N_sw/2],i2+[-N_sw/2:1:-1,1:N_sw/2]);

            for j=1:N_sw
                for j2 = 1:N_sw
                    Istatic = a_sw(:,:,j,j2);
                    [~,dy, dx, ~, ~] = PerformMoCo(Istatic, Imoving, 1*[32 32 48], 12);
                    Fx(:,:,j,j2) = x + dx;
                    Fy(:,:,j,j2) = y + dy;
                    %Bx(:,:,j,j2) = x + dxInv;
                    %By(:,:,j,j2) = y + dyInv;                    
                end
                Fx(:,:,j,N_sw+1) = x;
                Fy(:,:,j,N_sw+1) = y;
            end
            for j2 = 1:N_sw+1
                Fx(:,:,N_sw+1,j2) = x;
                Fy(:,:,N_sw+1,j2) = y;
            end
            LGE_img_register(:,:,i) = interp2( y, x, Imoving, sum(sum(Fy,4),3)/(N_sw+1)/(N_sw+1), sum(sum(Fx,4),3)/(N_sw+1)/(N_sw+1),'spline');
        end
    end
    LGE_img_register(LGE_img_register<a_min) = a_min;
    LGE_img_register(LGE_img_register>a_max_1) = a_max_1;
    LGE_img_register = medfilt1(medfilt1(LGE_img_register, 3, [], 4), 3, [], 3);
    LGE_TA = LGE_img_register( :, :, 1+N_sw/2:num_s1+N_sw/2, 1+N_sw/2:num_s2+N_sw/2); % 20240815 Ding
else
    a_r = a_0;
    disp('Error! Size of input array is not 3D or 4D!')
    return
end

a_0 = a_0/a_scale;
a_r = LGE_TA/a_scale;

if a_max > 3000
    a_0 = a_0 + 2048;
    a_r = a_r + 2048;
end

if ~isempty(t_info)
    t_temp = t_info;
    if isstruct(t_info)
        t_temp = t_info(J);
        t_info = t_temp;
    elseif iscell(t_info)
        t_temp = t_info(J);
        for i=1:length(t_info), t_temp{i} = t_info{J(i)}; end
        t_info = t_temp;
    else
        disp('t_info is neither a structure array nor a cell array.');
        return
    end
end

return


