 drop table mcustsum purge;

create table mcustsum
as
select rownum custno
, '2025' || lpad(ceil(rownum/100000), 2, '0') salemm
, decode(mod(rownum, 12), 1, 'A', 'B') salegb
, round(dbms_random.value(1000,100000), -2) saleamt
from dual
connect by level <= 1200000;