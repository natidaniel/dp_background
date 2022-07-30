function croppedImage = crop_image_thd(im,thd)
    hsvImage = rgb2hsv(im);
    saturationImage = hsvImage(:,:,2); %ns
    leafMask = saturationImage > thd;
    leafMask = bwareafilt(leafMask, 1);
    leafMask = imfill(leafMask, 'holes');
    labeledImage = bwlabel(leafMask);
    props = regionprops(labeledImage, 'BoundingBox');
    boundingBox = props.BoundingBox;
    croppedImage = imcrop(im, boundingBox);
end