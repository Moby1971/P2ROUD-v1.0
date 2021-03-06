function image_out = fft_reco3D_mc(app,kspace_in,nr_coils,autosense,coilsensitivies,coilactive,ndimx,ndimy,ndimz)


% kspace_in = {coil}[X Y Z NR]
%                    1 2 3 4  
dimx = size(kspace_in{1},1);
dimy = size(kspace_in{1},2);
dimz = size(kspace_in{1},3);
nr_dynamics = size(kspace_in{1},4);

% kspace data x,y,NR,slices,coils
if autosense == 1
    
    for i = 1:nr_coils
        kspace(:,:,:,:,i) = kspace_in{i}*coilactive(i);
    end
    
else
    
    for i = 1:nr_coils
        kspace(:,:,:,:,i) = kspace_in{i}*coilsensitivies(i)*coilactive(i);
    end
    
end
    

% reset progress counter
app.RecoProgressGauge.Value = 0;
drawnow;


% dynamic loop
for dynamic = 1:nr_dynamics
    
    % kspace of dynamic
    kdata = squeeze(kspace(:,:,:,dynamic,:));
    
    % zero-fill or crop x-dimension
    if ndimx > dimx
        padsizex = round((ndimx - dimx)/2);
        kdatai = padarray(kdata,[padsizex,0,0],'both');
    else
        cropsize = round((dimx - ndimx)/2)-1;
        cropsize(cropsize<0)=0;
        kdatai = kdata(cropsize+1:end-cropsize,:,:,:);
    end
    
    % zero-fill or crop y-dimension
    if ndimy > dimy
        padsizey = round((ndimy - dimy)/2);
        kdatai = padarray(kdatai,[0,padsizey,0],'both');
    else
        cropsize = round((dimy - ndimy)/2)-1;
        cropsize(cropsize<0)=0;
        kdatai = kdatai(:,cropsize+1:end-cropsize,:,:);
    end
    
    % zero-fill or crop z-dimension
    if ndimz > dimz
        padsizez = round((ndimz - dimz)/2);
        kdatai = padarray(kdatai,[0,0,padsizez],'both');
    else
        cropsize = round((dimz - ndimz)/2)-1;
        cropsize(cropsize<0)=0;
        kdatai = kdatai(:,:,cropsize+1:end-cropsize,:);
    end
    
    % make sure dimensions are exactly ndimx, ndimy, coils
    kdatai = kdatai(1:ndimx,1:ndimy,1:ndimz,:);
    
    % FFT
    for coil = 1:nr_coils
        image_tmp(:,:,:,coil) = fft3c_mri(squeeze(kdatai(:,:,:,coil)));
    end
    
    % root sum of squares
    image_out(:,:,:,dynamic) = rssq(image_tmp,4);
    
end

image_out = flip(flip(image_out,2),3);

% update gauge
app.RecoProgressGauge.Value = 100;
drawnow;

end



