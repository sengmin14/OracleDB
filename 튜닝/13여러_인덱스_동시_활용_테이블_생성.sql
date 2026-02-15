
-- 1. 기존 테이블/인덱스 정리
BEGIN
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE emp2 PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP INDEX emp2_col1'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP INDEX emp2_col2'; EXCEPTION WHEN OTHERS THEN NULL; END;
END;
/

-- 2. 테이블 생성
CREATE TABLE emp2 (
    RID VARCHAR2(18),
    COL1 VARCHAR2(1),
    COL2 VARCHAR2(1),
    DUMMY_COL VARCHAR2(100)
);

-- 3. 데이터 삽입
DECLARE
    v_rowid VARCHAR2(18);
    v_counter NUMBER := 0;
BEGIN
    -- (1) COL1='A' AND COL2='D' (극소수 = 타겟)
    FOR i IN 1..50 LOOP
        v_counter := v_counter + 1;
        v_rowid := 'KEYAD_'||LPAD(v_counter,10,'0');
        INSERT INTO emp2 VALUES (v_rowid,'A','D','TARGET_'||LPAD(v_counter,6,'0'));
    END LOOP;

    -- (2) COL1='A' AND COL2<>'D' (대량)
    FOR i IN 1..200000 LOOP
        v_counter := v_counter + 1;
        v_rowid := 'KEYA_'||LPAD(v_counter,10,'0');
        INSERT INTO emp2 VALUES (v_rowid,'A','X','FILLER_'||LPAD(v_counter,6,'0'));
    END LOOP;

    -- (3) COL1<>'A' AND COL2='D' (대량)
    FOR i IN 1..200000 LOOP
        v_counter := v_counter + 1;
        v_rowid := 'KEYD_'||LPAD(v_counter,10,'0');
        INSERT INTO emp2 VALUES (v_rowid,'Z','D','FILLER_'||LPAD(v_counter,6,'0'));
    END LOOP;

    -- (4) 기타 데이터 (잡음)
    FOR i IN 1..50000 LOOP
        v_counter := v_counter + 1;
        v_rowid := 'KEYX_'||LPAD(v_counter,10,'0');
        INSERT INTO emp2 VALUES (
            v_rowid,
            CHR(66+MOD(i,5)), -- B~F
            CHR(67+MOD(i,4)), -- C~F
            'FILLER_'||LPAD(v_counter,6,'0')
        );
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('총 데이터 건수: '||v_counter);
END;
/

-- 4. 인덱스 생성
CREATE INDEX emp2_col1 ON emp2(COL1);
CREATE INDEX emp2_col2 ON emp2(COL2);

-- 5. 통계 수집
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname=>USER,tabname=>'EMP2',estimate_percent=>100,cascade=>TRUE);
END;
/