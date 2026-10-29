-- ASSIGNMENT 02: 상병별 집계 및 당뇨 방문 간격
-- [출처 상태] 학습용 재구성 SQL (원본 제출 SQL 아님)
-- [당시 확인] J209 2,554건 / 894명 / 2.86건, HAVING >= 500 결과 7행,
--             E119 관련 90일 초과 간격 1건(94일)
-- [주의] 이전 과제에서 사용된 전체 기간 및 기타 WHERE 조건은 확보되지 않았으므로
--         아래 예시는 해당 수치 재현을 보장하지 않음.

-- A / 질병코드별 명세서 수와 고유 수진자 수
SELECT c.main_sick, s.krnm,
       COUNT(*) AS claims,
       COUNT(DISTINCT c.jid) AS patients,
       ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT c.jid), 0), 2) AS claims_per_patient
FROM kr_claims.claim AS c
JOIN kr_claims.sick_master AS s
  ON s.sickcd = c.main_sick
GROUP BY c.main_sick, s.krnm
ORDER BY claims DESC;

-- B / 충분한 명세서 수가 있는 상병만
SELECT c.main_sick,
       COUNT(*) AS claims
FROM kr_claims.claim AS c
GROUP BY c.main_sick
HAVING COUNT(*) >= 500
ORDER BY claims DESC;

-- C / 환자별 방문 간격을 계산한 뒤, 간격 90일 초과 방문을 별도 필터링
WITH visits AS (
    SELECT c.jid, c.recu_fr_dd,
           ROW_NUMBER() OVER (
               PARTITION BY c.jid
               ORDER BY c.recu_fr_dd, c.mid
           ) AS visit_no,
           LAG(c.recu_fr_dd) OVER (
               PARTITION BY c.jid
               ORDER BY c.recu_fr_dd, c.mid
           ) AS prev_visit_date
    FROM kr_claims.claim AS c
    WHERE c.main_sick = 'E119'
)
SELECT jid, visit_no, recu_fr_dd, prev_visit_date,
       DATEDIFF(recu_fr_dd, prev_visit_date) AS gap_days
FROM visits
WHERE DATEDIFF(recu_fr_dd, prev_visit_date) > 90
ORDER BY gap_days DESC;
