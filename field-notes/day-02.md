# DAY 02 — COMPARE / 묶는 기준이 결론을 바꾼다

> **질문:** 큰 병원과 동네 의원의 진료비·본인부담률은 어떻게 다른가? 환자는 얼마나 자주 돌아오는가?

**학습:** `GROUP BY` · `HAVING` · `COUNT` · `AVG` · `SUM` · `ROW_NUMBER` · `LAG` · `OVER`  
**실습:** `kr_claims` 교육용 청구 데이터

## 핵심 구분

| `GROUP BY` | 윈도우 함수 |
|:--|:--|
| 같은 기준의 행을 **접어 한 행**으로 만든다 | 원래 행을 **유지하며 새 열**을 붙인다 |
| 병원 종별 건수·평균·부담률 | 환자별 방문 순번·간격·누적 진료비 |

## 기억할 패턴

```sql
-- 비율은 단순 평균이 아닌 총 부담금 / 총 진료비
ROUND(SUM(c.rvd_slf_brdn_amt) * 100 /
      SUM(c.rvd_rpe_tamt_amt), 1) AS self_pct

-- 같은 환자의 바로 전 방문과 현재 방문 간격
DATEDIFF(recu_fr_dd,
    LAG(recu_fr_dd) OVER (
        PARTITION BY jid ORDER BY recu_fr_dd
    )) AS gap_days
```

## 해석의 반전 — 입원과 외래를 합치면

전체 명세서로 집계하면 병원 종별 본인부담률에 차이가 나타나지만, **외래만 분리하면 상급종합병원 27.7%, 의원 27.2%**로 비슷한 수치가 나온다. **집계할 때 섞인 집단의 구성이 결론을 바꿀 수 있다.**

## 실패를 알려주는 오류

- `ERROR 1055`: 그룹 기준이 아닌 열을 집계 없이 선택했다.
- `ERROR 3593`: `WHERE` 안에서 윈도우 함수를 사용했다. **CTE에서 계산한 뒤 바깥에서 거른다.**
- DBeaver의 기본 표시 행 수를 전체 결과 수로 오해하지 않는다.

[전체 개념·실습 과정 읽기 →](../deep-notes/day-02-full.md) · [오류 사례집](../case-studies/failure-atlas.md)
