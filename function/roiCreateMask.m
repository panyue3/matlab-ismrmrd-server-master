function roiMask = roiCreateMask(imagedata, metadata)

% Define the center position, size, normal vector, and in-plane rotation angle of the box
x_center = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiPosSag'))).value;
y_center = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiPosCor'))).value;
z_center = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiPosTra'))).value;
box_center = [x_center, y_center, z_center];

length = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiSizePhase'))).value;
width = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiSizeReadout'))).value;
height = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiSizeThickness'))).value;
box_size = [length, width, height];

nx = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiNormSag'))).value;
ny = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiNormCor'))).value;
nz = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiNormTra'))).value;
box_normvec = [nx, ny, nz];

box_theta = metadata.userParameters.userParameterDouble(find(strcmp({metadata.userParameters.userParameterDouble.name}, 'roiInPlaneRot'))).value;

% Define the center position, normal vector and size of the image plane
plane_center = imagedata.head.position;

meta = ismrmrd.Meta.deserialize(imagedata.attribute_string);
u_vector_rotated = double(meta.ImageColumnDir);
v_vector_rotated = double(meta.ImageRowDir);
plane_normvec = double(imagedata.head.slice_dir);

plane_size = double(imagedata.head.field_of_view(1:2));
matrix_size = double(imagedata.head.matrix_size(1:2));

% Construct the 3D rotation matrix
box_R = normangle2rotm(box_normvec, box_theta);

% Define the eight vertices of the box relative to the center
vertices = [
    -0.5, -0.5, -0.5;
    0.5, -0.5, -0.5;
    0.5, 0.5, -0.5;
    -0.5, 0.5, -0.5;
    -0.5, -0.5, 0.5;
    0.5, -0.5, 0.5;
    0.5, 0.5, 0.5;
    -0.5, 0.5, 0.5;
    ] .* box_size;

% Apply rotation and translate to the center position
vertices = vertices * box_R + box_center;

% Define the edges of the box as pairs of vertex indices
edges = [1, 2; 2, 3; 3, 4; 4, 1; 5, 6; 6, 7; 7, 8; 8, 5; 1, 5; 2, 6; 3, 7; 4, 8];

% Loop through each edge
intersection_points = [];
for i = 1:size(edges, 1)
    % Get the vertices of the edge
    v1 = vertices(edges(i, 1), :);
    v2 = vertices(edges(i, 2), :);

    % Compute the direction vector of the edge
    edge_vector = v2 - v1;

    % Compute the parameter t for the line-plane intersection
    t = dot((plane_center - v1), plane_normvec) / dot(edge_vector, plane_normvec);

    % If t is between 0 and 1, the intersection point lies on the edge
    if t >= 0 && t <= 1
        intersection_point = v1 + t * edge_vector;
        intersection_points = [intersection_points; intersection_point];
    end
end
intersection_points = unique(intersection_points, 'rows'); % Remove duplicate intersection points

% Plot the intersection points
if ~isempty(intersection_points)

    projected_points = [intersection_points * u_vector_rotated', intersection_points * v_vector_rotated'];
    projected_points = double(flip(matrix_size/2)) + projected_points .* flip(matrix_size./plane_size) ;

    % Compute the centroid of the projected points
    centroid = mean(projected_points);

    % Compute the angle of each point with respect to the centroid
    angles = atan2(projected_points(:, 2) - centroid(2), projected_points(:, 1) - centroid(1));

    % Sort the points by angle to form a convex polygon
    [~, sort_idx] = sort(angles);
    projected_points = projected_points(sort_idx, :);
else
    cropfactor = 4;
    projected_points = repmat(flip(matrix_size),[4 1]) .* (1+[-1/cropfactor, -1/cropfactor; 1/cropfactor, -1/cropfactor; 1/cropfactor, 1/cropfactor; -1/cropfactor, 1/cropfactor]) / 2;
end

figure
imagesc(imagedata.data)
h = drawpolygon('Position', projected_points);
roiMask = createMask(h);
% pause(3)
close

end