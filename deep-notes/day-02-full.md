> 원본 학습 노트의 내용을 보존한 상세 기록입니다. 본 저장소의 의료 실습 데이터는 실제 환자 자료가 아닙니다.

# 2일차 개념 정리: GROUP BY와 윈도우 함수 (3·4교시)

2026-10-29 정리본 · 교육용 학습 자료

2일차는 38,375행짜리 명세서를 읽을 수 있게 만드는 두 방법이다. GROUP BY는 행을 접어 요약하고, 윈도우 함수는 행을 남긴 채 열을 붙인다.

## 핵심 정리

1. **GROUP BY는 그룹마다 한 행을 낸다.** SELECT에는 GROUP BY에 쓴 열과 집계 함수만 쓴다. 아니면 에러 1055.
2. **WHERE는 묶기 전 행, HAVING은 묶은 뒤 그룹을 거른다.** 실행 순서는 FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT.
3. **비율은 합 ÷ 합이다.** 평균의 평균은 금액 크기를 무시한다. 지표는 정의를 먼저 정해야 숫자가 나온다.
4. **코드표를 JOIN할 때는 `code_type` 조건이 필수다.** 빼면 다른 종류 코드가 붙어 행이 불어난다.
5. **윈도우 함수는 행을 남기고 열을 붙인다.** 공식은 `함수() OVER (PARTITION BY 누구별로 ORDER BY 어떤 순서로)`. `LAG`는 직전 행 값(첫 행은 NULL), `SUM OVER`에 ORDER BY가 있으면 누적 합.
6. **윈도우 함수는 SELECT 단계에서 계산된다.** WHERE에 쓰면 에러 3593. 계산 → 이름 붙이기(WITH) → 바깥에서 거르기.
7. **묶는 기준이 바뀌면 결론이 바뀐다.** 입원과 외래를 합치면 큰 병원의 본인부담률이 낮지만, 외래만 보면 비슷하다.
8. **결과 판정 습관.** 에러 문구는 끝까지 읽고("Expression #2" = SELECT의 두 번째 항목), DBeaver 화면 행 수(기본 200행)로 판정하지 않고 `COUNT(*)`나 기준 행으로 확인한다. 에러 없이 실행됐다고 질문에 다 답한 것은 아니다.

## 데이터와 열 사전

실습 DB는 `kr_claims`이고, 명세서와 요양기관은 가상 기록이다.

| 테이블 | 내용 | 행 수 |
| --- | --- | --- |
| `claim` | 명세서 | 38,375 |
| `institution` | 요양기관 | 2,184 |
| `code_table` | 여러 종류의 코드가 한 테이블에 섞인 코드표 | 종별코드만 20행 |

| 열 | 뜻 |
| --- | --- |
| `mid` | 명세서 번호 |
| `yid` | 요양기관 번호 (claim과 institution을 잇는 키) |
| `jid` | 수진자(환자) 번호 |
| `recu_fr_dd` | 요양개시일자 (방문 날짜) |
| `rvd_rpe_tamt_amt` | 진료비 총액 |
| `rvd_slf_brdn_amt` | 본인부담금 |
| `main_sick` | 주상병 코드 (고혈압은 `I10`이 아니라 `I109`) |
| `fom_tp_cd` | 서식구분 (`031` 외래, `021` 입원) |
| `cl_cd` | 요양기관 종별코드 (institution에 있음) |
| `code_type`, `code`, `code_nm` | 코드표의 종류, 코드값, 이름 |

종별코드 20개 중 명세서에 나오는 것은 네 가지다.

| code | 이름 | 뜻 | 실습 데이터 기관 수 |
| --- | --- | --- | --- |
| 01 | 상급종합병원 | 규모가 가장 큰 병원 | 47 |
| 11 | 종합병원 | 여러 진료과를 갖춘 큰 병원 | 337 |
| 21 | 병원 | 입원 병상을 갖춘 병원 | 300 |
| 31 | 의원 | 동네 의원 | 1,500 |

