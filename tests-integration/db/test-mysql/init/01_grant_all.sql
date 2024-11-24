CREATE USER 'test'@'%' IDENTIFIED WITH mysql_native_password BY 'test';
GRANT ALL PRIVILEGES ON *.* TO 'test'@'%' WITH GRANT OPTION;
ALTER USER 'test'@'%' IDENTIFIED WITH mysql_native_password BY 'test';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'test';
FLUSH PRIVILEGES;