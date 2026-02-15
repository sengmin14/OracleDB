/*
요약
결합 인덱스를 만들지 못하는 경우
2개 이상의 INDEX컬럼을 INDEX RANGE SCAN하는것 보다 INDEX MERGE SCAN이 성능이 좋다.
*/

/*
인덱스 스캔 방법 7가지
    인덱스 엑세스 방법      관련 힌트
1. index range scan         index
2. index unique scan        index
3. index skip scan          index_ss
4. index full scan          index_fs
5. index fast full scan     index_ffs
6. index merge scan         and_equal
7. index bitmap merge scan  index_combine
*/

/*index merge scan         and_equal*/

CREATE INDEX emp2_col1 ON emp2(COL1);
CREATE INDEX emp2_col2 ON emp2(COL2);

SELECT COUNT(*)
FROM emp2
WHERE COL1='A' AND COL2='D';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                        | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                 |           |      1 |        |      1 |00:00:00.09 |     555 |
|   1 |  SORT AGGREGATE                  |           |      1 |      1 |      1 |00:00:00.09 |     555 |
|   2 |   BITMAP CONVERSION COUNT        |           |      1 |  12859 |      1 |00:00:00.09 |     555 |
|   3 |    BITMAP AND                    |           |      1 |        |      1 |00:00:00.09 |     555 |
|   4 |     BITMAP CONVERSION FROM ROWIDS|           |      1 |        |      2 |00:00:00.06 |     365 |
|*  5 |      INDEX RANGE SCAN            | EMP2_COL1 |      1 |  64293 |    200K|00:00:00.03 |     365 |
|   6 |     BITMAP CONVERSION FROM ROWIDS|           |      1 |        |      1 |00:00:00.03 |     190 |
|*  7 |      INDEX RANGE SCAN            | EMP2_COL2 |      1 |  64293 |    103K|00:00:00.02 |     190 |
*/



-- 1. 단일 인덱스 (emp2_col1) 사용
SELECT /*+ index(emp2 emp2_col1) */ COUNT(*)
FROM emp2
WHERE COL1='A' AND COL2='D';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |           |      1 |        |      1 |00:00:00.10 |    1441 |
|   1 |  SORT AGGREGATE                      |           |      1 |      1 |      1 |00:00:00.10 |    1441 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP2      |      1 |     50 |     50 |00:00:00.10 |    1441 |
|*  3 |    INDEX RANGE SCAN                  | EMP2_COL1 |      1 |    200K|    200K|00:00:00.04 |     365 |
*/



-- 2. 단일 인덱스 (emp2_col2) 사용  
SELECT /*+ index(emp2 emp2_col2) */ COUNT(*)
FROM emp2
WHERE COL1='A' AND COL2='D';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                            | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |           |      1 |        |      1 |00:00:00.10 |    1734 |
|   1 |  SORT AGGREGATE                      |           |      1 |      1 |      1 |00:00:00.10 |    1734 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMP2      |      1 |     50 |     50 |00:00:00.10 |    1734 |
|*  3 |    INDEX RANGE SCAN                  | EMP2_COL2 |      1 |    212K|    212K|00:00:00.04 |     388 |
*/



-- 3. AND_EQUAL 힌트로 두 인덱스 결합
SELECT /*+ and_equal(emp2 emp2_col1 emp2_col2) */ COUNT(*)
FROM emp2
WHERE COL1='A' AND COL2='D';


SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation          | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |      1 |        |      1 |00:00:00.01 |      46 |
|   1 |  SORT AGGREGATE    |           |      1 |      1 |      1 |00:00:00.01 |      46 |
|*  2 |   AND-EQUAL        |           |      1 |        |     50 |00:00:00.01 |      46 |
|*  3 |    INDEX RANGE SCAN| EMP2_COL1 |      1 |  64293 |     60 |00:00:00.01 |      23 |
|*  4 |    INDEX RANGE SCAN| EMP2_COL2 |      1 |  90010 |     60 |00:00:00.01 |      23 |
*/



/*결합 컬럼 인덱스*/
CREATE INDEX EMP2_COL1_COL2 ON EMP2(COL1, COL2);

SELECT /*+ INDEX(EMP EMP_COL1_COL2) */COUNT(*)
FROM emp2
WHERE COL1='A' AND COL2='D';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                |      1 |        |      1 |00:00:00.01 |       3 |
|   1 |  SORT AGGREGATE   |                |      1 |      1 |      1 |00:00:00.01 |       3 |
|*  2 |   INDEX RANGE SCAN| EMP2_COL1_COL2 |      1 |  19567 |     50 |00:00:00.01 |       3 |
*/