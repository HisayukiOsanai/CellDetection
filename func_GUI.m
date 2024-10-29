function [outputs] = func_GUI(path_Image_def, path_AreaROI_def, str_rule_MergedImage_def, str_start_def, str_end_1_def, ...
    px_adaptivemean_def, MedFiltPx_def, MedFiltPx_def_NeuN, Morph_denoise_def, Morph_smooth_def, Area_ignore_def, RatioBack_def_sparse, RatioBack_def_dense, S_ignore_def, ...
    Thr_image1_def, Thr_image2_def, Thr_image3_def, Thr_image4_def)


%% GUI panels for folder path

% get(gcf,'Position')
fig = uifigure("Position", [108         325        1047         605]);
fig.Name = "Cell Counting GUI";
% gl = uigridlayout(fig,[9 3]);
% gl = uigridlayout(fig,[14 6]);
gl = uigridlayout(fig,[15 8]);

% lbl = uilabel(gl,"Text","Enter image path:", ...
%     "HorizontalAlignment","center");
lbl = uilabel(gl); lbl.Text = "Enter Image path:";
lbl.Layout.Row = 1; lbl.Layout.Column = 1;
ef1 = uieditfield(gl);
ef1.Value = path_Image_def;
ef1.Layout.Row = 1; ef1.Layout.Column = [2 8];


lbl = uilabel(gl); lbl.Text = "Enter ROI path:";
lbl.Layout.Row = 2; lbl.Layout.Column = 1;
ef2 = uieditfield(gl);
ef2.Value = path_AreaROI_def;
ef2.Layout.Row = 2; ef2.Layout.Column = [2 8];





lbl = uilabel(gl); lbl.Text = "staining:";
lbl.Layout.Row = 4; lbl.Layout.Column = 1;
dd = uidropdown(gl, 'Items',{'Single','Double','Triple', 'Quad', 'select a file'});
dd.Layout.Row = 4; dd.Layout.Column = 2;




btn = uibutton(gl,"Text","OK","ButtonPushedFcn",@updateButton);
btn.Layout.Row = 4; btn.Layout.Column = 8;
waitfor(btn,"UserData","Clicked");


path_Image = ef1.Value;
path_AreaROI = ef2.Value;

str_rule = '.roi';
fnamelist_roi = filenamelisting(path_AreaROI, str_rule);
fprintf('processing roi file names:\n');
disp(fnamelist_roi)
fprintf('total %d files\n', length(fnamelist_roi))


%%
% [file,location] = uigetfile({'*.*', 'All Files (*.*)'}, 'Select an image file');


%% GUI panels for file name rules



lbl = uilabel(gl); lbl.Text = 'Image filename rules to find ROI files:';
lbl.Layout.Row = 5; lbl.Layout.Column = [1 3];


lbl = uilabel(gl); lbl.Text = "merged image files contains text:";
lbl.Layout.Row = 5; lbl.Layout.Column = [4 5];
ef1 = uieditfield(gl);
ef1.Value = str_rule_MergedImage_def;
ef1.Layout.Row = 5; ef1.Layout.Column = 6;



lbl = uilabel(gl); lbl.Text = "sample name start:";
lbl.Layout.Row = 6; lbl.Layout.Column = 1;
ef2 = uieditfield(gl);
ef2.Value = str_start_def;
ef2.Layout.Row = 6; ef2.Layout.Column = 2;

lbl = uilabel(gl); lbl.Text = "sample name end:";
lbl.Layout.Row = 6; lbl.Layout.Column = 3;
ef3 = uieditfield(gl);
ef3.Value = str_end_1_def;
ef3.Layout.Row = 6; ef3.Layout.Column = 4;



s_staining = dd.Value;
if strcmp(s_staining, 'Single')
    lbl = uilabel(gl); lbl.Text = "Image name1 (NeuN):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 1;
    ef5 = uieditfield(gl);
    % str = "_Cy5-T1.jpg";
    str = "_DAPI-T4.jpg";
    ef5.Value = str;
    ef5.Layout.Row = 7; ef5.Layout.Column = 2;

    staining1 = uieditfield(gl);
    str = "NeuN";
    staining1.Value = str;
    staining1.Layout.Row = 8; staining1.Layout.Column = 2;

    staining_str = {staining1.Value};

