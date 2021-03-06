close all
clear all

files = {'img_evaltests/dataset2/segment_cropped (1).png', 'img_evaltests/dataset2/segment_cropped (2).png', 'img_evaltests/dataset2/segment_cropped (3).png',... 
         'img_evaltests/dataset2/segment_cropped (4).png', 'img_evaltests/dataset2/segment_cropped (5).png'};

%files = {'img_evaltests/dataset2/segment_cropped (1).png', 'img_evaltests/dataset2/segment_cropped (2).png'};
metafile = {'img_evaltests/dataset2/segment4meta.png'};
expTimes = [];
n_segments = 150;
images = cell(n_segments,numel(files));

global exposure_min exposure_max
exposure_min = 1;
exposure_max = 255;

for i = 1:numel(files)
    path = cell2mat(files(i));
    img = imread(path);
    segments = segmentimg(img,n_segments);
    %filter = fspecial('average', [22 11]);

    for j=1:n_segments
        images{j,i} = segments{j};
        %background_illum{j,i} = imfilter(segments{j},filter,'replicate');
        %exposures{j}(i) = mean(background_illum{j,i}(:));
        exposures{j}(i) = mean(images{j,i}(:));
    end
	
end

montage(files)


%%plot HDR output for each segments
%figure;
for i=1:n_segments
    exp_normalized{i} = exposures{i}./exposures{1}(1);
    hdr{i} = makehdr_mod(metafile,images(i,:),'RelativeExposure',exp_normalized{i},'MinimumLimit',exposure_min,'MaximumLimit',exposure_max);
    %figure, imshow(hdr); %was just curious what it looks like
    
    %subplot(1,n_segments,i);
    %imshow(rgb{i});
end

hdrresult = reconstructimg(hdr);
rgb = tonemap(hdrresult);
figure;
imshow(rgb);
hdr_global();

function hdr_global()
global exposure_min exposure_max
    files = {'img_evaltests/dataset2/segment_cropped (1).png', 'img_evaltests/dataset2/segment_cropped (2).png', 'img_evaltests/dataset2/segment_cropped (3).png',...  
         'img_evaltests/dataset2/segment_cropped (4).png', 'img_evaltests/dataset2/segment_cropped (5).png'}; 
    expTimes = [0.0333, 0.1000, 0.3333, 0.6250, 1.3000]; 
 
    for i = 1:5 
        path = cell2mat(files(i)); 
        img = imread(path); 
      expTimes(i) = mean(img(:)); 
    end 
 
    %montage(files) 
    hdr = makehdr(files,'RelativeExposure',expTimes./expTimes(1),'MinimumLimit',exposure_min,'MaximumLimit',exposure_max);
    rgb = tonemap(hdr); 
    figure; 
    subplot(2,1,1),imshow(rgb);
end

function output = segmentimg(img,divisions_vertical)
    output = cell(1,divisions_vertical);
    [nrows, ncols, dim] = size(img);
    for n = 1:divisions_vertical
        output{n} = img(:,((n-1)*floor(ncols/divisions_vertical))   +1:n*floor(ncols/divisions_vertical),:);
    end
    imwrite(output{1},'img_evaltests/dataset2/segment4meta.png');
end

function output = reconstructimg(segments)
   output = [];
   for n = 1:numel(segments)
       output = horzcat(output, segments{n});
   end
end