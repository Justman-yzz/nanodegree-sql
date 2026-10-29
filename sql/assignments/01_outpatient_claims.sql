-- ASSIGNMENT 01: 외래 명세서 탐색
-- [출처 상태] 제출한 SQL 원문이 아니라 학습 자료 및 질문을 바탕으로 재구성한 예시
-- [당시 확인] Q1: 2025년 7월 외래 명세서 1,450건
-- [검증 상태] 이번 저장소 제작 시 DB에서 재실행하지 않음
-- 실행 전: kr_claims 교육용 실습 DB를 설치해야 함.

-- Q1 / 확정된 필터 조건
SELECT COUNT(*) AS outpatient_claims
FROM kr_claims.claim
WHERE recu_fr_dd >= '2025-07-01'
  AND recu_fr_dd <  '2025-08-01'
  AND fom_tp_cd = '031';

-- Q2 / 조건을 참고한 학습용 예시. 제출 당시 결과 원문과 다를 수 있음.
-- 7월 외래 진료비 상위 10건에 상병 한글명을 결합한다.
SELECT c.mid, c.recu_fr_dd, c.main_sick, s.krnm,
       c.rvd_rpe_tamt_amt
FROM kr_claims.claim AS c
JOIN kr_claims.sick_master AS s
  ON s.sickcd = c.main_sick
WHERE c.recu_fr_dd >= '2025-07-01'
  AND c.recu_fr_dd < '2025-08-01'
  AND c.fom_tp_cd = '031'
ORDER BY c.rvd_rpe_tamt_amt DESC, c.mid ASC
LIMIT 10;

-- Q3 / 조건을 참고한 학습용 예시. 원래 제출 SQL과 일치한다고 주장하지 않음.
-- 전체 실습 기간의 입원 기록 가운데 입내원일수가 긴 10건 확인
SELECT c.mid, c.recu_fr_dd, c.vst_ddcnt,
       c.main_sick, s.krnm
FROM kr_claims.claim AS c
JOIN kr_claims.sick_master AS s
  ON s.sickcd = c.main_sick
WHERE c.fom_tp_cd = '021'
ORDER BY c.vst_ddcnt DESC, c.mid ASC
LIMIT 10;
