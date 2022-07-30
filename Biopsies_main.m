%close all;clc;
%% Initialize 
RootDirectory = 'C:\Nati\Biopsies';
SavetoDisk = 'TRUE';
UseFullImages = 'TRUE';
UseCroppedImages = 'FALSE';
UseNLImages = 'FALSE';
UseActiveImages = 'TRUE';

%% Load in input images
imds = imageDatastore('ImageEoeFinal/', 'IncludeSubfolders',true,...
    'LabelSource','FolderNames');

lc = imds.countEachLabel;

%% Color-Based Segmentation Using K-Means Clustering
if strcmp(UseNLImages,'TRUE')
    for ii = lc{1,2}+1:length(imds.Files)
        close all;
       % Read image
        originalimg = imread(imds.Files{ii});
        im = originalimg;
        % Initiate figure number
        fgn = 1;

        figure(fgn);
        imshow(im,[]), title('Original image');
        fgn = fgn + 1;
        RepeateCropping = 'TRUE'; countCropping = 1;countLabel = 1;

        while strcmp(RepeateCropping,'TRUE')
        % Convert Image from RGB Color Space to L*a*b* Color Space
            lab_he = rgb2lab(im);

            % Classify the Colors in 'a*b*' Space Using K-Means Clustering
            ab = lab_he(:,:,2:3);
            nrows = size(ab,1);
            ncols = size(ab,2);
            ab = reshape(ab,nrows*ncols,2);

            % Repeat the clustering 3 times to avoid local minima
            nColors = 2; % number of clusters (in complex images - huge noise, use 3 clusters)
            [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);

            % Label Every Pixel in the Image Using the Results from Kmeans
            pixel_labels = reshape(cluster_idx,nrows,ncols);
            figure(fgn);
            imshow(pixel_labels,[]), title('image labeled by cluster index');
            fgn = fgn + 1;
            % Create Images that Segment the Original Image by Color
            segmented_images = cell(1,3);
            rgb_label = repmat(pixel_labels,[1 1 3]);

            for k = 1:nColors %loop on clusters
                color = im;
                color(rgb_label ~= k) = 0;
                segmented_images{k} = color;
            end

            for fi=1:nColors % plot all the clusters
                figure(fgn);
                title_str = sprintf('objects in cluster %d',fi);
                imshow(segmented_images{fi}), title(title_str);
                fgn = fgn + 1;
            end

            % Percentage part of a tissue object from all the image
            NumOfC1Pixels = sum(sum(pixel_labels==1));
            NumOfC2Pixels = sum(sum(pixel_labels==2));
            RatioPixels = (NumOfC2Pixels /(NumOfC2Pixels + NumOfC1Pixels))*100;
            if (RatioPixels < 50)
               tissue_label = 2; 
            else
               tissue_label = 1;
            end
            if (countLabel == 1)
                if strcmp(SavetoDisk,'TRUE') % Saving full images to specific paths
                   if strcmp(UseFullImages,'TRUE')
                      imwrite(segmented_images{tissue_label}, sprintf('%s/Full images/NL/NL_%d.png', RootDirectory, ii));
                   end
                end
                countLabel = countLabel + 1;
            end
            [ip,jp] = find(pixel_labels == tissue_label);
            tissue_img = segmented_images{tissue_label}(min(ip):max(ip),min(jp):max(jp),:);
            figure(fgn);
            imshow(tissue_img,[]);title('tissue image');
            fgn = fgn + 1;

            croppedTissueImage = crop_image_thd(im,0.07);
            figure(fgn);
            imshow(croppedTissueImage,[]);title('Cropped tissue from Original image');
            fgn = fgn + 1;

            if (RatioPixels < 20)
                if (countCropping == 1)
                    tsuimg = croppedTissueImage;
                else
                    tsuimg = tissue_img;
                end
                if (countCropping == 1)
                    RepeateCropping = 'TRUE';
                    im = tsuimg;
                    countCropping = countCropping + 1;
                else
                   RepeateCropping = 'FALSE';
                end
             else
                tsuimg = tissue_img;
                RepeateCropping = 'FALSE';
             end

            figure(fgn);
            imshow(tsuimg,[]);title('Final tissue image to use for trainning');
            fgn = fgn + 1;
        end 
        % Saving cropped images to specific paths
        if strcmp(SavetoDisk,'TRUE')
            if strcmp(UseCroppedImages,'TRUE')
                imwrite(tsuimg, sprintf('%s/Cropped images/NL/NL_%d.png' , RootDirectory, ii)) ;
            end
        end
     end
