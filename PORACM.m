function [time,itr] = PORACM(Img_gray,Img_ori,show,alpha1,alpha2)
 warning('off'); %#ok<WNOFF>
%% 
    tic %%Start stop-watch
    %% Selection of the Contour Initialization Technique
    fn = {'Circular Hough Transform','Near the Image Boundary','Manually'};
    [indx,tf] = listdlg('PromptString',{'Select a Contour Initialization Option.',...
                'Only one option can be selected at a time.',''},...
                'SelectionMode','single','ListString',fn)    
    if indx==1
        [img2_temp,m]=contour_ini(Img_ori); %%Initialize Contour using Circular Hough Transform
                                %%img2_temp is the off-disk eliminated image and m is the corresponding mask
    elseif indx==2
        delt=20; % for initial curve
        m=zeros(size(Img_gray,1),size(Img_gray,2)); %%Create binary mask of image size with '0' value 
        m(delt:size(Img_gray,1)-(delt),delt:size(Img_gray,2)-(delt))=1; %%Initial curve for near image boundary
    else
        figure();
        imshow(Img_ori); %%Display image to initialize curve
        [x,y]=ginput(2);
        x=round(x);
        y=round(y);
        m(y(1):y(2),x(1):x(2))=1; %%Initial curve setup manually
    end
    %% Selection of Image on which Program is to be execute
    if indx==1
        fn = {'Original Image','Off-disk Eliminated Image'};
        [indx_im,tf] = listdlg('PromptString',{'Select a image for program.',...
                'Only one option can be selected at a time.',''},...
                'SelectionMode','single','ListString',fn) 
        if indx_im==1
            img2_temp=Img_ori; %%Original Image
        else
            img2_temp=img2_temp; %%Off-disk Eliminated Image
        end    
    else
        img2_temp=Img_ori; %%Original Image
    end
    %% 
    phi=m; %%Initial contour mask
    Img = rgb2gray(img2_temp); %%Convert image to gray scale
    imshow(Img) %%Display image
    [row,col] = size(Img); %%Determine row and column of the image    
    Img = double(Img); %%Convert image to double
    %% Selection of Image on which contour is to be displayed
    if indx==1
        fn = {'Original Image','Gray-scale Image','Off-disk Eliminated Image','Off-disk Eliminated Gray-scale Image'};
        [indx_imc,tf] = listdlg('PromptString',{'Select a image on which contour is to be displayed.',...
                'Only one option can be selected at a time.',''},...
                'SelectionMode','single','ListString',fn) 
        if indx_imc==1
            img_temp=Img_ori; %%Original Image
        elseif indx_imc==2
            img_temp=Img_gray; %%Gray-scale Image
        elseif indx_imc==3
            img_temp=img2_temp; %%Off-disk Eliminated Image
        else
            img_temp=Img; %%Off-disk Eliminated Gray-scale Image
        end
    else
        fn = {'Original Image','Gray-scale Image'};
        [indx_imc,tf] = listdlg('PromptString',{'Select a image on which contour is to be displayed.',...
                'Only one option can be selected at a time.',''},...
                'SelectionMode','single','ListString',fn) 
        if indx_imc==1
            img_temp=Img_ori; %%Original Image
        elseif indx_imc==2
            img_temp=Img_gray; %%Gray-scale Image
        end
    end
    %%     
    obj = - phi; objPos = obj >= 0; objNeg = ~objPos;
    itr = 0; %%Initialize the iteration value
    Area1 = sum(objNeg(:)); Area2 =sum(objPos(:)); %%Determine the total area outside and inside the curve
    if show, 
        figure;imshow(img_temp,[]); hold on; %%Display image on which contour to be setup 
        contour(obj, [0 0], 'r','LineWidth',4);hold on; %%Dispaly initial contour of width 4 
        contour(obj, [0 0], 'g','LineWidth',1.3);hold on; %%Display initial contour of width 1.3
        title(['ORACM2 : ',int2str(itr),'th iteration, the total area of the object:',int2str(abs(Area2))]);axis off; 
        drawnow; 
    end
%     tic
        while abs(Area2-Area1)>0  
            c1 = sum(sum(Img.*objNeg))/sum(sum(objNeg)); %%Calculate mean intensity outside the curve 
            c2 = sum(sum(Img.*objPos))/sum(sum(objPos)); %%Calculate mean intensity inside the curve
            nImg = Img - (alpha1*c1 + alpha2*c2)/2; %%Function for PORACM
            obj = nImg /max(abs(nImg(:)));            
            objPos = obj >= 0; 
            %% Redundant pixels elimination            
            objPos=bwareaopen(objPos,5); %%Perform morphological opening operation
            objPos=imclose(objPos,strel('disk',4)); objNeg = ~objPos; %%Perform morphological closing operation           
            %% 
            obj = objPos - objNeg;            
            Area1= Area2;  Area2 =sum(objPos(:));    
            itr = itr + 1; %%Increase the iteration by '1'        
            if show,
                figure;imshow(img_temp,[]); hold on; %%Display image on which contour to be setup 
                contour(obj, [0 0], 'r','LineWidth',4);hold on; %%Dispaly the contour of width 4 
                contour(obj, [0 0], 'g','LineWidth',1.3);hold on; %%Dispaly the contour of width 1.3
                title(['PORACM : ',int2str(itr),'th iteration, the total area of the object:',int2str(abs(Area2))]);axis off; 
                drawnow;
            end
        end
        
        figure
        phi1=obj;
        mask1_1=zeros(size(phi1,1),size(phi1,2)); %%Initialize final mask
        mask1_1(find(phi1<=0))=1;
        mask1_1=logical(mask1_1);
        imshow(mask1_1) %%Display the final mask
        
        if show,
            figure;
            imshow(img_temp,[]); hold on; %%Display image on which contour to be setup 
            contour(obj, [0 0], 'r','LineWidth',4);hold on; %%Display the final contour of width 4 
            contour(obj, [0 0], 'g','LineWidth',1.3);hold on; %%Display the final contour of width 1.3
            title(['PORACM : ',int2str(itr),'th iteration, the total area of the object:',int2str(abs(Area2))]);axis off; 
            drawnow;
        end
        
        
        phi3 = bwdist(mask1_1)-bwdist(1-mask1_1)+im2double(mask1_1)-.5; 
        [img2_temp,mi]=contour_ini(Img_ori); %%Initialize Contour using Circular Hough Transform
                                %%img2_temp is the off-disk eliminated image and m is the corresponding mask
        phi1_1= mi;
        obj = - phi; objPos = obj >= 0; objNeg = ~objPos;
        %% Create white image        
        [m,n,o]=size(Img_gray)
        B=ones(m,n)*255;
        B=uint8(B);
        %% Generate only contour        
        figure,
        imshow(B);
        hold on;
        contour(phi3, [0 0], 'k','LineWidth',3);
        contour(phi3, [0 0], 'k','LineWidth',1.2);
        hold on;
        contour(obj, [0 0], 'k','LineWidth',3);
        contour(obj, [0 0], 'k','LineWidth',1.2);
        
        
    time = toc; %%Stop stop-watch    
%     pause;
end