DELETE FROM sessions
WHERE expiration_at < NOW();

