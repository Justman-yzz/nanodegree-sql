-- SQL 1일차 개념 검증 / 교육용 청구데이터 기준
-- 제출 과제 원문이 아니며 재실행 여부 미확인.
-- 1. 행 수 확인
SELECT COUNT(*) AS claims FROM kr_claims.claim;
-- 2. 외래 2025년 12월 데이터 조건 확인
SELECT COUNT(*) AS outpatient_december
FROM kr_claims.claim
WHERE fom_tp_cd = '031'
  AND recu_fr_dd >= '2025-12-01'
  AND recu_fr_dd < '2026-01-01';
-- 3. 상병 이름 결합
SELECT c.mid, c.main_sick, s.krnm
FROM kr_claims.claim AS c
JOIN kr_claims.sick_master AS s ON s.sickcd = c.main_sick
ORDER BY c.mid
LIMIT 5;
