function cintour_gen(i,im,imo)
[img_m,mask1]=cosegmentation_ini(im);
phi2 = bwdist(mask1)-bwdist(1-mask1)+im2double(mask1)-.5; 
phi1_1=phi2;
i=imresize(i,[1024 1024]);
figure,
imshow(i);
hold on;
contour(phi2, [0 0], 'r','LineWidth',4);
contour(phi2, [0 0], 'g','LineWidth',1.2);
%% Eliminate off-disk region
i(find(phi2>=0))=150;
figure,imshow(i)
%% 
phi2(find(i==76))=-1;
phi2(find(i==150))=1;

%% Selection of Image on which contour is to be displayed
   
fn = {'Original Image','Gray-scale Image'};
[indx_imc,tf] = listdlg('PromptString',{'Select a image on which contour is to be displayed.',...
                'Only one option can be selected at a time.',''},...
                'SelectionMode','single','ListString',fn) 
if indx_imc==1
    img_temp=imo; %%Original Image
elseif indx_imc==2
    img_temp=im; %%Gray-scale Image
end
%-- Display settings
figure,
imshow(img_temp);
hold on;
contour(phi2, [0 0], 'r','LineWidth',4);
contour(phi2, [0 0], 'g','LineWidth',1.2);

mask2 = imbinarize(i);    
phi3 = bwdist(mask2)-bwdist(1-mask2)+im2double(mask2)-.5; 
%% Create white image   
[m,n,o]=size(im)
B=ones(m,n)*255;
B=uint8(B);
%% Generate only contour
figure,
imshow(B);
hold on;
contour(phi3, [0 0], 'k','LineWidth',3);
contour(phi3, [0 0], 'k','LineWidth',1.2);
hold on;
contour(phi1_1, [0 0], 'k','LineWidth',3);
contour(phi1_1, [0 0], 'k','LineWidth',1.2);
