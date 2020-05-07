close all;
%% Read the fits file
img_1 = fitsread('G:\Fuzzy_Active_Contour\Solar_Image_2017_fits\AIA20170130_2300_0193.fits','image'); %% Read fits file 
[m n]=size(img_1) %% Display the size of the fits file image
minI=min(min(img_1)) %% Display the minimum value of image in fits file
maxI=max(max(img_1)) %% Display the maximum value of image in fits file

%% Normalize the value of fits file image and display it 
mn=(img_1-double((minI)))*(1/(double((maxI))-double((minI))));
img_2=mn*(1/255);
img_3=imrotate(img_2,180); %% Rotate fits image by 180 degree
img_3 = flip(img_3 ,2); %% horizontal flip %% This is done to handle the orientation of image in matlab
figure,subplot(221),imshow((img_3)*255), %% Display image 

%% Linear scaling between a user supplied range
img_4=imrotate(img_1,180); %% Rotate magnetogram image by 180 degree
img_4 = flip(img_4 ,2); %# horizontal flip
subplot(222),imshow((img_4),[100 2500]) %% Display image 

%% Non-linear logarithmic scaling between a supplied range.
[M,N]=size(img_1);
        for x = 1:M
            for y = 1:N
                m=double(img_1(M-x+1,y));
                z1(x,y)=10.*log(1+m); 
            end
        end
subplot(223), imshow((z1),[10.*log(100) 10.*log(2500)]); %% Display image 

%% Non-linear square root scaling between a supplied range.
for x = 1:M
            for y = 1:N
                m=double(img_1(M-x+1,y));
                zz(x,y)=sqrt(m); 
            end
end
subplot(224), imshow((zz),[sqrt(100) sqrt(2500)]); %% Display image


%% Generation of false color image from fits file
% case 193:    //copper : B87333

img_1=double(img_1);
img_11=zeros(1024,1024,3);

img_11(:,:,1) = (img_1);                %    //184 mapped to 255
img_11(:,:,2) = (img_1./ 255.0 * 115.0);%    //115 mapped to 255
img_11(:,:,3) = (img_1./ 255.0 * 51.0); %    //50 mapped to 255
                
size(img_1)
% cmap = jet ;
img_11=imrotate(img_11,180); %% Rotate magnetogram image by 180 degree
img_11 = flip(img_11 ,2); %% horizontal flip
figure,imshow(uint8(img_11)) %% Display image

%% Calculate the image varience
img_3=rgb2gray((img_11));
v = var(double(img_3(:)))
v = var(img_1(:))
v = var(img_2(:))