## 3교시 개념: GROUP BY로 종별 진료비 비교

풀려는 문제는 "큰 병원으로 가면 건당 진료비와 본인부담률이 얼마나 달라지나"이다. 산출물은 종별 명세서 수, 건당 진료비, 본인부담률 표(4행)이다.

### 1) 행을 그룹으로 접기

기준이 같은 행끼리 접어 한 줄로 만든다. 슬라이드의 설명용 값은 의원 3건 평균 26,900, 병원 2건 평균 49,000이다.

### 2) 집계 함수와 용어

| 함수 | 하는 일 | 실습에서 |
| --- | --- | --- |
| `COUNT(*)` | 행 수 | 명세서 수 |
| `AVG(열)` | 평균 | 건당 진료비 |
| `SUM(열)` | 합계 | 본인부담금 합, 총액 합 |
| `ROUND(값, 1)` | 반올림 | 본인부담률 소수 1자리 |

| 용어 | 뜻 |
| --- | --- |
| 건당 진료비 | 명세서 한 건의 평균 진료비 총액 |
| 본인부담률 | 본인부담금 합 ÷ 진료비 총액 합 (환자가 낸 비율) |

### 3) GROUP BY 기본 틀

```sql
SELECT fom_tp_cd,
       COUNT(*) AS claims,
       ROUND(AVG(rvd_rpe_tamt_amt)) AS avg_total
FROM claim
GROUP BY fom_tp_cd;
```

| fom\_tp\_cd | claims | avg\_total |
| --- | --- | --- |
| 031 | 37751 | 42733 |
| 021 | 624 | 2692921 |

38,375행이 2행으로 접힌다. `ORDER BY`가 없으면 두 행의 순서는 정해져 있지 않으므로, 순서를 정하려면 끝에 `ORDER BY fom_tp_cd`를 쓴다. SELECT에는 GROUP BY에 쓴 열과 집계 함수만 올 수 있다. 그룹마다 한 행만 나오기 때문이다.

### 4) WHERE와 HAVING

| 구 | 거르는 대상 | 예 |
| --- | --- | --- |
| WHERE | 묶기 **전** 행 | `WHERE fom_tp_cd = '031'` |
| HAVING | 묶은 **뒤** 그룹 | `HAVING COUNT(*) >= 3000` |

실행 순서는 FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY/LIMIT이다. "명세서 수 3000건 이상"은 묶어야 알 수 있는 값이라 HAVING에 쓴다. 위 쿼리에 `HAVING COUNT(*) >= 1000`을 붙이면 `031` 한 행만 남는다.

### 5) 비율은 합 ÷ 합

비율은 합을 합으로 나누고, 평균의 평균을 내지 않는다.

|  | 총액 | 본인부담 | 개별 비율 |
| --- | --- | --- | --- |
| A | 10,000 | 3,000 | 30% |
| B | 90,000 | 18,000 | 20% |

비율의 평균은 25%, 합 ÷ 합은 21,000 ÷ 100,000 = 21%이다. 금액이 큰 B의 비중이 반영되는 쪽이 합 ÷ 합이다. `AVG(본인부담금 / 총액)`도 틀린 것은 아니지만 정의가 다른 값이라 결과가 다르다.

```sql
ROUND(SUM(c.rvd_slf_brdn_amt) * 100 / SUM(c.rvd_rpe_tamt_amt), 1) AS self_pct
```

### 6) 테이블 3개 잇기

종별 이름은 명세서에 없다. 요양기관 테이블에 종별코드가 있고, 코드표에 이름이 있다. 2교시의 JOIN을 한 번 더 잇는다.

| 단계 | 테이블 | 값 (예) |
| --- | --- | --- |
| 명세서 | `claim` | mid 5000001, yid 2377 |
| 요양기관 | `institution` | yid 2377, cl\_cd 31 |
| 종별 이름 | `code_table` | code\_type 종별코드, code 31, code\_nm 의원 |

