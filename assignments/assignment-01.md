# ASSIGNMENT 01 / 찾으려던 기록은 정확히 남았는가?

`SELECT` · `WHERE` · `JOIN` · `ORDER BY` · `LIMIT`

## 당시 확인한 결과

2025년 7월 외래 명세서(`fom_tp_cd = '031'`) 수는 **1,450건**이었다. 과제 Q1에서 확인한 집계 결과다.

```sql
-- 학습용 재구성: 제출 당시 쿼리 원문은 아님
SELECT COUNT(*) AS outpatient_claims
FROM kr_claims.claim
WHERE recu_fr_dd >= '2025-07-01'
  AND recu_fr_dd <  '2025-08-01'
  AND fom_tp_cd = '031';
```

**과제 1의 다른 문항(노트에 기록된 요청):**
- Q2: 7월 외래 명세서에 상병 한글명을 JOIN하고 진료비 내림차순 정렬, 첫 `mid`와 진료비 확인.
- Q3: 전체 기간 입원 명세서를 입내원일수 내림차순 정렬하고 상병 한글명·일수 확인.
- Q4: 헬스케어 데이터 직무에 대한 학습 소감.

Q2·Q3의 정확한 제출 코드 및 실제 첫 행 값은 현재 확보한 기록에 없다. 강의의 **2025년 12월 실습 결과를 7월 과제 결과로 바꿔 넣지 않았다.**

## 가져간 기술적 교훈

`WHERE` 조건 하나가 분석 대상을 바꾼다. `JOIN`으로 코드에 이름을 붙일 때도 명세서 행 수가 달라지지 않았는지 확인해야 한다. 데이터의 저장 코드(`I10` vs `I109`)를 검증하는 습관도 중요했다.

[재구성 SQL](../sql/assignments/01_outpatient_claims.sql) · [조회·JOIN 상세 노트](../deep-notes/day-01-full.md) · [과제 결과 목록](README.md)
