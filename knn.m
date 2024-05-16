function [uji, klasifikasi, hasil, s] = knn(model)

[I, path] = uigetfile('*jpg', 'select an input image');
str = strcat(path, I);
s = imread(str);

% GLCM extraction
m = graycomatrix(a);
g = graycoprops(m);

uji(1) = g.Contrast;
uji(2) = g.Correlation;
uji(3) = g.Energy;
uji(4) = g.Homogeneity;

% Define names for GLCM features
feature_names = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};

% Display the GLCM features with named x-axis
subplot(2, 3, 4);
bar(uji);
title('GLCM Features');
xticks(1:4);  % Set ticks for each feature
xticklabels(feature_names);  % Set feature names as labels

% Classification
klasifikasi = model.predict(uji());

% Display the final classification result
subplot(2, 3, [5, 6]);
imshow(s);
if klasifikasi' == 1
    hasil = {'Bunga Daisy'};
elseif klasifikasi' == 2
    hasil = {'Bunga Sunflower'};
else
    hasil = {'Tidak Diketahui'};
end
title(['Predicted: ' char(hasil)], 'FontSize', 15);

sgtitle(['Classification Result: ' char(hasil)], 'FontSize', 15);
end
