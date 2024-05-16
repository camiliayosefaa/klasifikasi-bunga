function [uji,target,klasifikasi,hasil] = knn_acc(model)
cd("D:\SEFA\MDP\SMST 5\PCD\TA PCD Richie-Yosefa\uji");
data = {'daisy','sunflower'};
jmlkls = length(data);
for n=1:jmlkls
    cd(char(data(n)));
    datacitra = dir('*.jpg');
    jmldata = length(datacitra);
    for i = 1:jmldata
        namafile = datacitra(i).name;
        
        a = rgb2gray(imread(namafile));
        m = graycomatrix(a);
        g = graycoprops(m);
        uji(i+jmldata*(n-1),1) = g.Contrast;
        uji(i+jmldata*(n-1),2) = g.Correlation;
        uji(i+jmldata*(n-1),3) = g.Energy;
        uji(i+jmldata*(n-1),4) = g.Homogeneity;

        target(i+jmldata*(n-1)) = n;
        klasifikasi(i+jmldata*(n-1)) = model.predict(uji(i+jmldata*(n-1),:));
        if klasifikasi(i+jmldata*(n-1)) == target(n)
            hasil(i+jmldata*(n-1)) = {'Benar'};
        else
            hasil(i+jmldata*(n-1)) = {'Salah'};
        end
    end
    cd('..');
end
end