elseif strcmp(s_staining, 'Double')



    lbl = uilabel(gl); lbl.Text = "Image name1 (NeuN):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 1;
    ef5 = uieditfield(gl);
    % str = "_Cy5-T1.jpg";
    str = "_DAPI-T4.jpg";
    ef5.Value = str;
    ef5.Layout.Row = 7; ef5.Layout.Column = 2;

    lbl = uilabel(gl); lbl.Text = "Image name2 (cfos):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 3;
    ef6 = uieditfield(gl);
    % ef6.Value = "_EGFP-T3.jpg";
    ef6.Value = "_Cy5-T1.jpg";
    ef6.Layout.Row = 7; ef6.Layout.Column = 4;




    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 1;
    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 3;



    staining1 = uieditfield(gl);
    str = "NeuN";
    staining1.Value = str;
    staining1.Layout.Row = 8; staining1.Layout.Column = 2;
    staining2 = uieditfield(gl);
    str = "cfos";
    staining2.Value = str;
    staining2.Layout.Row = 8; staining2.Layout.Column = 4;

    staining_str = {staining1.Value, staining2.Value};

elseif strcmp(s_staining, 'Triple')
    lbl = uilabel(gl); lbl.Text = "Image name1 (NeuN):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 1;
    ef5 = uieditfield(gl);
    str = "_Cy5-T1.jpg";
    ef5.Value = str;
    ef5.Layout.Row = 7; ef5.Layout.Column = 2;

    lbl = uilabel(gl); lbl.Text = "Image name2 (cfos):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 3;
    ef6 = uieditfield(gl);
    ef6.Value = "_EGFP-T3.jpg";
    ef6.Layout.Row = 7; ef6.Layout.Column = 4;

    lbl = uilabel(gl); lbl.Text = "Image name3 (Npas4):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 5;
    ef7 = uieditfield(gl);
    ef7.Value = "_DsRed-T2.jpg";
    ef7.Layout.Row = 7; ef7.Layout.Column = 6;


    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 1;
    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 3;
    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 5;
    staining1 = uieditfield(gl);
    str = "NeuN";
    staining1.Value = str;
    staining1.Layout.Row = 8; staining1.Layout.Column = 2;
    staining2 = uieditfield(gl);
    str = "cfos";
    staining2.Value = str;
    staining2.Layout.Row = 8; staining2.Layout.Column = 4;
    staining3 = uieditfield(gl);
    str = "Npas4";
    staining3.Value = str;
    staining3.Layout.Row = 8; staining3.Layout.Column = 6;

    staining_str = {staining1.Value, staining2.Value, staining3.Value};

elseif strcmp(s_staining, 'Quad')

    lbl = uilabel(gl); lbl.Text = "Image name1 (NeuN):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 1;
    ef5 = uieditfield(gl);
    % str = "_Cy5-T1.jpg";
    str = "_DAPI-T4.jpg";
    ef5.Value = str;
    ef5.Layout.Row = 7; ef5.Layout.Column = 2;

    lbl = uilabel(gl); lbl.Text = "Image name2 (cfos):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 3;
    ef6 = uieditfield(gl);
    % ef6.Value = "_EGFP-T3.jpg";
    ef6.Value = "_Cy5-T1.jpg";
    ef6.Layout.Row = 7; ef6.Layout.Column = 4;

    lbl = uilabel(gl); lbl.Text = "Image name3 (Npas4):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 5;
    ef7 = uieditfield(gl);
    ef7.Value = "_DsRed-T2.jpg";
    ef7.Layout.Row = 7; ef7.Layout.Column = 6;

    lbl = uilabel(gl); lbl.Text = "Image name4 (Arc):";
    lbl.Layout.Row = 7; lbl.Layout.Column = 7;
    ef7_2 = uieditfield(gl);
    ef7_2.Value = "_EGFP-T3.jpg";
    ef7_2.Layout.Row = 7; ef7_2.Layout.Column = 8;



    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 1;
    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 3;
    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 5;
    lbl = uilabel(gl); lbl.Text = "Staining:";
    lbl.Layout.Row = 8; lbl.Layout.Column = 7;


    staining1 = uieditfield(gl);
    str = "NeuN";
    staining1.Value = str;
    staining1.Layout.Row = 8; staining1.Layout.Column = 2;
    staining2 = uieditfield(gl);
    str = "cfos";
    staining2.Value = str;
    staining2.Layout.Row = 8; staining2.Layout.Column = 4;
    staining3 = uieditfield(gl);
    str = "Npas4";
    staining3.Value = str;
    staining3.Layout.Row = 8; staining3.Layout.Column = 6;
    staining4 = uieditfield(gl);
    str = "Arc";
    staining4.Value = str;
    staining4.Layout.Row = 8; staining4.Layout.Column = 8;

    staining_str = {staining1.Value, staining2.Value, staining3.Value, staining4.Value};

