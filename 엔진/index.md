# 🥕 인덱스(INDEX)

## RDBMS의 인덱스란?
- 인덱스란 DB테이블에서 특정 데이터에 대한 검색 작업을 수행할 때, 검색 성능을 높이기 위해 사용되는 도구이다.
- 만약 데이터가 N개가 존재하는 테이블에서 특정 컬럼의 값이 X인 데이터를 찾기 위해서는, 전체 테이블을 모두 확인해야 하며 O(N)의 시간복잡도를 갖는다.
- 이를 FULL TABLE SCAN 이라고 하는데, 하나의 데이터를 위해 매번 O(N)이 걸리는 것은 상당히 비효율적이다.
- 인덱스는 주로 B+Tree 자료구조를 이용하며 O(logN)의 향상된 시간복잡도를 갖는다.

<img width="700" height="429" alt="Image" src="https://github.com/user-attachments/assets/b1bd37a8-277e-47a0-bca0-ea8cc26bb14f" />


## 인덱스에 이용되는 자료구조
### 1. Hash Table
- 해시 테이블은 Key-Value 자료구조이다.
- 특정 데이터의 Key를 갖고 있다면 해당 Key를 해싱하여 인덱스를 도출해내고, 이를 이용하여 해당 데이터를 갖는데 시간복잡도 O(1)이 소요된다.

<img width="1280" height="912" alt="Image" src="https://github.com/user-attachments/assets/98f47101-ef69-467a-bea4-d72024f706c1" />


https://one-armed-boy.tistory.com/entry/%EC%9E%90%EB%A3%8C%EA%B5%AC%EC%A1%B0-in-DB-%EC%9D%B8%EB%8D%B1%EC%8A%A4
