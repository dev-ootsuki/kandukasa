CREATE USER kandukasa WITH PASSWORD 'kandukasa';
ALTER ROLE kandukasa CREATEDB SUPERUSER;
ALTER DATABASE kandukasa OWNER TO kandukasa;
ALTER ROLE kandukasa IN DATABASE tst SET search_path = kandukasa, public, $user;