elseif strcmp(s_staining, 'select a file')

    [file,location] = uigetfile({'*.*', 'All Files (*.*)'}, 'Select an image file');

    ef2.Value = file;
    ef2.Layout.Row = 6; ef2.Layout.Column = 2;

    ef3.Value = '';
    ef3.Layout.Row = 6; ef3.Layout.Column = 4;


    clear('ef5')
    % ef5.Value = '';
    lbl = uilabel(gl); lbl.Text = "Image name1:";
    lbl.Layout.Row = 7; lbl.Layout.Column = 1;
    ef5 = uieditfield(gl);
    str = ".jpg";
    % str = file;
    ef5.Value = str;
    ef5.Layout.Row = 7; ef5.Layout.Column = 2;

    staining1 = uieditfield(gl);
    str = "user-selected";
    staining1.Value = str;
    staining1.Layout.Row = 8; staining1.Layout.Column = 2;

    staining_str = {staining1.Value};
end


btn = uibutton(gl,"Text","OK","ButtonPushedFcn",@updateButton);
btn.Layout.Row = 9; btn.Layout.Column = 8;
waitfor(btn,"UserData","Clicked");




str_rule_MergedImage = ef1.Value;
str_start = ef2.Value;
str_end = ef3.Value;
% str_end_1 = ef3.Value;
% str_end_2 = ef4.Value;

if strcmp(s_staining, 'Single')
    str_Image{1} = ef5.Value;

elseif strcmp(s_staining, 'Double')
    str_Image{1} = ef5.Value;
    str_Image{2} = ef6.Value;

elseif strcmp(s_staining, 'Triple')
    str_Image{1} = ef5.Value;
    str_Image{2} = ef6.Value;
    str_Image{3} = ef7.Value;

elseif strcmp(s_staining, 'Quad')
    str_Image{1} = ef5.Value;
    str_Image{2} = ef6.Value;
    str_Image{3} = ef7.Value;
    str_Image{4} = ef7_2.Value;

elseif strcmp(s_staining, 'select a file')
    str_Image{1} = ef5.Value;

end




fnamelist = filenamelisting(path_Image, str_rule_MergedImage);
fprintf('processing image file names:\n');
disp(fnamelist)
fprintf('total %d files\n', length(fnamelist))


startIndex = regexp(fnamelist{1}, str_start, 'once');
[~,endIndex] = regexp(fnamelist{1}, str_end, 'once');
% [~,endIndex] = regexp(fnamelist{1}, str_end_1, 'once');
% if isempty(endIndex) ==1
%     [~,endIndex] = regexp(fnamelist{1}, str_end_2, 'once');
% end

fprintf('\n')
fprintf(strcat('When "', fnamelist{1}, '" is processed,\n'))
fprintf(strcat('roi files are searched with strings: "', fnamelist{1}(startIndex:endIndex), '"\n'))
fprintf('\n')


%% GUI panels for parameters
% fig = uifigure("Position",[300 100 800 550]);
% fig.Name = "Cell Counting GUI";
% % gl = uigridlayout(fig,[9 3]);
% gl = uigridlayout(fig,[15 6]);


lbl2 = uilabel(gl);
lbl2.Text = "Parameters:";
lbl2.Layout.Row = 10; lbl2.Layout.Column = 1;


