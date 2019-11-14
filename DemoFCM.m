function DemoFCM
% Segment a sample 2D image into 3 classes using fuzzy c-means algorithm. 
% Note that similar syntax would be used for c-means based segmentation,
% except there would be no fuzzy membership maps (denoted by variable U 
% below).
close all;
%% Selection of Image for Coronal Holes Detection
[file,path,indx] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp',...
    'Figures (*.png,*.jpg,*.jpeg,*.bmp)'}, ...
    'Select a Figure File'); %%Select figure file
       
im = imread([path,file]); %%Read the image file
imo=im; %%Store original image
tic %%Start stop-watch
im=rgb2gray(im); %%Convert image from RGB to Gray 
[C,U,LUT,H]=FastFCMeans(im,2,50,true); % Perform fast fuzzy c-means segmentation

 
%% Visualize the fuzzy membership functions
figure('color','w')
subplot(2,1,1)
I=double(min(im(:)):max(im(:)));
c={'-r' '-g' '-b'};
for i=1:2
    plot(I(:),U(:,i),c{i},'LineWidth',2)
    if i==1, hold on; end
    plot(C(i)*ones(1,2),[0 1],'--k')
end
xlabel('Intensity Value','FontSize',30)
ylabel('Class Memberships','FontSize',30)
set(gca,'XLim',[0 260],'FontSize',20)
 
subplot(2,1,2)
plot(I(:),LUT(:),'-k','LineWidth',2)
xlabel('Intensity Value','FontSize',30)
ylabel('Class Assignment','FontSize',30)
set(gca,'XLim',[0 260],'Ylim',[0 3.1],'YTick',1:3,'FontSize',20)


%% Visualize the segmentation
figure('color','w')  
subplot(1,2,1), imshow(im)
set(get(gca,'Title'),'String','ORIGINAL')
 
L=LUT2label(im,LUT);
Lrgb=zeros([numel(L) 3],'uint8');
for i=1:3
    Lrgb(L(:)==i,i)=255;
end
% Lrgb=reshape(Lrgb,[size(im) 3]);%Changed by me
size(Lrgb)
[size(im) 3]
Lrgb=reshape(Lrgb,[size(im) 3]);
size(Lrgb)

subplot(1,2,2), imshow(Lrgb,[])
set(get(gca,'Title'),'String','FUZZY C-MEANS (C=2)')

%% Initialize phi
[img_m,mask1]=contour_ini(im);%%Initialize Contour using Circular Hough Transform
                              %%img2_temp is the off-disk eliminated image and m is the corresponding mask 
phi1 = bwdist(mask1)-bwdist(1-mask1)+im2double(mask1)-.5; %% Initialization of phi
%-- End Initialization
Lgray=rgb2gray(Lrgb); %%Convert fast fuzzy c-mean output to gray-scale
figure,imshow(Lrgb) %% Display rgb output
figure,imshow(Lgray)%% Display gray-scale output
%% Display contour based on FFCM output
phi1(find(Lgray==76))=-1;
phi1(find(Lgray==150))=1;
figure,imshow(imo);
hold on;
contour(phi1, [0 0], 'r','LineWidth',4);   %%Dispaly final contour of width 4
contour(phi1, [0 0], 'g','LineWidth',1.2); %%Dispaly final contour of width 1.2
%% Visualize the binary mask
figure
mask1_1=zeros(size(phi1,1),size(phi1,2));
mask1_1(find(phi1<=0))=1;
mask1_1=logical(mask1_1);
imshow(mask1_1) %%Display the binary mask
objPos = mask1_1 == 0; %%Assign object in output binary mask         
%% Dialog Box to Get User Input for Values of Parameters
prompt = {'Enter size of structuring element for image opening:','Enter size of structuring element for image closing:'};
dlgtitle = 'Input Parameters Values';
dims = [1 70];
definput = {'5','8'}; %%Default values
se = inputdlg(prompt,dlgtitle,dims,definput); %%Dialog box to get input for alpha1 and alpha2
%% Redundant pixels elimination
objPos=bwareaopen(objPos,str2num(se{1})); %%Perform morphological opening operation
objPos=imclose(objPos,strel('disk',str2num(se{2}))); %%Perform morphological closing operation 
%% 
objNeg = ~objPos;            
mask1_2 = objPos - objNeg; 
figure,imshow(~uint8(mask1_2)) %%Display binary mask of the output image after morphological operation

figure,
Lgray(find(mask1_2==0))=76;  %%Assign intensity value for the foreground  
Lgray(find(mask1_2==1))=150; %%Assign intensity value for the background  
imshow(Lgray); %%Display gray-scale mask of the output image

%%%%%%%%%%%%%%%%%%%%%%%

%% If necessary, you can also unpack the membership functions to produce membership maps
Umap=FM2map(im,U,H);
figure('color','w')
for i=1:2
    subplot(1,2,i), imshow(Umap(:,:,i))
    ttl=sprintf('Class %d membership map',i);
    set(get(gca,'Title'),'String',ttl)
end
%% Contour generation on output gray scale image
ans = questdlg('Would you like to continue?', ...
	'Enter your choise', ...
	'Yes','No','No');
% Handle response
switch ans
    case 'Yes'
        contour_gen(Lgray,im,imo)
    case 'No'
        toc %%Stop stop-watch
        return;
end

toc %%Stop stop-watch

