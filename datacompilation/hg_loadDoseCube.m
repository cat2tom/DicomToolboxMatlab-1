function [cube, xVec, yVec, zVec] = hg_loadDoseCube(file_path)
% The function takes a file path to RTDOSE dicom file and returns the dose
% cube and cube grid vectors.
%
% Hubert Gabrys <h.gabrys@dkfz.de>, 2015
% This file is licensed under GPLv2
%

dicom_info = dicominfo(file_path);
cube_o = dicomread(file_path);

if ndims(cube_o) == 4
    cube(:, :, :) = cube_o(:,:,1,:); % first two dimensions are x or y, third dimension is maybe an alpha channel, fourth dimension is a number of slices
    cube = double(cube); % convert dose values to double
    cube = cube * dicom_info.DoseGridScaling; % multiply by DoseGridScaling to obtain dose in Gy
    if dicom_info.GridFrameOffsetVector(1) ~= 0
        offset = dicom_info.GridFrameOffsetVector - dicom_info.GridFrameOffsetVector(1);
    else
        offset = dicom_info.GridFrameOffsetVector;
    end
    zVec = dicom_info.ImagePositionPatient(3) + offset;
    
    if zVec(2) - zVec(1) > 0 % Flip cube if zVec is ascending
        zVec(:,1) = flip(zVec);
        cube = flip(cube, 3);
    end
    
elseif ismatrix(cube_o)
    % dicom dosecube defined in slices
    cube = cube_o;
    cube = double(cube); % convert dose values to double
    cube = cube * dicom_info.DoseGridScaling; % multiply by DoseGridScaling to obtain dose in Gy
    max(cube(:))
    zVec = dicom_info.ImagePositionPatient(3);
end


if dicom_info.ImageOrientationPatient(1) == 1 && dicom_info.ImageOrientationPatient(2) == 0 && dicom_info.ImageOrientationPatient(3) == 0
    xVec = dicom_info.ImagePositionPatient(2) + (0:double(dicom_info.Rows-1))' * dicom_info.PixelSpacing(2);
elseif dicom_info.ImageOrientationPatient(1) == -1 && dicom_info.ImageOrientationPatient(2) == 0 && dicom_info.ImageOrientationPatient(3) == 0
    xVec = dicom_info.ImagePositionPatient(2) - (0:double(dicom_info.Rows-1))' * dicom_info.PixelSpacing(2);
    xVec = sort(xVec);
    cube = flip(cube,1);
end

if dicom_info.ImageOrientationPatient(4) == 0 && dicom_info.ImageOrientationPatient(5) == 1 && dicom_info.ImageOrientationPatient(6) == 0
    yVec = dicom_info.ImagePositionPatient(1) + (0:double(dicom_info.Columns-1))' * dicom_info.PixelSpacing(1);
elseif dicom_info.ImageOrientationPatient(4) == 0 && dicom_info.ImageOrientationPatient(5) == -1 && dicom_info.ImageOrientationPatient(6) == 0
    yVec = dicom_info.ImagePositionPatient(1) - (0:double(dicom_info.Columns-1))' * dicom_info.PixelSpacing(1);
    yVec = sort(yVec);
    cube = flip(cube,2);
end


end