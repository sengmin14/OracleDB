/*
결합 컬럼 인덱스에서 컬럼 순서의 중요성
 - 결합 컬럼 인덱스를 생성할 때 컬럼의 순서를 어떻게 두느냐는 단순한 선택이 아니라
   쿼리 성능을 좌우하는 핵심 요소
 - 동일한 조건식을 사용하더라도 인덱스 컬럼의 배치 순서에 따라 불필요한 스캔이 발생할 수 있고,
   반대로 최소한의 스캔만으로 원하는 데이터를 빠르게 찾아낼 수도 있다.
 - 따라서 컬럼 순서를 어떻게 결정하느냐가 인덱스 설계의 핵심이라고 할 수 있다.
*/

/*
이론1. 조건 유형의 구분
 - 인덱스 설계에서 중요한 것은 조건이 어떤 형태로 사용되는가를 구분하는 것이다.
 - 조건은 크게 두 가지 유형으로 나눌 수 있다.
   1. 점조건(Point Condition)
      - = 또는 IN 연산자를 사용하는 조건을 의미한다.
      - 특정 값을 정확히 지정하는 방식으로, 인덱스 검색 시 탐색 범위를 매우 좁게 한정할 수 있다.
      - 예 : 판매구분 = 'A', 부서번호 IN(10, 20)
    
   2. 선분조건(Range Condition)
      - BETWEEN, LIKE, >, < 등의 연산자를 사용하는 조건을 의미한다.
      - 값의 범위를 지정하므로 인덱스에서는 특정 구간 전체를 스캔해야 하며,
         결과적으로 읽는 데이터 양이 많아질 수 있다.
      - 예 : 판매월 BETWEEN '202501' AND '202502', 급여 > 3000
*/

/*
이론2. 컬럼 순서에 따른 차이
 - 예를 들어 다음과 같은 조건으로 데이터를 조회한다 가정한다.
   select count(*)
   from 매출
   where 판매월 between '202501' and '202502'
   and 판매구분 = 'A';

   1. 인덱스를 (판매월 + 판매구분) 순서로 만든 경우
      - 판매월 조건은 범위 조건이므로, 해당 기간에 속하는 모든 데이터를 먼저 읽어야 한다.
      - 이후 판매구분 조건을 적용해 불필요한 데이터를 걸러내야 하므로, 인덱스 스캔 범위가 넓어진다.
      - 결과적으로 많은 양의 데이터를 불필요하게 읽게 되어 비효율적이다.

   2. 인덱스를 (판매구분 + 판매월) 순서로 만든 경우
      - 판매구분 조건은 동등 조건이므로, 우선적으로 판매구분 = 'A'인 데이터만 좁혀서 찾을 수 있다.
      - 그 후 판매월 범위를 적용하면 이미 축소된 범위 내에서만 데이터를 확인하면 된다.
      - 인덱스 스캔 범위가 최소화되므로 검색 성능이 크게 향상된다.
*/

/*
이론3. 결합 컬럼 인덱스 설계 원칙
 - 결합 인덱스 설계에서 반드시 기억해야 할 원칙은 다음과 같다.
   - 첫 번째 컬럼은 점조건이 적용되는 컬럼을 배치한다.
   - 두 번째 컬럼 이후에 선분조건이 적용되는 컬럼을 배치한다.

이 순서를 지키면 불필요한 스캔을 최소화하고, 원하는 데이터를 가장 빠른 경로로 찾아낼 수 있다. 
반대로 선분조건을 선두에 두면 범위 전체를 먼저 읽어야 하기 때문에 인덱스 효율이 떨어진다.
*/

create  index  mcustsum_salegb_salemm  on  mcustsum(salegb, salemm);
create  index  mcustsum_salemm_salegb  on  mcustsum(salemm, salegb);

-- 튜닝전:
select /*+ index(t mcustsum_salemm_salegb)
           no_index_ss( t mcustsum_salemm_salegb) */ count(*)
from mcustsum t
where salegb = 'A'
and salemm between '202501' and '202512';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name                   | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                        |      1 |        |      1 |00:00:00.08 |    3090 |
|   1 |  SORT AGGREGATE   |                        |      1 |      1 |      1 |00:00:00.08 |    3090 |
|*  2 |   INDEX RANGE SCAN| MCUSTSUM_SALEMM_SALEGB |      1 |    600K|    100K|00:00:00.08 |    3090 |
*/



-- 튜닝후:
select /*+ index(t mcustsum_salegb_salemm) */ count(*)
    from mcustsum t
    where salegb = 'A'
    and salemm between '202501' and '202512';
    
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name                   | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                        |      1 |        |      1 |00:00:00.01 |     281 |
|   1 |  SORT AGGREGATE   |                        |      1 |      1 |      1 |00:00:00.01 |     281 |
|*  2 |   INDEX RANGE SCAN| MCUSTSUM_SALEGB_SALEMM |      1 |    600K|    100K|00:00:00.01 |     281 |
*/



-- 만약 인덱스가 mcustsum_salemm_salegb 밖에 없는 상황이고 
-- mcustsum_salegb_salemm를 만들수 없는 상황이라면?
-- 선분조건에서 점조건으로 바꿔주면 된다.

drop index mcustsum_salegb_salemm;

select /*+ index(t mcustsum_salemm_salegb) no_index_ss( t mcustsum_salemm_salegb) */ count(*)
    from mcustsum t
    where salegb = 'A'
    and salemm in ('202501','202502','202503','202504','202505','202506','202507','202508','202509',
    '202510','202511','202512');
    
SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation          | Name                   | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |                        |      1 |        |      1 |00:00:00.02 |     304 |      8 |
|   1 |  SORT AGGREGATE    |                        |      1 |      1 |      1 |00:00:00.02 |     304 |      8 |
|   2 |   INLIST ITERATOR  |                        |      1 |        |    100K|00:00:00.02 |     304 |      8 |
|*  3 |    INDEX RANGE SCAN| MCUSTSUM_SALEMM_SALEGB |     12 |    600K|    100K|00:00:00.01 |     304 |      8 |
*/
@DEMO;
create  index  EMP_JOB_DEPTNO  on  EMP(JOB, DEPTNO);
create  index  EMP_DEPTNO_JOB  on  EMP(DEPTNO, JOB);

SELECT COUNT(*)
FROM EMP
WHERE DEPTNO BETWEEN 10 AND 30
AND JOB = 'CLERK';

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation         | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                |      1 |        |      1 |00:00:00.01 |       1 |
|   1 |  SORT AGGREGATE   |                |      1 |      1 |      1 |00:00:00.01 |       1 |
|*  2 |   INDEX RANGE SCAN| EMP_JOB_DEPTNO |      1 |      4 |      4 |00:00:00.01 |       1 |
*/