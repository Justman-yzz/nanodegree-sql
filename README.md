<div align="center">

![BEYOND THE QUERY — SQL Field Notes](assets/hero.svg)

### 실행된 SQL보다, 믿을 수 있는 결과.

**SQL · MySQL · DBeaver · Healthcare Data · Cohort Analysis**

교육용 의료 데이터를 통해 익힌 SQL 3일·6교시의 핵심 개념과 실제 과제 기록을 정리한 학습 포트폴리오.

**[학습 기록](#3-주요-실습-내용) · [SQL 코드](#4-주요-sql과-설명) · [결과 보기](#6-실행-결과) · [배운 점](#7-배운-점)**

</div>

---

> **THE QUESTION**  
> 쿼리에 오류가 없더라도 분석 결과는 틀릴 수 있다.  
> 어떤 행을 선택했고, 누구를 분모에 남겼으며, 어떤 근거로 결과를 해석했는지가 중요하다.

## 1. 프로젝트 소개

**BEYOND THE QUERY — SQL FIELD NOTES**는 2026년 10월 나노디그리 SQL 강의 1~3일차에서 배운 내용을 실습 및 과제와 연결해 정리한 저장소다.

건강보험 청구 형식의 교육용 데이터와 폐암 합성데이터를 이용해, **조건 조회 → 다중 테이블 연결 → 집계 및 방문 이력 분석 → 코호트와 사망 기록 분석**으로 학습 범위를 넓혔다. 단순히 정답 숫자를 제시하기보다 잘못된 JOIN, 데이터 코드, 비율의 분모처럼 결과를 왜곡할 수 있는 지점을 함께 기록했다.

| 학습 범위 | 실제로 다룬 질문 | 대표 데이터 |
|:--|:--|:--|
| **01 / READ** | 필요한 청구 기록을 정확히 찾았는가? | 청구 명세서 **38,375행** |
| **02 / COMPARE** | 집계·방문 패턴에 따라 해석이 달라지는가? | 고혈압·당뇨 등 상병 및 방문 기록 |
| **03 / DEFINE** | 누구를 대상으로, 어느 기간의 사건을 셌는가? | 폐암 합성데이터 **9,897명** |

**데이터 윤리:** `kr_claims`의 청구·환자 기록은 교육용 가상 데이터이고, `kr_lung_cancer`는 공개된 폐암 합성데이터다. **실제 환자의 임상 결과가 아니며 원본 환자 단위 기록은 이 저장소에 포함하지 않는다.**

## 2. 사용 기술

| 도구 / 개념 | 활용 내용 |
|:--|:--|
| **MySQL / DBeaver** | SQL 실행, 데이터 확인, 결과 검토 |
| `SELECT` · `WHERE` · `ORDER BY` | 기간·조건 검색과 정렬 |
| `JOIN` · `LEFT JOIN` | 명세서·상병 마스터·사망 기록 연결 |
| `GROUP BY` · `HAVING` | 상병별·기관 종별 집계 및 그룹 조건 |
| `ROW_NUMBER` · `LAG` · `OVER` | 환자별 방문 순번·간격·누적값 |
| `WITH`(CTE) · `CASE WHEN` | 연구 코호트·병기 구분·조건부 집계 |
| Markdown · SVG | 재현 가능한 학습 기록과 결과 시각화 |

**핵심 학습 관점:** 데이터 한 행의 의미를 확인하고, `JOIN` 전후 행 수와 비율의 분자·분모를 검산하는 습관.

## 3. 주요 실습 내용

| 날짜 / 범위 | 학습 내용 | 대표 실습 | 기록 |
|:--|:--|:--|:--|
| **DAY 01 — READ** (1·2교시) | SELECT · WHERE · JOIN | 2025년 특정 월 외래 청구, 상병코드에 이름 붙이기 | [핵심](field-notes/day-01.md) · [상세](deep-notes/day-01-full.md) |
| **DAY 02 — COMPARE** (3·4교시) | GROUP BY · HAVING · 윈도우 함수 | 기관 종별 진료비 비교, 고혈압 방문 간격 | [핵심](field-notes/day-02.md) · [상세](deep-notes/day-02-full.md) |
| **DAY 03 — DEFINE** (5·6교시) | CTE · 코호트 · CASE · LEFT JOIN | 진단 연도별 사망 기록, 병기별 치료·사망 비율 | [핵심](field-notes/day-03.md) · [상세](deep-notes/day-03-full.md) |

```mermaid
flowchart LR
    A[조회 범위 정의] --> B[테이블 연결]
    B --> C[그룹과 방문 이력 분석]
    C --> D[코호트 및 사건 정의]
    D --> E{행 수·분모·결측 확인}
    E -->|재검토| A
    E -->|검증| F[해석 가능한 결과]
```

과제 수행 기록은 별도로 분리했다. **제출 때 확인한 결과**와 **학습 목적으로 재구성한 SQL**은 같은 것으로 취급하지 않는다.

| 과제 | 실제로 다룬 문제 | 확인된 수치 | 자료 |
|:--|:--|:--|:--|
| **ASSIGNMENT 01** | 2025년 7월 외래 명세서 조회·상병명 결합 | **1,450건** (Q1) | [과제 기록](assignments/assignment-01.md) · [SQL](sql/assignments/01_outpatient_claims.sql) |
| **ASSIGNMENT 02** | 상병별 명세서·수진자, 당뇨 방문 간격 분석 | **J209 2,554건 / 894명**, 방문 간격 **94일** | [과제 기록](assignments/assignment-02.md) · [SQL](sql/assignments/02_diagnosis_diabetes.sql) |
| **ASSIGNMENT 03** | 진단 코호트와 병기별 1,095일 이내 사망 기록 분석 | **6,873명** 코호트 | [과제 기록](assignments/assignment-03.md) · [SQL](sql/assignments/03_lung_cancer_3year_mortality.sql) |

[세 과제 전체 기록과 근거 구분 보기](assignments/README.md)

## 4. 주요 SQL과 설명

### 4-1. 기간·서식 조건으로 정확한 기록 고르기

```sql
SELECT COUNT(*) AS outpatient_claims
FROM kr_claims.claim
WHERE recu_fr_dd >= '2025-07-01'
  AND recu_fr_dd <  '2025-08-01'
  AND fom_tp_cd = '031';
```

**확인된 당시 결과:** 1,450건. `WHERE`가 조회 대상을 정의하고, `COUNT(*)`가 명세서 건수를 센다. 위 SQL은 동일 조건으로 다시 정리한 **재구성 코드**이며 제출 당시의 원문을 그대로 복사한 것은 아니다.

### 4-2. 환자별 방문 간격 계산하기

```sql
WITH visits AS (
    SELECT jid, recu_fr_dd,
           LAG(recu_fr_dd) OVER (
               PARTITION BY jid ORDER BY recu_fr_dd
           ) AS previous_visit
    FROM kr_claims.claim
    WHERE main_sick = 'E119'
)
SELECT jid, recu_fr_dd,
       DATEDIFF(recu_fr_dd, previous_visit) AS gap_days
FROM visits
WHERE previous_visit IS NOT NULL;
```

`LAG`로 같은 환자의 직전 방문일을 불러온다. 윈도우 함수를 `WHERE`에서 바로 거를 수 없으므로 CTE에서 먼저 계산한 뒤 바깥에서 조회한다. **과제 2 전체 조건이 복원되지 않아, 이 코드는 교육용 패턴이며 과제 결과를 재현한다고 주장하지 않는다.**

### 4-3. 코호트를 고정하고 사건 없는 대상도 보존하기

```sql
WITH cohort AS (
    SELECT pt_sbst_no, bspt_frst_diag_ymd
    FROM kr_lung_cancer.lung_pt_bsnf
    WHERE bspt_frst_diag_ymd >= '2010-01-01'
      AND bspt_frst_diag_ymd < '2018-01-01'
)
SELECT COUNT(*) AS cohort_size
FROM cohort;
```

2010~2017년 최초 진단 환자 6,873명이 과제 3의 기본 대상이다. 이후 사망 테이블은 `LEFT JOIN`으로 연결해 사망 기록이 없다는 이유만으로 대상자를 분모에서 제거하지 않도록 한다. 병기별 전체 재구성 코드는 [과제 3 SQL](sql/assignments/03_lung_cancer_3year_mortality.sql)에 포함했다.

> SQL 파일은 모두 **학습용 재구성 코드**로 표시했다. 원본 제출 SQL과 1:1 일치하거나 이번 저장소 제작 중 실제 DB에서 재실행했다고 주장하지 않는다.

## 5. 문제 해결 과정

이 과정에서 가장 중요했던 것은 **오류가 발생하지 않는 잘못된 결과**를 발견하는 일이었다.

<table>
<tr>
<td width="33%" valign="top"><strong>01 · ZERO IS NOT ZERO</strong><p><code>I10</code>을 조회했더니 0행. 저장된 청구 코드는 <code>I109</code>였다. 코드 형태를 먼저 확인해야 했다.</p></td>
<td width="33%" valign="top"><strong>02 · GROUPS CHANGE RESULTS</strong><p>입원과 외래를 합친 본인부담률과 외래만 비교한 결과가 달랐다. 무엇을 묶는지에 따라 해석이 바뀌었다.</p></td>
<td width="33%" valign="top"><strong>03 · JOIN ERASES PEOPLE</strong><p>8,436명의 학습용 코호트에 <code>INNER JOIN</code>하면 3,293명만 남는 사례. 기록 없는 환자가 분모에서 빠졌다.</p></td>
</tr>
</table>

| 문제 | 원인 | 확인·개선 방법 |
|:--|:--|:--|
| `I10` 검색 결과가 0행 | 실제 청구 데이터가 세부코드 `I109`를 사용 | 코드 마스터·`LIKE 'I10%'`로 실제 저장 형태 확인 |
| JOIN 후 집계 인원 감소 | 사건 없는 사람까지 `INNER JOIN`으로 제거 | `LEFT JOIN`, 단계별 `COUNT(*)` 비교 |
| 다중 코드표 JOIN 시 값 중복 | `code` 외에 `code_type` 조건 누락 | 조인 키의 복합 조건 및 행 수 검산 |
| SQL은 정상인데 병기 구분 오류 | 문자 `'x'`를 숫자 0처럼 비교 | `CASE WHEN ... IN ('0','1','2')`, 그룹별 분포 검증 |
| 사망 기록 없는 사람을 생존으로 간주 | 중도절단 정보 미반영 | 사건 기록 비율과 생존 추정치를 구분해 설명 |

[문제 해결과 검증 사례 전체 보기](case-studies/failure-atlas.md)

## 6. 실행 결과

### 6-1. 확인된 과제 집계

| 결과 | 확인 수치 | 해석 |
|:--|--:|:--|
| 2025년 7월 외래 명세서 | **1,450건** | 과제 1 Q1 집계 |
| J209 명세서 | **2,554건** | 과제 2의 당시 질문 조건에 따른 수치. 전체 기간 통계로 단정하지 않음 |
| J209 수진자 | **894명** | 명세서 건수와 구분해야 할 고유 인원 |
| 당뇨 방문 간격 90일 초과 | **1건, 94일** | 과제 2에서 확인된 결과. 전체 필터 조건 미복원 |
| 2010–2017 진단 코호트 | **6,873명** | 과제 3 Q1 |

### 6-2. 과제 3 — 병기별 1,095일 이내 사망 기록

![과제 3 병기별 사망 기록 비율](assets/stage-outcomes.svg)

| 병기 그룹 | 환자 수 | 1,095일 이내 사망 기록 | 기록 비율 |
|:--|--:|--:|--:|
| 초기 (0·1·2) | 2,666 | 347 | **13.02%** |
| 국소 진행 (3) | 1,098 | 535 | **48.72%** |
| 전이 (4) | 2,879 | 1,838 | **63.84%** |
| 병기 미상 | 230 | 109 | **47.39%** |
| **합계** | **6,873** | **2,829** | **41.16%** |

위 결과는 **기존 과제 대화에서 확인된 교육용 합성데이터 집계**다. 사망 기록이 없다는 사실만으로 3년 생존이 확인된 것은 아니므로, 이 표는 **중도절단을 반영한 생존율이 아니다.** 또한 이번 작업에서 DB를 다시 실행해 검증한 수치는 아니다.

[결과 집계와 한계 상세](sql/results/README.md) · [과제 3 기록](assignments/assignment-03.md)

## 7. 배운 점

SQL을 배우면서 가장 크게 느낀 것은 **쿼리가 실행되는 것과 질문에 맞는 답을 구하는 것은 다르다**는 점이다. 처음에는 문법과 실행 결과에 집중했지만, 여러 테이블을 연결하면서 행이 늘거나 줄어드는 문제를 접하고 나서는 데이터를 어떤 기준으로 세는지가 더 중요하게 다가왔다.

`GROUP BY`와 윈도우 함수의 차이, 코호트의 분모와 기간을 정하는 과정도 특히 인상적이었다. 같은 데이터라도 묶는 기준과 추적 기간이 달라지면 해석이 크게 달라진다는 것을 배웠다. 앞으로 데이터를 다루거나 AI가 작성한 SQL을 사용할 때도 결과를 그대로 받아들이기보다 데이터의 구조와 계산 기준을 먼저 확인하려고 한다.

[학습 회고 전체 보기](docs/reflection.md)

## 8. GitHub 링크 및 결과물 경로

| 확인할 자료 | 저장소 내 경로 |
|:--|:--|
| 메인 소개 | **현재 README** (`README.md`) |
| 3일차 학습 핵심 노트 | [`field-notes/`](field-notes/) |
| 3일차 상세 개념 정리 | [`deep-notes/`](deep-notes/) |
| 과제 1·2·3 정리 | [`assignments/`](assignments/) |
| 과제별 SQL 재구성 | [`sql/assignments/`](sql/assignments/) |
| 학습용 실습 SQL | [`sql/practice/`](sql/practice/) |
| 집계 결과와 시각화 | [`sql/results/`](sql/results/) · [`assets/stage-outcomes.svg`](assets/stage-outcomes.svg) |
| 오류·문제 해결 사례 | [`case-studies/`](case-studies/) |
| 실행 및 검증 안내 | [`docs/verification.md`](docs/verification.md) |

**GitHub 저장소 URL:** 공개 저장소 `nanodegree-sql`을 생성한 뒤, GitHub에서 실제 생성된 주소를 복사해 나노디그리 제출란에 입력한다. **아직 존재하지 않는 주소를 활성 링크로 표시하지 않는다.**

**관련 별도 프로젝트:** [NEXT VALUE — Hitter Radar](https://github.com/Justman-yzz/next-value-hitter-radar) — AI Agent 수업 프로젝트. 이 SQL 수업 실습 데이터와 직접 연결한 프로젝트라고 주장하지 않는다.

---

<div align="center">

**BEYOND THE QUERY** · SQL FIELD NOTES

<sub>Less about writing queries. More about trusting the right results.</sub>

</div>