```sql
SELECT c.mid, c.yid, i.cl_cd, t.code_nm
FROM claim c
JOIN institution i ON i.yid = c.yid
JOIN code_table t ON t.code_type = '종별코드' AND t.code = i.cl_cd
WHERE c.mid = 5000001;
```

`code_table`에는 여러 종류의 코드가 섞여 있어서 `code_type = '종별코드'` 조건을 꼭 넣는다. 빼면 다른 종류의 코드까지 붙어 행이 불어난다.

### 라이브 코딩 3단계

1. 시작 지점 확인: `claim` 38375행, `institution` 2184행
2. `code_table`에서 `code_type = '종별코드'`만 골라 보기
3. 서식구분별로 세어 보기 (위 3번의 쿼리)

## 3교시 실습 구조와 에러 1055

### &#91;실습 2\] 상급종합병원과 동네 의원의 진료비 비교

보험 정책 담당자가 "큰 병원으로 가면 명세서 한 건의 진료비와 본인부담이 얼마나 달라집니까? 심평원 통계와 같은 모양으로 뽑아 주세요"라고 묻는 상황이다. 쓰는 열은 `claim`의 `yid`, `rvd_rpe_tamt_amt`, `rvd_slf_brdn_amt`, `institution`의 `yid`, `cl_cd`, `code_table`의 `code_type`, `code`, `code_nm`이다.

| 단계 | 할 일 | 쓰는 개념 |
| --- | --- | --- |
| Step 1 | 서식구분별로 세어 보기 | GROUP BY 기본 |
| Step 2 | 명세서에 종별 이름 붙이기 (5행만 먼저 확인) | JOIN 3개 + `code_type` 조건 |
| Step 3 | 종별로 묶어 세 가지 지표 내기 | GROUP BY + COUNT/AVG/SUM/ROUND |
| Step 4 | 명세서 3,000건 이상인 종별만 남기기 | HAVING |

Step 3의 지표 설계는 다음과 같다. 정렬은 `avg_total` 큰 순서이고, 입원과 외래를 나누지 않고 전부 넣는다(심평원 종별 통계와 같은 정의).

| 지표 | 식 | 별칭 |
| --- | --- | --- |
| 묶는 기준 | `t.code_nm` | `cl_nm` |
| 명세서 수 | `COUNT(*)` | `claims` |
| 건당 진료비 | `ROUND(AVG(c.rvd_rpe_tamt_amt))` | `avg_total` |
| 본인부담률(%) | `ROUND(SUM(c.rvd_slf_brdn_amt) * 100 / SUM(c.rvd_rpe_tamt_amt), 1)` | `self_pct` |

**막힘 포인트**

- Step 2에서 `code_type` 조건을 빼먹으면 행이 불어난다.
- 본인부담률을 `AVG(부담금/총액)`으로 쓰면 값이 달라진다. 합 ÷ 합으로 쓴다.
- 에러 문구는 끝까지 읽는다. "Expression #2"는 SELECT의 몇 번째 항목인지를 가리킨다.

### 에러 1055: SELECT에 GROUP BY에 없는 열을 넣었을 때

```sql
SELECT i.cl_cd, c.main_sick, COUNT(*)
FROM claim c
JOIN institution i ON i.yid = c.yid
GROUP BY i.cl_cd;
```

```
ERROR 1055 (42000): Expression #2 of SELECT list is not in GROUP BY clause
and contains nonaggregated column 'kr_claims.c.main_sick' ...
incompatible with sql_mode=only_full_group_by
```

읽는 법은 "SELECT의 두 번째 항목(`c.main_sick`)이 GROUP BY에 없다"이다. 종별 하나에 상병이 여러 개라서, 접힌 한 행에 어느 상병을 보여 줄지 정할 수 없기 때문이다. DBeaver는 표시 형식이 다를 수 있지만 번호(1055)와 본문은 같다.

