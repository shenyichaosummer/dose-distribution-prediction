clear all;clc;
all_patient = dir("F:\SingleVMAT\test_data2");
for number_patient = 46:49
    patient = all_patient(number_patient).name;  
    %定义CT文件与文件个数
    fileNameCT = ['F:\SingleVMAT\test_data2\' , patient , '\CT&RS\'];
    filesCT = dir([fileNameCT '*.dcm']);
    filesCT_num = length(filesCT);
    sort_nat_name = sort_nat({filesCT.name});
    maskCTfiles_all = [];
    
    for CTi=1:filesCT_num
        CTdata = dicomread([fileNameCT sort_nat_name{CTi}]);
        maskCTfiles_all = cat(3,maskCTfiles_all,CTdata);
    end
    
    filenamesplit = strsplit(sort_nat_name{1},'.');
    stringsize = size(filenamesplit);
    start_page_BODY = str2double(filenamesplit(stringsize(2)-1));
    
    
    CTinfo = dicominfo([fileNameCT sort_nat_name{CTi}]);
    widthheight = CTinfo.Width;
    
    
    
    fileName = ['F:\SingleVMAT\test_data2\' , patient , '\CT&RS\mask2\mask\bladder\'];
    %寻找bmp结尾的文件，求得文件个数，并按自然顺序排序,生成中间mask矩阵
    files = dir([fileName '*.bmp']);
    files_num = length(files);
    maskfiles_all = [];
    sort_nat_name = sort_nat({files.name});
    for mi=1:files_num
        data = imread([fileName sort_nat_name{mi}]);
        maskfiles_all = cat(3,maskfiles_all,data);
    end
    %求得中间mask矩阵的开始和结束页码
    maskslicetogether = [];
    for j = 1:files_num
        filenamesplit = strsplit(sort_nat_name{j},'.');
        stringsize = size(filenamesplit);
        maskslice = filenamesplit(stringsize(2)-1);
        maskslicetogether = [maskslicetogether,str2double(maskslice)];
    end
    startpage = min(maskslicetogether) - start_page_BODY;
    endpage = max(maskslicetogether) - start_page_BODY;
    blankstartslice=zeros(widthheight,widthheight,startpage-1);
    blankendslice=zeros(widthheight,widthheight,filesCT_num-endpage);
    Bladder = cat(3,blankstartslice,maskfiles_all,blankendslice);
    
    
    
    fileName = ['F:\SingleVMAT\test_data2\' , patient , '\CT&RS\mask2\mask\rectum\'];
    %寻找bmp结尾的文件，求得文件个数，并按自然顺序排序,生成中间mask矩阵
    files = dir([fileName '*.bmp']);
    files_num = length(files);
    maskfiles_all = [];
    sort_nat_name = sort_nat({files.name});
    for mi=1:files_num
        data = imread([fileName sort_nat_name{mi}]);
        maskfiles_all = cat(3,maskfiles_all,data);
    end
    %求得中间mask矩阵的开始和结束页码
    maskslicetogether = [];
    for j = 1:files_num
        filenamesplit = strsplit(sort_nat_name{j},'.');
        stringsize = size(filenamesplit);
        maskslice = filenamesplit(stringsize(2)-1);
        maskslicetogether = [maskslicetogether,str2double(maskslice)];
    end
    startpage = min(maskslicetogether) - start_page_BODY;
    endpage = max(maskslicetogether) - start_page_BODY;
    blankstartslice=zeros(widthheight,widthheight,startpage-1);
    blankendslice=zeros(widthheight,widthheight,filesCT_num-endpage);
    Rectum = cat(3,blankstartslice,maskfiles_all,blankendslice);
    
    
    
    
    
    fileName = ['F:\SingleVMAT\test_data2\' , patient , '\CT&RS\mask2\mask\lfem\'];
    %寻找bmp结尾的文件，求得文件个数，并按自然顺序排序,生成中间mask矩阵
    files = dir([fileName '*.bmp']);
    files_num = length(files);
    maskfiles_all = [];
    sort_nat_name = sort_nat({files.name});
    for mi=1:files_num
        data = imread([fileName sort_nat_name{mi}]);
        maskfiles_all = cat(3,maskfiles_all,data);
    end
    %求得中间mask矩阵的开始和结束页码
    maskslicetogether = [];
    for j = 1:files_num
        filenamesplit = strsplit(sort_nat_name{j},'.');
        stringsize = size(filenamesplit);
        maskslice = filenamesplit(stringsize(2)-1);
        maskslicetogether = [maskslicetogether,str2double(maskslice)];
    end
    startpage = min(maskslicetogether) - start_page_BODY;
    endpage = max(maskslicetogether) - start_page_BODY;
    blankstartslice=zeros(widthheight,widthheight,startpage-1);
    blankendslice=zeros(widthheight,widthheight,filesCT_num-endpage);
    L_femoral_head = cat(3,blankstartslice,maskfiles_all,blankendslice);
    
    
    
    
    fileName = ['F:\SingleVMAT\test_data2\' , patient , '\CT&RS\mask2\mask\rfem\'];
    %寻找bmp结尾的文件，求得文件个数，并按自然顺序排序,生成中间mask矩阵
    files = dir([fileName '*.bmp']);
    files_num = length(files);
    maskfiles_all = [];
    sort_nat_name = sort_nat({files.name});
    for mi=1:files_num
        data = imread([fileName sort_nat_name{mi}]);
        maskfiles_all = cat(3,maskfiles_all,data);
    end
    %求得中间mask矩阵的开始和结束页码
    maskslicetogether = [];
    for j = 1:files_num
        filenamesplit = strsplit(sort_nat_name{j},'.');
        stringsize = size(filenamesplit);
        maskslice = filenamesplit(stringsize(2)-1);
        maskslicetogether = [maskslicetogether,str2double(maskslice)];
    end
    startpage = min(maskslicetogether) - start_page_BODY;
    endpage = max(maskslicetogether) - start_page_BODY;
    blankstartslice=zeros(widthheight,widthheight,startpage-1);
    blankendslice=zeros(widthheight,widthheight,filesCT_num-endpage);
    R_femoral_head = cat(3,blankstartslice,maskfiles_all,blankendslice);
    
    
    
    
    fileName = ['F:\SingleVMAT\test_data2\' , patient , '\CT&RS\mask2\mask\bowel\'];
    %寻找bmp结尾的文件，求得文件个数，并按自然顺序排序,生成中间mask矩阵
    files = dir([fileName '*.bmp']);
    files_num = length(files);
    maskfiles_all = [];
    sort_nat_name = sort_nat({files.name});
    for mi=1:files_num
        data = imread([fileName sort_nat_name{mi}]);
        maskfiles_all = cat(3,maskfiles_all,data);
    end
    %求得中间mask矩阵的开始和结束页码
    maskslicetogether = [];
    for j = 1:files_num
        filenamesplit = strsplit(sort_nat_name{j},'.');
        stringsize = size(filenamesplit);
        maskslice = filenamesplit(stringsize(2)-1);
        maskslicetogether = [maskslicetogether,str2double(maskslice)];
    end
    startpage = min(maskslicetogether) - start_page_BODY;
    endpage = max(maskslicetogether) - start_page_BODY;
    blankstartslice=zeros(widthheight,widthheight,startpage-1);
    blankendslice=zeros(widthheight,widthheight,filesCT_num-endpage);
    Small_bowel = cat(3,blankstartslice,maskfiles_all,blankendslice);
    
    
    
    
    
    fileName = ['F:\SingleVMAT\test_data2\' , patient , '\CT&RS\mask2\mask\PTV\'];
    %寻找bmp结尾的文件，求得文件个数，并按自然顺序排序,生成中间mask矩阵
    files = dir([fileName '*.bmp']);
    files_num = length(files);
    maskfiles_all = [];
    sort_nat_name = sort_nat({files.name});
    for mi=1:files_num
        data = imread([fileName sort_nat_name{mi}]);
        maskfiles_all = cat(3,maskfiles_all,data);
    end
    %求得中间mask矩阵的开始和结束页码
    maskslicetogether = [];
    for j = 1:files_num
        filenamesplit = strsplit(sort_nat_name{j},'.');
        stringsize = size(filenamesplit);
        maskslice = filenamesplit(stringsize(2)-1);
        maskslicetogether = [maskslicetogether,str2double(maskslice)];
    end
    startpage = min(maskslicetogether) - start_page_BODY;
    endpage = max(maskslicetogether) - start_page_BODY;
    blankstartslice=zeros(widthheight,widthheight,startpage-1);
    blankendslice=zeros(widthheight,widthheight,filesCT_num-endpage);
    PTV = cat(3,blankstartslice,maskfiles_all,blankendslice); 
    
    BladderexcludePTV =  double(imresize3((Bladder - PTV)/255,[512,512,filesCT_num]))/10 ;
    RectumexcludePTV =  double(imresize3((Rectum - PTV)/255,[512,512,filesCT_num]))/10 ;
    FemLexcludePTV =  double(imresize3((L_femoral_head - PTV)/255,[512,512,filesCT_num]))/10 ;
    FemRexcludePTV =  double(imresize3((R_femoral_head - PTV)/255,[512,512,filesCT_num]))/10 ;
    SmallbowelexcludePTV =  double(imresize3((Small_bowel - PTV)/255,[512,512,filesCT_num]))/10 ;
    PTV =  4.5 * double(imresize3(PTV/255,[512,512,filesCT_num]))/10 ;
    
    bladder_file_name = ['F:\SingleVMAT\stack\bladder\input_',patient,'.npy'];
    rectum_file_name = ['F:\SingleVMAT\stack\rectum\input_',patient,'.npy'];
    feml_file_name = ['F:\SingleVMAT\stack\lfem\input_',patient,'.npy'];
    femr_file_name = ['F:\SingleVMAT\stack\rfem\input_',patient,'.npy'];
    bowel_file_name = ['F:\SingleVMAT\stack\bowel\input_',patient,'.npy'];
     PTV_file_name = ['F:\SingleVMAT\stack\PTV\input_',patient,'.npy'];
    CT_file_name = ['F:\SingleVMAT\stack\CT\input_',patient,'.npy'];


    
    writeNPY(BladderexcludePTV, bladder_file_name)
    writeNPY(RectumexcludePTV, rectum_file_name)
    writeNPY(FemLexcludePTV,feml_file_name)
    writeNPY(FemRexcludePTV,femr_file_name)
    writeNPY(SmallbowelexcludePTV, bowel_file_name)
    writeNPY(PTV, PTV_file_name)
    writeNPY(imresize3(maskCTfiles_all,[512,512,filesCT_num]), CT_file_name)
    
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    