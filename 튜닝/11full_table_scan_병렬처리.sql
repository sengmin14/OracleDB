/*
인덱스가 없거나
전체 데이터를 조회해야 하는 경우
*/

/*ORACLE VERSION 확인*/
/*Exrpess Edition의 경우 병렬처리 불가*/
SELECT *
FROM V$VERSION;
/*cpu코어 수 확인*/
SELECT *
FROM v$parameter
WHERE name LIKE '%cpu%';
/*
136	cpu_count	                    3	    18	            18	            0
137	cpu_min_count	                2	    18	            18	            null
482	resource_manager_cpu_allocation	3	    0	            0	            0
490	resource_manager_cpu_scope	    2	INSTANCE_ONLY	INSTANCE_ONLY	INSTANCE_ONLY
4097	parallel_threads_per_cpu	3	    1	            1	            1
*/



/*튜닝 전*/
@demo

SELECT job, count(*)
FROM emp
group  by  job; 
/*
PRESIDENT	1
MANAGER	3
SALESMAN	4
CLERK	4
ANALYST	2
*/

SELECT * 
FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation          | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |      1 |        |      5 |00:00:00.01 |       7 |
|   1 |  HASH GROUP BY     |      |      1 |     14 |      5 |00:00:00.01 |       7 |
|   2 |   TABLE ACCESS FULL| EMP  |      1 |     14 |     14 |00:00:00.01 |       7 |
*/



/*튜닝 후*/
/*병렬도 : 4*/
/*
cpu count에 따른 최대값 제한
4코어 이하       2-4         코어 수와 동일하거나 약간 적게
8코어            4-8         시스템 부하 고려하여 조정
16코어 이상      8-16        다른 작업과의 리소스 경합 고려
*/
SELECT /*+ PARALLEL(emp, 4) */ job, count(*)
FROM emp
group  by  job; 

SELECT * 
FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation              | Name     | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |          |      1 |        |       |     8 (100)|          |
|   1 |  PX COORDINATOR        |          |      1 |        |       |            |          |
|   2 |   PX SEND QC (RANDOM)  | :TQ10001 |      0 |      5 |    65 |     8  (25)| 00:00:01 |
|   3 |    HASH GROUP BY       |          |      0 |      5 |    65 |     8  (25)| 00:00:01 |
|   4 |     PX RECEIVE         | :TQ10000 |      0 |     14 |   182 |     7  (15)| 00:00:01 |
|   5 |      PX SEND HASH      | :TQ10000 |      0 |     14 |   182 |     7  (15)| 00:00:01 |
|   6 |       HASH GROUP BY    |          |      0 |     14 |   182 |     7  (15)| 00:00:01 |
|   7 |        PX BLOCK ITERATOR|         |      0 |     14 |   182 |     6   (0)| 00:00:01 |
|   8 |         TABLE ACCESS FULL| EMP    |      0 |     14 |   182 |     6   (0)| 00:00:01 |
*/



/*index scan 병렬처리*/
@demo
create index emp_job on emp(job);
 
select /*+ parallel_index(emp, emp_job, 4) */ job, count(*)
from emp
group by job;
/*
PRESIDENT	1
MANAGER	    3
SALESMAN	4
CLERK	    4
ANALYST	    2
*/
 
SELECT * 
FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
/*
| Id  | Operation                        | Name    | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |    TQ  |IN-OUT| PQ Distrib |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                 |         |      1 |        |       |     4 (100)|          |       |       |        |      |            |
|   1 |  PX COORDINATOR                  |         |      1 |        |       |            |          |       |       |        |      |            |
|   2 |   PX SEND QC (RANDOM)            | :TQ10001|      1 |      4 |    20 |     4  (25)| 00:00:01 |       |       |  Q1,01 | P->S | QC (RAND)  |
|   3 |    HASH GROUP BY                 |         |      4 |      4 |    20 |     4  (25)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
|   4 |     PX RECEIVE                   |         |      4 |     14 |    70 |     3   (0)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
|   5 |      PX SEND HASH                | :TQ10000|      1 |     14 |    70 |     3   (0)| 00:00:01 |       |       |  Q1,00 | P->P | HASH       |
|   6 |       HASH GROUP BY              |         |      4 |     14 |    70 |     3   (0)| 00:00:01 |       |       |  Q1,00 | PCWP |            |
|*  7 |        PX BLOCK ITERATOR         |         |      4 |     14 |    70 |     2   (0)| 00:00:01 |       |       |  Q1,00 | PCWC |            |
|   8 |         INDEX FAST FULL SCAN     | EMP_JOB |      4 |     14 |    70 |     2   (0)| 00:00:01 |       |       |  Q1,00 | PCWP |            |
*/