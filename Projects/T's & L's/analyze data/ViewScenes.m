
%display image

% %CHANGE TO SCENE PATH   
[imgmtx, dmns, notes]=loadcx(strcat('S:\Contextual\21ro405\TL23.ctx'));


newimg = imgmtx - 127;
lut = loadlut('bg001.lut');
dbllut = lut / 255;
figure;
imshow(newimg, dbllut);


    % %locate T
% h=scatter(Tloc(20,1),Tloc(20,2),'filled');
% setpixelposition(gcf,[0 0 1000 800]);
% setpixelposition(gca,[100 100 800 599]);
% xlim([0 12]);
% ylim([0 9]);



% close all
        