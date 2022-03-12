create database test_db;
\c test_db;
CREATE role "test-admin-user" with encrypted password 'test-admin-user';
create role "test-simple-user" with encrypted password 'test-simple-user';
create table if not exists orders (id SERIAL not null, "наименование" varchar(250) not null UNIQUE, "цена" int not null, primary key (id));
create table if not exists clients (id SERIAL not null, "фамилия" varchar(250) not null, "страна проживания" varchar(250) not null, "заказ" varchar(250) , primary key (id), FOREIGN KEY ("заказ")  REFERENCES orders ("наименование"));
create INDEX my_index on clients ("страна проживания");
grant all privileges on ALL TABLES IN SCHEMA public to "test-admin-user";
grant select, insert, update, delete on orders,clients to "test-simple-user";
