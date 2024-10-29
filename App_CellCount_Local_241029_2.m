clear
% close all
all_fig = findall(0, 'type', 'figure');
close(all_fig)


%% default settings
% parameters

% pixels of mean filter for adaptive thresholding
px_adaptivemean_def = 31;

% median filter pixels
MedFiltPx_def = 11;
MedFiltPx_def_NeuN = 7;

% threhold, multipled by std
Thr_NeuN_def = 2; %for NeuN
Thr_cfos_def = 5; %for cfos
Thr_Npas4_def = 5; %for Npas4
Thr_Arc_def = 5; %for Arc


% mophological denoising and smoothing parameters
Morph_denoise_def = 5; %parameter to eliminate grainy noise
Morph_smooth_def = 2;

% ignore detections if cell area is less than this [pixels]
Area_ignore_def = 50;

% parameters for background-assumption
RatioBack_def_sparse = 95; %Consider Background occupies >95% area of original Image
RatioBack_def_dense = 80;


%consider pixels with intensity=0 is no signal area such as outside of tissue
S_ignore_def = 0;


Thr_image1_def = Thr_NeuN_def;
Thr_image2_def = Thr_cfos_def;
Thr_image3_def = Thr_Npas4_def;
Thr_image4_def = Thr_Arc_def;




%% file name rules for batch processing

%merged image file
str_rule_MergedImage_def = '-(\d)(\d).jpg';

%sample name rule
str_start_def = '(\d)(\d)(\d)(\d)(\d)';
str_end_1_def = '(\d)\s(\d)+[A-Z]\s[a-zA-Z]+';

%% folder pass (default)

% folder of Images
path_Image_def = 'D:\experiments\240409 Miari\code\code_new\MethodPaper_figs\For GUI panel fig\new\image';

% folder of ROI areas
% path_AreaROI_def = 'D:\experiments\240409 Miari\240822 for paper\Miari_IHC_of_3_IEGs\4colors_CFC\CFC_BLAa';
path_AreaROI_def = path_Image_def;



%% GUI


[outputs] = func_GUI(path_Image_def, path_AreaROI_def, str_rule_MergedImage_def, str_start_def, str_end_1_def, ...
    px_adaptivemean_def, MedFiltPx_def, MedFiltPx_def_NeuN, Morph_denoise_def, Morph_smooth_def, Area_ignore_def, RatioBack_def_sparse, RatioBack_def_dense, S_ignore_def, ...
    Thr_image1_def, Thr_image2_def, Thr_image3_def, Thr_image4_def);

path_Image = outputs.path_Image;
path_AreaROI = outputs.path_AreaROI;

staining_str = outputs.staining_str;
str_Image = outputs.str_Image;
px_adaptivemean = outputs.px_adaptivemean;
MedFiltPx = outputs.MedFiltPx;
MedFiltPx_NeuN = outputs.MedFiltPx_NeuN;
Morph_denoise = outputs.Morph_denoise;
Morph_smooth = outputs.Morph_smooth;
RatioBack_sparse = outputs.RatioBack_sparse;
RatioBack_dense = outputs.RatioBack_dense;
Area_ignore = outputs.Area_ignore;

S_ignore = outputs.S_ignore;
Thr_Image = outputs.Thr_Image;

str_rule_MergedImage = outputs.str_rule_MergedImage;
str_start = outputs.str_start;
str_end = outputs.str_end;

fnamelist = outputs.fnamelist;


%% Load image


