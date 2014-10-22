function [ ] = video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
    hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, target_energy,...
    hFindMax, threshold, gain, target_size, hPlot, hROIPattern, Im_p )

    Im = rgb2gray(step(vidDevice));
    Im_gp = step(hGaussPymd3, Im);

    % Frequency domain convolution.
    Im_p(1:ri, 1:ci) = Im_gp;    % Zero-pad
    img_fft = step(hFFT2D2, Im_p);
    corr_freq = img_fft .* target_fft;
    corrOutput_f = step(hIFFFT2D, corr_freq);
    corrOutput_f = corrOutput_f(rt:ri, ct:ci);

    % Calculate image energies and block run tiles that are size of
    % target template.
    IUT_energy = (Im_gp).^2;
    IUT = step(hConv2D, IUT_energy, C_ones);
    IUT = sqrt(IUT);

    % Calculate normalized cross correlation.
    norm_Corr_f = (corrOutput_f) ./ (IUT * target_energy);
    xyLocation = step(hFindMax, norm_Corr_f);

    % Calculate linear indices.
    linear_index = sub2ind([ri-rt, ci-ct]+1, xyLocation(:,2),...
        xyLocation(:,1));

    norm_Corr_f_linear = norm_Corr_f(:);
    norm_Corr_value = norm_Corr_f_linear(linear_index);
    detect = (norm_Corr_value > threshold);
    target_roi = zeros(length(detect), 4);
    ul_corner = (gain.*(xyLocation(detect, :)-1))+1;
    target_roi(detect, :) = [ul_corner, fliplr(target_size(detect, :))];

    % Draw bounding box.   
    Imf = insertShape(Im, 'Rectangle', target_roi, 'Color', 'green');
    % Plot normalized cross correlation.
    videopatternplots1('update',hPlot,norm_Corr_value);
    step(hROIPattern, Imf);
    
end