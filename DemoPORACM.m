function DemoPORACM
clear; close all; clc;
%% Selection of Image for Coronal Holes Detection
    [file,path,indx] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp',...
    'Figures (*.png,*.jpg,*.jpeg,*.bmp)'}, ...
    'Select a Figure File'); %%Select figure file
    show = 1; result = zeros(0);
    
    img = imread([path,file]); %%Read the image file
    img_ori=img; %%Store original image 
    if size(img,3)>1,img = rgb2gray(img);end %%Convert image from RGB to Gray
    img = double(img); %%Change Image to Double
    %% Dialog Box to Get User Input for Values of Parameters
    prompt = {'Enter value for \alpha_{1}:','Enter value for \alpha_{2}:'};
    dlgtitle = 'Input Parameters Values';
    dims = [1 70];
    definput = {'0.5','0.4'}; %%Default values
    opts.Interpreter = 'tex'; %%The options structure to specify TeX to be the interpreter.
    alpha = inputdlg(prompt,dlgtitle,dims,definput,opts); %%Dialog box to get input for alpha1 and alpha2
    
    [time1,itr1] = PORACM(img,img_ori,show,str2num(alpha{1}),str2num(alpha{2})); %%Run Program for PORACM
    result = [result;time1 itr1];
result %%Display result