- 고치는 법 1: `GROUP BY i.cl_cd, c.main_sick`처럼 묶는 기준에 넣는다.
- 고치는 법 2: `COUNT(DISTINCT c.main_sick)`처럼 집계 함수로 감싼다.

### 심화

- **입원과 외래를 나눠 보기:** `code_table`을 한 번 더 이어(`code_type = '서식구분코드'`, `code = c.fom_tp_cd`) 서식구분 이름을 붙이고, 종별과 서식구분 두 기준으로 묶는다(7행). 외래만 보면 본인부담률이 종별과 상관없이 27% 대(상급종합병원 27.7, 의원 27.2)이고, 합쳤을 때 큰 병원의 본인부담률이 낮게 나온 까닭은 입원이 섞였기 때문이다.
- **2025년 외래 다빈도 상병 10개:** `sick_master`를 이어 상병별 명세서 수와 환자 수(`COUNT(DISTINCT c.jid)`)를 낸다. 고혈압은 환자 수에 비해 명세서가 많다. 같은 사람이 여러 번 온다는 뜻이고, 4교시의 소재이다.

### 직무 매핑

| SQL 행동 | 현장에서의 의미 | 오늘 한 것 |
| --- | --- | --- |
| GROUP BY로 종별 집계 | 현장 질문은 대개 "종별로", "상병별로"처럼 묶어서 묻는다 | 종별 4행 표 |
| 합을 합으로 나눈 비율 | 본인부담률 같은 지표는 정의를 먼저 정해야 숫자가 나온다 | 본인부담금 합 ÷ 진료비 총액 합 |
| 결과를 공식 통계와 나란히 보기 | 연습용 데이터와 실제 통계를 구분해서 말한다 | 심평원 종별 진료비 통계(2024년 진료분)와 비교 |

## 4교시 개념: 윈도우 함수로 방문 순번·간격·누적

풀려는 문제는 "고혈압 환자는 제때 오나, 석 달 넘게 비운 사람은 누구인가"이다. 산출물은 환자별 방문 순번, 방문 간격, 누적 진료비 표이다.

### 1) GROUP BY는 접고, 윈도우 함수는 붙인다

환자 100006의 고혈압 외래 방문 6건이다.

| recu\_fr\_dd | rvd\_rpe\_tamt\_amt |
| --- | --- |
| 2025-02-15 | 24500 |
| 2025-04-21 | 29500 |
| 2025-06-22 | 34200 |
| 2025-08-05 | 32600 |
| 2025-10-10 | 25700 |
| 2025-12-14 | 19900 |

`GROUP BY jid`로 묶으면 1행(6건, 합계 166400)이 된다. 윈도우 함수는 6행을 그대로 두고 새 열을 붙인다. 방문 사이를 보려면 행이 남아 있어야 한다.

### 2) OVER의 부품

```sql
SELECT jid, recu_fr_dd,
       ROW_NUMBER() OVER (PARTITION BY jid ORDER BY recu_fr_dd) AS visit_no
FROM claim
WHERE main_sick = 'I109' AND fom_tp_cd = '031'
ORDER BY jid, visit_no
LIMIT 8;
```

| 부품 | 뜻 |
| --- | --- |
| `ROW_NUMBER()` | 무엇을 계산할지 (번호 매기기) |
| `PARTITION BY jid` | 환자별로 따로 |
| `ORDER BY recu_fr_dd` | 날짜순으로 |

환자마다 1, 2, 3 순으로 번호가 붙고 다음 환자에서 다시 1부터 시작한다. 행 수는 줄지 않는다.

### 3) 목표 결과의 모양 (환자 100006의 첫 네 행)

| jid | recu\_fr\_dd | visit\_no | gap\_days | cum\_amt |
| --- | --- | --- | --- | --- |
| 100006 | 2025-02-15 | 1 | NULL | 24500 |
| 100006 | 2025-04-21 | 2 | 65 | 54000 |
| 100006 | 2025-06-22 | 3 | 62 | 88200 |
| 100006 | 2025-08-05 | 4 | 44 | 120800 |

