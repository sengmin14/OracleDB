@demo
INSERT INTO emp(empno, ename, sal) VALUES(1111, '  JACK  ', 3000);
COMMIT;

CREATE INDEX emp_ename ON emp(ename);

SELECT ename, sal
FROM emp
WHERE ename LIKE '%JACK%';
// full table scan 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));

SELECT ENAME, SAL
FROM EMP
WHERE TRIM(ENAME) = 'JACK';
// full table scan 발생 // INDEX 컬럼을 가공했기 때문에
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));

// 함수기반 인덱스 생성
CREATE INDEX EMP_ENAME_FUNC
ON EMP(TRIM(ENAME));

SELECT ENAME, SAL
FROM EMP
WHERE TRIM(ENAME) = 'JACK';
// INDEX 스캔 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));



@DEMO;
INSERT INTO emp(empno, ename, sal) VALUES(9381, 'smith', 3400);
INSERT INTO emp(empno, ename, sal) VALUES(9382, 'Smith', 3400);
INSERT INTO emp(empno, ename, sal) VALUES(9383, 'SMith', 3400);

commit;

create index emp_ename on  emp(ename); 

SELECT ENAME, SAL
FROM EMP;

SELECT ENAME, SAL
FROM EMP
WHERE upper(ENAME) = 'SMITH';
// INDEX 컬럼 가공했기에 FULL TABLE SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));

create index emp_ename_func on  emp(upper(ENAME)); 

SELECT ENAME, SAL
FROM EMP
WHERE upper(ENAME) = 'SMITH';
// INDEX SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));




@demo
CREATE INDEX emp_hiredate ON emp(hiredate);

SELECT ename, hiredate
FROM emp
WHERE to_char(hiredate, 'RRRR') = '1980';
// INDEX 컬럼 가공했기에 FULL TABLE SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));

CREATE INDEX emp_hiredate_func ON emp(to_char(hiredate, 'RRRR'));

SELECT ename, hiredate
FROM emp
WHERE to_char(hiredate, 'RRRR') = '1980';
// INDEX SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));




// index를 생성해주는 db입장에서는 저장공간 이슈
// 새로운 index로 인하여 기존 쿼리 성능 이슈가 발생할 수 있음
@demo;
CREATE INDEX emp_hiredate ON emp(hiredate);


SELECT ename, hiredate
FROM emp
WHERE to_char(hiredate, 'RRRR') = '1980';
// FULL SCAN
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));

SELECT ename, hiredate
FROM emp
WHERE hiredate BETWEEN  TO_DATE('1980/01/01', 'RRRR/MM/DD')
                AND     TO_DATE('1980/12/31', 'RRRR/MM/DD')+1;
// INDEX 스캔
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));