end

if strcmp(UseActiveImages,'TRUE')
   for ii = 1:lc{1,2} 
        close all;
        % Read image
        originalimg = imread(imds.Files{ii});
        im = originalimg;
        % Initiate figure number
        fgn = 1;

        figure(fgn);
        imshow(im,[]), title('Original image');
        fgn = fgn + 1;
        RepeateCropping = 'TRUE'; countCropping = 1;countLabel = 1;

        while strcmp(RepeateCropping,'TRUE')
        % Convert Image from RGB Color Space to L*a*b* Color Space
            lab_he = rgb2lab(im);

            % Classify the Colors in 'a*b*' Space Using K-Means Clustering
            ab = lab_he(:,:,2:3);
            nrows = size(ab,1);
            ncols = size(ab,2);
            ab = reshape(ab,nrows*ncols,2);

            % Repeat the clustering 3 times to avoid local minima
            nColors = 2; % number of clusters (in complex images - huge noise, use 3 clusters)
            [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);

            % Label Every Pixel in the Image Using the Results from Kmeans
            pixel_labels = reshape(cluster_idx,nrows,ncols);
            figure(fgn);
            imshow(pixel_labels,[]), title('image labeled by cluster index');
            fgn = fgn + 1;
            % Create Images that Segment the Original Image by Color
            egmented_images = cell(1,3);
            rgb_label = repmat(pixel_labels,[1 1 3]);

            for k = 1:nColors %loop on clusters
                color = im;
                color(rgb_label ~= k) = 0;
                segmented_images{k} = color;
            end

            for fi=1:nColors % plot all the clusters
                figure(fgn);
                title_str = sprintf('objects in cluster %d',fi);
                imshow(segmented_images{fi}), title(title_str);
                fgn = fgn + 1;
            end

            % Percentage part of a tissue object from all the image
            NumOfC1Pixels = sum(sum(pixel_labels==1));
            NumOfC2Pixels = sum(sum(pixel_labels==2));
            RatioPixels = (NumOfC2Pixels /(NumOfC2Pixels + NumOfC1Pixels))*100;
            if (RatioPixels < 50)
               tissue_label = 2; 
            else
               tissue_label = 1;
            end
            if (countLabel == 1)
                if strcmp(SavetoDisk,'TRUE') % Saving full images to specific paths
                   if strcmp(UseFullImages,'TRUE')
                      imwrite(segmented_images{tissue_label}, sprintf('%s/Full images/Active/Active_%d.png', RootDirectory, ii));
                   end
                end
                countLabel = countLabel + 1;
            end
            [ip,jp] = find(pixel_labels == tissue_label);
            tissue_img = segmented_images{tissue_label}(min(ip):max(ip),min(jp):max(jp),:);
            figure(fgn);
            imshow(tissue_img,[]);title('tissue image');
            fgn = fgn + 1;

            croppedTissueImage = crop_image_thd(im,0.07);
            figure(fgn);
            imshow(croppedTissueImage,[]);title('Cropped tissue from Original image');
            fgn = fgn + 1;

            if (RatioPixels < 20)
                if (countCropping == 1)
                    tsuimg = croppedTissueImage;
                else
                    tsuimg = tissue_img;
                end
                if (countCropping == 1)
                    RepeateCropping = 'TRUE';
                    im = tsuimg;
                    countCropping = countCropping + 1;
                else
                   RepeateCropping = 'FALSE';
                end
             else
                tsuimg = tissue_img;
                RepeateCropping = 'FALSE';
             end

            figure(fgn);
            imshow(tsuimg,[]);title('Final tissue image to use for trainning');
            fgn = fgn + 1;
        end
        % Saving cropped images to specific paths
        if strcmp(SavetoDisk,'TRUE')
            if strcmp(UseCroppedImages,'TRUE')
                imwrite(tsuimg, sprintf('%s/Cropped images/Active/Active_%d.png' , RootDirectory, ii)) ;
            end
        end
    end
end
