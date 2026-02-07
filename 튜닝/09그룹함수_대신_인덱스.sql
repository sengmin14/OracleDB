@demo;
SELECT ENAME, SAL
FROM EMP
WHERE SAL = (SELECT MAX(SAL)
             FROM EMP);
/*
KING	5000
*/       
             
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation           | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |      1 |        |      1 |00:00:00.01 |      14 |
|*  1 |  TABLE ACCESS FULL  | EMP  |      1 |      1 |      1 |00:00:00.01 |      14 |
|   2 |   SORT AGGREGATE    |      |      1 |      1 |      1 |00:00:00.01 |       7 |
|   3 |    TABLE ACCESS FULL| EMP  |      1 |     14 |     14 |00:00:00.01 |       7 |
*/


@demo;
create index emp_sal  on emp(sal);

SELECT /*+ index_desc(emp emp_sal) */ ENAME, SAL
FROM EMP
WHERE SAL >= 0 /*인덱스를 위한 조건*/
AND ROWNUM = 1;
/*
KING	5000
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name    | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |         |      1 |        |      1 |00:00:00.01 |       2 |
|*  1 |  COUNT STOPKEY                       |         |      1 |        |      1 |00:00:00.01 |       2 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP     |      1 |      1 |      1 |00:00:00.01 |       2 |
|*  3 |    INDEX RANGE SCAN DESCENDING       | EMP_SAL |      1 |     14 |      1 |00:00:00.01 |       1 |
*/



@demo;
SELECT ENAME, HIREDATE
FROM EMP
WHERE HIREDATE = (SELECT MAX(HIREDATE)
                  FROM EMP);
/*
ADAMS	83/01/15
*/ 

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation           | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |      1 |        |      1 |00:00:00.01 |      14 |
|*  1 |  TABLE ACCESS FULL  | EMP  |      1 |      1 |      1 |00:00:00.01 |      14 |
|   2 |   SORT AGGREGATE    |      |      1 |      1 |      1 |00:00:00.01 |       7 |
|   3 |    TABLE ACCESS FULL| EMP  |      1 |     14 |     14 |00:00:00.01 |       7 |
*/



-- 실습2. 튜닝 후
CREATE INDEX EMP_HIREDATE ON EMP(HIREDATE);

SELECT /*+ INDEX_DESC(EMP EMP_HIREDATE) */ ENAME, HIREDATE
FROM EMP
WHERE HIREDATE < TO_DATE('9999/12/31', 'RRRR/MM/DD')
AND ROWNUM = 1;
/*
ADAMS	83/01/15
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |              |      1 |        |      1 |00:00:00.01 |       2 |
|*  1 |  COUNT STOPKEY                       |              |      1 |        |      1 |00:00:00.01 |       2 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP          |      1 |     14 |      1 |00:00:00.01 |       2 |
|*  3 |    INDEX RANGE SCAN DESCENDING       | EMP_HIREDATE |      1 |     14 |      1 |00:00:00.01 |       1 |
*/



@demo;
SELECT ENAME, SAL
FROM EMP
WHERE SAL = (SELECT MIN(SAL)
             FROM EMP);
/*
SMITH	800
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation           | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |      1 |        |      1 |00:00:00.01 |      14 |
|*  1 |  TABLE ACCESS FULL  | EMP  |      1 |      1 |      1 |00:00:00.01 |      14 |
|   2 |   SORT AGGREGATE    |      |      1 |      1 |      1 |00:00:00.01 |       7 |
|   3 |    TABLE ACCESS FULL| EMP  |      1 |     14 |     14 |00:00:00.01 |       7 |
*/



CREATE INDEX EMP_SAL ON EMP(SAL);

SELECT /*+ INDEX_ASC(EMP EMP_SAL) */ENAME, SAL
FROM EMP
WHERE SAL >= 0
AND ROWNUM = 1;
/*
SMITH	800
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name    | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |         |      1 |        |      1 |00:00:00.01 |       2 |
|*  1 |  COUNT STOPKEY                       |         |      1 |        |      1 |00:00:00.01 |       2 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP     |      1 |     14 |      1 |00:00:00.01 |       2 |
|*  3 |    INDEX RANGE SCAN                  | EMP_SAL |      1 |     14 |      1 |00:00:00.01 |       1 |
*/