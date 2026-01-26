// emp 테이블을 생성하세요
@demo;


// emp 테이블에 ename 에 인덱스를 생성하고 ename 의 인덱스 구조 확인하기
create  index emp_ename  on  emp(ename);

select  ename, rowid
from emp
where ename > '  ';

  
// emp 테이블에 sal 에 인덱스를 생성하고 sal 의 인덱스 구조 확인하기
create  index  emp_sal  on  emp(sal);

select  sal, rowid
from  emp
where  sal >= 0 ;
  
  
// emp 테이블에  hiredate 에 인덱스를 생성하고 hiredate 의 인덱스 구조 확인하기
create  index  emp_hiredate on  emp(hiredate); 

select hiredate, rowid
from emp
where  hiredate <= to_date('9999/12/31','RRRR/MM/DD');
