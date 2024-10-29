
%% eye-based counting accuracy
function func_EyeAccuracy(filename_Image, path_Image, roi_new, roifile, Cells_inROI_Image, BinaryCells_Image, staining_str, f_save, ...
    fig_ImageLabel, ROIy, ROIx, minX, minY, str_end, Info_cells_Image)



eye_coordinate = {};

%% NeuN
k = 1;

try
    %%
    close all

    filename = filename_Image{k}; f = fullfile(path_Image, filename);
    I = rgb2gray(imread(f));
    img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
    img = img(ROIy, ROIx,:);
    fig_ImageLabel_eye{k} = figure('InvertHardCopy', 'off');
    img = labeloverlay(uint8(img), BinaryCells_Image{k}, 'Colormap','autumn','Transparency',0.8);
    imshow(img)

    axis on; hold on;
    % plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
    % plot(roi_new(:,1), roi_new(:,2), 'w--', 'LineWidth', 1);
    plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    set(gcf, 'InvertHardCopy', 'off');
    set(gcf, 'InvertHardCopy', 'off');
    hold on
    Info_cells = Info_cells_Image{k};
    for kk = 1:numel(Info_cells)
        cc = Info_cells(kk).Centroid;
        % text(cc(1), cc(2)-10, sprintf('%d', kk), ...
        %     'HorizontalAlignment', 'center', ...
        %     'VerticalAlignment', 'middle', 'Color', 'w');
        text(cc(1), cc(2)-10, sprintf('%d', kk), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'Color', [1 1 0.999]);
    end



    %
    path_IdentifiedCells_temp = 'D:\experiments\240409 Miari\240822 for paper\Miari_IHC_of_3_IEGs\NeuN_Visually_Counted_ROI';
    listing = dir(path_IdentifiedCells_temp);
    ftable = struct2table(listing);
    A = ftable.name;

    clear('IdentifiedCellFilename')
    [~, roiname, ~] = fileparts(roifile);
    searchname = roiname;
    for iii = 1:length(A)
        if regexp(A{iii}, '.roi')
            if regexp(A{iii}, searchname)
                IdentifiedCellFilename = A{iii};
            end
        end
    end

    f = fullfile(path_IdentifiedCells_temp, IdentifiedCellFilename);
    [sROI_cell] = ReadImageJROI(f);

    roi_cells = sROI_cell.mfCoordinates;

    x_cells = roi_cells(:,1)-minX;
    y_cells = roi_cells(:,2)-minY;
    % plot(x_cells, y_cells, '+', 'LineWidth', 1, 'Color', [0 0 1], 'MarkerSize', 8);
    % plot(x_cells, y_cells, '+', 'LineWidth', 2, 'Color', [0 0.5 1], 'MarkerSize', 8);
    plot(x_cells, y_cells, '+', 'LineWidth', 1.5, 'Color', [0 0.5 1], 'MarkerSize', 8);
    coordinate_NeuN = [x_cells, y_cells];

    title(strcat("eye ", staining_str{k}))

    s = strcat('_fig_eye_', num2str(k), '_', staining_str{k}, '.jpg');
    ss = strcat(f_save, s);
    % print(fig_ImageLabel_eye{k}, ss, '-djpeg')


    axis off
    title('')
    pos = [ 662   265   710   577];
    set(gcf,'Position',pos);
    set(gcf, 'color', 'w');

    % print(fig_ImageLabel_eye{k}, 'NeuNAccuracy', '-djpeg')




    plot([80 80],[30 1200], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 1750],[30 880], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([1750 1550],[880 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 1550],[1200 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);



    %%  analyze with new ROI


    close all

    k = 1;

    a = [80 30; 80 1200; 80 30; 1750 880; 1750 880; 1550 1250; 1550 1250; 80 1200; 80 30];



    filename = filename_Image{k}; f = fullfile(path_Image, filename);
    I = rgb2gray(imread(f));
    img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
    img = img(ROIy, ROIx,:);
    fig_ImageLabel_eye{k} = figure('InvertHardCopy', 'off');
    Label_cells = bwlabel(BinaryCells_Image{k});
    img = labeloverlay(uint8(img), Label_cells, 'Colormap','jet','Transparency',0.5);
    imshow(img)


    bw = poly2mask(a(:,1), a(:,2), size(img,1), size(img,2));
    Cells_inROI = BinaryCells_Image{k};
    Cells_inROI(~bw) = 0;
    Label_cells = bwlabel(Cells_inROI);

    % img = labeloverlay(uint8(img), Label_cells, 'Colormap','jet','Transparency',0.5);
    % img = labeloverlay(uint8(img), BinaryCells_Image{k}, 'Colormap','autumn','Transparency',0.8);
    % imshow(img)
    axis on; hold on;
    % plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    % plot(a(:,1), a(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    set(gcf, 'InvertHardCopy', 'off');

    Info_cells = regionprops(Label_cells, 'FilledArea', "BoundingBox", 'Centroid',"Image",...
        "MajorAxisLength", "MinorAxisLength", "Circularity"); %#ok<MRPBW>

    for kk = 1:numel(Info_cells)
        cc = Info_cells(kk).Centroid;
        % text(cc(1), cc(2)-10, sprintf('%d', kk), ...
        %     'HorizontalAlignment', 'center', ...
        %     'VerticalAlignment', 'middle', 'Color', 'w');
        text(cc(1), cc(2)-10, sprintf('%d', kk), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'Color', [1 1 0.999]*0.7);
    end



    %
    path_IdentifiedCells_temp = 'D:\experiments\240409 Miari\240822 for paper\Miari_IHC_of_3_IEGs\NeuN_Visually_Counted_ROI';
    listing = dir(path_IdentifiedCells_temp);
    ftable = struct2table(listing);
    A = ftable.name;

    clear('IdentifiedCellFilename')
    [~, roiname, ~] = fileparts(roifile);
    searchname = roiname;
    for iii = 1:length(A)
        if regexp(A{iii}, '.roi')
            if regexp(A{iii}, searchname)
                IdentifiedCellFilename = A{iii};
            end
        end
    end

    f = fullfile(path_IdentifiedCells_temp, IdentifiedCellFilename);
    [sROI_cell] = ReadImageJROI(f);

    roi_cells = sROI_cell.mfCoordinates;

    x_cells = roi_cells(:,1)-minX;
    y_cells = roi_cells(:,2)-minY;
    % plot(x_cells, y_cells, '+', 'LineWidth', 1.0, 'Color', [0.99 1 1], 'MarkerSize', 8);
    plot(x_cells, y_cells, '+', 'LineWidth', 1.0, 'Color', [0.99 1 1], 'MarkerSize', 6);
    coordinate_NeuN = [x_cells, y_cells];

    title(strcat("eye ", staining_str{k}))

    s = strcat('_fig_eye_', num2str(k), '_', staining_str{k}, '.jpg');
    ss = strcat(f_save, s);
    % print(fig_ImageLabel_eye{k}, ss, '-djpeg')


    axis off
    title('')
    pos = [ 662   265   710   577];
    set(gcf,'Position',pos);
    set(gcf, 'color', 'w');
    % print(fig_ImageLabel_eye{k}, 'NeuNAccuracy', '-djpeg')


    hold on
    plot([80 80],[30 1200], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 1750],[30 880], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([1750 1550],[880 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 1550],[1200 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    set(gcf,'Position',pos);

    %     ss = 'NeuNcount';
    % % print(gcf, ss, '-djpeg')
    % set(gcf,'Renderer', 'Painters');
    % print(gcf, ss, '-dmeta')


    %%

    figure
    filename = filename_Image{k}; f = fullfile(path_Image, filename);
    I = rgb2gray(imread(f));
    img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
    img = img(ROIy, ROIx,:);
    imshow(img)

    axis off
    title('')
    % clim([0 150])
    % xlim([550 1050])
    % ylim([500 1000])
    % set(gcf, 'color', 'none');
    pos = [ 662   265   710   577];
    set(gcf,'Position',pos);
    % % % get(gcf,'Position')
    % dir_save = 'D:\experiments\240409 Miari\code\code_new\MethodPaper_figs\Images';
    % s = strcat('fig_DG_original2');
    % ss = fullfile(dir_save, s);
    % print(gcf, ss, '-djpeg')

    % print(gcf, 'NeuNtemp', '-djpeg')


    %% show img with new roi
    close all


    filename = filename_Image{k}; f = fullfile(path_Image, filename);
    I = rgb2gray(imread(f));
    img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
    img = img(ROIy, ROIx,:);
    fig_ImageLabel_eye{k} = figure('InvertHardCopy', 'off');
    Label_cells = bwlabel(BinaryCells_Image{k});
    img = labeloverlay(uint8(img), Label_cells, 'Colormap','jet','Transparency',0.5);
    imshow(img)

    axis on; hold on;
    set(gcf, 'InvertHardCopy', 'off');
    set(gcf, 'InvertHardCopy', 'off');
    hold on
    Info_cells = Info_cells_Image{k};
    for kk = 1:numel(Info_cells)
        cc = Info_cells(kk).Centroid;
        % text(cc(1), cc(2)-10, sprintf('%d', kk), ...
        %     'HorizontalAlignment', 'center', ...
        %     'VerticalAlignment', 'middle', 'Color', 'w');
        text(cc(1), cc(2)-10, sprintf('%d', kk), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'Color', [1 1 0.999]*0.7);
    end


    % plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    % plot(x_cells, y_cells, '+', 'LineWidth', 1.0, 'Color', [0.3 0.8 1], 'MarkerSize', 8);
    plot(x_cells, y_cells, '+', 'LineWidth', 1.0, 'Color', [0.99 1 1], 'MarkerSize', 8);
    set(gcf,'Position',pos);

    % plot([50 1200], [80 80], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 80],[30 1200], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 1750],[30 880], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([1750 1550],[880 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 1550],[1200 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);

    axis off


    figure
    I = rgb2gray(imread(f));
    img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
    img = img(ROIy, ROIx,:);
    imshow(img)
    hold on
    plot([80 80],[30 1200], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 1750],[30 880], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([1750 1550],[880 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    plot([80 1550],[1200 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
    set(gcf,'Position',pos);

catch e %e is an MException struct
    coordinate_NeuN = [];
    % fprintf('error\n')

    % fprintf(1,'The identifier was:\n%s',e.identifier);
    % fprintf(1,'There was an error! The message was:\n%s',e.message);
    % error_line = e.stack;
    % % error_line = struct2table(e.stack.name)
    % % error_ = vertcat(e.stack.name)
    % disp(error_line)
end

eye_coordinate{1} = coordinate_NeuN;



%% other IEGs

for k = 2:4

    try
        %%
        filename = filename_Image{k}; f = fullfile(path_Image, filename);
        I = rgb2gray(imread(f));
        img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
        img = img(ROIy, ROIx,:);
        fig_ImageLabel_temp{k} = figure('InvertHardCopy', 'off');
        img = labeloverlay(uint8(img), BinaryCells_Image{k}, 'Colormap','autumn','Transparency',0.8);
        imshow(img)

        axis on; hold on;
        plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
        set(gcf, 'InvertHardCopy', 'off');
        title(staining_str{k})


        % eye-count


        filename = filename_Image{k};
        [~, fname_temp, ~] = fileparts(filename);

        % find brain area name from the readed brain-area roi file
        [~, roiname, ~] = fileparts(roifile);
        [~,endIndex] = regexp(roiname, str_end, 'once');
        brainareaname = {};
        try
            % brainareaname = regexp(roiname(endIndex+1:end), "[a-zA-Z1-9]+\s", 'match');
            brainareaname = regexp(roiname(endIndex+1:end), "[a-zA-Z1-9]+", 'match');
            brainareaname =  brainareaname{1}(1:end);
        catch e
            % fprintf(1,'The identifier was:\n%s',e.identifier);
            % fprintf(1,'There was an error! The message was:\n%s',e.message);
            % error_line = e.stack;
            % % error_line = struct2table(e.stack.name)
            % % error_ = vertcat(e.stack.name)
            % disp(error_line)
        end

        close all

        f = fullfile(path_Image, strcat("count ", fname_temp, '-1.jpg'));
        if isempty(brainareaname) == 0
            f = fullfile(path_Image, strcat("count ", fname_temp, '-1_', brainareaname,'.jpg'));
        end
        I = imread(f);
        % figure('visible','off');
        img = I(ROIy, ROIx,:);
        P = prctile(img(:), 99);
        adj = 150/P;
        % adj = 200/P;
        img = img * adj;
        fig = figure;
        imshow(img)
        hold on
        plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
        title("eye-count")

        s = strcat('_fig_eye_original_', num2str(k), '_', staining_str{k}, '.jpg');
        ss = strcat(f_save, s);
        % print(fig, ss, '-djpeg')

        %%

        % overlay
        % A = img(:,:,1) - img(:,:,2);
        % A(A<100) = 0;
        % A(A>=100) = 255;
        % B = img(:,:,1) - img(:,:,3);
        % A(B>50) = 0;
        % A = img(:,:,1)./img(:,:,2);

        % A = double(img(:,:,1)) ./ sqrt(double(img(:,:,1)).^2 + double(img(:,:,2)).^2 + double(img(:,:,3)).^2);
        % A(A<=2) = 0;


        A = img;
        mask1 = A(:,:,1) > 200;
        mask2 = A(:,:,2) < 60;
        mask3 = A(:,:,2) < 100;
        mask = mask1 & mask2 & mask3;
        % BW = bwareafilt(mask,[30 inf]);
        filtered_RGB = A .* uint8(mask);

        % figure
        % imshow(filtered_RGB)


        A = filtered_RGB(:,:,1);


        acceptdiff = 5;
        SE = strel("diamond",acceptdiff);
        A = imclose(A, SE);
        % A = imdilate(A, SE);
        % acceptdiff = 1; %
        % SE = strel("diamond",acceptdiff);
        % A = imopen(A, SE);
        figure
        imshow(A)
        clim([0 10])


        %%
        BW = imbinarize(A, 0);

        bw = poly2mask(roi_new(:,1), roi_new(:,2), size(A,1), size(A,2));
        BW(~bw) = 0;

        Label_cells = bwlabel(BW);




        Info_cells = regionprops(BW, 'FilledArea', 'Centroid');
        hold on

        c = vertcat(Info_cells.Centroid);
        A = vertcat(Info_cells.FilledArea);
        c(A<3,:) = [];
        % for iii = 1:size(c,1)
        %     text(c(iii,1), c(iii,2)-10, sprintf('%d', iii), ...
        %         'HorizontalAlignment', 'center', ...
        %         'VerticalAlignment', 'middle', 'Color', 'w');
        % end

        centers = c;

        plot(c(:,1), c(:,2), '+', 'LineWidth', 2, 'Color', [0 0.5 1], 'MarkerSize', 8);
        % coordinate_NeuN = [x_cells, y_cells];



        filename = filename_Image{k}; f = fullfile(path_Image, filename);
        I = rgb2gray(imread(f));
        img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
        img = img(ROIy, ROIx,:);
        fig_ImageLabel_eye{k} = figure('InvertHardCopy', 'off');
        img = labeloverlay(uint8(img), BinaryCells_Image{k}, 'Colormap','autumn','Transparency',0.8);
        imshow(img)
        axis on; hold on;
        % plot(roi_new(:,1), roi_new(:,2), 'w', 'LineWidth', 1);
        plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        set(gcf, 'InvertHardCopy', 'off');
        hold on
        Info_cells = Info_cells_Image{k};
        for kk = 1:numel(Info_cells)
            cc = Info_cells(kk).Centroid;
            % text(cc(1), cc(2)-10, sprintf('%d', kk), ...
            %     'HorizontalAlignment', 'center', ...
            %     'VerticalAlignment', 'middle', 'Color', 'w');
            text(cc(1), cc(2)-10, sprintf('%d', kk), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', [1 1 0.999]);
        end
        hold off
        % s = strcat("Cells in ROI, indexed, ", staining_str{k});
        % title(s)
        title(strcat("eye ", staining_str{k}))

        hold on
        % plot(c(:,1), c(:,2), '+', 'LineWidth', 2, 'Color', [0 0.5 1], 'MarkerSize', 8);
        plot(c(:,1), c(:,2), '+', 'LineWidth', 1.5, 'Color', [0 0.5 1], 'MarkerSize', 8);

        s = strcat('_fig_eye_', num2str(k), '_', staining_str{k}, '.jpg');
        ss = strcat(f_save, s);
        % print(fig_ImageLabel_eye{k}, ss, '-djpeg')


        %fig_ImageLabel_eye{k}

        %%
        close all

        figure
        I = rgb2gray(imread(f));
        img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
        img = img(ROIy, ROIx,:);
        imshow(img)

        axis off
        title('')
        % clim([0 150])
        % xlim([550 1050])
        % ylim([500 1000])
        % set(gcf, 'color', 'none');
        pos = [ 662   265   710   577];
        set(gcf,'Position',pos);
        % % % get(gcf,'Position')
        % dir_save = 'D:\experiments\240409 Miari\code\code_new\MethodPaper_figs\Images';
        % s = strcat('fig_DG_original2');
        % ss = fullfile(dir_save, s);
        % print(gcf, ss, '-djpeg')
        %
        set(gcf, 'color', 'w');
        % print(fig_ImageLabel_eye{k}, 'IEGaccuracy', '-djpeg')
        % print(gcf, 'cfostemp', '-djpeg')


        hold on
        plot([80 80],[30 1200], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        plot([80 1750],[30 880], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        plot([1750 1550],[880 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        plot([80 1550],[1200 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        set(gcf,'Position',pos);

        %% DG

        close all
        I = rgb2gray(imread(f));
        img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
        img = img(ROIy, ROIx,:);

        figure
        Label_cells = bwlabel(BinaryCells_Image{k});
        img = labeloverlay(uint8(img), Label_cells, 'Colormap','jet','Transparency',0.5);
        imshow(img)

        axis on; hold on;
        set(gcf, 'InvertHardCopy', 'off');
        hold on
        % k = 2;
        Info_cells = Info_cells_Image{k};
        for kk = 1:numel(Info_cells)
            cc = Info_cells(kk).Centroid;
            % text(cc(1), cc(2)-10, sprintf('%d', kk), ...
            %     'HorizontalAlignment', 'center', ...
            %     'VerticalAlignment', 'middle', 'Color', 'w');
            text(cc(1), cc(2)-10, sprintf('%d', kk), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', [1 1 0.999]*0.7);
        end

        axis off

        % xlim([1350 1750])
        % ylim([300 950])
        % % get(gcf,'Position')
        % axis off
        % title('')
        % set(gcf, 'color', 'none');
        % pos = [ 39   394   423   572];
        % set(gcf,'Position',pos);


        figure


        % plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        % plot(x_cells, y_cells, '+', 'LineWidth', 1.0, 'Color', [0.3 0.8 1], 'MarkerSize', 8);
        % plot(c(:,1), c(:,2), '+', 'LineWidth', 1.0, 'Color', [0.99 1 1], 'MarkerSize', 8);
        hold on
        plot(c(:,1), c(:,2), '+', 'LineWidth', 1.0, 'Color', [0.99 1 1], 'MarkerSize', 6);
        % plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);

        set(gcf,'Position',pos);

        % % plot([50 1200], [80 80], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        % plot([80 80],[30 1200], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        % plot([80 1750],[30 880], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        % plot([1750 1550],[880 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        % plot([80 1550],[1200 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);

        axis off

        set(gcf, 'color', 'w');






        path_AreaROI = 'D:\experiments\240409 Miari\code\code_new\MethodPaper_figs\Images\DG example';
        rdroi = 'ROI 240611cfosNpas4Arc HC-8 24L dHPC.roi';
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


        px = 31;
        if minX-px*2>1, minX=minX-px*2; else, minX=1; end
        if minY-px*2>1, minY=minY-px*2; else, minY=1; end
        if maxX+px*2<size(I,2), maxX=maxX+px*2; else, maxX=size(I,2); end
        if maxY+px*2<size(I,1), maxY=maxY+px*2; else, maxY=size(I,1); end

        ROIx = minX:maxX; % y pixels of ROI
        ROIy = minY:maxY; % x pixels of ROI

        % ROIx = 1:size(Itemp,2); % y pixels of ROI
        % ROIy = 1:size(Itemp,1); % x pixels of ROI

        hold on
        roi_new2 = [roi(:,1)-minX, roi(:,2)-minY];
        plot(roi_new2(:,1), roi_new2(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);


        %             ss = 'DGcfoscount';
        % % % print(gcf, ss, '-djpeg')
        % set(gcf,'Renderer', 'Painters');
        % print(gcf, ss, '-dmeta')

        %%
        %%  analyze with new ROI


        % close all

        k = 2;

        a = [80 30; 80 1200; 80 30; 1750 880; 1750 880; 1550 1250; 1550 1250; 80 1200; 80 30];



        filename = filename_Image{k}; f = fullfile(path_Image, filename);
        I = rgb2gray(imread(f));
        img = I; P = prctile(img(:), 99.5); adj = 150/P; img = img * adj;
        img = img(ROIy, ROIx,:);
        fig_ImageLabel_eye{k} = figure('InvertHardCopy', 'off');
        Label_cells = bwlabel(BinaryCells_Image{k});
        img = labeloverlay(uint8(img), Label_cells, 'Colormap','jet','Transparency',0.5);
        imshow(img)


        bw = poly2mask(a(:,1), a(:,2), size(img,1), size(img,2));
        Cells_inROI = BinaryCells_Image{k};
        Cells_inROI(~bw) = 0;
        Label_cells = bwlabel(Cells_inROI);

        % img = labeloverlay(uint8(img), Label_cells, 'Colormap','jet','Transparency',0.5);
        % img = labeloverlay(uint8(img), BinaryCells_Image{k}, 'Colormap','autumn','Transparency',0.8);
        % imshow(img)
        axis on; hold on;
        % plot(roi_new(:,1), roi_new(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        % plot(a(:,1), a(:,2), '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        set(gcf, 'InvertHardCopy', 'off');

        Info_cells = regionprops(Label_cells, 'FilledArea', "BoundingBox", 'Centroid',"Image",...
            "MajorAxisLength", "MinorAxisLength", "Circularity"); %#ok<MRPBW>

        for kk = 1:numel(Info_cells)
            cc = Info_cells(kk).Centroid;
            % text(cc(1), cc(2)-10, sprintf('%d', kk), ...
            %     'HorizontalAlignment', 'center', ...
            %     'VerticalAlignment', 'middle', 'Color', 'w');
            text(cc(1), cc(2)-10, sprintf('%d', kk), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', [1 1 0.999]*0.7);
        end



        hold on
        plot(c(:,1), c(:,2), '+', 'LineWidth', 1.0, 'Color', [0.99 1 1], 'MarkerSize', 6);

        title(strcat("eye ", staining_str{k}))

        s = strcat('_fig_eye_', num2str(k), '_', staining_str{k}, '.jpg');
        ss = strcat(f_save, s);
        % print(fig_ImageLabel_eye{k}, ss, '-djpeg')


        axis off
        title('')
        pos = [ 662   265   710   577];
        set(gcf,'Position',pos);
        set(gcf, 'color', 'w');
        % print(fig_ImageLabel_eye{k}, 'NeuNAccuracy', '-djpeg')


        hold on
        plot([80 80],[30 1200], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        plot([80 1750],[30 880], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        plot([1750 1550],[880 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        plot([80 1550],[1200 1250], '--', 'LineWidth', 1, 'Color',[1 1 0.999]);
        set(gcf,'Position',pos);

        %     ss = 'cfosNcount';
        % % print(gcf, ss, '-djpeg')
        % set(gcf,'Renderer', 'Painters');
        % print(gcf, ss, '-dmeta')



    catch e


        c = [];

        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'Error in eye-based detection. The message was:\n%s',e.message);
        % error_line = e.stack;
        % error_line = struct2table(e.stack.name)
        % error_ = vertcat(e.stack.name)
        % disp(error_line)
    end
    % c
    eye_coordinate{k} = c;
end




%% accuracy
% for culculating precision, sensitivity

% clear('AutoCount_T', 'EyeCount_T')
AutoCount_T = cell(length(filename_Image),1);
EyeCount_T = cell(length(filename_Image),1);
TP_auto = cell(length(filename_Image),1);
TP_eye = cell(length(filename_Image),1);
error_auto = cell(length(filename_Image),1);
error_eye = cell(length(filename_Image),1);

% k = 1;
for k = 1:length(filename_Image)
    if isempty(eye_coordinate{k})==0
        coordinate_temp = eye_coordinate{k};

        acceptdiff = 3; % accepet if eye-detection site is <5 pixels away from cell edge.
        SE = strel("disk",acceptdiff);

        % AutoCounted based
        Label_cells = bwlabel(Cells_inROI_Image{k});
        Overlap = zeros(max(max(Label_cells)),2);
        for iii = 1:max(max(Label_cells))
            Overlap(iii,1) = iii;
            A = Label_cells == iii;
            A = imdilate(A, SE);
            % [rows, columns] = find(A == iii);
            for j = 1:size(coordinate_temp,1)
                x = round(coordinate_temp(j,1));
                y = round(coordinate_temp(j,2));
                if A(y,x) ==1
                    Overlap(iii,2) = j;
                end
            end
        end
        AutoCount = Overlap;


        % EyeCounted based
        Label_cells = bwlabel(Cells_inROI_Image{k});
        Label_cells = imdilate(Label_cells, SE);
        Overlap2 = zeros(length(coordinate_temp),2);
        for iii = 1:size(coordinate_temp,1)
            Overlap2(iii,1) = iii;
            x = round(coordinate_temp(iii,1));
            y = round(coordinate_temp(iii,2));
            if Label_cells(y,x) >=1
                Overlap2(iii,2) = Label_cells(y,x);
            end
        end
        EyeCount = Overlap2;


        TP_auto{k} = length(find(AutoCount(:,2)>=1));
        TP_eye{k} = length(find(EyeCount(:,2)>=1));
        error_auto{k} = length(find(Overlap==0));
        error_eye{k} = length(find(Overlap2==0));


        AutoCount_T{k} = array2table(AutoCount, 'VariableNames',{'idx_auto', 'idx_eye'});
        EyeCount_T{k} = array2table(fliplr(EyeCount), 'VariableNames',{'idx_auto', 'idx_eye'});

    end
end



%% save

for k = 1:length(filename_Image)

    if isempty(EyeCount_T{k}) ==0

        s = strcat(f_save, '_CellDetectionAccuracy_', staining_str{k}, '.mat');
        save(s, 'AutoCount_T', 'EyeCount_T', 'TP_auto', 'TP_eye', 'error_auto', 'error_eye', '-v7.3');
    end

end

end