lbl = uilabel(gl); lbl.Text = "Mean Filter Pixels for background assumption:";
% lbl.Layout.Row = 10; lbl.Layout.Column = [4 5];
lbl.Layout.Row = 10; lbl.Layout.Column = [2 3];
ef1 = uieditfield(gl, "numeric");
ef1.Value = px_adaptivemean_def;
% ef1.Layout.Row = 10; ef1.Layout.Column = 6;
ef1.Layout.Row = 10; ef1.Layout.Column = 4;



if strcmp(s_staining, 'Double') || strcmp(s_staining, 'Triple') || strcmp(s_staining, 'Quad')
    lbl = uilabel(gl); lbl.Text = "Median Filt Pixels for image2~:"; lbl.HorizontalAlignment = 'right';
    % lbl.Layout.Row = 10; lbl.Layout.Column = 7 ;
    lbl.Layout.Row = 10; lbl.Layout.Column = 5 ;
    ef2 = uieditfield(gl, "numeric");
    ef2.Value = MedFiltPx_def;
    % ef2.Layout.Row = 10; ef2.Layout.Column = 8;
    ef2.Layout.Row = 10; ef2.Layout.Column = 6;
else
    clear('ef2')
    ef2.Value = 1;
end



lbl = uilabel(gl); lbl.Text = "Median Pixels for image1 (NeuN):"; lbl.HorizontalAlignment = 'right';
lbl.Layout.Row = 10; lbl.Layout.Column = 7 ;
ef2_2 = uieditfield(gl, "numeric");
ef2_2.Value = MedFiltPx_def_NeuN;
ef2_2.Layout.Row = 10; ef2_2.Layout.Column = 8;



lbl = uilabel(gl); lbl.Text = "Std Thresholds:";
lbl.Layout.Row = 11; lbl.Layout.Column = 1;


if strcmp(s_staining, 'Single')
    lbl = uilabel(gl); lbl.Text = "NeuN:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 1;
    ef3 = uieditfield(gl, "numeric");
    % ef3.Value = Thr_NeuN_def;
    ef3.Value = Thr_image1_def;
    ef3.Layout.Row = 11; ef3.Layout.Column = 2;

elseif strcmp(s_staining, 'Double')


    lbl = uilabel(gl); lbl.Text = "NeuN:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 1;
    ef3 = uieditfield(gl, "numeric");
    % ef3.Value = Thr_NeuN_def;
    ef3.Value = Thr_image1_def;
    ef3.Layout.Row = 11; ef3.Layout.Column = 2;

    lbl = uilabel(gl); lbl.Text = "cfos:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 3;
    ef4 = uieditfield(gl, "numeric");
    % ef4.Value = Thr_cfos_def;
    ef4.Value = Thr_image2_def;
    ef4.Layout.Row = 11; ef4.Layout.Column = 4;


elseif strcmp(s_staining, 'Triple')
    %%
    lbl = uilabel(gl); lbl.Text = "NeuN:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 1;
    ef3 = uieditfield(gl, "numeric");
    % ef3.Value = Thr_NeuN_def;
    ef3.Value = Thr_image1_def;
    ef3.Layout.Row = 11; ef3.Layout.Column = 2;

    lbl = uilabel(gl); lbl.Text = "cfos:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 3;
    ef4 = uieditfield(gl, "numeric");
    % ef4.Value = Thr_cfos_def;
    ef4.Value = Thr_image2_def;
    ef4.Layout.Row = 11; ef4.Layout.Column = 4;

    lbl = uilabel(gl); lbl.Text = "Npas4:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 5;
    ef5 = uieditfield(gl, "numeric");
    ef5.Value = Thr_image3_def;
    ef5.Layout.Row = 11; ef5.Layout.Column = 6;