새 열 세 개는 `visit_no`(방문 순번), `gap_days`(직전 방문과의 간격), `cum_amt`(누적 진료비)이다.

### 4) LAG: 직전 방문과의 간격

```sql
DATEDIFF(recu_fr_dd, LAG(recu_fr_dd) OVER (PARTITION BY jid ORDER BY recu_fr_dd))
```

`LAG`는 같은 환자의 바로 앞 행 값을 가져온다. 첫 방문은 앞 행이 없어 NULL이며 오류가 아니다. `DATEDIFF(뒤, 앞)`은 날짜 차이(일)이다.

### 5) 누적 합

```sql
SUM(rvd_rpe_tamt_amt) OVER (PARTITION BY jid ORDER BY recu_fr_dd)
```

같은 창에 ORDER BY가 있으면 첫 행부터 지금 행까지 더한다. 환자 100006의 첫 네 방문은 24500, 54000, 88200, 120800으로 쌓인다.

### 6) 윈도우 함수가 계산되는 자리

윈도우 함수는 SELECT 단계에서 계산된다. WHERE, GROUP BY, HAVING이 끝난 뒤이고 ORDER BY와 LIMIT보다는 앞이다.

```
FROM → WHERE → GROUP BY → HAVING → SELECT(윈도우 계산) → ORDER BY/LIMIT
```

### 라이브 코딩 3단계

1. 환자 100006의 고혈압 방문을 띄워 GROUP BY와 비교한다.
2. 환자별 방문 순번을 붙인다.
3. `LAG(recu_fr_dd)`만 먼저 붙여 직전 날짜가 옆에 오는 것을 보고, `DATEDIFF`로 감싼다.

## 4교시 실습 구조와 에러 3593

### &#91;실습 3\] 고혈압 환자의 방문 간격

만성질환 관리 담당자가 "고혈압 환자들이 제때 옵니까? 석 달 넘게 비운 사람은 누구죠?"라고 묻는 상황이다. 쓰는 열은 `claim`의 `jid`, `recu_fr_dd`, `rvd_rpe_tamt_amt`, `main_sick`, `fom_tp_cd`이다.

| 단계 | 할 일 | 쓰는 개념 |
| --- | --- | --- |
| Step 1 | 고혈압 외래 명세서만 고르기 | WHERE 조건 + `COUNT(DISTINCT)` |
| Step 2 | 환자별 방문 순번 붙이기 | ROW\_NUMBER + PARTITION BY |
| Step 3 | 직전 방문과의 간격, 누적 진료비 붙이기 | LAG + DATEDIFF + SUM OVER |
| Step 4 | 90일 넘게 비운 방문만 보기 | WITH(CTE) 틀 |

**알아둘 점**

- 고혈압 코드는 `I10`이 아니라 `I109`이다.
- 어제와 건수가 다른 이유는 오늘 외래 조건(`fom_tp_cd = '031'`)이 추가되어 입원 명세서 1건이 빠졌기 때문이다.
- Step 3은 `LIMIT`을 빼고 실행한다. 결과가 수천 행인데 DBeaver는 기본 설정에서 200행만 가져와 보여 준다. 화면의 행 수로 판정하지 말고, 맨 위 환자 100006의 네 행이 위 "목표 결과의 모양" 표와 같은지 확인한다.

### 에러 3593: WHERE에 윈도우 함수를 썼을 때

```sql
SELECT jid, recu_fr_dd
FROM claim
WHERE main_sick = 'I109'
  AND DATEDIFF(recu_fr_dd, LAG(recu_fr_dd) OVER (PARTITION BY jid ORDER BY recu_fr_dd)) > 90;
```

```
ERROR 3593 (HY000): You cannot use the window function 'lag' in this context.'
```

