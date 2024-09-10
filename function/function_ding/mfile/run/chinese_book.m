clear all, close all
a1 = imread('Elementary_Chinezse_I.jpg','jpg');
a2 = imread('Elementary_Chinezse_II.jpg','jpg');
a3 = imread('Elementary_Chinezse_III.jpg','jpg');
a4 = imread('Elementary_Chinezse_IV.jpg','jpg');

b = zeros((397*2),(273*2),3); 
b(1:397,1:273,1:3)=a1;
b(1:397,274:273*2,1:3)=a2;
b(398:397*2,1:273,1:3)=a3;
b(398:397*2,274:273*2,1:3)=a4;
b = b./max(b(:)); imagesc(b)

