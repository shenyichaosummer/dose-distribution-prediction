import pydicom as dicom
import numpy as np
from scipy.sparse import csc_matrix
import matplotlib.pyplot as plt
from collections import defaultdict
import os
import glob
import shutil
import operator
import warnings
import os, pdb, cv2
from tqdm import tqdm

def get_rs_name(sample_path, ct_uid):
    rs_names = []
    for filename in os.listdir(sample_path):
        filepath = os.path.join(sample_path, filename)
        if not os.path.isdir(filepath):
            file_obj = dicom.read_file(filepath, force=True)
            if "Modality" in file_obj.dir() and file_obj.Modality == "RTSTRUCT":
                if ct_uid == file_obj.ReferencedFrameOfReferenceSequence[0].RTReferencedStudySequence[0].RTReferencedSeriesSequence[0].SeriesInstanceUID:
                    rs_names.append(filename)
    return rs_names

def get_ct_uids(sample_path):
    ct_uids = set()
    for filename in os.listdir(sample_path):
        filepath = os.path.join(sample_path, filename)
        # import ipdb;ipdb.set_trace()
        if not os.path.isdir(filepath):
            file_obj = dicom.read_file(filepath, force=True)
            if "Modality" in file_obj.dir() and file_obj.Modality == "CT":
                ct_uids.add(file_obj.SeriesInstanceUID)
    return ct_uids

def get_slice_order(sample_path):
    slices = []
    for filename in os.listdir(sample_path):
        filepath = os.path.join(sample_path, filename)
        # import ipdb;ipdb.set_trace()

        if not os.path.isdir(filepath):
            dicom_obj = dicom.read_file(filepath, force=True)
            if "Modality" in dicom_obj and dicom_obj.Modality == "CT":
                slices.append(dicom_obj)
    
    slice_dict = {s.SOPInstanceUID: s.ImagePositionPatient[-1] for s in slices}
    ordered_slices = sorted(slice_dict.items(), key=operator.itemgetter(1))
    return ordered_slices

def get_roi_names(rs_path):
    rs_file = dicom.read_file(rs_path, force=True)
    roi_seq_names = [roi_seq.ROIName for roi_seq in list(rs_file.StructureSetROISequence)]
    return roi_seq_names

def get_slice_byzcoord(sample_path, target_zcoord, slice_order, deviation = 0.1):
    raw_name = None
    for slice_info in slice_order:
        slice_zcoord = slice_info[1]
        if abs(float(slice_zcoord) - float(target_zcoord)) <= deviation:
            raw_name = slice_info[0]
    return raw_name

def coord2pixels(contour_dataset, sample_path, contour_idx, slice_dict, CT_prefixs=["CT.", "CT", "CT_"]):
    contour_coord = contour_dataset.ContourData
    # x, y, z coordinates of the contour in mm
    coord = []
    for i in range(0, len(contour_coord), 3):
        coord.append((contour_coord[i], contour_coord[i + 1], contour_coord[i + 2]))
    
    z_coord = coord[0][2] # get the z coordinate of the contour
    img_ID = get_slice_byzcoord(sample_path, z_coord, slice_dict)
    if img_ID is None:
        warnings.warn("Haven't found the {} {}-th contour's ContourImageSequence".format(sample_path, contour_idx))
        return None, None
    
    # get the right name of CT slice. The prefix of CT from Eclipse and RayStation are "CT." and "CT".
    for CT_prefix in CT_prefixs:
        img_path = os.path.join(sample_path, CT_prefix + img_ID + ".dcm")
        if os.path.exists(img_path): break
    # img_path = './test_data2/22714701/CT&RS/CT.1.2.840.113619.2.278.3.296537803.458.1613951484.261.71.dcm'        
    img = dicom.read_file(img_path, force=True)
    
    # physical distance between the center of each pixel
    x_spacing, y_spacing = float(img.PixelSpacing[0]), float(img.PixelSpacing[1])
    # this is the center of the upper left voxel
    origin_x, origin_y, _ = img.ImagePositionPatient
    Width,Height = img.Rows,img.Columns
    
    # y, x is how it's mapped
    pixel_coords = [(np.ceil((x - origin_x) / x_spacing).astype(np.int32), np.ceil((y - origin_y) / y_spacing).astype(np.int32)) for x, y, _ in coord]
    for i, (x, y) in enumerate(pixel_coords):
        target_x, target_y = x, y
        if x < 0:
            target_x = 0
        if x > (Height-1):
            target_x = Height-1
        if y < 0:
            target_y = 0
        if y > (Width-1):
            target_y = Width-1
        pixel_coords[i] = (target_x, target_y)
        
    return pixel_coords, img_ID, Width, Height


