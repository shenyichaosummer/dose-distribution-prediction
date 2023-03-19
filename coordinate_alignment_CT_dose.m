clear all
    
    % prediction = prediction_D95;
all_patient = dir("F:\SingleVMAT\test_data2");
for number_patient = 3:49
    patient = all_patient(number_patient).name;
    
    CTfile = ['F:\SingleVMAT\test_data2\',patient,'\CT&RS\'];
    RDfile = ['F:\SingleVMAT\test_data2\',patient,'\RD\'];
    
    firstfiles = dir([CTfile '*.dcm']);
    CTname = firstfiles.name;
    RD = dir([RDfile '*.dcm']);
    RDname = RD.name;
    
    %read size of RD file(*** input file name***)
    CTinfo=dicominfo([CTfile CTname]);
    RDinfo=dicominfo([RDfile RDname]);
    label = dicomread([RDfile RDname]);
    RDcolumns=RDinfo.Columns;
    RDrows=RDinfo.Rows;
    label = squeeze(label) * RDinfo.DoseGridScaling;
    
    cropped_label = label;
    
    %resize label and prediction to resolution of CT slices
    scale=RDinfo.PixelSpacing/CTinfo.PixelSpacing;
    resize_label=zeros(ceil(size(cropped_label,1)*scale(1)),ceil(size(cropped_label,2)*scale(2)),size(cropped_label,3));
    for depth=1:size(cropped_label,3)
      resize_label(:,:,depth)=imresize(cropped_label(:,:,depth),scale(1));
    end
    
    %pad resized label to original coordinate as CT slices
    size_resize_label = size(resize_label);
    left = round((RDinfo.ImagePositionPatient(1)-CTinfo.ImagePositionPatient(1))/CTinfo.PixelSpacing(1));
    right = CTinfo.Width - left - size_resize_label(2);
    top = round((RDinfo.ImagePositionPatient(2)-CTinfo.ImagePositionPatient(2))/CTinfo.PixelSpacing(2));
    buttom = CTinfo.Width - top - size_resize_label(1);
    
    if left < 0
       resize_label = resize_label(:,-1*left:size_resize_label(2),:);
       left = 0;
    end


    if top < 0
       resize_label = resize_label(-1*top:size_resize_label(1),:,:);
       top = 0;
    end


    if left + size_resize_label(2) > 512
       resize_label = resize_label(:,1:size_resize_label(2) - (left + size_resize_label(2)-512),:);
    end

    if top + size_resize_label(1) > 512
       resize_label = resize_label(1:size_resize_label(1) - (top + size_resize_label(1)-512),:,:);
    end

    leftrightpad_label = cat(2,zeros(size_resize_label(1),left,size_resize_label(3)),resize_label,zeros(size_resize_label(1),right,size_resize_label(3)));
    topbuttompad_label = cat(1,zeros(top,CTinfo.Width,size_resize_label(3)),leftrightpad_label,zeros(buttom,CTinfo.Width,size_resize_label(3)));
    final_label = topbuttompad_label;
    final_label = flip(final_label,3);
    
    
    z_start_COORD = double(RDinfo.ImagePositionPatient(3));
    z_coord_all = [];
    for z_index = 1:size(RDinfo.GridFrameOffsetVector)
      z_coord = RDinfo.GridFrameOffsetVector(z_index);
      z_coord_BY =  z_start_COORD + z_coord;
      z_coord_all = [z_coord_all,z_coord_BY];
    end
    z_coord_all = fliplr(z_coord_all);
    
    ct_start = double(CTinfo.ImagePositionPatient(3));
    ct_coord_all = [];
    for ct_index = 0:size(firstfiles,1) - 1 
      ct_coord = ct_start - 3 * ct_index;
      ct_coord_all = [ct_coord_all,ct_coord];
    end
    
    
    if ct_coord_all(1) > z_coord_all(1)
        z_start = 1;
    else
        z_start = find(z_coord_all == ct_coord_all(1));
    end
    
    
    
    
    if ct_coord_all(size(firstfiles,1)) > z_coord_all(z_index)
        z_end = find(z_coord_all == ct_coord_all(size(firstfiles,1)));
    else
        z_end = z_index;
    end
    
    
    
    
    if ct_coord_all(1) > z_coord_all(1)
        output_start = zeros(CTinfo.Width,CTinfo.Width,find(ct_coord_all == z_coord_all(1))-1);
    else
        output_start = [];
    end
    
    
    
    output_middle = final_label(:,:,z_start:z_end);
    
    
    if ct_coord_all(size(firstfiles,1)) < z_coord_all(z_index)
        output_end = zeros(CTinfo.Width,CTinfo.Width, size(firstfiles,1) - find(ct_coord_all == z_coord_all(z_index)));
    else
        output_end = [];
    end
    
    
    output = cat(3, output_start, output_middle, output_end);
    
    output = imresize3(output,[512,512,ct_index + 1]);
    outputfile = ['F:\SingleVMAT\npy\',patient,'_RD.npy'];
    writeNPY(output, outputfile);
end