elseif strcmp(s_staining, 'Quad')
    %%
    lbl = uilabel(gl); lbl.Text = "NeuN:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 1;
    ef3 = uieditfield(gl, "numeric");
    % ef3.Value = Thr_NeuN_def;
    ef3.Value = Thr_image1_def;
    ef3.Layout.Row = 11; ef3.Layout.Column = 2;

    lbl = uilabel(gl); lbl.Text = "cfos:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 3;
    ef4 = uieditfield(gl, "numeric");
    % ef4.Value = Thr_cfos_def;
    ef4.Value = Thr_image2_def;
    ef4.Layout.Row = 11; ef4.Layout.Column = 4;

    lbl = uilabel(gl); lbl.Text = "Npas4:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 5;
    ef5 = uieditfield(gl, "numeric");
    ef5.Value = Thr_image3_def;
    ef5.Layout.Row = 11; ef5.Layout.Column = 6;

    lbl = uilabel(gl); lbl.Text = "Arc:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 7;
    ef5_2 = uieditfield(gl, "numeric");
    ef5_2.Value = Thr_image4_def;
    ef5_2.Layout.Row = 11; ef5_2.Layout.Column = 8;

elseif strcmp(s_staining, 'select a file')
    lbl = uilabel(gl); lbl.Text = "NeuN:"; lbl.HorizontalAlignment = 'right';
    lbl.Layout.Row = 11; lbl.Layout.Column = 1;
    ef3 = uieditfield(gl, "numeric");
    % ef3.Value = Thr_NeuN_def;
    ef3.Value = Thr_image1_def;
    ef3.Layout.Row = 11; ef3.Layout.Column = 2;
end




lbl = uilabel(gl); lbl.Text = "Morphological processing [pix]"; lbl.HorizontalAlignment = 'right';
lbl.Layout.Row = 12; lbl.Layout.Column = [3 4];
lbl = uilabel(gl); lbl.Text = "denoising"; lbl.HorizontalAlignment = 'right';
lbl.Layout.Row = 12; lbl.Layout.Column = 5;
ef6 = uieditfield(gl, "numeric");
ef6.Value = Morph_denoise_def;
ef6.Layout.Row = 12; ef6.Layout.Column = 6;

lbl = uilabel(gl); lbl.Text = "smoothing"; lbl.HorizontalAlignment = 'right';
lbl.Layout.Row = 12; lbl.Layout.Column = 7;
ef7 = uieditfield(gl, "numeric");
ef7.Value = Morph_smooth_def;
ef7.Layout.Row = 12; ef7.Layout.Column = 8;



lbl = uilabel(gl); lbl.Text = "Background area ratio [%] for image1 (NeuN)"; lbl.HorizontalAlignment = 'left';
lbl.Layout.Row = 13; lbl.Layout.Column = [1 2];
ef8_2 = uieditfield(gl, "numeric");
ef8_2.Value = RatioBack_def_dense;
ef8_2.Layout.Row = 13; ef8_2.Layout.Column = 3;

if strcmp(s_staining, 'Double') || strcmp(s_staining, 'Triple') || strcmp(s_staining, 'Quad')
    lbl = uilabel(gl); lbl.Text = "for sparse (image2~)"; lbl.HorizontalAlignment = 'right';
    % lbl.Layout.Row = 13; lbl.Layout.Column = [3 4];
    lbl.Layout.Row = 13; lbl.Layout.Column = [4];
    ef8 = uieditfield(gl, "numeric");
    ef8.Value = RatioBack_def_sparse;
    ef8.Layout.Row = 13; ef8.Layout.Column = 5;

else
    ef8.Value = 0;
end



% lbl = uilabel(gl); lbl.Text = "Background area ratio in image [%] for sparse"; lbl.HorizontalAlignment = 'left';
% % lbl.Layout.Row = 13; lbl.Layout.Column = [3 4];
% lbl.Layout.Row = 13; lbl.Layout.Column = [1 2];
% ef8 = uieditfield(gl, "numeric");
% ef8.Value = RatioBack_def_sparse;
% ef8.Layout.Row = 13; ef8.Layout.Column = 3;
% 
% lbl = uilabel(gl); lbl.Text = "for dense images"; lbl.HorizontalAlignment = 'right';
% % lbl.Layout.Row = 13; lbl.Layout.Column = [3 4];
% lbl.Layout.Row = 13; lbl.Layout.Column = [4];
% ef8_2 = uieditfield(gl, "numeric");
% ef8_2.Value = RatioBack_def_dense;
% ef8_2.Layout.Row = 13; ef8_2.Layout.Column = 5;





