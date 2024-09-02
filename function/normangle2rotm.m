function R = normangle2rotm(normal_vector, in_plane_rotation)

% Normalize the normal vector
normal_vector = normal_vector / norm(normal_vector);

% Compute two orthogonal vectors in the plane of the normal vector
plane_basis = null(normal_vector(:)')';

% plane_basis will be a 3x2 matrix where each column is a vector in the plane
u_vector = plane_basis(1,:); % First orthogonal vector in the plane
v_vector = plane_basis(2,:); % Second orthogonal vector in the plane

% Create the 2D rotation matrix
R2D = [
    cos(in_plane_rotation), -sin(in_plane_rotation);
    sin(in_plane_rotation), cos(in_plane_rotation)
];

% Rotate the basis vectors in the plane
rotated_plane_basis = R2D * [u_vector; v_vector];

% Update the u and v vectors after rotation
u_vector_rotated = rotated_plane_basis(1, :);
v_vector_rotated = rotated_plane_basis(2, :);

% Construct the 3D rotation matrix
R = [u_vector_rotated; v_vector_rotated; normal_vector];

end
