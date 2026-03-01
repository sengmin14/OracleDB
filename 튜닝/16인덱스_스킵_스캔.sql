/*
index skip scan이란? (INDEX_SS)
index skip scan은 복합 인덱스(Composite index)의 선두 컬럼이 where절의 조건에 없거나
선택이 낮을 때, 해당 컬럼을 건너뛰고 뒤쪽 컬럼을 기준으로 효율적으로 검색하는 기법
*/

/*
1. 단일 컬럼 인덱스
예 : CREATE INDEX EMP_JOB ON EMP(JOB);

2. 복합 컬럼 인덱스
예 : CREATE INDEX EMP_DEPTNO_JOB ON EMP(DEPTNO, JOB);
복합 컬럼 인덱스에서 선두 컬럼이 WHERE조건에 없으면 FULL TABLE SCAN 발생
SELECT ENAME, DEPTNO, JOB
FROM EMP
WHERE JOB = 'MANAGER'
*/

@DEMO;

CREATE INDEX EMP_DEPTNO_JOB ON EMP(DEPTNO, JOB);

-- 복합 컬럼 인덱스의 첫번째 컬럼이 WHERE 절에 있는 경우
SELECT ENAME, DEPTNO, JOB
FROM EMP
WHERE DEPTNO = 30;

-- INDEX RANGE SCAN 발생
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                |      1 |        |      6 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP            |      1 |      6 |      6 |00:00:00.01 |       2 |
|*  2 |   INDEX RANGE SCAN                  | EMP_DEPTNO_JOB |      1 |      6 |      6 |00:00:00.01 |       1 |
*/



-- 복합 컬럼 인덱스의 첫번째 컬럼이 WHERE 절에 없는 경우
SELECT ENAME, DEPTNO, JOB
FROM EMP
WHERE JOB = 'MANAGER';

-- FULL TABLE SCAN 발생
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      3 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      3 |      3 |00:00:00.01 |       7 |
*/



SELECT /*+ INDEX_SS(EMP EMP_DEPTNO_JOB) */ ENAME, DEPTNO, JOB
FROM EMP
WHERE JOB = 'MANAGER';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                |      1 |        |      3 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP            |      1 |      3 |      3 |00:00:00.01 |       2 |
|*  2 |   INDEX SKIP SCAN                   | EMP_DEPTNO_JOB |      1 |      1 |      3 |00:00:00.01 |       1 |
*/

/*
INDEX SKIP SCAN은 복합 컬럼 인덱스의 첫 번째 컬럼을 건너뛰면서 수행한다.
복합 인덱스의 첫 번째 컬럼의 고유 값이 적을수록 더 효과적이다.
INDEX SKIP SCAN은 FULL TABLE SCAN을 피하고 인덱스를 활용할 수 있개 해준다.
*/



-- 문제1
@DEMO;

CREATE INDEX EMP_JOB_SAL ON EMP(JOB, SAL);

SELECT ENAME, JOB, SAL
FROM EMP
WHERE SAL = 1250;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      2 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      2 |      2 |00:00:00.01 |       7 |
*/



-- 문제1 풀이
SELECT /*+ INDEX_SS(EMP EMP_JOB_SAL) */ ENAME, JOB, SAL
FROM EMP
WHERE SAL = 1250;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name        | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |             |      1 |        |      2 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP         |      1 |      2 |      2 |00:00:00.01 |       2 |
|*  2 |   INDEX SKIP SCAN                   | EMP_JOB_SAL |      1 |      1 |      2 |00:00:00.01 |       1 |
*/



-- 문제2
-- 직업의 종류가 몇개가 있는지 조회하기
SELECT COUNT(DISTINCT(JOB))
FROM EMP;



-- 문제3
-- 환경구성
drop table mcustsum purge;
create table mcustsum
as
select rownum custno
, '2025' || lpad(ceil(rownum/100000), 2, '0') salemm
, decode(mod(rownum, 12), 1, 'A', 'B') salegb
, round(dbms_random.value(1000,100000), -2) saleamt
from dual
connect by level <= 1200000;
create index m_salemm_salegb on mcustsum(salemm,salegb);

-- 튜닝전 SQL
select count(*)
from mcustsum t
where salegb = 'A'
and salemm between '202501' and '202512';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation             | Name            | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |                 |      1 |        |      1 |00:00:00.35 |    3367 |   3353 |
|   1 |  SORT AGGREGATE       |                 |      1 |      1 |      1 |00:00:00.35 |    3367 |   3353 |
|*  2 |   INDEX FAST FULL SCAN| M_SALEGB_SALEMM |      1 |    600K|    100K|00:00:00.35 |    3367 |   3353 |
*/

-- 튜닝후 SQL
select /*+ INDEX_SS(t m_salemm_salegb) */ count(*)
from mcustsum t
where salegb = 'A'
and salemm between '202501' and '202512';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation        | Name            | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |                 |      1 |        |      1 |00:00:00.02 |     300 |
|   1 |  SORT AGGREGATE  |                 |      1 |      1 |      1 |00:00:00.02 |     300 |
|*  2 |   INDEX SKIP SCAN| M_SALEMM_SALEGB |      1 |    600K|    100K|00:00:00.01 |     300 |
*/