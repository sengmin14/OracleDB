@demo;

CREATE INDEX EMP_SAL ON EMP(SAL);

// 숫자가 문자보다 우선순위가 높아서 문자가 숫자로 형변환된다.
SELECT ENAME, SAL
FROM EMP
WHERE SAL = '3000';

// INDEX컬럼이 가공되지 않았기에 INDEX RANGE SCAN 발생
// access("SAL"=3000)
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

// 문자를 숫자로 바꿀 수 없는 상황
SELECT ENAME, SAL
FROM EMP
WHERE SAL LIKE '30%';

// INDEX컬럼이 가공되었기에 FULL TABLE SCAN 발생
// filter(TO_CHAR("SAL") LIKE '30%')
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));



// 숫자형 데이터에 LIKE를 자주 사용하는 경우에는 함수형 INDEX를 사용해야 한다.
CREATE INDEX EMP_SAL_FUNC ON EMP(TO_CHAR(SAL));

SELECT ENAME, SAL
FROM EMP
WHERE SAL LIKE '30%';

// 함수형 인덱스로 인해 INDEX RANGE SCAN 발생
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));



DROP TABLE emp9000;

CREATE TABLE emp9000(
    ename VARCHAR2(10),
    sal VARCHAR2(10)
);

INSERT INTO emp9000 VALUES('scott', '3000');
INSERT INTO emp9000 VALUES('smith', '1000');
INSERT INTO emp9000 VALUES('allen', '2000');
COMMIT;



CREATE INDEX emp9000_sal ON emp9000(sal);

SELECT ename, sal
FROM emp9000
WHERE sal = 3000;  -- 암시적 형변환 발생
// FULL TABLE SCAN 발생 : SAL은 문자열 -> NUMBER로 형변환 발생
// filter(TO_NUMBER("SAL")=3000)
// INDEX 컬럼이 가공됨
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));



CREATE INDEX EMP9000_SAL_FUNC ON EMP9000(TO_NUMBER("SAL"));

SELECT ename, sal
FROM emp9000
WHERE sal = 3000;  -- 암시적 형변환 발생

// 함수기반 INDEX로 인해 INDEX RANGE SCAN 발생
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
