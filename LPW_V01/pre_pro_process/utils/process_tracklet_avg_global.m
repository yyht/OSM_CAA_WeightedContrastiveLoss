function [tracklet_feature] = process_tracklet_avg_global(net, tracklet, batch_size)
%PROCESS_TRACKLET_AVE_LOCAL3 Summary of this function goes here
%The fixed quality version
%   1. Input
%       net: the trained model
%       tracklet: image names cell
%       batch_size: the maximum input for each forward
%   2. Process
%       a. form batch
%       b. forward
%       c. extract output features
%   3. Output: (1, dim)
feature1 = [];

num_img = length(tracklet);
num_batch = floor(num_img/batch_size);

net.blobs('data').reshape([224 224 3 batch_size]);

for bt = 1 : num_batch
    % form batch
    batch_data = zeros(224, 224, 3, batch_size, 'single');
    for ind = 1 : batch_size
        ind_img = (bt-1)*batch_size + ind;
        img_name = tracklet{ind_img};
        batch_data(:,:,:, ind) = process_image( img_name );
    end
    % set_data, forward
    net.blobs('data').set_data(batch_data);
    net.forward_prefilled;
    % extract features
    feature1 = [feature1; (squeeze(net.blobs('pool5/7x7_s1').get_data))'];
end

% remained images
if  mod(num_img, batch_size) ~= 0
    remained_images = tracklet(num_batch*batch_size + 1 : end);
    num_img_remained = length(remained_images);
    batch_data = zeros(224, 224, 3, num_img_remained, 'single');

    net.blobs('data').reshape([224 224 3 num_img_remained]);

    for ind = 1 : num_img_remained
        img_name = remained_images{ind};
        batch_data(:,:,:, ind) = process_image( img_name );
    end

    % set data, forward
    net.blobs('data').set_data(batch_data);
    net.forward_prefilled;
    % extract features
    feature1 = [feature1; (squeeze(net.blobs('pool5/7x7_s1').get_data))'];
end

tracklet_feature = [sum(feature1/num_img)];

end

