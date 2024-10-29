%% Main function, CellDetection

function [BinaryCells, Cells_inROI, Info_cells, I_subtract, thr_std, thr_Otsu, adj, thr] = ...
    func_CellDetection(I, ROIx, ROIy, MedFiltPx, Thr, px, Morph_denoise, Morph_smooth, Area_ignore, ...
    S_ignore, NumContour, RatioBack, roi_new)



%% original image
figure
% figure('visible','off');
I = rgb2gray(I);
I_original = I;
I = I(ROIy, ROIx);

I_preadj = I;



P = prctile(I(:), 99.5);
imshow(I_preadj)
clim(double([0 P]) * 255/150)
colorbar
title("original image before intensity adjustment")

% P = prctile(I(:), 99.5);
% I(I>P) = P;


fig = figure;
P = prctile(I(:), 99.5);
adj = 150/P;
I = I * adj; % adjust 99.5 percentile intensity as 150.
imshow(I)
title("original image")

hold on
% plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);

I_original = I;


%% median filter
I = medfilt2(I_original,[MedFiltPx MedFiltPx]);
figure
% figure('visible','off');
imshow(I)
title("median filtered")
axis on

Imed = I;


hold on
% plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);

% I_preadj = medfilt2(I_preadj,[MedFiltPx MedFiltPx]);



%% Otsu's method to get putative-background

% fprintf('Calc. peudo-background\n')

I_bak = Otsu_based_background(I, S_ignore, NumContour, RatioBack);

% fill NaN area with edge intensity
grayImage = I_bak;
goodPixels = ~isnan(grayImage);
goodPixels = bwconvhull(goodPixels, 'union');
props = regionprops(goodPixels, 'BoundingBox');
grayImage = imcrop(grayImage, props.BoundingBox); % Crop to outermost bounding box of the good pixels.

badPixels = isnan(grayImage);
grayImage = regionfill(grayImage, badPixels);
I_bak_filled = grayImage;


figure
% figure('visible','off');
imshow(I_bak_filled)
% clim([0 max(I_bak_filled(:))*1.2])
clim([0 250])
title("Otsu based peudo-background (Filled)")



%% adaptive threshold using mean filtering

I = double(I);
mean_I_bak = imfilter(I_bak_filled, fspecial('disk',px), 'replicate');

figure
% figure('visible','off');
imshow(mean_I_bak)
title('mean filtered image to subtract')
clim([0 100])

figure
% figure('visible','off');
I_subtract = I - mean_I_bak;
imshow(I_subtract)
clim([0 100])
title('adaptive mean subtract')


% now, effect of uneven illumination or dyeing is suppressed



%% Cell Detection Criteria 1: Thresholding with std

% close all

I_temp = I_subtract;
S_ignore = [];
I_bak = Otsu_based_background(I_temp, S_ignore, NumContour, RatioBack);


A = I_bak(:);
thr = Thr * std(A, "omitmissing");
% disp(thr)

img_t = I_subtract;
img_t(img_t< thr) = 0;

BW = imbinarize(img_t, 0);

figure
% figure('visible','off');
I3 = labeloverlay(uint8(I), BW, 'Colormap','autumn','Transparency',0.8);
imshow(I3)
title("Superimposed std-Thresholded Image")
clim([0 100])

BW_adapt_th = BW;
I_ThrOverlay = I3;

thr_std = thr;

%% Cell Detection Criteria 2: Background assumption using Otsu's method


II = I_subtract;
% figure
figure('visible','off');
imshow(uint8(II))


A = II(:);
A(A<=0)=[]; % ignore under zero intensities
thresh = multithresh(A, NumContour);

labels = imquantize(II,thresh);
figure
labelsRGB = label2rgb(labels);
imshow(labelsRGB)
title("Segmented Image")

% background based on Otsu
BW = labels == 1;
i = 0;
while  length(find(BW>0))/ length(BW(:)) < RatioBack/100
    i = i+1;
    BW = labels <= i;
    % disp(i)
end
figure
% figure('visible','off');
imshow(BW)
title("Otsu based Background and Signal")

BW_OtsuCriteria = BW;

if i>0
    thr_Otsu = thresh(i);
elseif i ==0
    thr_Otsu = thresh(1);
end

%% result of two criteria cell detection

figure
% figure('visible','off');
I3 = labeloverlay(I_ThrOverlay, BW_OtsuCriteria,'Transparency',0.6);
imshow(I3)
title("Otsu based Background Masking")
clim([0 100])
axis on
hold on
plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
try % plot eye-based identified cells if exists
    plot(coordinate_cfos(:,1), coordinate_cfos(:,2),'g+', 'LineWidth', 1, 'MarkerSize', 8);
    plot(coordinate_Npas4(:,1), coordinate_Npas4(:,2), '+', 'LineWidth', 1, 'Color', [1 0 0], 'MarkerSize', 8);
