# DAY 01 — READ / 원하는 기록을 정확히 찾는 법

> **질문:** 2025년 12월 외래 진료비가 큰 청구는 무엇이었을까?

**학습:** `SELECT` · `FROM` · `WHERE` · `ORDER BY` · `LIMIT` · `JOIN`  
**실습:** `kr_claims` (의료 청구 구조를 본뜬 교육용 가상 데이터)

## 가져간 원칙

1. `WHERE`는 행을 고르고, `SELECT`는 열을 고른다.
2. 명세서의 상병 코드와 이름은 별도 테이블이므로 `JOIN`이 필요하다.
3. `ORDER BY` 없는 `LIMIT`의 첫 행은 보장되지 않는다.
4. 쿼리가 0행을 반환했다면 SQL 오류를 단정하기 전에 **저장된 값의 형태**부터 확인한다.
5. `JOIN` 후에는 키와 행 수를 검산한다.

## 실습 패턴

```sql
SELECT c.mid, c.recu_fr_dd, c.main_sick, s.krnm,
       c.rvd_rpe_tamt_amt
FROM claim AS c
JOIN sick_master AS s ON s.sickcd = c.main_sick
WHERE c.fom_tp_cd = '031'
  AND c.recu_fr_dd BETWEEN '2025-12-01' AND '2025-12-31'
ORDER BY c.rvd_rpe_tamt_amt DESC
LIMIT 10;
```

## 인상적인 함정 — 0행이 꼭 0건은 아니다

수업 데이터에서 `main_sick = 'I10'`으로 찾으면 0행이지만, 더 상세한 `I109` 코드로 찾으면 4,403행이 나온다. **문법이 맞아도 질문의 조건을 잘못 번역하면 답은 틀린다.**

## 내가 가져갈 검수 질문

- 지금 한 행은 무엇을 의미하지?
- JOIN이 명세서 수를 바꾸지 않았나?
- 실제 값은 `I10`인가 `I109`인가?
- 결과 첫 행과 전체 행 수는 기준값과 맞나?

[전체 개념·실습 과정 읽기 →](../deep-notes/day-01-full.md) · [오류 사례집](../case-studies/failure-atlas.md)

> 데이터 주의: 실습의 환자·청구 기록은 가상 데이터다. 실제 환자 개인기록은 공개하지 않는다.
