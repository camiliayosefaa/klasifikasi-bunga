function varargout = Test(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code

% --- Executes just before Test is made visible.
function Test_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for Test
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Test_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

% Eksekusi btn Input Citra
function btnInput_Callback(hObject, eventdata, handles)
    % Memilih gambar dari file explorer
    [fileName, filePath] = uigetfile({'*.jpg;*.jpeg;*.png'}, 'Select an image file');
    if ~isequal(fileName, 0)
        imagePath = fullfile(filePath, fileName);
        handles.imageData = imread(imagePath);

         % Cek gambar RGB atau tidak
        if size(handles.imageData, 3) == 3
            handles.grayImage = rgb2gray(handles.imageData);
        else
            % Gunakan gambar original jika sdh rgb
            handles.grayImage = handles.imageData;
        end

        handles.imageData = imresize(handles.imageData, [320 240]);

        imshow(handles.imageData, 'Parent', handles.gbrOri);
        title(handles.gbrOri, 'Original Image');
    end
    guidata(hObject, handles);  % Menyimpan handles kembali setelah mengupdate data

% Eksekusi btn Grayscale
function btnGrayscale_Callback(hObject, eventdata, handles)
    if ~isempty(handles.imageData)
        grayImage = rgb2gray(handles.imageData);
        handles.grayImage = grayImage;
        imshow(grayImage, 'Parent', handles.gbrGrayscale);
        title(handles.gbrGrayscale, 'Grayscale Image');
    else
        msgbox('Please input an image first.', 'Error', 'error');
    end
    guidata(hObject, handles);

function features = calculateGLCMFeatures(image)
    % Pastikan citra berada dalam skala abu-abu
    if size(image, 3) == 3
        image = rgb2gray(image);
    end

    % Fungsi untuk menghitung fitur GLCM
    glcm = graycomatrix(image);
    props = graycoprops(glcm);
    features = [props.Contrast, props.Correlation, props.Energy, props.Homogeneity];
    features = reshape(features, 1, []);

% Eksekusi btn GLCM
function btnGLCM_Callback(hObject, eventdata, handles)
  % Menampilkan hasil ekstraksi fitur GLCM
  if isfield(handles, 'segmentedImage') && ~isempty(handles.segmentedImage)
    glcmFeature = calculateGLCMFeatures(handles.segmentedImage);

    % Membuat satu baris data untuk ditambahkan ke dalam tabel
    data = {glcmFeature(1), glcmFeature(2), glcmFeature(3), glcmFeature(4)};
    % Mendapatkan data yang ada di tabel (jika ada)
    existingData = get(handles.tabel, 'Data');

    % Menambahkan data baru ke dalam baris pertama tabel
    tabel = [data; existingData];

    % Menyimpan data baru ke dalam tabel
    set(handles.tabel, 'Data', tabel); % Ganti 'myTable' dengan tag yang sesuai

    % Menampilkan gambar hasil ekstraksi fitur di axesGLCM
    imshow(handles.segmentedImage, 'Parent', handles.gbrEkstraksi);
    title(handles.gbrEkstraksi, 'GLCM Features');
  else
        msgbox('Please input an image first.', 'Error', 'error');
    end

% KNN Model
knnModel = glcmKnn();  
handles.knnModel = knnModel; % Kembalikan model ke handles
guidata(hObject, handles);  % Update handles structure

% Training
function knnModel = glcmKnn()
    cd('D:\TA PCD 2125250007 - 2125250088\');
    
    % Mendefinisikan kelas dataset
    dataset = {'daisy'; 'sunflower'};
    
    % Mendeklarasikan variabel untuk fitur dan kelas
    fitur_mat = [];
    kelas = [];
        
    % Loop melalui setiap kelas
    for i = 1:numel(dataset)
        currentClass = dataset{i};
        
        % Mendapatkan daftar file dalam setiap kelas
        files = dir(fullfile(currentClass, '*.jpg')); 
        
        % Loop melalui setiap file
        for j = 1:numel(files)
            % Membaca citra
            currentImage = imread(fullfile(currentClass, files(j).name));
            
             % Meresize citra ke ukuran [320 240]
            resizedImage = imresize(currentImage, [320 240]);
            
            % Ekstraksi fitur GLCM dari citra yang sudah diresize
            glcmFeatures = calculateGLCMFeatures(resizedImage);
            
            % Menambahkan fitur dan kelas ke matriks
            fitur_mat = [fitur_mat; glcmFeatures];
            kelas = [kelas; i]; % i merepresentasikan indeks kelas saat ini
        end
    end
    % Pelatihan model K-NN
    knnModel = fitcknn(fitur_mat, kelas, 'NumNeighbors', 1, 'Distance', 'euclidean');

% Perolehan akurasi
function etAcc_Callback(hObject, eventdata, handles)
    [uji, target, klasifikasi, hasil] = knn_acc(handles.knnModel);
    % Normalisasi fitur uji
    uji = zscore(uji);
    
    [{'Contrast', 'Correlation', 'Energy', 'Homogeneity', 'Target', 'Kelas', 'Hasil'};
        num2cell([uji target' klasifikasi']) hasil']
    cm = confusionmat(target', klasifikasi')
    akurasi = sum(diag(cm))/sum(sum(cm))*100
    precision = cm(1,1) / (cm(1,1) + cm(2,1))*100
    recall = cm(1,1) / (cm(1,1) + cm(1,2))*100
    set(handles.etAcc, 'String', akurasi);

% Eksekusi btn Result
function btnResult_Callback(hObject, eventdata, handles)
    if isfield(handles, 'segmentedImage') && ~isempty(handles.segmentedImage) && isfield(handles, 'knnModel') && ~isempty(handles.knnModel)
        
        % Cek citra rgb atau tidak, jika RGB ubah ke grayscale
        if size(handles.imageData, 3) == 3
            grayImage = rgb2gray(handles.imageData);
        else
            grayImage = handles.imageData;
        end

        % Resize image
        grayImage = imresize(grayImage, [320 240]);
        
        % Extract GLCM features
        glcmFeatures = calculateGLCMFeatures(handles.grayImage); % Menggunakan handles.segmentedImage
        
        % Perform KNN prediction
        prediction = predict(handles.knnModel, glcmFeatures);
        
        % Tampilkan hasil prediksi
        if prediction == 1
            classificationResult = 'Daisy';
        elseif prediction == 2
            classificationResult = 'Sunflower';
        else
            classificationResult = 'Unknown';
        end

        set(handles.etResult, 'String', classificationResult);
        imshow(handles.imageData, 'Parent', handles.gbrResult);
        title(handles.gbrResult, 'Result Image');
        % Hitung dan tampilkan akurasi
        etAcc_Callback(hObject, eventdata, handles);

    else
        msgbox('Please input an image and train the model first.', 'Error', 'error');
    end

function etResult_Callback(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function etResult_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in btnSeg.
function btnSeg_Callback(hObject, eventdata, handles)
   if isfield(handles, 'grayImage') && ~isempty(handles.grayImage)
        segmentedImage = performSegmentation(handles.grayImage);
        handles.segmentedImage = segmentedImage;

        % Menampilkan hasil segmentasi
        imshow(segmentedImage, 'Parent', handles.gbrSegmentasi);
        title(handles.gbrSegmentasi, 'Segmented Image');
    else
        msgbox('Please convert the image to grayscale first.', 'Error', 'error');
    end
    guidata(hObject, handles);

function segmentedImage = performSegmentation(grayImage)
   % Segmentasi thresholding
    thresholdValue = graythresh(grayImage); % Menghitung nilai threshold menggunakan metode otsu
    binaryImage = imbinarize(grayImage, thresholdValue);
    
    % Mengecek nilai threshold
    disp(['Otsu Threshold: ', num2str(thresholdValue)]);

    % Menggunakan connected component analysis (CCA) untuk menghilangkan
    % noise kecil pada citra biner
    CC = bwconncomp(binaryImage); % Identifikasi komponen terhubung pd citra biner
    numPixels = cellfun(@numel, CC.PixelIdxList); % Hitung jumlah pixel tiap komponen
    [~, idx] = max(numPixels); % Mencari indeks komponen terbesar (komponen dengan jumlah piksel terbanyak) 
    binaryImage(CC.PixelIdxList{idx}) = 1; % Atur pixel diluar komponen terbesar jadi latar belakang

    % Menyimpan hasil segmentasi
    segmentedImage = binaryImage;


% --- Executes during object creation, after setting all properties.
function etAcc_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
