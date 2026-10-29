# SQL 핵심 복습 — 다시 볼 때 여기부터

> **목표:** 문법을 외우는 데서 끝내지 않고, 분석 결과를 믿어도 되는지 스스로 점검하기. 교육용 SQL 강의·실습 기록을 바탕으로 정리했다.

[스스로 확인 문제 풀기](self-check.md) · [조회·JOIN 상세 노트](../deep-notes/day-01-full.md) · [집계·윈도우 상세 노트](../deep-notes/day-02-full.md) · [CTE·코호트 상세 노트](../deep-notes/day-03-full.md)

## 1. 데이터를 고르는 순서: `SELECT`와 `WHERE`

- `FROM`: 어떤 테이블을 읽는가?
- `WHERE`: 어떤 **행**을 남기는가? (기간, 코드, 서식 조건)
- `SELECT`: 어떤 **열**을 보여 주는가?
- `ORDER BY`: 무엇을 기준으로 정렬하는가?
- `LIMIT`: 그 정렬 결과에서 몇 행을 보여 주는가? 정렬이 없으면 '상위'라고 말하기 어렵다.

```sql
-- 강의에서 다룬 청구 데이터 구조를 이용한 복습용 예시
SELECT mid, recu_fr_dd, main_sick
FROM kr_claims.claim
WHERE recu_fr_dd >= '2025-07-01'
  AND recu_fr_dd < '2025-08-01'
ORDER BY recu_fr_dd DESC
LIMIT 10;
```

**기억할 질문:** 검색 결과가 0행일 때 데이터가 없다고 확정하지 말자. 강의의 `I10`/`I109` 사례처럼 **실제 저장 코드**와 데이터 유형부터 확인한다.

## 2. 연결하고 나서 행 수 확인: `JOIN`

- `INNER JOIN`: 양쪽에서 연결되는 행이 있을 때 결과에 남긴다.
- `LEFT JOIN`: 왼쪽 행을 유지하되, 오른쪽에 없는 값은 `NULL`로 표시한다.
- **중요:** `LEFT JOIN`을 써도 오른쪽에 같은 키가 여러 행이면 행 수가 늘 수 있다. 조인하기 전후에 전체 행과 고유 ID 수를 비교한다.

```sql
-- 코드표에 상병명을 붙이는 구조(복습용 예시)
SELECT c.mid, c.main_sick, s.krnm
FROM kr_claims.claim AS c
LEFT JOIN kr_claims.sick_master AS s
  ON c.main_sick = s.sickcd;
```

**검수할 질문:** 한 청구 명세서가 JOIN 뒤 몇 행으로 바뀌었나? 코드표에서 `sickcd`가 유일한가? 다른 구분키가 필요한가?

## 3. 집계 단위를 정하기: `COUNT`와 `GROUP BY`

| 표현 | 답하는 질문 |
|:--|:--|
| `COUNT(*)` | 조건에 맞는 **행이 몇 건인가?** |
| `COUNT(DISTINCT jid)` | 서로 다른 **사람이 몇 명인가?** |
| `GROUP BY main_sick` | 상병별로 나누어 집계하면? |
| `HAVING COUNT(*) >= 500` | 집계된 그룹 중 500건 이상인 그룹은? |

J209 관련 과제에서 **명세서 2,554건**, **수진자 894명**이 서로 다른 값이라는 사실을 확인했다. 명세서 1행과 환자 1명은 같은 단위가 아니다.

**검수할 질문:** `COUNT(*)`와 `COUNT(DISTINCT)` 중 어느 쪽이 문제에서 요구하는 지표인가? 비율을 계산할 때 분모는 무엇인가?

## 4. 행을 줄이는 집계 vs 행을 유지하는 윈도우 함수

| `GROUP BY` | `ROW_NUMBER()` / `LAG()` / `SUM() OVER (...)` |
|:--|:--|
| 여러 행을 그룹별 **한 행으로 요약** | 원래 행을 보존하면서 계산값을 **열로 추가** |
| 질병별 건수·평균·합계 | 환자별 방문 순번·직전 방문·누적합 |

```sql
WITH visit_history AS (
  SELECT jid, recu_fr_dd,
         LAG(recu_fr_dd) OVER (
           PARTITION BY jid ORDER BY recu_fr_dd
         ) AS previous_visit
  FROM kr_claims.claim
)
SELECT jid, recu_fr_dd,
       DATEDIFF(recu_fr_dd, previous_visit) AS days_between
FROM visit_history
WHERE previous_visit IS NOT NULL;
```

- `PARTITION BY jid`: 환자마다 기록을 나눈다.
- `ORDER BY recu_fr_dd`: 환자별 날짜 순서를 정한다.
- `LAG`: 같은 환자의 **바로 이전 행** 값을 가져온다.
- `WHERE`에서 윈도우 함수 결과를 바로 필터링하지 않고, **CTE에서 계산한 뒤 바깥에서 조건을 적용**한다 (`ERROR 3593`의 교훈).
- 같은 날 기록이 여러 건이면 날짜만으로 순서가 충분한지 확인한다.

## 5. 분석 대상을 고정하기: `WITH` · `CASE` · `LEFT JOIN`

- `WITH`(CTE): 먼저 **대상자·기간·사건 기준**을 이름 붙여 정리한다.
- `CASE`: 원래 값을 범주로 나누거나 조건에 맞는 사건을 1/0으로 표시한다.
- `LEFT JOIN`: 사건 기록이 없는 대상도 분석 목록에서 사라지지 않게 연결한다.
- `NULL`: 0이 아니라 **값이 기록되지 않은 상태**일 수 있다.

강의에서는 2010~2019년 코호트 **8,436명**, 과제에서는 2010~2017년 코호트 **6,873명**을 다루었다. **기간이 다르므로 서로 같은 집계로 보지 않는다.**

과제의 1,095일 이내 사망 기록 집계도 사건 기록의 비율을 계산한 것이지, 관찰 기간이 충분한지까지 확인한 **생존율 추정**은 아니다.

## 6. 헷갈리기 쉬운 두 가지 오류

- **MySQL `ERROR 1055`:** `GROUP BY`로 묶지 않은 열을 집계 없이 선택하고 있지 않은가?
- **MySQL `ERROR 3593`:** 윈도우 함수 결과를 같은 SELECT의 `WHERE`에서 직접 걸러내지 않았는가? CTE로 두 단계 분리할 수 있다.

## 7. 다음에 SQL을 실행할 때의 5단계

1. **질문 정의:** 누구를 대상으로 어떤 기간의 무슨 값을 구할까?
2. **행의 의미:** 청구 1건인가, 방문 1회인가, 환자 1명인가?
3. **연결 검산:** JOIN 전후 `COUNT(*)`와 `COUNT(DISTINCT ID)`는?
4. **결과 이름:** 건수·인원·비율·관찰기간이 드러나는가?
5. **해석 범위:** 데이터에 없는 정보를 없는 사실로 단정하고 있지 않은가?

---

[복습 문제](self-check.md) · [실습 예시 모음](../sql/practice/) · [문제 해결 노트](../case-studies/failure-atlas.md) · [메인으로](../README.md)
