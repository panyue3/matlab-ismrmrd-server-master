clc
a_klm=a_3;
s=size(a_klm);
[a_1_eigen,V,D]=KL_Eigenimage(a_klm);
wname='db5';
clean_a_1_eigen_multip1=zeros(s(1),s(2),s(3));
no_of_frames=s(3);
threshold1=zeros(no_of_frames,1);
threshold2=zeros(no_of_frames,1);
threshold3=zeros(no_of_frames,1);
for m=1:s(3)
    [swa,swh,swv,swd]=swt2(a_1_eigen(:,:,m),3,wname);
    tmp=swh(:,:,1);
    Nvar1=median(abs(tmp(:)))/0.6745;
    tmp=swv(:,:,1);
    Nvar2=median(abs(tmp(:)))/0.6745;
    tmp=swd(:,:,1);
    Nvar3=median(abs(tmp(:)))/0.6745;
    sorh='s';
% For subband - Horizontal Details
    for j=1:3
        beta1=sqrt(log(length(swh(:,:,j))/3));
        beta1n=1;
        Ssig1=std(swh(:));
        thr1=(beta1*Nvar1^2)/Ssig1;
        swh(:,:,j)=wthresh(swh(:,:,j),sorh,thr1*3);
    end
% For subband - Vertical Details
    for k=1:3
        beta2=sqrt(log(length(swv(:,:,k))/3));
        beta2n=1;
        Ssig2=std(swv(:));
        thr2=(beta2*Nvar2^2)/Ssig2;
        swv(:,:,k)=wthresh(swv(:,:,k),sorh,thr2*3);
    end
% For subband - Diagonal Details
    for l=1:3
        beta3=sqrt(log(length(swd(:,:,l))/3));
        beta3n=1;
        Ssig3=std(swd(:));
        thr3=(beta3*Nvar3^2)/Ssig3;
        swd(:,:,l)=wthresh(swd(:,:,l),sorh,thr3*3);
    end
    clean_eigen1=iswt2(swa,swh,swv,swd,wname);
    clean_a_1_eigen_multip1(:,:,m)=clean_eigen1;
    threshold1(m)=thr1;
    threshold2(m)=thr2;
    threshold3(m)=thr3;
end
new_a_1_multip1=invKLT_3D(clean_a_1_eigen_multip1,V);
%s1=size(a_klm);

% t_klm=t_1;
% l1=zeros(length(t_klm),1);
% h1=zeros(length(t_klm),1);
% 
% for i=1:length(t_klm)
% l1(i)=0;
% h1(i)=t_klm(i).WindowCenter+(t_klm(i).WindowWidth/2);
% for j=1:s1(1)
%     for k=1:s1(2)
%         if(a_klm(j,k,i)<l1(i))
%             a_klm(j,k,i)=l1(i);
%         end
%         if(new_a_1_multip1(j,k,i)<l1(i))
%             new_a_1_multip1(j,k,i)=l1(i);
%         end
%         if(a_klm(j,k,i)>h1(i))
%             a_klm(j,k,i)=h1(i);
%         end
%         if(new_a_1_multip1(j,k,i)>h1(i))
%             new_a_1_multip1(j,k,i)=h1(i);
%         end
%     end
% end
% end

%combo1=scaledata(new_a_1_multip1,0,255);
%a1giforig=scaledata(a_klm,0,255);
 
