-- delete user by email
DELETE FROM users
WHERE email = $1;

