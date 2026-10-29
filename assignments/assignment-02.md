# ASSIGNMENT 02 / 같은 질병, 서로 다른 방문 패턴

`GROUP BY` · `HAVING` · `COUNT(DISTINCT)` · `ROW_NUMBER` · `LAG` · `DATEDIFF`

## 과제에서 확인한 결과

| 구분 | 확인된 내용 |
|:--|:--|
| Q1 | `J209`: **명세서 2,554건 / 환자 894명 / 1인당 2.86건** |
| Q2 | `HAVING COUNT(*) >= 500` 조건 적용 후 **7행** |
| Q3 | `E119` 당뇨병 방문 기록 중 **90일 초과 간격 1건**, **94일** |
| Q4 | 질병별 재방문 특성 비교: `I109` **5.66건**, `J209` **2.86건** |

아래 수치는 과제 수행 당시 기록한 집계다. 제출 SQL 원문과 모든 필터 조건이 남아 있지는 않아, 이어지는 복습용 쿼리의 결과와 1:1로 같다고 단정할 수 없다.

## SQL 동작을 이해하기 위한 패턴

### 환자와 명세서를 다르게 세기

```sql
-- 개념 예시: 제출 원문이 아니며, 과제의 전체 WHERE 조건은 미확인
SELECT main_sick,
       COUNT(*) AS claims,
       COUNT(DISTINCT jid) AS patients,
       ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT jid), 0), 2) AS per_patient
FROM kr_claims.claim
GROUP BY main_sick;
```

### 방문 간격 계산 뒤 바깥에서 필터링

```sql
-- 개념 예시: 실제 과제의 전체 날짜·서식 조건은 미확인
WITH visits AS (
    SELECT jid, recu_fr_dd,
           ROW_NUMBER() OVER (PARTITION BY jid ORDER BY recu_fr_dd) AS visit_no,
           DATEDIFF(
               recu_fr_dd,
               LAG(recu_fr_dd) OVER (PARTITION BY jid ORDER BY recu_fr_dd)
           ) AS gap_days
    FROM kr_claims.claim
    WHERE main_sick = 'E119'
)
SELECT *
FROM visits
WHERE gap_days > 90
ORDER BY gap_days DESC;
```

위 예시 SQL은 기능 설명 목적이다. 실제 제출 결과 **1건·94일**을 그대로 재현한다고 보장하지 않는다. 과제 원문에서 추가된 기간·외래 조건 등이 있다면 반영해야 한다.

## 결과 해석

- `COUNT(*)`는 명세서 수, `COUNT(DISTINCT jid)`는 환자 수다. 같은 환자의 여러 방문을 중복 집계하면 해석이 틀어진다.
- `GROUP BY`는 행을 줄여 집계하고, `LAG`는 원래 방문 행을 유지한 채 직전 방문을 읽는다.
- 윈도우 함수는 `WHERE`에서 바로 필터링할 수 없다. CTE에서 계산하고 바깥에서 조건을 건다.

[재구성 SQL](../sql/assignments/02_diagnosis_diabetes.sql) · [집계·윈도우 상세 노트](../deep-notes/day-02-full.md) · [과제 결과 목록](README.md)
