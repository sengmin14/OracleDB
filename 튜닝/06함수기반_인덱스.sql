@demo
INSERT INTO emp(empno, ename, sal) VALUES(1111, '  JACK  ', 3000);
COMMIT;

CREATE INDEX emp_ename ON emp(ename);

-- 튜닝 전 1
SELECT ename, sal
FROM emp
WHERE ename LIKE '%JACK%';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      0 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      1 |      0 |00:00:00.01 |       7 |
*/

-- 튜닝 전 2
SELECT ENAME, SAL
FROM EMP
WHERE TRIM(ENAME) = 'JACK';

// full table scan 발생 // INDEX 컬럼을 가공했기 때문에
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      1 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      1 |      1 |00:00:00.01 |       7 |
*/

-- 튜닝 후
// 함수기반 인덱스 생성
CREATE INDEX EMP_ENAME_FUNC
ON EMP(TRIM(ENAME));

SELECT ENAME, SAL
FROM EMP
WHERE TRIM(ENAME) = 'JACK';

// INDEX 스캔 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                |      1 |        |      1 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP            |      1 |      1 |      1 |00:00:00.01 |       2 |
|*  2 |   INDEX RANGE SCAN                  | EMP_ENAME_FUNC |      1 |      1 |      1 |00:00:00.01 |       1 |
*/



@DEMO;
INSERT INTO emp(empno, ename, sal) VALUES(9381, 'smith', 3400);
INSERT INTO emp(empno, ename, sal) VALUES(9382, 'Smith', 3400);
INSERT INTO emp(empno, ename, sal) VALUES(9383, 'SMith', 3400);

commit;

create index emp_ename on  emp(ename); 

-- 튜닝 전
SELECT ENAME, SAL
FROM EMP
WHERE upper(ENAME) = 'SMITH';

// INDEX 컬럼 가공했기에 FULL TABLE SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      4 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      4 |      4 |00:00:00.01 |       7 |
*/

-- 튜닝 후
create index EMP_ENAME_FUNC2 on  emp(upper(ENAME)); 

SELECT ENAME, SAL
FROM EMP
WHERE upper(ENAME) = 'SMITH';

// INDEX SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                           | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                |      1 |        |      4 |00:00:00.01 |       2 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP            |      1 |      4 |      4 |00:00:00.01 |       2 |
|*  2 |   INDEX RANGE SCAN                  | EMP_ENAME_FUNC |      1 |      4 |      4 |00:00:00.01 |       1 |
*/



@demo
CREATE INDEX emp_hiredate ON emp(hiredate);

-- 튜닝 전
SELECT ename, hiredate
FROM emp
WHERE to_char(hiredate, 'YYYY') = '1980';

// INDEX 컬럼 가공했기에 FULL TABLE SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      1 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      1 |      1 |00:00:00.01 |       7 |
*/

-- 튜닝 후
CREATE INDEX emp_hiredate_func ON emp(to_char(hiredate, 'YYYY'));

SELECT ename, hiredate
FROM emp
WHERE to_char(hiredate, 'YYYY') = '1980';

// INDEX SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      1 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      1 |      1 |00:00:00.01 |       7 |
*/

// index를 생성해주는 db입장에서는 저장공간 이슈
// 새로운 index로 인하여 기존 쿼리 성능 이슈가 발생할 수 있음
@demo;
CREATE INDEX emp_hiredate ON emp(hiredate);

-- 튜닝 전
SELECT ename, hiredate
FROM emp
WHERE to_char(hiredate, 'YYYY') = '1980';

// FULL SCAN
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |      1 |        |      1 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| EMP  |      1 |      1 |      1 |00:00:00.01 |       7 |
*/

-- 튜닝 후
SELECT ename, hiredate
FROM emp
WHERE hiredate BETWEEN  TO_DATE('1980/01/01', 'RRRR/MM/DD')
                AND     TO_DATE('1980/12/31', 'RRRR/MM/DD')+1;
// INDEX 스캔
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |              |      1 |        |      1 |00:00:00.01 |       2 |
|*  1 |  FILTER                              |              |      1 |        |      1 |00:00:00.01 |       2 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP          |      1 |      1 |      1 |00:00:00.01 |       2 |
|*  3 |    INDEX RANGE SCAN                  | EMP_HIREDATE |      1 |      1 |      1 |00:00:00.01 |       1 |
*/