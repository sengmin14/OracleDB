/*
index fast full scan은 인덱스의 모든 엔트리를 멀티 블록 i/o로 읽는 실행 방식

         |   index full scan       |      index fast full scan
----------------------------------------------------------------
I/O방식   |  single block I/O       |      multi block I/O
----------------------------------------------------------------
정렬      |     정렬 보장            |            정렬 안됨
----------------------------------------------------------------
속도      |        느림             |              빠름
----------------------------------------------------------------
병렬읽기  |       지원 안됨          |              지원됨
----------------------------------------------------------------
*/

@DEMO;

CREATE INDEX EMP_JOB ON EMP(JOB);
-- 튜닝 전 (INDEX FULL SCAN)
SELECT JOB, COUNT(*)
FROM EMP
WHERE JOB IS NOT NULL
GROUP BY JOB;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation            | Name    | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |         |      1 |        |      5 |00:00:00.01 |       1 |
|   1 |  SORT GROUP BY NOSORT|         |      1 |     14 |      5 |00:00:00.01 |       1 |
|*  2 |   INDEX FULL SCAN    | EMP_JOB |      1 |     14 |     14 |00:00:00.01 |       1 |
*/

-- 튜닝 후 (INDEX FAST FULL SCAN)
SELECT /*+ INDEX_FFS(EMP EMP_JOB)*/JOB, COUNT(*)
FROM EMP
WHERE JOB IS NOT NULL
GROUP BY JOB;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation             | Name    | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |         |      1 |        |      5 |00:00:00.01 |       4 |
|   1 |  HASH GROUP BY        |         |      1 |     14 |      5 |00:00:00.01 |       4 |
|*  2 |   INDEX FAST FULL SCAN| EMP_JOB |      1 |     14 |     14 |00:00:00.01 |       4 |
*/



@DEMO;

CREATE INDEX EMP_DEPTNO_SAL ON EMP(DEPTNO, SAL);

-- 튜닝 전
SELECT DEPTNO, SUM(SAL)
FROM EMP
WHERE DEPTNO IS NOT NULL
GROUP BY DEPTNO;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation            | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |                |      1 |        |      3 |00:00:00.01 |       1 |
|   1 |  SORT GROUP BY NOSORT|                |      1 |     14 |      3 |00:00:00.01 |       1 |
|*  2 |   INDEX FULL SCAN    | EMP_DEPTNO_SAL |      1 |     14 |     14 |00:00:00.01 |       1 |
*/

-- 튜닝 후
SELECT /*+ INDEX_FFS(EMP EMP_DEPTNO_SAL)*/ DEPTNO, SUM(SAL)
FROM EMP
WHERE DEPTNO IS NOT NULL
GROUP BY DEPTNO;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation             | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |                |      1 |        |      3 |00:00:00.01 |       4 |
|   1 |  HASH GROUP BY        |                |      1 |     14 |      3 |00:00:00.01 |       4 |
|*  2 |   INDEX FAST FULL SCAN| EMP_DEPTNO_SAL |      1 |     14 |     14 |00:00:00.01 |       4 |
*/



@demo 

create index emp_job on emp(job);

select /*+ index_ffs(emp emp_job) 
           parallel_index(emp, emp_job, 4) */ job, count(*)
from emp
where job is not null
group by job;

-- 오라클 소프트웨어 xe라서 아래의 실행계획을 볼 수 없다.
select * from table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
Plan hash value: xxxxxxxxxx

-------------------------------------------------------------------------------
| Id  | Operation                     | Name    | Rows | Bytes | Cost | Time    |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |         |    X |   XX  |  XX  |         |
|   1 |  PX COORDINATOR               |         |      |       |      |         |
|   2 |   PX SEND QC (RANDOM)         | :TQ1000 |    X |   XX  |  XX  |         |
|   3 |    HASH GROUP BY              |         |    X |   XX  |  XX  |         |
|   4 |     PX RECEIVE                |         |    X |   XX  |  XX  |         |
|   5 |      PX SEND HASH             | :TQ1000 |    X |   XX  |  XX  |         |
|   6 |       HASH GROUP BY           |         |    X |   XX  |  XX  |         |
|   7 |        PX BLOCK ITERATOR      |         |    X |   XX  |  XX  |         |
|   8 |         INDEX FAST FULL SCAN  | EMP_JOB |    X |   XX  |  XX  |         |
-------------------------------------------------------------------------------
*/