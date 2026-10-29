# DAY 03 — DEFINE / 누구를 분모에 둘 것인가

> **질문:** 진단 연도별 사망률과 병기별 치료 비율을 계산하기 전에 무엇을 먼저 정해야 할까?

**학습:** `WITH`(CTE) · 코호트 · `LEFT JOIN` · `CASE WHEN` · 조건부 집계 · 중도절단  
**실습:** `kr_lung_cancer` 공개 합성데이터 (실제 환자 기록 아님)

## 먼저 정의할 것

**누구를** → 2010~2019년 진단자 8,436명  
**언제부터** → 최초 진단일  
**무엇을** → 진단일부터 365일 내 사망 사건  
**얼마나 관찰했는가** → 사망일 / 마지막 방문일 / 중도절단

```sql
WITH cohort AS (
  SELECT pt_sbst_no,
         bspt_frst_diag_ymd AS index_dd
  FROM lung_pt_bsnf
  WHERE bspt_frst_diag_ymd >= '2010-01-01'
    AND bspt_frst_diag_ymd < '2020-01-01'
)
SELECT COUNT(*) FROM cohort;
```

## 중요한 함정 세 가지

1. **`INNER JOIN`의 분모 손실.** 사망자 테이블과 내부 조인하면 사망 기록이 없는 사람이 빠져, 8,436명 코호트가 3,293명으로 줄어든 사례가 있다.
2. **문자형 병기 값.** `bspt_stag_vl`에는 `'x'`가 존재한다. 숫자로 비교하면 `'x'`가 0으로 변환되어 병기 미상 350명이 초기 그룹에 잘못 섞인다.
3. **중도절단을 생존으로 오해.** 1년 전에 추적이 끊긴 4,098명(48.6%)은 확인된 생존자가 아니다. 이들을 모두 사망하지 않은 사람으로 세면 사망률 해석이 왜곡된다.

## 0/1 평균으로 비율 만들기

```sql
AVG(CASE WHEN bspt_frst_oprt_ymd IS NOT NULL
         THEN 1 ELSE 0 END) * 100 AS surgery_pct
```

`NULL`은 0이 아니라 기록 없음 또는 미확인이라는 상태다. 또한 위처럼 단순 0/1로 계산한 비율과 중도절단을 고려한 생존분석은 서로 다르다.

[전체 개념·실습 과정 읽기 →](../deep-notes/day-03-full.md) · [오류 사례집](../case-studies/failure-atlas.md)

> 의료적 의사결정을 위한 분석이 아닌 교육용 합성데이터 실습이다.
