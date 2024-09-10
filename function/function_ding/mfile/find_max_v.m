% Find the extreme value of a matrix, typically the maximum velocity.
% v = find_max_v(a)

function v = find_max_v(a)

m_1 = max(a(:));
m_2 = min(a(:));
v = m_1(1);
if abs(m_2(1))>abs(m_1(1)),
    v = m_2;
end
