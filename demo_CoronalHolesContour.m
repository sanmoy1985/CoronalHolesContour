function demo_CoronalHolesContour
%% Selection of the Function to be Execute for Coronal Holes Detection
fn = {'PORACM','FFCMSCM'};
[indx,tf] = listdlg('PromptString',{'Select a file.',...
    'Only one file can be selected at a time.',''},...
    'SelectionMode','single','ListString',fn)
%% Program to be Execute
if indx==1
    DemoPORACM %%Run program for PORACM
else
    DemoFCM    %%Run program for FFCMSCM
end