catch
end

maskedImage = BW_adapt_th; % binary image of threshold-passed cells
maskedImage(BW_OtsuCriteria) = 0; % Zero image outside the circle mask.

BW_TwoCriteriaPassed = maskedImage;

figure
% figure('visible','off');
% I3 = labeloverlay(uint8(I), BW_TwoCriteriaPassed, 'Colormap','autumn','Transparency',0.8);
I3 = labeloverlay(uint8(I), BW_TwoCriteriaPassed, 'Colormap','autumn','Transparency',0.7);
imshow(I3)
title("Signals passed two criteria")
clim([0 100])


BW_adapt_th = BW_TwoCriteriaPassed;
I_ThrOverlay = I3;



%% Morphological denoising and smoothing

% BW_threshold = BW;
[BW_mor, ~] = MorphologicalProcess(Morph_denoise, Morph_smooth, BW_TwoCriteriaPassed, Imed);

BW_mor2 = bwareaopen(BW_mor, Area_ignore); % ignore <= 50pix areas


I_overlay = labeloverlay(uint8(I), BW_mor2, 'Colormap','autumn','Transparency',0.7);


figure
% figure('visible','off');
imshow(I_overlay)
title("Signals passed Adapt-threshold and Otsu-back criteria and denoised")
hold on
% plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);




%% separate cells by watershed processing with intensity and cell morphology
% https://blogs.mathworks.com/steve/2013/11/19/watershed-transform-question-from-tech-support/?from=jp

% close all

% Morph_SmoothForWatershed = 5;
Morph_SmoothForWatershed = 2;

[BinaryCells, I_watershed] = func_watershed(BW_mor2, Imed, MedFiltPx, Morph_SmoothForWatershed, Area_ignore);






%% compare

% close all



figure
% figure('visible','off');
imshow(I_watershed)
title("Watersheded")
hold on
% plot(roi_new(:,1), roi_new(:,2), 'w--', 'LineWidth', 1);


%% remove outside-ROI cells


bw = poly2mask(roi_new(:,1), roi_new(:,2), size(I,1), size(I,2));


I_masked = imoverlay(I_watershed, ~bw, 'k') ;
figure
% figure('visible','off');
imshow(I_masked)
title("Cells in ROI")

Cells_inROI = BinaryCells;
Cells_inROI(~bw) = 0;


Label_cells = bwlabel(Cells_inROI);

Info_cells = regionprops(Label_cells, I_subtract/double(adj), 'FilledArea', "BoundingBox", 'Centroid',"Image",...
    "MajorAxisLength", "MinorAxisLength", "Circularity", "MaxIntensity", "MeanIntensity", "MinIntensity"); %#ok<MRPBW>



figure
imshow(I_masked)
hold on
for k = 1:numel(Info_cells)
    c = Info_cells(k).Centroid;
    text(c(1), c(2)-10, sprintf('%d', k), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'Color', 'w');
end
hold off

title("Cells in ROI, indexed")




%% show detection result

close all

figure
A = I_original;
imshow(A)
clim([0 150])
% get(gcf,'Position')
pos = [511          64        1140         889];
set(gcf,'Position',pos);


Cells_inROI = BinaryCells;
Label_cells = bwlabel(Cells_inROI);
Cells_inROI(~bw) = 0;
Label_cells_temp = bwlabel(Cells_inROI);
Info_cells_temp = regionprops(Label_cells_temp, I_subtract/double(adj), 'FilledArea', "BoundingBox", 'Centroid',"Image",...
    "MajorAxisLength", "MinorAxisLength", "Circularity", "MaxIntensity", "MeanIntensity", "MinIntensity"); %#ok<MRPBW>




figure
I3 = labeloverlay(I_original , Label_cells, 'Colormap','jet','Transparency',0.5);
imshow(I3)
hold on
for k = 1:numel(Info_cells_temp)
    c = Info_cells_temp(k).Centroid;
    text(c(1), c(2)-10, sprintf('%d', k), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'Color', [0.999 1 1]);
end
h = plot(roi_new(:,1), roi_new(:,2), 'w--', 'LineWidth', 1);


% get(gcf,'Position')
pos = [511          64        1140         889];
set(gcf,'Position',pos);


plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color', [0.999 1 1]);



end






%% functions
%% Morphological denoising and smoothing

function [I_mor, I_overlay] = MorphologicalProcess(Morph_denoise, Morph_smooth, BW, I)


se = strel("diamond", Morph_denoise) ;
I_temp = BW;
Ie = imerode(I_temp,se);
Iobr = imreconstruct(Ie,I_temp);
I_temp = Iobr;


