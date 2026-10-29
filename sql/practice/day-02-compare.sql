-- SQL 2일차 개념 검증 / 교육용 청구데이터 기준
-- 제출 과제 원문이 아니며 재실행 여부 미확인.
-- 1. 종별 명세서·평균 진료비·본인부담률
SELECT t.code_nm,
       COUNT(*) AS claims,
       ROUND(AVG(c.rvd_rpe_tamt_amt)) AS avg_total,
       ROUND(100 * SUM(c.rvd_slf_brdn_amt) /
             NULLIF(SUM(c.rvd_rpe_tamt_amt),0),1) AS self_pct
FROM kr_claims.claim AS c
JOIN kr_claims.institution AS i ON i.yid = c.yid
JOIN kr_claims.code_table AS t
  ON t.code_type = '종별코드' AND t.code = i.cl_cd
GROUP BY t.code_nm
ORDER BY avg_total DESC;

-- 2. 환자별 방문 순번과 직전 방문일
SELECT jid, recu_fr_dd,
       ROW_NUMBER() OVER (PARTITION BY jid ORDER BY recu_fr_dd, mid) AS visit_no,
       LAG(recu_fr_dd) OVER (PARTITION BY jid ORDER BY recu_fr_dd, mid) AS prior_date
FROM kr_claims.claim
WHERE main_sick = 'I109'
ORDER BY jid, visit_no;
