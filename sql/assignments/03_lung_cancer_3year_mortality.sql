-- ASSIGNMENT 03 / 2010–2017 병기별 1095일 내 사망 기록 비율
-- [출처 상태] 학습용 재구성 예시: 실제 제출 당시의 원본 SQL이 아님
-- 실습 DB: kr_lung_cancer (교육용 폐암 합성데이터)
-- 이 파일 생성 과정에서 DB에 연결해 실행·검증하지 않았음.

WITH cohort AS (
    SELECT
        pt_sbst_no,
        bspt_frst_diag_ymd AS diagnosis_date,
        CASE
            WHEN bspt_stag_vl IN ('0', '1', '2') THEN '초기'
            WHEN bspt_stag_vl = '3' THEN '국소 진행'
            WHEN bspt_stag_vl = '4' THEN '전이'
            ELSE '병기 미상'
        END AS stage_group
    FROM kr_lung_cancer.lung_pt_bsnf
    WHERE bspt_frst_diag_ymd >= '2010-01-01'
      AND bspt_frst_diag_ymd < '2018-01-01'
),
outcomes AS (
    SELECT
        c.pt_sbst_no,
        c.stage_group,
        CASE
            WHEN d.dead_ymd >= c.diagnosis_date
             AND d.dead_ymd <= DATE_ADD(c.diagnosis_date, INTERVAL 1095 DAY)
            THEN 1 ELSE 0
        END AS dead_3yr
    FROM cohort AS c
    LEFT JOIN kr_lung_cancer.lung_dead_nfrm AS d
      ON c.pt_sbst_no = d.pt_sbst_no
)
SELECT
    stage_group,
    COUNT(*) AS patients,
    SUM(dead_3yr) AS deaths_within_1095d,
    ROUND(100.0 * SUM(dead_3yr) / NULLIF(COUNT(*), 0), 2) AS death_record_pct
FROM outcomes
GROUP BY stage_group
ORDER BY CASE stage_group
    WHEN '초기' THEN 1
    WHEN '국소 진행' THEN 2
    WHEN '전이' THEN 3
    ELSE 4
END;

-- 검수 포인트: cohort는 6,873명이어야 하며
-- LEFT JOIN 직후 환자 수가 바뀌지 않았는지 확인해야 한다.
-- 1,095일 이내 사망 기록 비율 ≠ 중도절단을 반영한 생존분석.