se = strel("diamond", Morph_smooth) ;
Ic = imclose(I_temp, se);

figure
I3 = labeloverlay(uint8(I), ~Ic, 'Colormap','autumn','Transparency',0.7);
imshow(I3)
title("Opening-reconstruction-Closing")
I_temp = Ic;


I_overlay = I3;
I_mor = I_temp;

end


%% Otsu' method based background assumption

function I_bak = Otsu_based_background(I, S_ignore, NumContour, RatioBack)

II = I;

A = II(:);
try
    A(A<=S_ignore)=[]; %remove no signal area
catch
end
thresh = multithresh(A, NumContour); %Otsu' method for multi-thresholding

thresh = unique(thresh, 'stable' );  %to avoid same threshold number, it causes error in the next line
labels = imquantize(II,thresh);


figure
% figure('visible','off');
labelsRGB = label2rgb(labels);
imshow(labelsRGB)
title("Otsu Segmented Image")


BW = labels == 1;
i = 0;
while  length(find(BW>0))/ length(BW(:)) <RatioBack/100
    i = i+1;
    BW = labels <= i;
end


% figure
figure('visible','off');
imshow(BW)
title("peudo-background")

figure
% figure('visible','off');
I3 = labeloverlay(uint8(II), BW, 'Colormap','autumn','Transparency',0.8);
imshow(I3)
title("Otsu based peudo-background overlay")
% clim([0 100])
axis on

I_bak = double(I);
I_bak(~BW) = NaN;
% figure
figure('visible','off');
imshow(I_bak)
clim([0 50])
title("Otsu based peudo-background")

end



%% watershed cell ceparation

function [BinaryCells, I_watershed] = func_watershed(BW_mor, Imed, MedFiltPx, Morph_SmoothForWatershed, Area_ignore)

%% find local maxima intensities

A = Imed;

if MedFiltPx <= 15
    A = medfilt2(A,[15 15]); % to smooth image
end

A(BW_mor==0) = 0;

% figure
figure('visible','off');
imshow(A)

fgm = imregionalmax(A);

% https://jp.mathworks.com/help/images/find-image-peaks-and-valleys.html
% https://jp.mathworks.com/help/images/marker-controlled-watershed-segmentation.html

%% smoothing local maxima regions
se2 = strel("disk", Morph_SmoothForWatershed) ;

fgm2 = imdilate(fgm, se2);

figure
% figure('visible','off');
I3 = labeloverlay(A,fgm2);
imshow(I3)
title("Smoothed Regional Maxima")

%% Further separate cell using local maxima info
% https://jp.mathworks.com/help/images/marker-controlled-watershed-segmentation.html

bw = fgm2;
D = bwdist(bw);
DL = watershed(D);

Iwt = A;
Iwt(DL == 0) = 0;
% % figure
% figure('visible','off');
% imshow(Iwt)

AA = imbinarize(Iwt,0) ;
% % figure
% figure('visible','off');
% imshow(AA)

AA = bwareaopen(AA, Area_ignore); % ignore <= 50pix areas

% % figure
% figure('visible','off');
% imshow(AA)

% % figure
% figure('visible','off');
Iwt = A;
Iwt(AA==0) = 0;
% imshow(Iwt)
% imshowpair(DL2,DL,'montage')
title("Detected cell shapes")


% figure('visible','off');
figure
BinaryCells = bwdist(~Iwt);
BinaryCells(BinaryCells>0) = 1;
I3 = labeloverlay(Imed, BinaryCells, 'Colormap','autumn','Transparency',0.7);
imshow(I3)
title("Detected cell shapes on Original Median Image")



%% morph_waterthreshold


bw = BinaryCells;

D = -bwdist(~bw);

mask = imextendedmin(D, 0.5);
% % figure
% figure('visible','off');
% imshowpair(bw,mask,'blend')


D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = bw;
bw3(Ld2 == 0) = 0;
% % figure
% figure('visible','off');
% imshow(bw3)


AA = imbinarize(bw3, 0) ;
AA = bwareaopen(AA, Area_ignore); % ignore <= 50pix areas
AA = imerode(AA, se2); %denoise just in case
AA = imdilate(AA, se2);

% figure
% % figure('visible','off');
% imshow(AA)


% figure('visible','off');
figure
BinaryCells = bwdist(~AA);
BinaryCells(BinaryCells>0) = 1;
I3 = labeloverlay(Imed, BinaryCells, 'Colormap','autumn','Transparency',0.7);
imshow(I3)
title("Detected cell shapes on Original Median Image")

I_watershed = I3;


% https://www.mathworks.com/content/dam/mathworks/tag-team/Objects/w/88385_93006v00_Watershed_Transform_2016.pdf



end
