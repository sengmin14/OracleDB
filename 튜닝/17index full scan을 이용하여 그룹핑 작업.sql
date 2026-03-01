/*
오라클에서는 NULL 값을 인덱스에 저장하지 않는다.
(NULL이 있는지 없는지 FULL SCAN을 해야만 알 수 있다.)
*/

@demo;
CREATE INDEX EMP_JOB ON EMP(JOB);

-- 튜닝 전
SELECT JOB, COUNT(*)
FROM EMP
GROUP BY JOB;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation          | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |      1 |        |      5 |00:00:00.01 |       7 |
|   1 |  HASH GROUP BY     |      |      1 |     14 |      5 |00:00:00.01 |       7 |
|   2 |   TABLE ACCESS FULL| EMP  |      1 |     14 |     14 |00:00:00.01 |       7 |
*/

-- 튜닝 후
-- 
SELECT /*+ INDEX(EMP EMP_JOB) */JOB, COUNT(*)
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



--문제 1
@DEMO;

CREATE INDEX EMP_DEPTNO ON EMP(DEPTNO);

SELECT DEPTNO, COUNT(*)
FROM EMP
GROUP BY DEPTNO;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation          | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |      1 |        |      3 |00:00:00.01 |       7 |
|   1 |  HASH GROUP BY     |      |      1 |     14 |      3 |00:00:00.01 |       7 |
|   2 |   TABLE ACCESS FULL| EMP  |      1 |     14 |     14 |00:00:00.01 |       7 |
*/

-- 문제1 해답
SELECT /*+ INDEX(EMP EMP_DEPTNO) */DEPTNO, COUNT(*)
FROM EMP
WHERE DEPTNO IS NOT NULL
GROUP BY DEPTNO;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation            | Name       | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |            |      1 |        |      3 |00:00:00.01 |       1 |
|   1 |  SORT GROUP BY NOSORT|            |      1 |     14 |      3 |00:00:00.01 |       1 |
|*  2 |   INDEX FULL SCAN    | EMP_DEPTNO |      1 |     14 |     14 |00:00:00.01 |       1 |
*/



--문제2
@DEMO;
CREATE INDEX EMP_JOB ON EMP(JOB);

SELECT JOB, SUM(SAL)
FROM EMP
GROUP BY JOB;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation          | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |      1 |        |      5 |00:00:00.01 |       7 |
|   1 |  HASH GROUP BY     |      |      1 |     14 |      5 |00:00:00.01 |       7 |
|   2 |   TABLE ACCESS FULL| EMP  |      1 |     14 |     14 |00:00:00.01 |       7 |
*/

--문제2 해답
SELECT /*+ INDEX(EMP EMP_JOB) */JOB, SUM(SAL)
FROM EMP
WHERE JOB IS NOT NULL AND SAL IS NOT NULL
GROUP BY JOB;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                    | Name    | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |      1 |        |      5 |00:00:00.01 |       2 |
|   1 |  SORT GROUP BY NOSORT        |         |      1 |     14 |      5 |00:00:00.01 |       2 |
|*  2 |   TABLE ACCESS BY INDEX ROWID| EMP     |      1 |     14 |     14 |00:00:00.01 |       2 |
|*  3 |    INDEX FULL SCAN           | EMP_JOB |      1 |     14 |     14 |00:00:00.01 |       1 |
*/

--문제2 2번째 해답
CREATE INDEX EMP_JOB_SAL ON EMP(JOB, SAL);

SELECT /*+ INDEX(EMP EMP_JOB_SAL) */JOB, SUM(SAL)
FROM EMP
WHERE JOB IS NOT NULL
GROUP BY JOB;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation            | Name        | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |             |      1 |        |      5 |00:00:00.01 |       1 |
|   1 |  SORT GROUP BY NOSORT|             |      1 |     14 |      5 |00:00:00.01 |       1 |
|*  2 |   INDEX FULL SCAN    | EMP_JOB_SAL |      1 |     14 |     14 |00:00:00.01 |       1 |
*/