def get_contour_dict(rs_path, sample_path, ROI_index, ROI_name, slice_dict):
    f = dicom.read_file(rs_path, force=True)
    ROI = f.ROIContourSequence[ROI_index]
    if "ContourSequence" not in ROI.dir():
#         warnings.warn("{} doesn't contain the {} ROI".format(rs_path, ROI_name))
        return None
    
    contours = [contour for contour in ROI.ContourSequence]
    contour_coords, img_IDs = [], []
    pre_sample_path = os.path.join(sample_path, '..')
    for i, cdata in enumerate(contours):
        contour_arr, img_ID, Width, Height = coord2pixels(cdata, pre_sample_path, i, slice_dict)
        if contour_arr is not None and img_ID is not None:
            contour_coords.append(contour_arr)
            img_IDs.append(img_ID)
    
    # debug: there are multiple contours for the same image indepently
    # sum contour arrays and generate new img_contour_arrays
    contour_dict = defaultdict(int)
    for j in range(len(img_IDs)):
        contour_arr, img_ID = contour_coords[j], img_IDs[j]
        if img_ID in contour_dict.keys():
            contour_dict[img_ID].append(contour_arr)
        else:
            contour_dict[img_ID] = [contour_arr]
    return contour_dict, Width, Height

def save_mask(mask_root, mask_name, contour_dict, color = (255, 255, 255)):
    mask_path = os.path.join(mask_root, mask_name)
    if not os.path.exists(mask_path):
        os.makedirs(mask_path)
    
    for img_ID, contours in contour_dict.items():
        mask_img = np.zeros((Width, Height))
        
        cv2.fillPoly(mask_img, pts = [np.array(contour) for contour in contours], color=color)
        cv2.imwrite(os.path.join(mask_path, img_ID + ".bmp"), mask_img)
        
    return mask_img

def plot2dcontour(img_arr, contour_arr, figsize=(20, 20)):

    masked_contour_arr = np.ma.masked_where(contour_arr == 0, contour_arr)
    plt.figure(figsize=figsize)
    plt.subplot(1, 2, 1)
    plt.imshow(img_arr, cmap='gray', interpolation='none')
    plt.subplot(1, 2, 2)
    plt.imshow(img_arr, cmap='gray', interpolation='none')
    plt.imshow(masked_contour_arr, cmap='cool', interpolation='none', alpha=0.7)
    plt.show()




patients_list = glob.glob('test_data2/*')
p_list = []
for patients in iter(patients_list):
    patients_id = patients.split('\\')[-1]
    p_list.append(patients_id)
    


for patient in p_list:
    data_root = "./test_data2/" + patient
    print(data_root)
    pp = sorted(os.listdir(data_root))
    print(pp)
# for i, sample_name in enumerate(()):
    sample_name = pp[0] 
    print("Processing {}\t{}".format(0, sample_name))
    sample_path = os.path.join(data_root, sample_name)
    mask_path = os.path.join(sample_path, "mask")
# if os.path.exists(mask_path):
    # 1/0

    slice_dict = get_slice_order(sample_path)
# import ipdb;ipdb.set_trace()

    ct_uids = list(get_ct_uids(sample_path))
    if len(ct_uids) > 1:
        print("{} has more than one ct series. ignored.".format(sample_name))
        1/0
    sample_path =os.path.join(data_root, pp[0], 'mask2')
    print(sample_path)
    rs_names = get_rs_name(sample_path, ct_uids[0])
    if len(rs_names) == 0:
        print("{} doesn't has matched rs file".format(sample_name))
    elif len(rs_names) > 1:
        print("{} has more than one rs file".format(sample_name))
# import ipdb;ipdb.set_trace() 
    rs_path = os.path.join(sample_path, rs_names[0])
    ROI_names = get_roi_names(rs_path)



    for ROI_idx, ROI_name in enumerate(ROI_names):
        print("\t {}".format(ROI_name))
        contour_dict, Width, Height = get_contour_dict(rs_path, sample_path, ROI_idx, ROI_name, slice_dict)
        if contour_dict is not None and len(contour_dict) > 0:
            img_mask = save_mask(os.path.join(sample_path, "mask"), ROI_name, contour_dict)
