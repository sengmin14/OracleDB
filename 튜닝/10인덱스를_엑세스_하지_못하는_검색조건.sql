
/*
인덱스를 액세스하지 못하는 조건
1. is null과 is not null조건을 사용했을 때
2. like 조건에서 와일드 카드(%)가 앞에 왔을때
3. 부정 연산자를 사용했을때(!=, <>, ^=)
*/


/*실습1 : IS NULL 조건 처리*/
/*튜닝 전*/
@demo;
CREATE INDEX EMP_COMM ON EMP(COMM);

SELECT ENAME, COMM
FROM EMP
WHERE COMM IS NULL;
/*
KING	NULL (하단 데이터 동일)
BLAKE	
CLARK	
JONES	
JAMES	
FORD	
SMITH	
SCOTT	
ADAMS	
MILLER	
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |     10 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |     10 |     10 |00:00:00.01 |       7 |
*/



/*실습1 : IS NULL 조건 처리*/
/*튜닝 후*/
@demo;
CREATE INDEX EMP_COMM_FUNC ON EMP(NVL(COMM, -1));

SELECT ENAME, COMM
FROM EMP
WHERE NVL(COMM, -1) = -1;
/*
KING	
BLAKE	
CLARK	
JONES	
JAMES	
FORD	
SMITH	
SCOTT	
ADAMS	
MILLER	
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |               |      1 |        |     10 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP           |      1 |     10 |     10 |00:00:00.01 |       2 |
|*  2 |   INDEX RANGE SCAN                  | EMP_COMM_FUNC |      1 |     10 |     10 |00:00:00.01 |       1 |
*/



/*실습2 : IS NOT NULL 조건 처리*/
/*튜닝 전*/
@DEMO;
CREATE INDEX EMP_COMM ON EMP(COMM);

SELECT ENAME, COMM
FROM EMP
WHERE COMM IS NOT NULL;
/*
MARTIN	1400
ALLEN	300
TURNER	0
WARD	500
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      4 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      4 |      4 |00:00:00.01 |       7 |
*/



/*실습2 : IS NOT NULL 조건 처리*/
/*튜닝 후*/
@demo;
CREATE INDEX EMP_COMM ON EMP(COMM);

SELECT ENAME, COMM
FROM EMP
WHERE COMM >= 0;
/*
TURNER	0
ALLEN	300
WARD	500
MARTIN	1400
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |          |      1 |        |      4 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP      |      1 |      4 |      4 |00:00:00.01 |       2 |
|*  2 |   INDEX RANGE SCAN                  | EMP_COMM |      1 |      4 |      4 |00:00:00.01 |       1 |
*/



/*실습3 : LIKE 조건에서의 와일드카드 적용*/
/*와일드카드가 뒤쪽에 위차하기 때문에 문제 없음*/
@DEMO;
CREATE INDEX EMP_ENAME ON EMP(ENAME);

SELECT ENAME, SAL
FROM EMP
WHERE ENAME LIKE 'S%';
/*
SCOTT	3000
SMITH	800
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |           |      1 |        |      2 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP       |      1 |      2 |      2 |00:00:00.01 |       2 |
|*  2 |   INDEX RANGE SCAN                  | EMP_ENAME |      1 |      2 |      2 |00:00:00.01 |       1 |
*/



/*실습4 : LIKE 조건에서의 와일드카드 적용*/
/*튜닝 전*/
@DEMO;
CREATE INDEX EMP_ENAME ON EMP(ENAME);

SELECT ENAME, SAL
FROM EMP
WHERE ENAME LIKE '%T';
/*
SCOTT	3000
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      1 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      1 |      1 |00:00:00.01 |       7 |
*/



/*실습4 : LIKE 조건에서의 와일드카드 적용*/
/*튜닝 후*/
@DEMO;
CREATE INDEX EMP_ENAME_FUNC ON EMP(SUBSTR(ENAME, -1, 1));

SELECT ENAME, SAL
FROM EMP
WHERE SUBSTR(ENAME, -1, 1) = 'T';
/*
SCOTT	3000
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                |      1 |        |      1 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP            |      1 |      1 |      1 |00:00:00.01 |       2 |
|*  2 |   INDEX RANGE SCAN                  | EMP_ENAME_FUNC |      1 |      1 |      1 |00:00:00.01 |       1 |
*/



/*실습5 : 부정연산자*/
/*튜닝 전*/
@DEMO;
CREATE INDEX EMP_JOB ON EMP(JOB);

SELECT ENAME, JOB
FROM EMP
WHERE JOB != 'SALESMAN';
/*
KING	PRESIDENT
BLAKE	MANAGER
CLARK	MANAGER
JONES	MANAGER
JAMES	CLERK
FORD	ANALYST
SMITH	CLERK
SCOTT	ANALYST
ADAMS	CLERK
MILLER	CLERK
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |     10 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |     10 |     10 |00:00:00.01 |       7 |
*/



/*실습5 : 부정연산자*/
/*튜닝 후*/
@DEMO;
CREATE INDEX EMP_JOB ON EMP(JOB);

SELECT ENAME, JOB
FROM EMP
WHERE JOB IN ('ANALYST', 'CLERK', 'MANAGER', 'PRESIDENT');
/*
FORD	ANALYST
SCOTT	ANALYST
JAMES	CLERK
SMITH	CLERK
ADAMS	CLERK
MILLER	CLERK
BLAKE	MANAGER
CLARK	MANAGER
JONES	MANAGER
KING	PRESIDENT
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name    | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |         |      1 |        |     10 |00:00:00.01 |       3 |
|   1 |  INLIST ITERATOR                     |         |      1 |        |     10 |00:00:00.01 |       3 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP     |      4 |     10 |     10 |00:00:00.01 |       3 |
|*  3 |    INDEX RANGE SCAN                  | EMP_JOB |      4 |      1 |     10 |00:00:00.01 |       2 |
*/



/*문제1. JOB이 MAN으로 끝나는 사원 조회 */
/*직업(JOB)이 끝글자가 MAN으로 끝나는 사원의 이름과 직업을 출력하세요.*/
@DEMO;
CREATE INDEX EMP_JOB ON EMP(JOB);

SELECT ENAME, JOB
FROM EMP
WHERE JOB LIKE '%MAN';
/*
MARTIN	SALESMAN
ALLEN	SALESMAN
TURNER	SALESMAN
WARD	SALESMAN
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      4 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      4 |      4 |00:00:00.01 |       7 |
*/



/*튜닝 후*/
@DEMO;
CREATE INDEX EMP_JOB_FUNC ON EMP(SUBSTR(JOB, -3, 3));

SELECT ENAME, JOB
FROM EMP
WHERE SUBSTR(JOB, -3, 3) = 'MAN';
/*
MARTIN	SALESMAN
ALLEN	SALESMAN
TURNER	SALESMAN
WARD	SALESMAN
*/

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |              |      1 |        |      4 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP          |      1 |      4 |      4 |00:00:00.01 |       2 |
|*  2 |   INDEX RANGE SCAN                  | EMP_JOB_FUNC |      1 |      4 |      4 |00:00:00.01 |       1 |
*/