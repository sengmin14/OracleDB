/*
강의 요약
WHERE 절에 여러 인덱스 조건이 AND로 연결되어 있을 경우
INDEX조건에 데이터가 적은 데이터로 HINT를 줘야 효율이 좋다.
*/

@demo;
/*
인덱스 힌트 사용이 효과적인 경우
1. 인덱스가 존재함에도 FULL TABLE SCAN을 선택하는 경우
2. 여러 인덱스 중에서 특정 인덱스를 선호해야 하는 경우
3. WHERE 절에 여러 조건이 AND로 연결되어 있을 때 최적의 인덱스를 지정해야 하는 경우
*/

-- 건수 확인
SELECT COUNT(*) AS total_rows FROM EMP;
/*10014*/
SELECT JOB, COUNT(*) FROM EMP GROUP BY JOB ORDER BY COUNT(*) DESC;
/*
CONSULTANT	708
PLANNER	705
CLERK	688
MANAGER	684
SALESMAN	681
DEVELOPER	676
TRAINER	676
TESTER	672
DBA	670
SUPPORT	666
ARCHITECT	662
ENGINEER	657
ANALYST	644
DESIGNER	625
PRESIDENT	600
*/
SELECT DEPTNO, COUNT(*) FROM EMP GROUP BY DEPTNO ORDER BY DEPTNO;
/*
10	2503
20	2505
30	2506
40	2500
*/

-- 인덱스 생성
create index emp_empno on emp(empno);
create index emp_deptno on emp(deptno);


SELECT COUNT(*)
FROM EMP
WHERE EMPNO = 7788;
/*
1
*/

SELECT COUNT(*)
FROM EMP
WHERE DEPTNO = 20;
/*
2505
*/

SELECT  /*+ INDEX(EMP EMP_DEPTNO) */ COUNT(*)
FROM EMP
WHERE EMPNO = 7788 AND DEPTNO = 20;
/*
1
*/
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name       | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |            |      1 |        |      1 |00:00:00.01 |      68 |
|   1 |  SORT AGGREGATE                      |            |      1 |      1 |      1 |00:00:00.01 |      68 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP        |      1 |      1 |      1 |00:00:00.01 |      68 |
|*  3 |    INDEX RANGE SCAN                  | EMP_DEPTNO |      1 |   2413 |   2505 |00:00:00.01 |       7 |
*/

SELECT  /*+ INDEX(EMP EMP_EMPNO) */ COUNT(*)
FROM EMP
WHERE EMPNO = 7788 AND DEPTNO = 20;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |           |      1 |        |      1 |00:00:00.01 |       3 |
|   1 |  SORT AGGREGATE                      |           |      1 |      1 |      1 |00:00:00.01 |       3 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP       |      1 |      1 |      1 |00:00:00.01 |       3 |
|*  3 |    INDEX RANGE SCAN                  | EMP_EMPNO |      1 |      1 |      1 |00:00:00.01 |       2 |
*/

-- EMP 테이블에 생성된 인덱스 조회하기
SELECT *
FROM USER_IND_COLUMNS
WHERE TABLE_NAME = 'EMP';
/*
EMP_EMPNO	EMP	EMPNO	1	22	0	ASC	
EMP_DEPTNO	EMP	DEPTNO	1	22	0	ASC	
*/



CREATE INDEX emp_hiredate ON emp(hiredate);
CREATE INDEX emp_deptno ON emp(deptno);

SELECT COUNT(*)
FROM EMP
WHERE hiredate between to_date('1981/01/01','RRRR/MM/DD') and to_date('1981/12/31','RRRR/MM/DD');
/*
10
*/

SELECT COUNT(*)
FROM EMP
WHERE deptno = 20;
/*
2505
*/

/*튜닝 전*/
SELECT /*+ index(emp emp_deptno) */ count(*)
FROM emp
WHERE hiredate between to_date('1981/01/01','RRRR/MM/DD') and to_date('1981/12/31','RRRR/MM/DD')
    AND deptno = 20;

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                             | Name       | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |            |      1 |        |      1 |00:00:00.01 |      68 |
|   1 |  SORT AGGREGATE                       |            |      1 |      1 |      1 |00:00:00.01 |      68 |
|*  2 |   FILTER                              |            |      1 |        |      2 |00:00:00.01 |      68 |
|*  3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMP        |      1 |      2 |      2 |00:00:00.01 |      68 |
|*  4 |     INDEX RANGE SCAN                  | EMP_DEPTNO |      1 |   2413 |   2505 |00:00:00.01 |       7 |
*/


/*튜닝 후*/
SELECT /*+ index(emp emp_hiredate) */ count(*)
FROM emp
WHERE hiredate between to_date('1981/01/01','RRRR/MM/DD') and to_date('1981/12/31','RRRR/MM/DD')
    AND deptno = 20;
    
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                             | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |              |      1 |        |      1 |00:00:00.01 |       3 |
|   1 |  SORT AGGREGATE                       |              |      1 |      1 |      1 |00:00:00.01 |       3 |
|*  2 |   FILTER                              |              |      1 |        |      2 |00:00:00.01 |       3 |
|*  3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMP          |      1 |      1 |      2 |00:00:00.01 |       3 |
|*  4 |     INDEX RANGE SCAN                  | EMP_HIREDATE |      1 |      1 |     10 |00:00:00.01 |       2 |
*/