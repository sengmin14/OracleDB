/*
요약
단일 컬럼 각각에 데이터가 많은 경우
단일 컬럼 인덱스 보단 결합 인덱를 통해 buffuers의 수를 줄일 수 있다.
*/

create index m_salegb on mcustsum(salegb);
create index m_salemm on mcustsum(salemm);
create index m_salegb_salemm on mcustsum(salegb,salemm);

SELECT COUNT(*) FROM mcustsum WHERE salegb = 'A';
/*100000*/
SELECT COUNT(*) FROM mcustsum WHERE salemm between '202501' and '202512';
/*1200000*/



/*튜닝 전*/
select /*+ index(t m_salegb) */ count(*)
from mcustsum t
where salegb = 'A'
and salemm between '202501' and '202512';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |          |      1 |        |      1 |00:00:00.06 |    4013 |
|   1 |  SORT AGGREGATE                      |          |      1 |      1 |      1 |00:00:00.06 |    4013 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| MCUSTSUM |      1 |    100K|    100K|00:00:00.06 |    4013 |
|*  3 |    INDEX RANGE SCAN                  | M_SALEGB |      1 |    100K|    100K|00:00:00.01 |     184 |
*/



/*튜닝 전*/
select /*+ index(t m_salemm) */ count(*)
from mcustsum t
where salegb = 'A'
and salemm between '202501' and '202512';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |          |      1 |        |      1 |00:00:00.72 |    6839 |
|   1 |  SORT AGGREGATE                      |          |      1 |      1 |      1 |00:00:00.72 |    6839 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| MCUSTSUM |      1 |    100K|    100K|00:00:00.71 |    6839 |
|*  3 |    INDEX RANGE SCAN                  | M_SALEMM |      1 |   1200K|   1200K|00:00:00.30 |    3010 |
*/



/*튜닝 후*/
select /*+ index(t m_salegb_salemm) */ count(*)
from mcustsum t
where salegb = 'A'
and salemm between '202501' and '202512';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name            | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                 |      1 |        |      1 |00:00:00.10 |     281 |    280 |
|   1 |  SORT AGGREGATE   |                 |      1 |      1 |      1 |00:00:00.10 |     281 |    280 |
|*  2 |   INDEX RANGE SCAN| M_SALEGB_SALEMM |      1 |    600K|    100K|00:00:00.10 |     281 |    280 |
*/



/*연습문제*/
@DEMO;
SELECT COUNT(*)
FROM EMP
WHERE DEPTNO = 20 AND JOB = 'ANALYST';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation          | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |      1 |        |      1 |00:00:00.01 |       7 |
|   1 |  SORT AGGREGATE    |      |      1 |      1 |      1 |00:00:00.01 |       7 |
|*  2 |   TABLE ACCESS FULL| EMP  |      1 |      2 |      2 |00:00:00.01 |       7 |
*/


CREATE INDEX EMP_DEPTNO ON EMP(DEPTNO);
CREATE INDEX EMP_JOB ON EMP(JOB);
CREATE INDEX EMP_DEPTNO_JOB ON EMP(DEPTNO, JOB);

/*옵티마이저가 자동으로 EMP_DEPTNO_JOB인덱스를 사용*/
SELECT COUNT(*)
FROM EMP
WHERE DEPTNO = 20 AND JOB = 'ANALYST';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                |      1 |        |      1 |00:00:00.01 |       1 |
|   1 |  SORT AGGREGATE   |                |      1 |      1 |      1 |00:00:00.01 |       1 |
|*  2 |   INDEX RANGE SCAN| EMP_DEPTNO_JOB |      1 |      2 |      2 |00:00:00.01 |       1 |
*/


SELECT /*+ INDEX(EMP EMP_DEPTNO_JOB */ COUNT(*)
FROM EMP
WHERE DEPTNO = 20 AND JOB = 'ANALYST';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                |      1 |        |      1 |00:00:00.01 |       1 |
|   1 |  SORT AGGREGATE   |                |      1 |      1 |      1 |00:00:00.01 |       1 |
|*  2 |   INDEX RANGE SCAN| EMP_DEPTNO_JOB |      1 |      2 |      2 |00:00:00.01 |       1 |
*/