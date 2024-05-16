function [fitur_mat, kelas] = glcm(dataset)
    fitur_mat = [];
    kelas = [];

    for i = 1:length(dataset)
        current_folder = dataset{i};
        img_files = dir(fullfile(current_folder, '*.jpg'));

        for j = 1:length(img_files)
            namafile = fullfile(current_folder, img_files(j).name);
            citra = imread(namafile);

            % Check if the image is RGB or grayscale
            if size(citra, 3) == 3
                citra = rgb2gray(citra);
            end

            glcm_mat = graycomatrix(citra);
            prop = graycoprops(glcm_mat);

            fitur_mat = [fitur_mat; prop.Contrast, prop.Correlation, prop.Energy, prop.Homogeneity];
            kelas = [kelas; i];
        end
    end
end