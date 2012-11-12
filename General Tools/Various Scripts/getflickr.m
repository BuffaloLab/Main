% function [] = getflickr(numpics)
% Mike Jutras
% Nathan Killian
% last updated 6/19/2012 nk, fixed url names and now grabs hi-res (_b) photos

% may be a max of 500 per day, 3500 for 7 days
% if photo is already in the folder it will be overwritten

% number of pictures desired
numpics=1500;

saveDir = 'S:\Flickr pics\';mkdir(saveDir);


l=0;%number of pics grabbed
for m=1:1000% number of reloads of the page
    s=urlread('http://www.flickr.com/explore/interesting/7days/');% (re)load the site source code
    
    clear siteind
    hind=strfind(s,'h');
    i=1;
    for k=1:length(hind)
        if ((hind(k)+6)<length(s))
            if strcmp(s(hind(k):hind(k)+6),'http://')
                firstquote=strfind(s(hind(k):end),'"');
                siteind{i}=s(hind(k):(firstquote(1)+hind(k)-2));
                i=i+1;
            end
        end
    end
    
    clear imageind
    i=1;
    for k=1:size(siteind,2)
%         siteind{k}
        if size(siteind{k},2)>30 %fixme: make generic 1-9
            if strcmp(siteind{k}(1:30),'http://farm6.staticflickr.com/')
                imageind{i}=siteind{k}(1:62); %63 char limit added 30-Jul-2009 due to error in flickr html source
                i=i+1;
            elseif strcmp(siteind{k}(1:30),'http://farm8.staticflickr.com/')
                imageind{i}=siteind{k}(1:62); %additional image server added 1/15/10
                i=i+1;
            elseif strcmp(siteind{k}(1:30),'http://farm9.staticflickr.com/')
                imageind{i}=siteind{k}(1:62); %additional image server added 1/15/10
                i=i+1;
            elseif strcmp(siteind{k}(1:30),'http://farm5.staticflickr.com/')
                imageind{i}=siteind{k}(1:62); %additional image server added 1/15/10
                i=i+1;
            elseif strcmp(siteind{k}(1:30),'http://farm4.staticflickr.com/')
                imageind{i}=siteind{k}(1:62); %additional image server added 1/15/10
                i=i+1;
            elseif strcmp(siteind{k}(1:30),'http://farm3.staticflickr.com/')
                imageind{i}=siteind{k}(1:62); %additional image server added 1/15/10
                i=i+1;
            end
        end
    end
    
    clear x
    for k=1:length(imageind)
        imageind{k} = [imageind{k}(1:end-5) 'b.jpg'];% b suffix is higher resolution, h appears to be higher res, but it looks like not all photos have an h type
        x{k}=imread(imageind{k});
        %     figure;image(x{k})
    end
    
    for k=1:length(x)
        imtitle=[saveDir imageind{k}(find(double(imageind{k})==47,1,'last')+1:end)];
        if exist(imtitle,'file')~=2
            %             imwrite(x{k},imtitle,'jpg','Bitdepth',12,'Mode','lossless','Quality',100);
            imwrite(x{k},imtitle,'jpg','Quality',95);
            l=l+1;
        end
        if l==numpics
            break
        end
    end
    
    if l==numpics
        break
    end
    
end


