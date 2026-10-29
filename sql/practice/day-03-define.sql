-- SQL 3일차 개념 검증 / 교육용 폐암 합성데이터 기준
-- 제출 과제 원문이 아니며 재실행 여부 미확인.
-- 2010~2019년 진단 코호트의 병기 그룹별 인원 집계
WITH cohort AS (
  SELECT pt_sbst_no, bspt_stag_vl,
         CASE
           WHEN bspt_stag_vl IN ('0','1','2') THEN '초기'
           WHEN bspt_stag_vl = '3' THEN '국소 진행'
           WHEN bspt_stag_vl = '4' THEN '전이'
           ELSE '병기 미상'
         END AS stage_group
  FROM kr_lung_cancer.lung_pt_bsnf
  WHERE bspt_frst_diag_ymd >= '2010-01-01'
    AND bspt_frst_diag_ymd < '2020-01-01'
)
SELECT stage_group, COUNT(*) AS patients
FROM cohort
GROUP BY stage_group
ORDER BY patients DESC;