lbl = uilabel(gl); lbl.Text = "Ignore cells if smaller than [pix]"; lbl.HorizontalAlignment = 'right';
lbl.Layout.Row = 13; lbl.Layout.Column = [6 7];
ef9 = uieditfield(gl, "numeric");
ef9.Value = Area_ignore_def;
ef9.Layout.Row = 13; ef9.Layout.Column = 8;


lbl = uilabel(gl); lbl.Text = "Pixels are regarded as outside-tissue if darker than [intensity]";
lbl.HorizontalAlignment = 'right';
lbl.Layout.Row = 14; lbl.Layout.Column = [3 7];
ef10 = uieditfield(gl, "numeric");
ef10.Value = S_ignore_def;
ef10.Layout.Row = 14; ef10.Layout.Column = 8;



btn = uibutton(gl,"Text","press to start","ButtonPushedFcn",@updateButton);
btn.Layout.Row = 15; btn.Layout.Column = 8;
waitfor(btn,"UserData","Clicked");


%%
px_adaptivemean = ef1.Value;
MedFiltPx = ef2.Value;
MedFiltPx_NeuN = ef2_2.Value;


Morph_denoise = ef6.Value;
Morph_smooth = ef7.Value;

RatioBack_sparse = ef8.Value;
RatioBack_dense = ef8_2.Value;
Area_ignore = ef9.Value;

S_ignore = ef10.Value;

% str_Image

if strcmp(s_staining, 'Single')
    Thr_Image{1} = ef3.Value;

elseif strcmp(s_staining, 'Double')
    Thr_Image{1} = ef3.Value;
    Thr_Image{2} = ef4.Value;

elseif strcmp(s_staining, 'Triple')
    Thr_Image{1} = ef3.Value;
    Thr_Image{2} = ef4.Value;
    Thr_Image{3} = ef5.Value;

elseif strcmp(s_staining, 'Quad')
    Thr_Image{1} = ef3.Value;
    Thr_Image{2} = ef4.Value;
    Thr_Image{3} = ef5.Value;
    Thr_Image{4} = ef6.Value;
elseif strcmp(s_staining, 'select a file')
    Thr_Image{1} = ef3.Value;
end

outputs.path_Image = path_Image;
outputs.path_AreaROI = path_AreaROI;


outputs.staining_str = staining_str;
outputs.str_Image = str_Image;
outputs.px_adaptivemean = px_adaptivemean;
outputs.MedFiltPx = MedFiltPx;
outputs.MedFiltPx_NeuN = MedFiltPx_NeuN;
outputs.Morph_denoise = Morph_denoise;
outputs.Morph_smooth = Morph_smooth;
outputs.RatioBack_sparse = RatioBack_sparse;
outputs.RatioBack_dense = RatioBack_dense;
outputs.Area_ignore = Area_ignore;

outputs.S_ignore = S_ignore;
outputs.Thr_Image = Thr_Image;

outputs.str_rule_MergedImage = str_rule_MergedImage;
outputs.str_start = str_start;
outputs.str_end = str_end;

outputs.fnamelist = fnamelist;

% saveas(fig,'output','bmp')
% exportapp(fig,'output.tiff')

end


%% functions
% %% Button pushed function: Button
% function BrowseFileNameButtonPushed(app, event)
%     [file,location] = uigetfile({'*.*', 'All Files (*.*)'}, 'Select an image file')
% end

%% gui buttons
function updateButton(src,event)
src.UserData = "Clicked";
end


%% find file name lists
function fnamelist = filenamelisting(path, str_rule)
% if ismac
%     % Code to run on Mac platform
%     listing = dir(path);
%     a = vertcat(listing.name);
%     a = cell2mat(struct2cell(listing));
% elseif ispc
%     % Code to run on Windows platform
%     listing = dir(path);
% end
listing = dir(path);

ftable = struct2table(listing);
A = ftable.name;

clear('fname')
for i = 1:length(A)
    if  (isempty( regexp(A{i}, str_rule, 'once')) == 0) && strcmp(A{i}([1 2]), 's ') ==0
        % if  (isempty( regexp(A{i}, '-(\d)(\d).jpg', 'once')) == 0) ==1
        fname{i,1} = A{i};
    end
end

x = find(cellfun('isempty',fname));
fname(x) = [];
fnamelist = fname;

% disp(fname)
end