clear
clc
close all

% Training
cd('D:\SEFA\MDP\SMST 5\PCD\TA PCD Richie-Yosefa');
dataset = {'daisy';'sunflower'};
[fitur_mat, kelas] = glcm(dataset);
model = fitcknn(fitur_mat,kelas','NumNeighbors',1);

%Testing
[uji, klasifikasi, hasil, s] = knn(model);
[{'Contrast', 'Correlation', 'Energy', 'Homogeneity', 'Kelas', 'Hasil'};
    num2cell([uji klasifikasi']) hasil']

% Pengujian Akurasi
[uji, target, klasifikasi, hasil] = knn_acc(model);
[{'Contrast', 'Correlation', 'Energy', 'Homogeneity', 'Target', 'Kelas', 'Hasil'};
    num2cell([uji target' klasifikasi']) hasil']
cm = confusionmat(target', klasifikasi')
akurasi = sum(diag(cm))/sum(sum(cm))*100