읽는 법은 "여기서는 윈도우 함수를 쓸 수 없다"이다. WHERE가 일할 때는 `gap_days`가 아직 계산되지 않아 존재하지 않기 때문이다. 해결 원칙은 먼저 계산해 이름을 붙이고, 바깥에서 거르는 것이다. 문구 끝의 작은따옴표 하나는 MySQL이 내는 그대로이다(8.0과 8.4 동일).

해결용 틀은 아래와 같다. CTE는 5교시에 자세히 배우고, 2일차에는 틀을 쓰고 두 군데만 채운다.

```
WITH v AS (
  (여기에 Step 3의 쿼리를 넣는다. 맨 끝의 ORDER BY 줄과 세미콜론은 뺀다)
)
SELECT * FROM v
WHERE (여기에 조건: gap_days가 90보다 큰 행)
ORDER BY gap_days DESC;
```

- `WITH v AS ( ... )`는 괄호 안 결과에 `v`라는 이름을 붙이는 문법이다.
- 틀의 마지막 세 줄을 `SELECT COUNT(*) FROM v;`로 바꿔 전체 행 수가 Step 3 결과와 같은지 검산할 수 있다.

**막힘 포인트**

- `PARTITION BY`를 빼면 환자별이 아니라 전체에 번호가 한 줄로 붙는다. 환자마다 1부터 시작해야 한다.
- DBeaver는 200행만 먼저 가져오므로 화면에 보이는 행 수로 판정하지 않는다.
- 틀에 Step 3 쿼리를 넣을 때 맨 끝의 `ORDER BY` 줄과 세미콜론을 뺀다.

### 심화

- **환자별 평균 간격:** Step 3 결과를 `WITH v AS (...)`로 감싸고 `GROUP BY jid`로 방문 수와 평균 간격을 낸다. `HAVING COUNT(*) >= 3`으로 방문이 3번 이상인 환자만 남기고 평균 간격이 긴 순으로 본다. 3교시의 GROUP BY와 4교시의 윈도우 함수가 결합되는 문제이다.
- **수진자 100001 다시 보기:** 상병 조건을 빼고 `WHERE jid = 100001`로 바꿔 한 사람의 모든 명세서에 순번과 간격을 붙인다.

### 직무 매핑

| SQL 행동 | 현장에서의 의미 | 오늘 한 것 |
| --- | --- | --- |
| PARTITION BY 환자 | 명세서를 사람 단위로 이으면 이력이 된다 | 환자별 방문 순번 |
| LAG와 DATEDIFF | "제때 오는가"를 직전 방문과의 간격으로 잰다 | 방문 간격, 90일 넘게 비운 방문 |
| 결과가 질문에 다 답했는지 따져 보기 | 에러 없이 실행됐다고 질문에 다 답한 것은 아니다 | 돌아오지 않은 사람은 이 쿼리로 안 잡힌다 (수업 후 풀이) |

## 과제와 다음 일정

- **과제 2:** 상병별 집계와 당뇨병 환자의 방문 간격. 문항은 부모 페이지 「3. \[과제\] - SQL」에 있고, 마감은 10월 14일(수) 23:59이다. 3교시의 상병별 집계와 4교시의 방문 간격이 모두 들어간다.
- **수업 후 공개 예정:** 3·4교시 모범답안과 풀이(공식 통계와 나란히 보기, 에러 1055와 에러 3593, 이 쿼리가 답하지 못하는 것).
- **다음:** 3일차는 병원 임상 데이터, 5교시는 CTE와 코호트이다. 3일차 데이터 확인용으로 `SELECT COUNT(*) FROM kr_lung_cancer.lung_pt_bsnf;`를 실행해 9897이 나오는지 확인한다.
- **참고:** MySQL 8.4 설명서(GROUP BY 처리, 윈도우 함수 개념과 문법), 심평원 의료기관종별 진료비 통계, 심평원 4단상병 통계.
