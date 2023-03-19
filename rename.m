clear;clc;
patient = dir('F:\SingleVMAT\data');
num_patient = size(patient,1);
for n = 5:num_patient
    path_name=['F:\SingleVMAT\data\' , patient(n).name , '\plan\CT'];
    CT_file =dir(strcat(path_name,'/*.DCM'));
    num_CTfile = length(CT_file);
    startstring='CT_';
    endstring='.dcm';
    for i = 1:num_CTfile
        old_file_name = CT_file(i).name;
        old_file_name_all = ['F:\SingleVMAT\data\' ,patient(n).name, '\plan\CT\',old_file_name];
        path_dicomimg = strcat(path_name,'\',old_file_name);
        info = (dicominfo(path_dicomimg));
        new_file_name = strcat(startstring,info.SOPInstanceUID,endstring);
        nem_file_name_all = ['F:\SingleVMAT\data\' ,patient(n).name, '\plan\CT\',new_file_name];
        movefile(old_file_name_all,nem_file_name_all);
    end
end







    
