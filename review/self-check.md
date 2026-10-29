# SQL 셀프 체크 — 답을 보기 전에 먼저 설명하기

> SQL 강의에서 다룬 개념을 내가 직접 설명할 수 있는지 확인하는 복습 페이지다. 예시 정답은 클릭해서 펼쳐 볼 수 있다.

## 문제 1 · WHERE vs SELECT

날짜 조건을 지정해서 특정 월 청구를 찾는다면, 어떤 절이 **행을 걸러내는 역할**을 할까?

<details><summary>정답·설명 확인</summary>

`WHERE`는 행을 선택하고 `SELECT`는 반환할 열을 정한다. 날짜 조건이 정확히 무엇인지가 집계 대상의 범위를 결정한다.

</details>

## 문제 2 · LIMIT

`ORDER BY` 없이 `LIMIT 10`을 쓰면 '진료비 상위 10건'이라고 말할 수 있을까?

<details><summary>정답·설명 확인</summary>

말할 수 없다. 진료비 기준 내림차순으로 정렬한 뒤 제한해야 한다.

</details>

## 문제 3 · 0건의 의미

`main_sick = 'I10'`이 0건이라고 해서 고혈압 관련 기록이 없다고 확정해도 될까?

<details><summary>정답·설명 확인</summary>

안 된다. 실습에서는 `I109`처럼 더 구체적인 코드가 저장되어 있었다. 코드값을 먼저 조회하고 필요한 경우 코드 마스터와 연결해 의미를 확인해야 한다.

</details>

## 문제 4 · 명세서 건수와 인원

`COUNT(*) = 2554`, `COUNT(DISTINCT jid) = 894`일 때 이 두 숫자는 무엇을 의미할까?

<details><summary>정답·설명 확인</summary>

첫 숫자는 행(명세서) 수, 둘째는 중복을 제거한 사람 수다. 문제의 단위가 건인지 명인지 먼저 구별한다.

</details>

## 문제 5 · WHERE vs HAVING

각 상병별로 그룹을 만든 다음 **500건 이상인 그룹만** 보려면 어떤 절을 사용할까?

<details><summary>정답·설명 확인</summary>

`GROUP BY main_sick` 뒤에 `HAVING COUNT(*) >= 500`. 개별 행 조건은 `WHERE`, 집계 이후 그룹 조건은 `HAVING`으로 구분한다.

</details>

## 문제 6 · GROUP BY vs LAG

환자의 직전 방문일을 기록별로 붙이면서 현재 방문 행도 유지하고 싶다면?

<details><summary>정답·설명 확인</summary>

`LAG(recu_fr_dd) OVER (PARTITION BY jid ORDER BY recu_fr_dd)` 같은 윈도우 함수를 사용한다. `GROUP BY`는 보통 여러 행을 그룹별로 요약한다.

</details>

## 문제 7 · ERROR 3593

`LAG()`의 결과로 계산한 방문 간격을 바로 `WHERE`에서 거르려니 오류가 난다. 해결 방법은?

<details><summary>정답·설명 확인</summary>

CTE 또는 서브쿼리에서 `LAG`를 계산하고 바깥 쿼리에서 그 결과를 필터링한다.

</details>

## 문제 8 · INNER JOIN의 함정

8,436명 코호트가 사망 정보 테이블과 `INNER JOIN`된 뒤 3,293명만 남았다면 무엇부터 의심해야 할까?

<details><summary>정답·설명 확인</summary>

오른쪽에 사건 기록이 없는 사람이 제외되었을 수 있다. 분석 대상자를 유지해야 하면 `LEFT JOIN`을 검토하고 조인 전후 전체·고유 ID 수를 확인한다. 같은 환자에 중복 행이 있는지도 별도 검산해야 한다.

</details>

## 문제 9 · CASE와 문자값

병기 열에 `'0'`, `'1'`, `'2'`와 `'x'`가 섞여 있다면 어떤 비교가 더 안전할까?

<details><summary>정답·설명 확인</summary>

문자 타입에 맞춰 `IN ('0', '1', '2')`처럼 명시적으로 비교한다. `'x'`와 같은 값을 숫자와 비교하면 묵시적 형변환으로 잘못 분류할 수 있다.

</details>

## 문제 10 · 사건 기록 비율 vs 생존율

3년 이내 사망 기록이 없다는 사실만으로 3년 생존이라고 말할 수 있을까?

<details><summary>정답·설명 확인</summary>

말할 수 없다. 사망 기록이 없는 이유가 추적 중단일 수도 있다. 이 과제의 값은 해당 조건의 **사망 기록 집계**이며, 관찰·추적 상황을 검토하지 않은 생존율 추정과 다르다.

</details>

---

**복습 후 내게 던질 한 가지 질문:** *내가 작성한 SQL을 누군가에게 보여줄 때, 왜 그 조건과 분모를 선택했는지 설명할 수 있을까?*

[개념 복습으로 돌아가기](quick-review.md) · [상세 강의 노트](../deep-notes/day-01-full.md) · [메인으로](../README.md)
