## 1.

> docker-compose манифест

```commandline
ersion: "3.9"
services:
  postgres:
    image: postgres:12
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - .:/docker-entrypoint-initdb.d
      - .:/var/lib/postgresql/data
      - ./tmp:/tmp
    ports:
      - "5432:5432"
```

> инициализация структуры БД (init.sql)

````commandline
create database test_db;
\c test_db;
CREATE role "test-admin-user" with encrypted password 'test-admin-user';
create role "test-simple-user" with encrypted password 'test-simple-user';
create table if not exists orders (id int not null, "наименование" varchar(250) not null UNIQUE, "цена" int not null, primary key (id));
create table if not exists clients (id int not null, "фамилия" varchar(250) not null, "страна проживания" varchar(250) not null, "заказ" varchar(250) not null, primary key (id), FOREIGN KEY ("заказ")  REFERENCES orders ("наименование"));
create INDEX my_index on clients ("страна проживания");
grant all privileges on ALL TABLES IN SCHEMA public to "test-admin-user";
grant select, insert, update, delete on orders,clients to "test-simple-user";
````

## 2.
> итоговый список БД после выполнения пунктов выше,
```commandline
test_db=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

 ```

> описание таблиц (describe)
```commandline

test_db=# \dt+
                       List of relations
 Schema |  Name   | Type  |  Owner   |    Size    | Description 
--------+---------+-------+----------+------------+-------------
 public | clients | table | postgres | 8192 bytes | 
 public | orders  | table | postgres | 0 bytes    | 
(2 rows)
```

> SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```commandline
test_db=# select * from information_schema.role_table_grants where grantee='test-simple-user'; 
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
(8 rows)

test_db=# select * from information_schema.role_table_grants where grantee='test-admin-user'; 
 grantor  |     grantee     | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
----------+-----------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-admin-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-admin-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | REFERENCES     | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | TRIGGER        | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-admin-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | REFERENCES     | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | TRIGGER        | NO           | NO
(14 rows)

test_db=# 


```

>список пользователей с правами над таблицами test_db
```commandline
test_db=# \dp
                                      Access privileges
 Schema |  Name   | Type  |         Access privileges          | Column privileges | Policies 
--------+---------+-------+------------------------------------+-------------------+----------
 public | clients | table | postgres=arwdDxt/postgres         +|                   | 
        |         |       | "test-admin-user"=arwdDxt/postgres+|                   | 
        |         |       | "test-simple-user"=arwd/postgres   |                   | 
 public | orders  | table | postgres=arwdDxt/postgres         +|                   | 
        |         |       | "test-admin-user"=arwdDxt/postgres+|                   | 
        |         |       | "test-simple-user"=arwd/postgres   |                   | 
(2 rows)


```

## 3.
```commandline
test_db=# select count(*) from clients;
 count 
-------
     5
(1 row)
```

````commandline
test_db=# select count(*) from orders;
 count 
-------
     5
(1 row)
````

## 4.

```commandline
UPDATE clients SET "заказ" = 'Книга' WHERE "фамилия" = 'Иванов Иван Иванович';
UPDATE clients SET "заказ" = 'Монитор' WHERE "фамилия" = 'Петров Петр Петрович';
UPDATE clients SET "заказ" = 'Гитара' WHERE "фамилия" = 'Иоганн Себастьян Бах'; 
```

```commandline
test_db=# SELECT * FROM clients WHERE "заказ" IS NOT NULL;
 id |       фамилия        | страна проживания |  заказ  
----+----------------------+-------------------+---------
  1 | Иванов Иван Иванович | USA               | Книга
  2 | Петров Петр Петрович | Canada            | Монитор
  3 | Иоганн Себастьян Бах | Japan             | Гитара
(3 rows)

```

## 5.

```commandline
test_db=# EXPLAIN SELECT * FROM clients WHERE "заказ" IS NOT NULL;
                         QUERY PLAN                         
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..10.50 rows=50 width=1552)
   Filter: ("заказ" IS NOT NULL)
(2 rows)
```

> cost - первое время это приблизмтельное время начала выдачи запроса, второе время - суммарное время выдачи запроса

> rows - количество ожидаемых строк

> width - средний размер строк в байтах


## 6.
```commandline
pugachevvv@debian-vlad:~/Документы/Netology/DevOps/dz_№24$  docker run --name backup_db -e POSTGRES_PASSWORD=postgres -d postgres:12

pugachevvv@debian-vlad:~/Документы/Netology/DevOps/dz_№24$ docker exec -it  backup_db /bin/bash
root@affc3c12c1c9:/# psql -U postgres
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=# create database test_db;
CREATE DATABASE
postgres=# CREATE role "test-admin-user" with encrypted password 'test-admin-user';
CREATE ROLE
postgres=# create role "test-simple-user" with encrypted password 'test-simple-user';
CREATE ROLE
postgres=# exit
root@affc3c12c1c9:/# exit
exit

pugachevvv@debian-vlad:~/Документы/Netology/DevOps/dz_№24$  docker exec -i backup_db /bin/bash -c "PGPASSWORD=postgres psql --username postgres test_db" < ./tmp/backup/1.sql
```