for ii =  1:length(fnamelist)

    close all

    filename_all = fnamelist{ii};
    [~, fname_temp, ~] = fileparts(filename_all);



    for i = 1:length(str_Image)
        filename_Image{i,1} = strcat(fname_temp, str_Image{i});
    end


    fprintf(['try ' filename_all, '\n'])
    fprintf(['processing ' filename_all, '\n'])


    %% read image to check ROI

    px = px_adaptivemean;

    try
        % b = a;
        ROIset = func_ROI(path_Image, filename_Image, fnamelist, path_AreaROI, str_start, str_end, px, ii);

    catch e

        S = warning(e.message);
        warning('error in ROI file loading. cell detection runs with whole image.');
        % warning(S);
        ROIset = 0;
    end



    %% batch analysis with multiple ROI


    for i = 1:length(ROIset)
        %%
        if iscell(ROIset) == 0
            filename = filename_Image{1};
            f = fullfile(path_Image, filename);
            I = imread(f);

            ROIx = 1:size(I,2); ROIy = 1:size(I,1);
            minX = 1;    minY = 1;
            maxX = max(ROIx);    maxY = max(ROIy);
            roi_new = [1 1; 1 maxY; maxX maxY; maxX 1];
            roifile = 0;

        else
            ROIx = ROIset{i}.ROIx;    ROIy = ROIset{i}.ROIy;
            roi_new = ROIset{i}.roi_new;
            minX = ROIset{i}.minX;    minY = ROIset{i}.minY;
            maxX = ROIset{i}.maxX;    maxY = ROIset{i}.maxY;
            roifile = ROIset{i}.name;
        end

        figure
        filename = filename_Image{1};
        f = fullfile(path_Image, filename);
        I = imread(f);
        % figure('visible','off');
        img = I(ROIy, ROIx,:);
        P = prctile(img(:), 99);
        adj = 150/P;
        img = img * adj;
        imshow(img)

        hold on
        plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
        title("Original Image with ROI")



        %% Image analysis start from here

        NumContour = 20; %Number of threshold countors estimated with Otsu's method [1-20]



        close all

        %%  Image1-4      cell detection
        for iii = 1:length(filename_Image)

            %%
            fprintf( strcat("processing image of ", staining_str{iii}, '\n'))

            filename = filename_Image{iii};
            f = fullfile(path_Image, filename);
            I = imread(f);

            Thr = Thr_Image{iii};
            if (iii == 1)  %NeuN
                [BinaryCells, Cells_inROI, Info_cells, I_subtract, thr_std, thr_Otsu, adj, thr] = func_CellDetection(I, ROIx, ROIy, MedFiltPx_NeuN, Thr, px, Morph_denoise, Morph_smooth, Area_ignore, ...
                    S_ignore, NumContour, RatioBack_dense, roi_new);

            else % IEGs
                [BinaryCells, Cells_inROI, Info_cells, I_subtract, thr_std, thr_Otsu, adj, thr] = func_CellDetection(I, ROIx, ROIy, MedFiltPx, Thr, px, Morph_denoise, Morph_smooth, Area_ignore, ...
                    S_ignore, NumContour, RatioBack_sparse, roi_new);
            end



            BinaryCells_Image{iii} = BinaryCells;
            Cells_inROI_Image{iii} = Cells_inROI;
            Info_cells_Image{iii} = Info_cells;
            I_subtract_Image{iii} = I_subtract/double(adj);
            Thrshold.Image{iii}.std = thr_std/double(adj);
            Thrshold.Image{iii}.Otsu = thr_Otsu/double(adj);

            thr_Image{iii} = thr;

            close all
        end


        %% show cell detection results


        close all

        M = length(BinaryCells_Image);
        if M == 1
            A = BinaryCells_Image{1}; %NeuN
            CC = zeros(size(A));
            C = zeros(size(A));
            B = zeros(size(A));
        elseif M == 2
            A = BinaryCells_Image{1};
            CC = BinaryCells_Image{2};
            C = zeros(size(A));
            B = zeros(size(A));
        elseif M == 3
            A = BinaryCells_Image{1};
            CC = BinaryCells_Image{2};
            C = BinaryCells_Image{3};
            B = zeros(size(A));
        elseif M == 4
            A = BinaryCells_Image{1}; %NeuN
            CC = BinaryCells_Image{2}; %c-dos
            C = BinaryCells_Image{3}; %Npas4
            B = BinaryCells_Image{4}; %Arc
        end



        % function imblend:
        % DGM (2024). Image Manipulation Toolbox (https://github.com/291ce4321ac/MIMT/releases/tag/v1.56)
        % https://jp.mathworks.com/matlabcentral/fileexchange/53786-image-manipulation-toolbox
        fig_celldetection_all = figure;
        s = size(A);
        % cm = [100, 100, 100 ; 0,0,255; 0,200,0; 200, 0, 0] / 255;
        cm = [50,50,50 ; 0,0,255; 0,200,0; 200, 0, 0] / 255;

        % colorize the images
        Temp = exist('imblend', 'file');
        if Temp~=2
            d = cd('.\imblend');
        end
        Ac = imblend(colorpict(s(1:2),cm(1,:)),A,1,'multiply');
        Bc = imblend(colorpict(s(1:2),cm(2,:)),B,1,'multiply');
        Cc = imblend(colorpict(s(1:2),cm(3,:)),C,1,'multiply');
        Dc = imblend(colorpict(s(1:2),cm(4,:)),CC,1,'multiply');

        % cmtemp = [0 1 0]*0.5;
        % Ac = imblend(colorpict(s(1:2),cmtemp),A,1,'multiply');
        % cmtemp = [1 1 0.2]*0.7;
        % Dc = imblend(colorpict(s(1:2),cmtemp),CC,1,'multiply');

        % blend the images
        E = mergedown(cat(4,Ac,Bc,Cc, Dc),1,'screen');
        clf; imshow(E)
        if Temp~=2
            cd(d);
        end
        title('Gray:NeuN, Blue:Arc, Green:Npas4 Red:c-fos')

        hold on
        plot(roi_new(:,1), roi_new(:,2), 'w--', 'LineWidth', 1);
        set(gcf, 'InvertHardCopy', 'off');

        % figure
        % imshow(Ac)
        % title('NeuN')
        % figure
        % imshow(Bc)
        % title('Arc')
        % figure
        % imshow(Cc)
        % title('Npas4')
        % figure
        % imshow(Dc)
        % title('c-fos')

        % title('')

        for iii = 1:M
            fig = figure('InvertHardCopy', 'off');
            if iii == 1
                imshow(Ac)
            elseif iii == 2
                imshow(Dc)
            elseif M == 3
                imshow(Cc)
            elseif M == 4
                imshow(Bc)
            end
            % title('NeuN')

            hold on
            plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color', [0.999 1 1]);
            pos = [  85          97        1258         880];
            set(gcf,'Position',pos);
            title('')
        end

        %% save
        s = '_fig_celldetection_1_all.jpg';
        ss = strcat(f_save, s);
        saveas(fig_celldetection_all, ss)


        %% superimpose on original image

        filename = filename_all;
        f = fullfile(path_Image, filename);
        I = imread(f);

        img = I;
        P = prctile(img(:), 99);
        adj = 150/P; img = img * adj; img = img(ROIy, ROIx,:);
        fig_original = figure;
        imshow(img)
        title("Original Merged Image")
        axis on
        Img_all = img;
        hold on
        plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
        set(gcf, 'InvertHardCopy', 'off');


        I = imfuse(img,E,'blend','Scaling','joint');
        fig_celldetection_overlay = figure;
        imshow(I)

        title('superimposed image')
        hold on
        plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);





        %% show intensity-adjusted original images
        close all

        for iii = 1:M
            filename = filename_Image{iii};
            f = fullfile(path_Image, filename);
            I = rgb2gray(imread(f));
            img = I; P = prctile(img(:), 99); adj = 150/P; img = img * adj;
            img = img(ROIy, ROIx,:);


            if iii == 1
                A = img; %NeuN
                CC = zeros(size(A));
                C = zeros(size(A));
                B = zeros(size(A));
            elseif iii == 2
                CC = img;
            elseif M == 3
                C = img;
            elseif M == 4
                B = img;
            end

        end


        fig_original_falsecolor = figure;
        s = size(A);
        cm = [200,200,200 ; 0,0,255; 0,200,0; 200, 0, 0] / 255;
        % colorize the images
        Temp = exist('imblend', 'file');
        if Temp~=2
            d = cd('.\imblend');
        end
        Ac = imblend(colorpict(s(1:2),cm(1,:)),A,1,'multiply');
        Bc = imblend(colorpict(s(1:2),cm(2,:)),B,1,'multiply');
        Cc = imblend(colorpict(s(1:2),cm(3,:)),C,1,'multiply');
        Dc = imblend(colorpict(s(1:2),cm(4,:)),CC,1,'multiply');
        % blend the images
        E = mergedown(cat(4,Ac,Bc,Cc, Dc),1,'screen');
        clf; imshow(E)
        if Temp~=2
            cd(d);
        end

        axis on; hold on;
        set(gcf, 'InvertHardCopy', 'off');
        title("Original Merged Image, False Colror")

        img_temp = E;
        hold on
        plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color', [0.999 1 1]);
        set(gcf, 'InvertHardCopy', 'off');
        axis off
        xlim([150 1925])


        pos = [  85          97        1258         880];
        set(gcf,'Position',pos);
        title('')


        for iii = 1:M
            fig_original_sigle{iii} = figure('InvertHardCopy', 'off');
            if iii == 1
                imshow(Ac)
            elseif iii == 2
                imshow(Dc)
            elseif M == 3
                imshow(Cc)
            elseif M == 4
                imshow(Bc)
            end
            % title('NeuN')

            hold on
            plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color', [0.999 1 1]);
            set(gcf,'Position',pos);
            title('')
        end


        %% save

        s = '_fig_original_1_falsecolor.jpg';
        ss = strcat(f_save, s);
        % print(fig_original_false, ss, '-djpeg')
        saveas(fig_original_falsecolor, ss)

        for iii = 1:length(filename_Image)
            s = strcat('_fig_original_2_falsecolor', staining_str{iii}, '.jpg');
            ss = strcat(f_save, s);
            print(fig_original_sigle{iii}, ss, '-djpeg')


        end


        %% count cells

        % close all


        [Results_Counts_Areas, NeuN_MaxI_T, cfos_MaxI_T, Npas4_MaxI_T, Arc_MaxI_T] = ...
            func_CellCount(Info_cells_Image, Cells_inROI_Image, I_subtract_Image);


        bw = poly2mask(roi_new(:,1), roi_new(:,2), size(I,1), size(I,2));
        ROIarea = sum(bw(:));


        %% save results

        path_save = fullfile(path_Image, 'results');
        % path_save = 'D:\experiments\240409 Miari\code\code_new\MethodPaper_figs\Images';
        [status, msg, msgID] = mkdir(path_save);


        if roifile ~= 0
            filename = roifile;
        else
            [~,filename,~] = fileparts(filename_Image{1});
        end

        [~, filename, ext] = fileparts(filename);
        f_save = fullfile(path_save, filename);


        s = strcat(f_save, '_CellDetection.mat');

        save(s, 'Info_cells_Image', 'ROIarea', 'ROIset', 'Thrshold', ...
            'Results_Counts_Areas', 'NeuN_MaxI_T', 'cfos_MaxI_T', 'Npas4_MaxI_T', 'Arc_MaxI_T',...
            '-v7.3');


        %% save images

        % s = '_fig_celldetection_1_all.jpg';
        % ss = strcat(f_save, s);
        % saveas(fig_celldetection_all, ss)

        % s = '_fig_celldetection_2_noNeuN.jpg';
        % ss = strcat(f_save, s);
        % print(fig_celldetection_noNeuN, ss, '-djpeg')

        s = '_fig_celldetection_3_overlay.jpg';
        ss = strcat(f_save, s);
        % saveas(fig_celldetection_overlay, ss)
        % print(fig_celldetection_overlay, ss, '-djpeg')

        % s = '_fig_celldetection_4_all_inROI.jpg';
        % ss = strcat(f_save, s);
        % print(fig_celldetection_all_inROI, ss, '-djpeg')


        %% save intensity adjusted images

        s = '_fig_original_1.jpg';
        ss = strcat(f_save, s);
        % print(fig_original, ss, '-djpeg')
        % saveas(fig_original, ss)

        s = '_fig_original_1_falsecolor.jpg';
        ss = strcat(f_save, s);
        % print(fig_original_false, ss, '-djpeg')
        % saveas(fig_original_false, ss)

        for iii = 1:length(filename_Image)
            s = strcat('_fig_original_2_falsecolor', staining_str{iii}, '.jpg');
            ss = strcat(f_save, s);
            % print(fig_original_sigle{iii}, ss, '-djpeg')


        end


        for iii = 1:length(filename_Image)
            fig = figure;
            imshow(I_subtract_Image{iii})
            s = strcat("background subtracted, ", staining_str{iii});
            title(s)
            clim([0 max(I_subtract_Image{iii}(:)) * 0.6])

            s = strcat('_fig_background_subtracted_', num2str(iii), '_', staining_str{iii}, '.jpg');
            ss = strcat(f_save, s);
            % print(fig, ss, '-djpeg')

        end


        %% save cell-indexed image

        close all


        for k = 1:length(filename_Image)
            % NeuN Image
            filename = filename_Image{k}; f = fullfile(path_Image, filename);
            I = rgb2gray(imread(f));
            img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
            img = img(ROIy, ROIx,:);
            fig_ImageLabel{k} = figure('InvertHardCopy', 'off');
            img = labeloverlay(uint8(img), BinaryCells_Image{k}, 'Colormap','autumn','Transparency',0.8);
            imshow(img)
            axis on; hold on;
            plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
            set(gcf, 'InvertHardCopy', 'off');
            hold on
            s = strcat("Cells in ROI, indexed, ", staining_str{k});
            title(s)

            s = strcat('_fig_nonlabeled_', num2str(k), '_', staining_str{k}, '.jpg');
            ss = strcat(f_save, s);
            print(fig_ImageLabel{k}, ss, '-djpeg')

            Info_cells = Info_cells_Image{k};
            for kk = 1:numel(Info_cells)
                c = Info_cells(kk).Centroid;
                text(c(1), c(2)-10, sprintf('%d', kk), ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', 'Color', 'w');
            end
            hold off




            s = strcat('_fig_label_', num2str(k), '_', staining_str{k}, '.jpg');
            ss = strcat(f_save, s);
            print(fig_ImageLabel{k}, ss, '-djpeg')


            %% medfilt
            img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
            img = img(ROIy, ROIx,:);
            if (iii == 1) || (iii == 4) %NeuN or Arc
                Imed = medfilt2(img,[MedFiltPx_NeuN MedFiltPx_NeuN]);
            else % other IEGs
                Imed = medfilt2(img,[MedFiltPx MedFiltPx]);
            end

            fmed = figure;
            imshow(Imed)
            s = strcat("median filtered, ", staining_str{k});
            title(s)
            axis on
            hold on
            plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
            s = strcat('_fig_med_', num2str(k), '_', staining_str{k}, '.jpg');
            ss = strcat(f_save, s);
            % print(fmed, ss, '-djpeg')

        end



        close all

        %% count accuracy of cell counting (under constructing)


        % close all
        %
        % % f_save = '';
        %
        % % under constructing, only works with quad color
        % func_EyeAccuracy(filename_Image, path_Image, roi_new, roifile, Cells_inROI_Image, BinaryCells_Image, staining_str, f_save,...
        %     fig_ImageLabel, ROIy, ROIx, minX, minY, str_end, Info_cells_Image)
        %



    end



end



%% functions


%% read ROI

function ROIset = readROI(path_AreaROI, ~, px, I, samplename)

listing = dir(path_AreaROI);
ftable = struct2table(listing);
A = ftable.name;


clear('RoiFileName')
j = 1;
for i = 1:length(A)
    if isempty(regexp(A{i}, samplename, 'once'))==0 && isempty(regexp(A{i}, '.roi', 'once'))==0
        RoiFileName{j} = A{i}; %#ok<AGROW>
        disp(RoiFileName{j})
        j = j+1;
    end
end



ROIset = cell(length(RoiFileName),1);
for i = 1:length(RoiFileName)

    rdroi = RoiFileName{i};
    roifile = fullfile(path_AreaROI, rdroi);
    [sROI] = ReadImageJROI( roifile);

    try
        roi = sROI.mnCoordinates;
    catch
        roitemp = sROI.vnRectBounds;
        roi = [roitemp(2) roitemp(1); roitemp(4) roitemp(1); roitemp(4) roitemp(3); roitemp(2) roitemp(3); roitemp(2) roitemp(1)];
    end

    hold on
    plot(roi(:,1), roi(:,2), 'w', 'LineWidth', 1);


    [minX, maxX] = bounds(roi(:,1));
    [minY, maxY] =  bounds(roi(:,2));

    if minX-px*2>1, minX=minX-px*2; else, minX=1; end
    if minY-px*2>1, minY=minY-px*2; else, minY=1; end
    if maxX+px*2<size(I,2), maxX=maxX+px*2; else, maxX=size(I,2); end
    if maxY+px*2<size(I,1), maxY=maxY+px*2; else, maxY=size(I,1); end

    ROIx = minX:maxX; % y pixels of ROI
    ROIy = minY:maxY; % x pixels of ROI


    hold on
    roi_new = [roi(:,1)-minX, roi(:,2)-minY];

    title("Original Image with ROI")

    ROIset{i}.ROIx = ROIx;
    ROIset{i}.ROIy = ROIy;
    ROIset{i}.roi = roi;
    ROIset{i}.roi_new = roi_new;
    ROIset{i}.minX = minX;
    ROIset{i}.minY = minY;
    ROIset{i}.maxX = maxX;
    ROIset{i}.maxY = maxY;
    ROIset{i}.name = roifile;


end


end




%% Cell counting



function [Results_Counts_Areas, NeuN_MaxI_T, cfos_MaxI_T, Npas4_MaxI_T, Arc_MaxI_T] = ...
    func_CellCount(Info_cells_Image, Cells_inROI_Image, I_subtract_Image)


% figure


% N_NeuN = length(Info_cells_Image{1});
% N_cfos = length(Info_cells_Image{2});
% N_NPAS4 = length(Info_cells_Image{3});
% N_Arc = length(Info_cells_Image{4});

M = length(Info_cells_Image);

N_cells = zeros(4, 1);
Area_cells = zeros(4, 1);
Label_cells = cell(4, 1);
for i = 1:4
    if i<=M
        N_cells(i,1) = length(Info_cells_Image{i}); % cell counts
        Area_cells(i,1) = sum( vertcat(Info_cells_Image{i}.FilledArea)); % area [pixels]
        Label_cells{i,1} = bwlabel(Cells_inROI_Image{i});

    else
        N_cells(i,1) = 0;
        Area_cells(i,1) = 0;
        Label_cells{i,1} = zeros(size(Cells_inROI_Image{1}));
    end
end

%% based on NeuN+, cfos+,Arc+, Npas4+ cells

% pos_idx{k}(x,y): cell indices of NeuN/IEG positive cells. k(1 to 4): NeuN+/c-fos+/Npas4+/Arc+.
% x: cell index; y: 1: NeuN index, 2: c-fos index, 3: Npas4 index, 4: Arc index.

% OverlapPixels{k}(x,y): overlapping areas of cells (pixels)

% Intensities{k}(x,y): Intensities. k:(1 to 4): NeuN+/c-fos+/Npas4+/Arc+. x: cell index;
% y: 1: NeuN max intensity, 2: c-fos max, 3: Npas4 max, 4: Arc max, 5-8: mean intensities.

clear('temp_idx', 'OverlapPixels', 'Intensities', 'N_cells_overlap', 'Area_overlap', 'pos_idx')


for k = 1:4 %M

    if k<= M
        temp_idx{k} = zeros(N_cells(k), 4);
        OverlapPixels{k} = zeros(max(max(Label_cells{k})), 4);
        Intensities{k} = zeros(max(max(Label_cells{k})), 4);


        for i = 1:max(max(Label_cells{k}))
            [rows, columns] = find(Label_cells{k} == i);

            count_both = zeros(M,1);
            Intensities_temp = zeros(length(rows), length(Info_cells_Image));

            for j = 1:length(rows) %count pixels
                for kk = 1:M
                    if Cells_inROI_Image{kk}(rows(j), columns(j)) > 0 %NeuN
                        count_both(kk) = count_both(kk) +1;
                        temp_idx{k}(i,kk) = Label_cells{kk}(rows(j), columns(j));
                    end

                end

                for jj = 1:length(Info_cells_Image)
                    Intensities_temp(j, jj) = [I_subtract_Image{jj}(rows(j), columns(j))];
                end
            end

            OverlapPixels{k}(i, 1:M) = count_both';
            Intensities{k}(i, 1:M) = [max(Intensities_temp, [], 1)];
        end

    else
        temp_idx{k} = [0 0 0 0];
        OverlapPixels{k} = zeros(1, 4);
        Intensities{k} = zeros(1, 4);

    end

    N_cells_overlap{k} = N_cells';
    Area_overlap{k} = Area_cells';
    for i = 1:length(Info_cells_Image)
        overthr_temp = length(find(OverlapPixels{k}(:,i)>5));
        N_cells_overlap{k} = [N_cells_overlap{k}, overthr_temp];
        Area_overlap{k} = [Area_overlap{k}, sum(OverlapPixels{k}(OverlapPixels{k}(:,i)>5, i), 1)];
    end

    % ignore areas less than 5 pixels
    A = OverlapPixels{k} <= 5;
    pos_idx{k} = temp_idx{k};
    pos_idx{k}(A) = 0;

end

%
% Intensities_pos = Intensities;
% for k = 1:length(Info_cells_Image)
%     Intensities_pos{k}(pos_idx{k}==0) = 0;
% end



%% count up cells
%  NeuN+/cfos+', 'NeuN+/Npas4+', 'NeuN+/Arc+'
Num_NeuNpos = sum(pos_idx{1}>0, 1); %get number of element greater than 0 in column


% 'NeuN+/cfos+/Npas4+', 'NeuN+/cfos+/Arc+', 'NeuN+/Npas4+/Arc+', 'NeuN+/cfos+/Npas4+/Arc+'
idx1=find(pos_idx{1}(:,2)>0);
idx2=find(pos_idx{1}(:,3)>0);
idx3=find(pos_idx{1}(:,4)>0);
Lia = ismember(idx1,idx2);
ind_NeuNcfosNpas4 = idx1(Lia);
Lia = ismember(idx1,idx3);
ind_NeuNcfosArc = idx1(Lia);
Lia = ismember(idx2,idx3);
ind_NeuNNpas4Arc = idx2(Lia);
Lia = ismember(ind_NeuNcfosNpas4,idx3);
ind_NeuNcfosNpas4Arc = ind_NeuNcfosNpas4(Lia);
NumTemp_NeuN = [length(ind_NeuNcfosNpas4); length(ind_NeuNcfosArc); length(ind_NeuNNpas4Arc); length(ind_NeuNcfosNpas4Arc)];

% Cell Areas, NeuN based
Area_NeuNcfos = sum(OverlapPixels{1}(idx1, 1));
Area_NeuNNpas4 = sum(OverlapPixels{1}(idx2, 1));
Area_NeuNArc = sum(OverlapPixels{1}(idx3, 1));
Area_NeuNcfosNpas4 = sum(OverlapPixels{1}(ind_NeuNcfosNpas4, 1));
Area_NeuNcfosArc = sum(OverlapPixels{1}(ind_NeuNcfosArc, 1));
Area_NeuNNpas4Arc = sum(OverlapPixels{1}(ind_NeuNNpas4Arc, 1));
Area_NeuNcfosNpas4Arc = sum(OverlapPixels{1}(ind_NeuNcfosNpas4Arc, 1));
Area_NeuNIEG = [Area_NeuNcfos; Area_NeuNNpas4; Area_NeuNArc; ...
    Area_NeuNcfosNpas4; Area_NeuNcfosArc; Area_NeuNNpas4Arc; Area_NeuNcfosNpas4Arc ];


% 'cfos+/Npas4+', 'cfos+/Arc+', 'Npas4+/Arc+', 'cfos+/Npas4+/Arc+'... % in the case that NeuN cannot be used, e.g. in DG
% idx1=find(pos_idx{2}(:,2)>0);
idx2=find(pos_idx{2}(:,3)>0);
idx3=find(pos_idx{2}(:,4)>0);
ind_cfosNpas4 = idx2;
ind_cfosArc = idx3;
Lia = ismember(idx2,idx3);
ind_cfosNpas4Arc = idx2(Lia);

idx1=find(pos_idx{3}(:,4)>0);
ind_Npas4Arc = idx1;

NumTemp = [length(ind_cfosNpas4); length(ind_cfosArc); length(ind_Npas4Arc); length(ind_cfosNpas4Arc)];

% Cell Areas, IEG based
Area_cfosNpas4 = sum(OverlapPixels{2}(idx2, 2));
Area_cfosArc = sum(OverlapPixels{2}(idx3, 2));
Area_cfosNpas4Arc = sum(OverlapPixels{2}(ind_cfosNpas4Arc, 1));
Area_Npas4Arc = sum(OverlapPixels{3}(ind_Npas4Arc, 1));
Area_IEG = [Area_cfosNpas4; Area_cfosArc; Area_Npas4Arc; Area_cfosNpas4Arc ];

%% for saving results

RowName = {'NeuN+', 'cfos+','Npas4+', 'Arc', 'NeuN+/cfos+', 'NeuN+/Npas4+', 'NeuN+/Arc+',...
    'NeuN+/cfos+/Npas4+', 'NeuN+/cfos+/Arc+', 'NeuN+/Npas4+/Arc+', 'NeuN+/cfos+/Npas4+/Arc+',...
    'cfos+/Npas4+', 'cfos+/Arc+', 'Npas4+/Arc+', 'cfos+/Npas4+/Arc+'... % in the case that NeuN cannot be used, e.g. in DG
    };

cell_counts = [N_cells; Num_NeuNpos(2:end)'; NumTemp_NeuN; NumTemp];
cell_Areas = [Area_cells; Area_NeuNIEG; Area_IEG];

colnames = {'cell count', 'Area [pix]'};
Results_Counts_Areas = table(cell_counts, cell_Areas, 'RowNames',RowName, 'VariableNames', colnames);

% Intensities
VariableNames = {'NeuN maxI', 'cfos maxI', 'Npas4 maxI', 'Arc maxI', 'NeuN ind', 'cfos ind', 'Npas4 ind', 'Arc ind'};
k = 1;
NeuN_MaxI_T = table(Intensities{k}(:,1), Intensities{k}(:,2), Intensities{k}(:,3), Intensities{k}(:,4), ...
    pos_idx{k}(:,1), pos_idx{k}(:,2), pos_idx{k}(:,3), pos_idx{k}(:,4), 'VariableNames', VariableNames);
k = 2;
cfos_MaxI_T = table(Intensities{k}(:,1), Intensities{k}(:,2), Intensities{k}(:,3), Intensities{k}(:,4), ...
    pos_idx{k}(:,1), pos_idx{k}(:,2), pos_idx{k}(:,3), pos_idx{k}(:,4), 'VariableNames', VariableNames);
k = 3;
Npas4_MaxI_T = table(Intensities{k}(:,1), Intensities{k}(:,2), Intensities{k}(:,3), Intensities{k}(:,4), ...
    pos_idx{k}(:,1), pos_idx{k}(:,2), pos_idx{k}(:,3), pos_idx{k}(:,4), 'VariableNames', VariableNames);
k = 4;
Arc_MaxI_T = table(Intensities{k}(:,1), Intensities{k}(:,2), Intensities{k}(:,3), Intensities{k}(:,4), ...
    pos_idx{k}(:,1), pos_idx{k}(:,2), pos_idx{k}(:,3), pos_idx{k}(:,4), 'VariableNames', VariableNames);





end



%% ROI function

function ROIset = func_ROI(path_Image, filename_Image, fnamelist, path_AreaROI, str_start, str_end, px, ii)

filename = filename_Image{1};

f = fullfile(path_Image, filename);
I = imread(f);


figure
% figure('visible','off');
img = I;
P = prctile(img(:), 99);
adj = 150/P;
img = img * adj;
imshow(img)

title('original image')



%% read ROI
% % change here to with try func. if no ROI info, use whole image


startIndex = regexp(fnamelist{ii}, str_start, 'once');
[~,endIndex] = regexp(fnamelist{ii}, str_end, 'once');


fprintf(strcat('"', fnamelist{ii}, '" is being processed,\n'))
samplename = fnamelist{ii}(startIndex:endIndex);

ROIset = readROI(path_AreaROI, filename, px, I, samplename);


%% draw ROI

for i =  1:length(ROIset)
    ROIx = ROIset{i}.ROIx;    ROIy = ROIset{i}.ROIy;
    roi_new = ROIset{i}.roi_new;

    figure
    % figure('visible','off');
    img = I(ROIy, ROIx,:);
    P = prctile(img(:), 99);
    adj = 150/P;
    img = img * adj;
    imshow(img)


    hold on
    plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
    title("Original Image with ROI")

end

end



