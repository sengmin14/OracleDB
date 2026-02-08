@DEMO;

/*
SQL처리 과정
1. 쿼리 작성
2. parsing : sql이 문법적으로 문제여부 확인 / emp테이블이 존재하는지
3. optimizer : sql을 어떻게 처리할지 계획을 세움 (실행계획이 만들어짐)
4. 실행계획
5. 실행 : 실행계획을 통해 실행
6. result
*/


EXPLAIN PLAN FOR
    SELECT ENAME, SAL
    FROM EMP
    WHERE SAL = 2850;
    
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
/*
Rows : 예상되는 ROW건수
Bytes : 예상되는 Byte수
Cost : CPU사용률 (해당 값이 가장 적은 실행계획이 동작한다.)
Time : 수행 시간
*/
/*
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    20 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    20 |     3   (0)| 00:00:01 |
*/



CREATE INDEX EMP_SAL ON EMP(SAL);

/*힌트란 옵티마이저가 실행계획을 만들 때, HINT대로 만들어달라*/
EXPLAIN PLAN FOR
    SELECT /*+ FULL(EMP) */ENAME, SAL
    FROM EMP
    WHERE SAL = 2850;
    
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
/*
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    20 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    20 |     3   (0)| 00:00:01 |
*/



EXPLAIN PLAN FOR
    SELECT /*+ INDEX(EMP EMP_SAL) */ENAME, SAL
    FROM EMP
    WHERE SAL = 2850;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
/*
| Id  | Operation                           | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |         |     1 |    20 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMP     |     1 |    20 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                  | EMP_SAL |     1 |       |     1   (0)| 00:00:01 |
*/



/*
문제 : 사원 테이블에 직업에 인덱스를 생성하고 
      사원 테이블에서 직업이 ANALYST 인 사원들의 이름과 월급과 직업을 
      출력하는 SQL의 실행계획이 full table scan 이 되게 실행계획을 제어하세요
*/
@DEMO;
CREATE INDEX EMP_JOB ON EMP(JOB);

EXPLAIN PLAN FOR
    SELECT /*+ FULL(EMP) */ENAME, JOB
    FROM EMP
    WHERE JOB = 'ANALYST';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
/*
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     2 |    26 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     2 |    26 |     3   (0)| 00:00:01 |
*/