USE [SmartCarePreProd]







	    DECLARE @FROMDATE DATETIME
		DECLARE @ToDate DATETIME
		SET @FROMDATE= '01/01/2022'
		SET @ToDate = '04/01/2022'

        DECLARE @ErrorMessage VARCHAR(MAX) = ''
      
        DECLARE @StartDate DATETIME = @FromDate
        DECLARE @EndDate DATETIME = @ToDate
        DECLARE @CalculateCharge CHAR(1) = 'Y'
        DECLARE @CalculateChargeByCPTCode CHAR(1) = 'N'


            DECLARE @Services INT
            DECLARE @ServicesWithNoUnitsByCoverage INT
            DECLARE @ServicesWithNoUnitsByCharge INT
            DECLARE @ServicesWithNoUnitsByPayment INT

            CREATE TABLE #ClaimLines ( ClaimLineId INT IDENTITY NOT NULL           
                                     , ServiceId INT NULL
                                     , CoveragePlanId INT NULL
                                     , ServiceUnits INT NULL
                                     , BillingCode VARCHAR(15) NULL
                                     , Modifier1 CHAR(2) NULL
                                     , Modifier2 CHAR(2) NULL
                                     , Modifier3 CHAR(2) NULL
                                     , Modifier4 CHAR(2) NULL
                                     , RevenueCode VARCHAR(15) NULL
                                     , RevenueCodeDescription VARCHAR(100) NULL
                                     , ClaimUnits INT NULL )	

            CREATE TABLE #Report ( ClientId INT NULL
                                 , ServiceId INT NULL
                                 , ProgramId INT NULL
                                 , ProcedureCodeId INT NULL
                                 , DateOfService DATETIME NULL
                                 , ServiceUnits INT NULL
                                 , ChargeAmount MONEY NULL
                                 , Subaccount VARCHAR(10) NULL
                                 , CoveragePlanIdByCoverage INT NULL
                                 , CoveragePlanIdByCharge INT NULL
                                 , CoveragePlanIdByPayment INT NULL
								 ,IsCCBHCByCoverage CHAR(1) NULL    -- New CCBHC Field added 3/22/22 mlm
								 ,IsCCBHCByProcedureCode CHAR(1) NULL			-- New CCBHC Field added 3/22/22 mlm
								 ,IsCCBHCByPayment CHAR(1) NULL      -- New CCBHC Field added 3/22/22 mlm
                                 , IsMedicaidByCoverage CHAR(1) NULL
                                 , IsMedicaidByCharge CHAR(1) NULL
                                 , IsMedicaidByPayment CHAR(1) NULL
                                 , IsGFByCoverage CHAR(1) NULL
                                 , IsGFByCharge CHAR(1) NULL
                                 , IsGFByPayment CHAR(1) NULL
                                 , IsABWByCoverage CHAR(1) NULL
                                 , IsABWByCharge CHAR(1) NULL
                                 , IsABWByPayment CHAR(1) NULL
                                 , IsMIChildByCoverage CHAR(1) NULL
                                 , IsMIChildByCharge CHAR(1) NULL
                                 , IsMIChildByPayment CHAR(1) NULL
                                 , IsQHPByCoverage CHAR(1) NULL
                                 , IsQHPByCharge CHAR(1) NULL
                                 , IsQHPByPayment CHAR(1) NULL
                                 , IsPFMedicaidByCoverage CHAR(1) NULL
                                 , -- PF - Pooled Funding
                                   IsPFMedicaidByCharge CHAR(1) NULL
                                 , IsPFMedicaidByPayment CHAR(1) NULL
                                 , IsPFLocalByCoverage CHAR(1) NULL
                                 , IsPFLocalByCharge CHAR(1) NULL
                                 , IsPFLocalByPayment CHAR(1) NULL
                                 , IsAutismMedicaidByCoverage CHAR(1) NULL
                                 , IsAutismMedicaidByCharge CHAR(1) NULL
                                 , IsAutismMedicaidByPayment CHAR(1) NULL
                                 , IsAutismMIChildByCoverage CHAR(1) NULL
                                 , IsAutismMIChildByCharge CHAR(1) NULL
                                 , IsAutismMIChildByPayment CHAR(1) NULL
                                 , IsHealthyMIByCoverage CHAR(1) NULL
                                 , IsHealthyMISUDByCoverage CHAR(1) NULL
                                 , IsMedicaidSUDByCoverage CHAR(1) NULL
                                 , IsABWSUDByCoverage CHAR(1) NULL
                                 , IsMIChildSUDByCoverage CHAR(1) NULL
                                 , IsBlockGrantSUDByCoverage CHAR(1) NULL
                                 , IsChildWaiverByCoverage CHAR(1) NULL
                                 , IsChildWaiverSEDByCoverage CHAR(1) NULL
                                 , IsChildWaiverSEDDHSByCoverage CHAR(1) NULL
                                 , IsOtherByCoverage CHAR(1) NULL
                                 , IsOtherByCharge CHAR(1) NULL
                                 , IsOtherByPayment CHAR(1) NULL
                                 , BillingCodeByCoverage VARCHAR(25) NULL
                                 , BillingCodeByCharge VARCHAR(25) NULL
                                 , BillingCodeByPayment VARCHAR(25) NULL
                                 , UnitsByCoverage DECIMAL(18, 2) NULL
                                 , UnitsByCharge DECIMAL(18, 2) NULL
                                 , UnitsByPayment DECIMAL(18, 2) NULL
                                 , Services INT NULL
                                 , ServicesWithNoUnits INT NULL
                                 , ServiceAreaId INT NULL
                                 , SpendDown CHAR(1)
                                 , SpendDownMet CHAR(1)
                                 , SpendDownDateMet DATETIME )  

            CREATE TABLE #Groups ( GroupId INT IDENTITY
                                               NOT NULL
                                 , Subaccount VARCHAR(10) NULL )

            INSERT INTO #Report
                    ( ClientId
                    ,ServiceId
                    ,ProgramId
                    ,ProcedureCodeId
                    ,DateOfService
                    ,ServiceUnits
                    ,Subaccount
                    ,ServiceAreaId )
                    SELECT s.ClientId
                        ,   s.ServiceId
                        ,   s.ProgramId
                        ,   s.ProcedureCodeId
                        ,   s.DateOfService
                        ,   s.Unit
                        ,   sap.SubAccount
                        ,   p.ServiceAreaId
                        FROM Services s
                            JOIN Programs p ON p.ProgramId = s.ProgramId
                            LEFT JOIN CustomGLSubAccountPrograms sap ON sap.ProgramId = s.ProgramId
                        WHERE s.Billable = 'Y'
                            AND s.Status = 75 -- Completed
							AND s.ProcedureCodeId <> 944 --Added 3.21 per finance request, excludes T1040.
							--AND p.ProgramName not like 'DCO%' --Added 3.21 per finance request to not include services from claims, then removed per 3.28 finance request
                            AND s.DateOfService >= @StartDate
                            AND s.DateOfService < DATEADD(dd, 1, @EndDate)
                            AND ISNULL(s.RecordDeleted, 'N') = 'N'
                            AND EXISTS ( SELECT *
                                            FROM Charges c
                                            WHERE c.ServiceId = s.ServiceId
                                                AND ISNULL(c.RecordDeleted, 'N') = 'N' )
                            AND NOT EXISTS ( SELECT *
                                                FROM CustomUnitsByCostExcludeProcedureCodes e
                                                WHERE e.ProcedureCodeId = s.ProcedureCodeId )

-- Calculate charge
            IF @CalculateCharge = 'Y'
                UPDATE r
                    SET ChargeAmount = c.ChargeAmount
                    FROM #Report r
                        JOIN ( SELECT c.ServiceId
                                ,   SUM(arl.Amount) AS ChargeAmount
                                FROM Charges c
                                    JOIN ARLedger arl ON arl.ChargeId = c.ChargeId
                                WHERE arl.LedgerType IN ( 4201, 4204 )
                                    AND ISNULL(c.RecordDeleted, 'N') = 'N'
                                    AND ISNULL(arl.RecordDeleted, 'N') = 'N'
                                GROUP BY c.ServiceId ) c ON c.ServiceId = r.ServiceId   

--
-- By Coverage Plan
--
--  added new CTE to get coverage plan for CCBHC Bucket  --Added 3/22/22 mlm for finance team request
;
With CTE_CCBHC
	As(SELECT r.ServiceId
                            ,   cap.AccountSubtype
                            ,   ccp.CoveragePlanId
                            ,   ROW_NUMBER() OVER ( PARTITION BY r.ServiceId ORDER BY cch.COBORder ) AS COBOrder
                            FROM #Report r
                                JOIN ClientCoveragePlans ccp ON ccp.ClientId = r.ClientId
                                JOIN ClientCoverageHistory cch ON cch.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                          AND cch.ServiceAreaId = r.ServiceAreaId
                                JOIN CustomGLAccountCoveragePlans cap ON cap.CoveragePlanId = ccp.CoveragePlanId
                                         AND cap.AccountSubtype IN ( 'CCBHC' )
                                JOIN CoveragePlans cp ON cp.CoveragePlanId = ccp.CoveragePlanId

                            WHERE r.DateOfService >= cch.StartDate
                                AND ( r.DateOfService < DATEADD(dd, 1, cch.EndDate)
                                      OR cch.EndDate IS NULL )
                                AND ISNULL(ccp.RecordDeleted, 'N') = 'N')
--Added 3/22/22 mlm 
Update r
Set r.IsCCBHCByCoverage ='Y'
From #Report r
Join CTE_CCBHC as c1 on c1.ServiceId = r.ServiceId

Update r
set r.IsCCBHCByProcedureCode ='Y'
From #Report r
Where r.ProcedureCodeId In(select pc.ProcedureCodeId 
from recodecategories rc join recodes r on rc.RecodeCategoryId=r.RecodeCategoryId
join procedurecodes pc on r.IntegerCodeId=pc.ProcedureCodeId
where CategoryName like '%ccbhc%')
--and procedurecodename not like '%DCO%')

-- Service is Medicaid if there is Medicaid coverage plan that can be used for it
;
            WITH    CTE_Coverage
                      AS ( SELECT r.ServiceId
                            ,   cap.AccountSubtype
                            ,   ccp.CoveragePlanId
                            ,   ROW_NUMBER() OVER ( PARTITION BY r.ServiceId ORDER BY cch.COBORder ) AS COBOrder
                            FROM #Report r
                                JOIN ClientCoveragePlans ccp ON ccp.ClientId = r.ClientId 
                                JOIN ClientCoverageHistory cch ON cch.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                                  AND cch.ServiceAreaId = r.ServiceAreaId
                                JOIN CustomGLAccountCoveragePlans cap ON cap.CoveragePlanId = ccp.CoveragePlanId
                                                                         AND cap.AccountSubtype IN ( 'MEDICAID', 'MEDICAIDSUD', 'MEDAUTISM', 'MEDICAREDUALS' )
                                JOIN CoveragePlans cp ON cp.CoveragePlanId = ccp.CoveragePlanId
                            WHERE r.DateOfService >= cch.StartDate
                                AND ( r.DateOfService < DATEADD(dd, 1, cch.EndDate)
                                      OR cch.EndDate IS NULL )
                                AND ISNULL(ccp.RecordDeleted, 'N') = 'N'
                                AND NOT EXISTS ( SELECT *
                                                    FROM CoveragePlans cp2
                                                        JOIN ClientCoveragePlans ccp2 ON ccp2.CoveragePlanId = cp2.CoveragePlanId
                                                        JOIN ClientCoverageHistory cch2 ON cch2.ClientCoveragePlanId = ccp2.ClientCoveragePlanId
                                                                                           AND cch2.ServiceAreaId = r.ServiceAreaId
                                                    WHERE ccp2.ClientId = r.ClientId
                                                        AND r.DateOfService >= cch2.StartDate
                                                        AND ( r.DateOfService < DATEADD(dd, 1, cch2.EndDate)
                                                              OR cch2.EndDate IS NULL )
                                                AND cch2.COBOrder < cch.COBOrder
                                                        AND ISNULL(ccp2.RecordDeleted, 'N') = 'N'
                                                        AND ISNULL(cch2.RecordDeleted, 'N') = 'N'
                                                        AND ( EXISTS ( SELECT *
                                                                        FROM CustomGLAccountCoveragePlans cap2
                                                                        WHERE cap2.CoveragePlanId = cp2.CoveragePlanId
                                                                            AND cap2.AccountSubtype IN ( 'CHILDWAIVER', 'CHILDWAIVERSED', 'CHILDWAIVERSEDDHS' ) )
                                                              OR EXISTS ( SELECT *
                                                                            FROM CustomQHPCoveragePlans qhp
                                                                            WHERE qhp.CoveragePlanId = cp2.CoveragePlanId ) )
                                                        AND NOT EXISTS ( SELECT *
                                                                            FROM CoveragePlanRules cpr
                                                                            WHERE cpr.CoveragePlanId = ISNULL(CASE WHEN cp2.BillingRulesTemplate = 'O' THEN cp2.UseBillingRulesTemplateId
                                                                                                                   ELSE cp2.CoveragePlanId
                                                                                                              END, cp2.CoveragePlanId)
                                                                                AND cpr.RuleTypeId = 4267
                                                                                AND ISNULL(cpr.RecordDeleted, 'N') = 'N'
                                                                                AND ( cpr.AppliesToAllProcedureCodes = 'Y'
                                                                                      OR EXISTS ( SELECT *
                                                                                                    FROM CoveragePlanRuleVariables cprv
                                                                                                    WHERE cpr.CoveragePlanRuleId = cprv.CoveragePlanRuleId
                                                                                                        AND cprv.ProcedureCodeId = r.ProcedureCodeId
                                                                                                        AND ISNULL(cprv.RecordDeleted, 'N') = 'N' ) ) ) )
                                AND NOT EXISTS ( SELECT *
                                                    FROM CoveragePlanRules cpr
                                                    WHERE cpr.CoveragePlanId = ISNULL(CASE WHEN cp.BillingRulesTemplate = 'O' THEN cp.UseBillingRulesTemplateId
                                                                                           ELSE cp.CoveragePlanId
                                                                                      END, cp.CoveragePlanId)
                                                        AND cpr.RuleTypeId = 4267
                                                        AND ISNULL(cpr.RecordDeleted, 'N') = 'N'
                                                        AND ( cpr.AppliesToAllProcedureCodes = 'Y'
                                                              OR EXISTS ( SELECT *
                                                                            FROM CoveragePlanRuleVariables cprv
                                                                            WHERE cpr.CoveragePlanRuleId = cprv.CoveragePlanRuleId
 AND cprv.ProcedureCodeId = r.ProcedureCodeId
                                                                                AND ISNULL(cprv.RecordDeleted, 'N') = 'N' ) ) )
                                AND ( NOT EXISTS ( SELECT *
                                                    FROM ClientMonthlyDeductibles cmd
                                                    WHERE cmd.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                        AND cmd.DeductibleYear = DATEPART(yy, r.DateOfService)
                                                        AND cmd.DeductibleMonth = DATEPART(mm, r.DateOfService)
                                                        AND ISNULL(cmd.RecordDeleted, 'N') = 'N' )
                                      OR EXISTS ( SELECT *
                                                    FROM ClientMonthlyDeductibles cmd
                                                    WHERE cmd.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                        AND cmd.DeductibleYear = DATEPART(yy, r.DateOfService)
                                                        AND cmd.DeductibleMonth = DATEPART(mm, r.DateOfService)
                                                        AND cmd.DeductibleMet = 'Y'
                                                        AND cmd.DateMet <= CONVERT(DATE, r.DateOfService)
                                                        AND ISNULL(cmd.RecordDeleted, 'N') = 'N' ) ))
                UPDATE r
                    SET CoveragePlanIdByCoverage = c.CoveragePlanId
                    ,   IsAutismMedicaidByCoverage = CASE WHEN c.AccountSubtype = 'MEDAUTISM' THEN 'Y'
                                                          ELSE 'N'
                                                     END
                    ,   IsMedicaidSUDByCoverage = CASE WHEN c.AccountSubtype = 'MEDICAIDSUD' THEN 'Y'
                                                       ELSE 'N'
                                                  END
                    ,   IsMedicaidByCoverage = CASE WHEN c.AccountSubtype IN ( 'MEDICAID', 'MEDICAREDUALS' ) THEN 'Y'
                                                    ELSE 'N'
                                               END
                    FROM #Report r
                        JOIN CTE_Coverage c ON c.ServiceId = r.ServiceId
                                               AND c.COBOrder = 1



-- AG 2022.03.31 added this block, mostly copied from above
-- Now look at active non-Medicaid coverage plans that can be used for the service
-- Choose the highest COB that is not CCBHC Demo plan; choose CCBHC Demo plan if nothing else if available
;
            WITH    CTE_Coverage
                      AS ( SELECT r.ServiceId
                            ,   cap.AccountSubtype
                            ,   ccp.CoveragePlanId
                                ,   ROW_NUMBER() OVER
												(PARTITION BY r.ServiceId 
												ORDER BY ( CASE WHEN ccp.CoveragePlanId = 428 THEN 98 -- Deprioritize CCBHC Demo plan
															WHEN ccp.coverageplanid = 49 THEN 99 -- Deprioritize GF even lower than CCBHC demo plan
															ELSE cch.COBORder END ) 
												) AS COBOrder
                            from #Report r
                                JOIN ClientCoveragePlans ccp ON ccp.ClientId = r.ClientId 
                                JOIN ClientCoverageHistory cch ON cch.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                                  AND cch.ServiceAreaId = r.ServiceAreaId
                                LEFT JOIN CustomGLAccountCoveragePlans cap ON cap.CoveragePlanId = ccp.CoveragePlanId -- AG 2022.03.31 changed to a left join so we don't kick anything that just happens not to be in this table, which we weren't sure who is maintaining
                                JOIN CoveragePlans cp ON cp.CoveragePlanId = ccp.CoveragePlanId
                            WHERE isnull(r.IsMedicaidByCoverage,'N') = 'N' -- AG added 2022-04-04, this is needed so we don't overwrite all the Medicaid records we just looked up in the previous block
								AND r.DateOfService >= cch.StartDate
                                AND ( r.DateOfService < DATEADD(dd, 1, cch.EndDate)
                                      OR cch.EndDate IS NULL )
                                AND ISNULL(ccp.RecordDeleted, 'N') = 'N'
                                AND NOT EXISTS ( SELECT *
                                                    FROM CoveragePlans cp2
                                                        JOIN ClientCoveragePlans ccp2 ON ccp2.CoveragePlanId = cp2.CoveragePlanId
                                                        JOIN ClientCoverageHistory cch2 ON cch2.ClientCoveragePlanId = ccp2.ClientCoveragePlanId
                                                                                           AND cch2.ServiceAreaId = r.ServiceAreaId
                                                    WHERE ccp2.ClientId = r.ClientId
                                                        AND r.DateOfService >= cch2.StartDate
                                                        AND ( r.DateOfService < DATEADD(dd, 1, cch2.EndDate)
                                                              OR cch2.EndDate IS NULL )
                                                AND cch2.COBOrder < cch.COBOrder
                                                        AND ISNULL(ccp2.RecordDeleted, 'N') = 'N'
                                                        AND ISNULL(cch2.RecordDeleted, 'N') = 'N'
                                                        AND ( EXISTS ( SELECT *
                                                                        FROM CustomGLAccountCoveragePlans cap2
                                                                        WHERE cap2.CoveragePlanId = cp2.CoveragePlanId
                                                                            AND cap2.AccountSubtype IN ( 'CHILDWAIVER', 'CHILDWAIVERSED', 'CHILDWAIVERSEDDHS' ) )
                                                              OR EXISTS ( SELECT *
                                                                            FROM CustomQHPCoveragePlans qhp
                                                                            WHERE qhp.CoveragePlanId = cp2.CoveragePlanId ) )
                                                        AND NOT EXISTS ( SELECT *
                                                                            FROM CoveragePlanRules cpr
                                                                            WHERE cpr.CoveragePlanId = ISNULL(CASE WHEN cp2.BillingRulesTemplate = 'O' THEN cp2.UseBillingRulesTemplateId
                                                                                                                   ELSE cp2.CoveragePlanId
                                                                                                              END, cp2.CoveragePlanId)
                                                                                AND cpr.RuleTypeId = 4267
                                                                                AND ISNULL(cpr.RecordDeleted, 'N') = 'N'
                                                                                AND ( cpr.AppliesToAllProcedureCodes = 'Y'
                                                                                      OR EXISTS ( SELECT *
                                                                                                    FROM CoveragePlanRuleVariables cprv
                                                                                                    WHERE cpr.CoveragePlanRuleId = cprv.CoveragePlanRuleId
                                                                                                        AND cprv.ProcedureCodeId = r.ProcedureCodeId
                                                                                                        AND ISNULL(cprv.RecordDeleted, 'N') = 'N' ) ) ) )
                                AND NOT EXISTS ( SELECT *
                                                    FROM CoveragePlanRules cpr
                                                    WHERE cpr.CoveragePlanId = ISNULL(CASE WHEN cp.BillingRulesTemplate = 'O' THEN cp.UseBillingRulesTemplateId
                                                                                           ELSE cp.CoveragePlanId
                                                                                      END, cp.CoveragePlanId)
                                                        AND cpr.RuleTypeId = 4267
                                                        AND ISNULL(cpr.RecordDeleted, 'N') = 'N'
                                                        AND ( cpr.AppliesToAllProcedureCodes = 'Y'
                                                              OR EXISTS ( SELECT *
                                                                            FROM CoveragePlanRuleVariables cprv
                                                                            WHERE cpr.CoveragePlanRuleId = cprv.CoveragePlanRuleId
 AND cprv.ProcedureCodeId = r.ProcedureCodeId
                                                                                AND ISNULL(cprv.RecordDeleted, 'N') = 'N' ) ) )
                                AND ( NOT EXISTS ( SELECT *
                                                    FROM ClientMonthlyDeductibles cmd
                                                    WHERE cmd.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                        AND cmd.DeductibleYear = DATEPART(yy, r.DateOfService)
                                                        AND cmd.DeductibleMonth = DATEPART(mm, r.DateOfService)
                                                        AND ISNULL(cmd.RecordDeleted, 'N') = 'N' )
                                      OR EXISTS ( SELECT *
                                                    FROM ClientMonthlyDeductibles cmd
                                                    WHERE cmd.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                        AND cmd.DeductibleYear = DATEPART(yy, r.DateOfService)
                                                        AND cmd.DeductibleMonth = DATEPART(mm, r.DateOfService)
                                                        AND cmd.DeductibleMet = 'Y'
                                                        AND cmd.DateMet <= CONVERT(DATE, r.DateOfService)
                                                        AND ISNULL(cmd.RecordDeleted, 'N') = 'N' ) ))
                UPDATE r
                    SET CoveragePlanIdByCoverage = c.CoveragePlanId
                    ,   IsAutismMedicaidByCoverage = CASE WHEN c.AccountSubtype = 'MEDAUTISM' THEN 'Y'
                                                          ELSE 'N'
                                                     END
                    ,   IsMedicaidSUDByCoverage = CASE WHEN c.AccountSubtype = 'MEDICAIDSUD' THEN 'Y'
                                                       ELSE 'N'
                                                  END
                    ,   IsMedicaidByCoverage = CASE WHEN c.AccountSubtype IN ( 'MEDICAID', 'MEDICAREDUALS' ) THEN 'Y'
                                                    ELSE 'N'
                                               END
                    FROM #Report r
                        JOIN CTE_Coverage c ON c.ServiceId = r.ServiceId
                                               AND c.COBOrder = 1

												

--  The rest determine based on the first charge instead of the coverage history
--  because IP plans are at the very end of COB order.
-- AG: We don't want to go based on charges that have happened, because CCBHC gets charged 
--   and then we have to wait for response until anything else gets charged
/*
            UPDATE r
                SET CoveragePlanIdByCoverage = ccp.CoveragePlanId
                ,   IsGFByCoverage = CASE WHEN cap.AccountSubtype = 'GF' THEN 'Y'
                                          ELSE 'N'
                                     END
                ,   IsABWByCoverage = CASE WHEN cap.AccountSubtype = 'ABW' THEN 'Y'
                                           ELSE 'N'
                                      END
                ,   IsMIChildByCoverage = CASE WHEN cap.AccountSubtype = 'MICHILD' THEN 'Y'
                                               ELSE 'N'
                                          END
                ,   IsAutismMIChildByCoverage = CASE WHEN cap.AccountSubtype = 'MICHILDAUTISM' THEN 'Y'
                                                     ELSE 'N'
                                                END
                ,   IsQHPByCoverage = CASE WHEN qhp.CoveragePlanId IS NOT NULL THEN 'Y'
                                           ELSE 'N'
                                      END
                ,   IsPFMedicaidByCoverage = CASE WHEN cap.AccountSubtype = 'PFMEDICAID' THEN 'Y'
                                                  ELSE 'N'
                                             END
                ,   IsPFLocalByCoverage = CASE WHEN cap.AccountSubtype = 'PFLOCAL' THEN 'Y'
                                               ELSE 'N'
                                          END
                ,   IsHealthyMIByCoverage = CASE WHEN cap.AccountSubtype = 'HEALTHYMI' THEN 'Y'
                                                 ELSE 'N'
                                            END
                ,   IsHealthyMISUDByCoverage = CASE WHEN cap.AccountSubtype = 'HEALTHYMISUD' THEN 'Y'
                                                    ELSE 'N'
                                               END
                ,   IsABWSUDByCoverage = CASE WHEN cap.AccountSubtype = 'ABWSUD' THEN 'Y'
                                              ELSE 'N'
                                         END
                ,   IsMIChildSUDByCoverage = CASE WHEN cap.AccountSubtype = 'MICHILDSUD' THEN 'Y'
                                                  ELSE 'N'
                                             END
                ,   IsBlockGrantSUDByCoverage = CASE WHEN cap.AccountSubtype = 'BLOCKGRANTSUD' THEN 'Y'
                                                     ELSE 'N'
                                                END
                ,   IsChildWaiverByCoverage = CASE WHEN cap.AccountSubtype = 'CHILDWAIVER' THEN 'Y'
                                                   ELSE 'N'
                                              END
                ,   IsChildWaiverSEDByCoverage = CASE WHEN cap.AccountSubtype = 'CHILDWAIVERSED' THEN 'Y'
                                                      ELSE 'N'
                                                 END
                ,   IsChildWaiverSEDDHSByCoverage = CASE WHEN cap.AccountSubtype = 'CHILDWAIVERSEDDHS' THEN 'Y'
                                                         ELSE 'N'
                                                    END
                ,   IsOtherByCoverage = CASE WHEN qhp.CoveragePlanId IS NULL
                                                  AND cap.CoveragePlanId IS NULL THEN 'Y'
                                             ELSE 'N'
                                        END
                FROM #Report r
                    JOIN Charges c ON c.ServiceId = r.ServiceId 
                    LEFT JOIN ClientCoveragePlans ccp ON ccp.ClientCoveragePlanId = c.ClientCoveragePlanId and ccp.CoveragePlanId <> 428 --Added for testing 3.29 for finance requests.
                    LEFT JOIN CustomQHPCoveragePlans qhp ON qhp.CoveragePlanId = ccp.CoveragePlanId
                    LEFT JOIN CustomGLAccountCoveragePlans cap ON cap.CoveragePlanId = ccp.CoveragePlanId
                                                                  AND cap.AccountSubtype IN ( 'GF', 'ABW', 'MICHILD', 'PFMEDICAID', 'PFLOCAL', 'MICHILDAUTISM', 'HEALTHYMI', 'HEALTHYMISUD', 'ABWSUD', 'MICHILDSUD', 'BLOCKGRANTSUD', 'CHILDWAIVER', 'CHILDWAIVERSED', 'CHILDWAIVERSEDDHS' )
                WHERE ISNULL(r.IsMedicaidByCoverage, 'N') = 'N'
                    AND ISNULL(r.IsAutismMedicaidByCoverage, 'N') = 'N'
                    AND ISNULL(r.IsMedicaidSUDByCoverage, 'N') = 'N'
                    AND ISNULL(c.RecordDeleted, 'N') = 'N'
                    AND EXISTS ( SELECT *
                                    FROM ClientCoverageHistory cch
                                    WHERE cch.ClientCoveragePlanId = c.ClientCoveragePlanId
                                        AND cch.ServiceAreaId = r.ServiceAreaId
                                        AND r.DateOfService >= cch.StartDate
                                        AND ( r.DateOfService < DATEADD(dd, 1, cch.EndDate)
                                              OR cch.EndDate IS NULL )
                                        AND ISNULL(cch.RecordDeleted, 'N') = 'N' )
                    AND EXISTS ( SELECT '*'
                                    FROM ARLedger arl
                                    WHERE arl.ChargeId = c.ChargeId
                                        AND ISNULL(arl.RecordDeleted, 'N') = 'N'
                                    GROUP BY arl.ChargeId
                             HAVING SUM(CASE WHEN arl.LedgerType IN ( 4201, 4204 ) THEN arl.Amount
                                                    ELSE 0
                                               END) <> 0 ) -- Charges, Trasfers
                    AND NOT EXISTS ( SELECT *
                                        FROM Charges c2
										join ClientCoveragePlans as ccp2 on c2.ClientCoveragePlanId = ccp2.ClientCoveragePlanId
                                        WHERE c2.ServiceId = r.ServiceId
											AND ccp2.CoveragePlanId <> 428
                                            AND ISNULL(c2.RecordDeleted, 'N') = 'N'
                                            AND CASE WHEN c2.Priority = 0 THEN 999
                                                     ELSE c2.Priority
                                                END < CASE WHEN c.Priority = 0 THEN 999
                                                           ELSE c.Priority
                                                      END
                                            AND EXISTS ( SELECT '*'
                                                            FROM ARLedger arl2
                                                            WHERE arl2.ChargeId = c2.ChargeId
                                                                AND ISNULL(arl2.RecordDeleted, 'N') = 'N'
                                                            GROUP BY arl2.ChargeId
                                                            HAVING SUM(CASE WHEN arl2.LedgerType IN ( 4201, 4204 ) THEN arl2.Amount
                                                                            ELSE 0
                                                                       END) <> 0 ) );
 
 
				WITH    CTE_Coverage
                          AS ( SELECT r.ServiceId
                                ,   CASE WHEN qhp.CoveragePlanId IS NOT NULL THEN 'QHP'
                                         ELSE cap.AccountSubtype
                                    END AS AccountSubtype
                                ,   ccp.CoveragePlanId
                                ,   ROW_NUMBER() OVER 
												(PARTITION BY r.ServiceId 
												ORDER BY ( CASE WHEN ccp.CoveragePlanId = 428 THEN 98
															WHEN ccp.coverageplanid = 49 THEN 99
															ELSE cch.COBORder END ) 
												) AS COBOrder
                                FROM #Report r
                                    JOIN ClientCoveragePlans ccp ON ccp.ClientId = r.ClientId --AND CCP.CoveragePlanId <> 428 --Modified 3.29 adding ccbhc cov plan exclusion per finance team request.
                                    JOIN ClientCoverageHistory cch ON cch.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                                      AND cch.ServiceAreaId = r.ServiceAreaId
                                    LEFT JOIN CustomQHPCoveragePlans qhp ON qhp.CoveragePlanId = ccp.CoveragePlanId
                                    LEFT JOIN CustomGLAccountCoveragePlans cap ON cap.CoveragePlanId = ccp.CoveragePlanId
                                                                                  AND cap.AccountSubtype IN ( 'GF', 'ABW', 'MICHILD', 'PFMEDICAID', 'PFLOCAL', 'MICHILDAUTISM', 'HEALTHYMI', 'HEALTHYMISUD', 'ABWSUD', 'MICHILDSUD', 'BLOCKGRANTSUD', 'CHILDWAIVER', 'CHILDWAIVERSED', 'CHILDWAIVERSEDDHS')
                                    JOIN CoveragePlans cp ON cp.CoveragePlanId = ccp.CoveragePlanId
                                WHERE r.DateOfService >= cch.StartDate
                                    AND ( r.DateOfService < DATEADD(dd, 1, cch.EndDate)
                                          OR cch.EndDate IS NULL )
                                    AND ISNULL(ccp.RecordDeleted, 'N') = 'N'
                                    AND ISNULL(cch.RecordDeleted, 'N') = 'N'
                                    AND NOT EXISTS ( SELECT *
                                                        FROM CoveragePlanRules cpr
                                                        WHERE cpr.CoveragePlanId = ISNULL(CASE WHEN cp.BillingRulesTemplate = 'O' THEN cp.UseBillingRulesTemplateId
                                                                                               ELSE cp.CoveragePlanId
                         END, cp.CoveragePlanId)
                                                            AND cpr.RuleTypeId = 4267
                                                            AND ISNULL(cpr.RecordDeleted, 'N') = 'N'
                                                            AND ( cpr.AppliesToAllProcedureCodes = 'Y'
                                                                  OR EXISTS ( SELECT *
                                                                                FROM CoveragePlanRuleVariables cprv
                                                                                WHERE cpr.CoveragePlanRuleId = cprv.CoveragePlanRuleId
                                                                                    AND cprv.ProcedureCodeId = r.ProcedureCodeId
                                                                                    AND ISNULL(cprv.RecordDeleted, 'N') = 'N' ) ) )
                                    AND ( NOT EXISTS ( SELECT *
                                                        FROM ClientMonthlyDeductibles cmd
                                                        WHERE cmd.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                            AND cmd.DeductibleYear = DATEPART(yy, r.DateOfService)
                                                            AND cmd.DeductibleMonth = DATEPART(mm, r.DateOfService)
                                                            AND ISNULL(cmd.RecordDeleted, 'N') = 'N' )
                                          OR EXISTS ( SELECT *
                                                        FROM ClientMonthlyDeductibles cmd
                                                        WHERE cmd.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                            AND cmd.DeductibleYear = DATEPART(yy, r.DateOfService)
                                                            AND cmd.DeductibleMonth = DATEPART(mm, r.DateOfService)
                                                            AND cmd.DeductibleMet = 'Y'
                                                            AND cmd.DateMet <= CONVERT(DATE, r.DateOfService)
                                                            AND ISNULL(cmd.RecordDeleted, 'N') = 'N' ) ))
                UPDATE r
                    SET CoveragePlanIdByCoverage = c.CoveragePlanId
                    ,   IsGFByCoverage = CASE WHEN c.AccountSubtype = 'GF' THEN 'Y'
                                              ELSE 'N'
                                         END
                    ,   IsABWByCoverage = CASE WHEN c.AccountSubtype = 'ABW' THEN 'Y'
                                               ELSE 'N'
                                          END
                    ,   IsMIChildByCoverage = CASE WHEN c.AccountSubtype = 'MICHILD' THEN 'Y'
                                                   ELSE 'N'
                                              END
                    ,   IsAutismMIChildByCoverage = CASE WHEN c.AccountSubtype = 'MICHILDAUTISM' THEN 'Y'
                                                         ELSE 'N'
                                                    END
                    ,   IsQHPByCoverage = CASE WHEN c.AccountSubtype = 'QHP' THEN 'Y'
                                               ELSE 'N'
                                          END
                    ,   IsPFMedicaidByCoverage = CASE WHEN c.AccountSubtype = 'PFMEDICAID' THEN 'Y'
                                                      ELSE 'N'
                                                 END
                    ,   IsPFLocalByCoverage = CASE WHEN c.AccountSubtype = 'PFLOCAL' THEN 'Y'
                                                   ELSE 'N'
                                              END
                    ,   IsHealthyMIByCoverage = CASE WHEN c.AccountSubtype = 'HEALTHYMI' THEN 'Y'
                                             ELSE 'N'
                                                END
                    ,   IsHealthyMISUDByCoverage = CASE WHEN c.AccountSubtype = 'HEALTHYMISUD' THEN 'Y'
                                                        ELSE 'N'
                                                   END
                    ,   IsABWSUDByCoverage = CASE WHEN c.AccountSubtype = 'ABWSUD' THEN 'Y'
                                                  ELSE 'N'
                                             END
                    ,   IsMIChildSUDByCoverage = CASE WHEN c.AccountSubtype = 'MICHILDSUD' THEN 'Y'
                                                      ELSE 'N'
                                                 END
                    ,   IsBlockGrantSUDByCoverage = CASE WHEN c.AccountSubtype = 'BLOCKGRANTSUD' THEN 'Y'
                                                         ELSE 'N'
                                                    END
                    ,   IsChildWaiverByCoverage = CASE WHEN c.AccountSubtype = 'CHILDWAIVER' THEN 'Y'
                                                       ELSE 'N'
                                                  END
                    ,   IsChildWaiverSEDByCoverage = CASE WHEN c.AccountSubtype = 'CHILDWAIVERSED' THEN 'Y'
                                                          ELSE 'N'
                                                     END
                    ,   IsChildWaiverSEDDHSByCoverage = CASE WHEN c.AccountSubtype = 'CHILDWAIVERSEDDHS' THEN 'Y'
                                                             ELSE 'N'
                                                        END
                    ,   IsOtherByCoverage = CASE WHEN c.AccountSubtype IS NULL THEN 'Y'
                                                 ELSE 'N'
                                            END
                    FROM #Report r
                        JOIN CTE_Coverage c ON c.ServiceId = r.ServiceId
                                               AND c.COBOrder = 1
                    WHERE ISNULL(r.IsMedicaidByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsAutismMedicaidByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsMedicaidSUDByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsGFByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsABWByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsMIChildByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsAutismMIChildByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsQHPByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsPFMedicaidByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsPFLocalByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsHealthyMIByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsHealthyMISUDByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsABWSUDByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsMIChildSUDByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsBlockGrantSUDByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsChildWaiverByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsChildWaiverSEDByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsChildWaiverSEDDHSByCoverage, 'N') = 'N'
                        AND ISNULL(r.IsOtherByCoverage, 'N') = 'N'
*/

            UPDATE #Report
                SET IsOtherByCoverage = 'Y'
                WHERE ISNULL(IsMedicaidByCoverage, 'N') = 'N'
                    AND ISNULL(IsAutismMedicaidByCoverage, 'N') = 'N'
                    AND ISNULL(IsMedicaidSUDByCoverage, 'N') = 'N'
                    AND ISNULL(IsGFByCoverage, 'N') = 'N'
                    AND ISNULL(IsABWByCoverage, 'N') = 'N'
                    AND ISNULL(IsMIChildByCoverage, 'N') = 'N'
                    AND ISNULL(IsAutismMIChildByCoverage, 'N') = 'N'
                    AND ISNULL(IsQHPByCoverage, 'N') = 'N'
                    AND ISNULL(IsPFMedicaidByCoverage, 'N') = 'N'
                    AND ISNULL(IsPFLocalByCoverage, 'N') = 'N'
                    AND ISNULL(IsHealthyMIByCoverage, 'N') = 'N'
                    AND ISNULL(IsHealthyMISUDByCoverage, 'N') = 'N'
                    AND ISNULL(IsABWSUDByCoverage, 'N') = 'N'
                    AND ISNULL(IsMIChildSUDByCoverage, 'N') = 'N'
                    AND ISNULL(IsBlockGrantSUDByCoverage, 'N') = 'N'
                    AND ISNULL(IsChildWaiverByCoverage, 'N') = 'N'
                    AND ISNULL(IsChildWaiverSEDByCoverage, 'N') = 'N'
                    AND ISNULL(IsChildWaiverSEDDHSByCoverage, 'N') = 'N'
                    AND ISNULL(IsOtherByCoverage, 'N') = 'N'
  

-- AG 2022.03.31 : Block for testing/diagnosing problems at this point
-- Shows all COB's
/*
Select r.ClientId, r.ServiceId, r.DateOfService
	, r.IsCCBHCByCoverage, r.IsCCBHCByProcedureCode
	, ccp.CoveragePlanId, cp.CoveragePlanName, COBNumber = 'COB' + cast(cch.COBOrder as char)
	, r.CoveragePlanIdByCoverage
from #Report as r
left join [ClientCoveragePlans] as ccp on r.ClientId = ccp.ClientId
left join [CoveragePlans] as cp on ccp.CoveragePlanId = cp.CoveragePlanId
left join [ClientCoverageHistory] as cch
	on ccp.ClientCoveragePlanId = cch.ClientCoveragePlanId
	and cch.StartDate <= r.DateOfService and ( r.DateOfService < cch.EndDate or cch.EndDate is null )
	and isnull(cch.RecordDeleted,'N') = 'N'
left join [Charges] as ch
	on r.ServiceId = ch.ServiceId
	and ccp.ClientCoveragePlanId = ch.ClientCoveragePlanId
	and isnull(ch.RecordDeleted,'N') = 'N'
where --r.CoveragePlanIdByCoverage is null
cch.ClientCoverageHistoryId is not null
order by r.ServiceId, 'COB' + cast(cch.COBOrder as char), ch.Priority

Select * from #Report where CoveragePlanIdByCoverage is null
*/	

--
-- By Charge
--

            UPDATE r
                SET CoveragePlanIdByCharge = ccp.CoveragePlanId
                ,   IsMedicaidByCharge = CASE WHEN cap.AccountSubtype = 'MEDICAID' THEN 'Y'
                                              ELSE 'N'
                                         END
                ,   IsAutismMedicaidByCharge = CASE WHEN cap.AccountSubtype = 'MEDAUTISM' THEN 'Y'
                                                    ELSE 'N'
                                               END
                ,   IsGFByCharge = CASE WHEN cap.AccountSubtype = 'GF' THEN 'Y'
                                        ELSE 'N'
                                   END
                ,   IsABWByCharge = CASE WHEN cap.AccountSubtype = 'ABW' THEN 'Y'
                                         ELSE 'N'
                                    END
                ,   IsMIChildByCharge = CASE WHEN cap.AccountSubtype = 'MICHILD' THEN 'Y'
                                             ELSE 'N'
                                        END
                ,   IsAutismMIChildByCharge = CASE WHEN cap.AccountSubtype = 'MICHILDAUTISM' THEN 'Y'
                                                   ELSE 'N'
                                              END
                ,   IsQHPByCharge = CASE WHEN qhp.CoveragePlanId IS NOT NULL THEN 'Y'
                                         ELSE 'N'
                                    END
                ,   IsPFMedicaidByCharge = CASE WHEN cap.AccountSubtype = 'PFMEDICAID' THEN 'Y'
                                                ELSE 'N'
                                           END
                ,   IsPFLocalByCharge = CASE WHEN cap.AccountSubtype = 'PFLOCAL' THEN 'Y'
                                             ELSE 'N'
                                        END
                ,   IsOtherByCharge = CASE WHEN qhp.CoveragePlanId IS NULL
                                                AND cap.CoveragePlanId IS NULL THEN 'Y'
                                           ELSE 'N'
                                      END
                FROM #Report r
                    JOIN Charges c ON c.ServiceId = r.ServiceId
                    LEFT JOIN ClientCoveragePlans ccp ON ccp.ClientCoveragePlanId = c.ClientCoveragePlanId
                    LEFT JOIN CustomGLAccountCoveragePlans cap ON cap.CoveragePlanId = ccp.CoveragePlanId
                                                                  AND cap.AccountSubtype IN ( 'MEDAUTISM', 'MEDICAID', 'GF', 'ABW', 'MICHILD', 'PFMEDICAID', 'PFLOCAL', 'MICHILDAUTISM' )
                    LEFT JOIN CustomQHPCoveragePlans qhp ON qhp.CoveragePlanId = ccp.CoveragePlanId
                WHERE ISNULL(c.RecordDeleted, 'N') = 'N'
                    AND EXISTS ( SELECT '*'
                                    FROM ARLedger arl
                                    WHERE arl.ChargeId = c.ChargeId
                                        AND ISNULL(arl.RecordDeleted, 'N') = 'N'
                                    GROUP BY arl.ChargeId
                                    HAVING SUM(CASE WHEN arl.LedgerType IN ( 4201, 4204 ) THEN Amount
     ELSE 0
                                               END) <> 0 -- Charges, Trasfers
                                        OR SUM(CASE WHEN arl.LedgerType IN ( 4202 ) THEN Amount
                                                    ELSE 0
                                               END) <> 0 -- Payments
                                        OR SUM(CASE WHEN arl.LedgerType IN ( 4203 ) THEN Amount
                                                    ELSE 0
                                               END) <> 0 ) -- Adjustments
                    AND NOT EXISTS ( SELECT *
                                        FROM Charges c2
                                            LEFT JOIN ClientCoveragePlans ccp2 ON ccp2.ClientCoveragePlanId = c2.ClientCoveragePlanId
                                            LEFT JOIN CustomGLAccountCoveragePlans cap2 ON cap2.CoveragePlanId = ccp2.CoveragePlanId
                                                                                           AND cap2.AccountSubtype IN ( 'MEDAUTISM', 'MEDICAID', 'GF', 'ABW', 'MICHILD', 'PFMEDICAID', 'PFLOCAL', 'MICHILDAUTISM' )
                                        WHERE c2.ServiceId = r.ServiceId
                                            AND ISNULL(c2.RecordDeleted, 'N') = 'N'
                                            AND CASE WHEN cap2.AccountSubtype = 'MEDICAID' THEN -1
                                                     WHEN c2.Priority = 0 THEN 999
                                                     ELSE c2.Priority
                                                END < CASE WHEN cap.AccountSubtype = 'MEDICAID' THEN -1
                                                           WHEN c.Priority = 0 THEN 999
                                                           ELSE c.Priority
                                                      END
                                            AND EXISTS ( SELECT '*'
                                                            FROM ARLedger arl
                                                            WHERE arl.ChargeId = c2.ChargeId
                                                                AND ISNULL(arl.RecordDeleted, 'N') = 'N'
                                                            GROUP BY arl.ChargeId
                                                            HAVING SUM(CASE WHEN arl.LedgerType IN ( 4201, 4204 ) THEN Amount
                                                                            ELSE 0
                                                                       END) <> 0 -- Charges, Trasfers
                                                                OR SUM(CASE WHEN arl.LedgerType IN ( 4202 ) THEN Amount
                                                                            ELSE 0
                                                                       END) <> 0 -- Payments
                                                                OR SUM(CASE WHEN arl.LedgerType IN ( 4203 ) THEN Amount
                                                                            ELSE 0
                                                                       END) <> 0 ) -- Adjustments
                  )


--
-- By Payment
--

            UPDATE r
                SET CoveragePlanIdByPayment = ccp.CoveragePlanId
                ,   IsMedicaidByPayment = CASE WHEN cap.AccountSubtype = 'MEDICAID' THEN 'Y'
                                               ELSE 'N'
                                          END
                ,   IsAutismMedicaidByPayment = CASE WHEN cap.AccountSubtype = 'MEDAUTISM' THEN 'Y'
                                                     ELSE 'N'
                                                END
                ,   IsGFByPayment = CASE WHEN cap.AccountSubtype = 'GF' THEN 'Y'
                                         ELSE 'N'
                                    END
                ,   IsABWByPayment = CASE WHEN cap.AccountSubtype = 'ABW' THEN 'Y'
                                          ELSE 'N'
                                     END
                ,   IsMIChildByPayment = CASE WHEN cap.AccountSubtype = 'MICHILD' THEN 'Y'
                                              ELSE 'N'
                                         END
                ,   IsAutismMIChildByPayment = CASE WHEN cap.AccountSubtype = 'MICHILDAUTISM' THEN 'Y'
                                                    ELSE 'N'
                                               END
                ,   IsQHPByPayment = CASE WHEN qhp.CoveragePlanId IS NOT NULL THEN 'Y'
                                          ELSE 'N'
                                     END
                ,   IsPFMedicaidByPayment = CASE WHEN cap.AccountSubtype = 'PFMEDICAID' THEN 'Y'
                                                 ELSE 'N'
                                            END
                ,   IsPFLocalByPayment = CASE WHEN cap.AccountSubtype = 'PFLOCAL' THEN 'Y'
                                              ELSE 'N'
                                         END
                ,   IsOtherByPayment = CASE WHEN qhp.CoveragePlanId IS NULL
                                                 AND cap.CoveragePlanId IS NULL THEN 'Y'
                                            ELSE 'N'
                                       END
                FROM #Report r
                    JOIN Charges c ON c.ServiceId = r.ServiceId
                    JOIN ( SELECT ChargeId
                            FROM ARLedger
                            WHERE LedgerType = 4202 -- Payment
                                AND ISNULL(RecordDeleted, 'N') = 'N'
                            GROUP BY ChargeId
                            HAVING SUM(Amount) < 0 ) l ON l.ChargeId = c.ChargeId
                    LEFT JOIN ClientCoveragePlans ccp ON ccp.ClientCoveragePlanId = c.ClientCoveragePlanId
                    LEFT JOIN CustomGLAccountCoveragePlans cap ON cap.CoveragePlanId = ccp.CoveragePlanId
                                                                  AND cap.AccountSubtype IN ( 'MEDAUTISM', 'MEDICAID', 'GF', 'ABW', 'MICHILD', 'PFMEDICAID', 'PFLOCAL', 'MICHILDAUTISM' )
                    LEFT JOIN CustomQHPCoveragePlans qhp ON qhp.CoveragePlanId = ccp.CoveragePlanId
                WHERE ISNULL(c.RecordDeleted, 'N') = 'N'
                    AND NOT EXISTS ( SELECT *
                                        FROM Charges c2
                                            JOIN ( SELECT ChargeId
                                                    FROM ARLedger
                                                    WHERE LedgerType = 4202
                                                        AND ISNULL(RecordDeleted, 'N') = 'N'
                                                    GROUP BY ChargeId
                                                    HAVING SUM(Amount) < 0 ) l2 ON l2.ChargeId = c2.ChargeId
                                            LEFT JOIN ClientCoveragePlans ccp2 ON ccp2.ClientCoveragePlanId = c2.ClientCoveragePlanId
                                            LEFT JOIN CustomGLAccountCoveragePlans cap2 ON cap2.CoveragePlanId = ccp2.CoveragePlanId
                                                                                           AND cap2.AccountSubtype IN ( 'MEDAUTISM', 'MEDICAID', 'GF', 'ABW', 'MICHILD', 'PFMEDICAID', 'PFLOCAL', 'MICHILDAUTISM' )
                                        WHERE c2.ServiceId = r.ServiceId
                                            AND ISNULL(c2.RecordDeleted, 'N') = 'N'
                                            AND CASE WHEN cap2.AccountSubtype = 'MEDICAID' THEN -1
                                                     WHEN c2.Priority = 0 THEN 999
                                                     ELSE c2.Priority
                                                END < CASE WHEN cap.AccountSubtype = 'MEDICAID' THEN -1
                                                    WHEN c.Priority = 0 THEN 999
                                                           ELSE c.Priority
                                                      END )

--
-- Calculate units
--

            INSERT INTO #ClaimLines
                    ( ServiceId
                    ,CoveragePlanId
                    ,ServiceUnits )
                    SELECT ServiceId
                        ,   CoveragePlanIdByCoverage
                        ,   ServiceUnits
                        FROM #Report

            INSERT INTO #ClaimLines
                    ( ServiceId
                    ,CoveragePlanId
                    ,ServiceUnits )
                    SELECT r.ServiceId
                        ,   ccp.CoveragePlanId
                        ,   r.ServiceUnits
                        FROM #Report r
                            JOIN Charges c ON c.ServiceId = r.ServiceId
                            JOIN ClientCoveragePlans ccp ON ccp.ClientCoveragePlanId = c.ClientCoveragePlanId
                        WHERE NOT EXISTS ( SELECT *
                                            FROM #ClaimLines cl
                                            WHERE cl.ServiceId = r.ServiceId
                                                AND cl.CoveragePlanId = ccp.CoveragePlanId )
                    UNION
                    SELECT r.ServiceId
                        ,   NULL
                        ,   r.ServiceUnits
                        FROM #Report r

            EXEC ssp_PMClaimsGetBillingCodes

            UPDATE r
                SET BillingCodeByCoverage = cl.BillingCode
                ,   UnitsByCoverage = cl.ClaimUnits
                FROM #Report r
                    JOIN #ClaimLines cl ON cl.ServiceId = r.ServiceId
                                           AND cl.CoveragePlanId = r.CoveragePlanIdByCoverage

            UPDATE r
                SET BillingCodeByCharge = cl.BillingCode
                ,   UnitsByCharge = cl.ClaimUnits
                FROM #Report r
                    JOIN #ClaimLines cl ON cl.ServiceId = r.ServiceId
                                           AND cl.CoveragePlanId = r.CoveragePlanIdByCharge
    
            UPDATE r
                SET BillingCodeByPayment = cl.BillingCode
                ,   UnitsByPayment = cl.ClaimUnits
                FROM #Report r
                    JOIN #ClaimLines cl ON cl.ServiceId = r.ServiceId
                                           AND cl.CoveragePlanId = r.CoveragePlanIdByPayment

            UPDATE r
                SET BillingCodeByCoverage = BillingCodeByCharge
                ,   UnitsByCoverage = UnitsByCharge
                FROM #Report r
                WHERE BillingCodeByCoverage IS NULL
                    AND BillingCodeByCharge IS NOT NULL

            UPDATE r
                SET BillingCodeByCoverage = BillingCodeByPayment
                ,   UnitsByCoverage = UnitsByPayment
                FROM #Report r
                WHERE BillingCodeByCoverage IS NULL
                    AND BillingCodeByPayment IS NOT NULL

            UPDATE r
                SET BillingCodeByCoverage = cl.BillingCode
                ,   UnitsByCoverage = cl.ClaimUnits
                FROM #Report r
                    JOIN #ClaimLines cl ON cl.ServiceId = r.ServiceId
                                           AND cl.CoveragePlanId IS NULL
                WHERE r.BillingCodeByCoverage IS NULL
                    AND cl.BillingCode IS NOT NULL

            UPDATE r
                SET BillingCodeByCoverage = c.BillingCode
                ,   UnitsByCoverage = c.Units
                FROM #Report r
                    JOIN Charges c ON c.ServiceId = r.ServiceId
                WHERE BillingCodeByCoverage IS NULL
                    AND c.BillingCode IS NOT NULL
                    AND ISNULL(c.RecordDeleted, 'N') = 'N'
      
-- Remove all J codes from the report
            DELETE FROM #Report
                WHERE ( BillingCodeByCoverage LIKE 'J%'
                        OR BillingCodeByCharge LIKE 'J%'
                        OR BillingCodeByPayment LIKE 'J%' )

            SELECT @Services = COUNT(*)
                ,   @ServicesWithNoUnitsByCoverage = SUM(CASE WHEN UnitsByCoverage IS NULL THEN 1
                                                              ELSE 0
                                                         END)
                ,   @ServicesWithNoUnitsByCharge = SUM(CASE WHEN UnitsByCharge IS NULL
                                                                 AND ( IsMedicaidByCharge = 'Y'
                                                                       OR IsGFByCharge = 'Y'
                                                                       OR IsABWByCharge = 'Y'
                                                                       OR IsMIChildByCharge = 'Y'
                                                                       OR IsQHPByCharge = 'Y'
                                                                       OR IsPFMedicaidByCharge = 'Y'
                                                                       OR IsPFLocalByCharge = 'Y'
                                                                       OR IsOtherByCharge = 'Y'
                                                                       OR IsAutismMedicaidByCharge = 'Y'
                                                                       OR IsAutismMIChildByCharge = 'Y' ) THEN 1
                                                            ELSE 0
                                                       END)
                ,   @ServicesWithNoUnitsByPayment = SUM(CASE WHEN UnitsByPayment IS NULL
                                                                  AND ( IsMedicaidByPayment = 'Y'
                                                                        OR IsGFByPayment = 'Y'
                                                                        OR IsABWByPayment = 'Y'
                                                                        OR IsMIChildByPayment = 'Y'
                                                                        OR IsQHPByPayment = 'Y'
                                                                        OR IsPFMedicaidByPayment = 'Y'
                                                                        OR IsPFLocalByPayment = 'Y'
                                                                        OR IsOtherByPayment = 'Y'
                                                                        OR IsAutismMedicaidByPayment = 'Y'
                                                                        OR IsAutismMIChildByPayment = 'Y' ) THEN 1
                                                             ELSE 0
                                                        END)
                FROM #Report

            UPDATE r
                SET SpendDown = 'Y'
                ,   SpendDownMet = cmd.DeductibleMet
                ,   SpendDownDateMet = cmd.DateMet
                FROM #Report r
                    JOIN ClientCoveragePlans ccp ON ccp.ClientId = r.ClientId
                    JOIN ClientCoverageHistory cch ON cch.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                                                      AND cch.ServiceAreaId = r.ServiceAreaId
                    JOIN CustomGLAccountCoveragePlans cap ON cap.CoveragePlanId = ccp.CoveragePlanId
                                                             AND cap.AccountSubtype IN ( 'MEDICAID', 'MEDICAIDSUD', 'MEDAUTISM', 'MEDICAREDUALS' )
                    JOIN CoveragePlans cp ON cp.CoveragePlanId = ccp.CoveragePlanId
                    JOIN ClientMonthlyDeductibles cmd ON cmd.ClientCoveragePlanId = ccp.ClientCoveragePlanId
                WHERE r.DateOfService >= cch.StartDate
                    AND ( r.DateOfService < DATEADD(dd, 1, cch.EndDate)
                          OR cch.EndDate IS NULL )
                    AND cmd.DeductibleYear = DATEPART(yy, r.DateOfService)
                    AND cmd.DeductibleMonth = DATEPART(mm, r.DateOfService)
                    AND ISNULL(cmd.RecordDeleted, 'N') = 'N'
                    AND ISNULL(ccp.RecordDeleted, 'N') = 'N'
                    AND ISNULL(cch.RecordDeleted, 'N') = 'N'
                    AND NOT EXISTS ( SELECT *
                                        FROM CoveragePlanRules cpr
                                        WHERE cpr.CoveragePlanId = ISNULL(CASE WHEN cp.BillingRulesTemplate = 'O' THEN cp.UseBillingRulesTemplateId
                                                                               ELSE cp.CoveragePlanId
                                                                          END, cp.CoveragePlanId)
                                            AND cpr.RuleTypeId = 4267
                                            AND ISNULL(cpr.RecordDeleted, 'N') = 'N'
                                            AND ( cpr.AppliesToAllProcedureCodes = 'Y'
                                                  OR EXISTS ( SELECT *
                                                                FROM CoveragePlanRuleVariables cprv
                                                                WHERE cpr.CoveragePlanRuleId = cprv.CoveragePlanRuleId
                                                                    AND cprv.ProcedureCodeId = r.ProcedureCodeId
                                                                    AND ISNULL(cprv.RecordDeleted, 'N') = 'N' ) ) )   
                                     
            SELECT p.ProgramName
                ,   ISNULL(r.Subaccount, 'Unknown') AS Account
                ,   r.ServiceId
                ,   r.ClientId
                ,   r.DateOfService
                ,   r.BillingCodeByCoverage
                ,   pc.DisplayAs AS ProcedureName
                ,   cp.DisplayAs AS CoveragePlan
                ,   r.UnitsByCoverage AS Units
                ,   r.ChargeAmount
                ,   CASE WHEN r.IsCCBHCByCoverage = 'Y'  AND r.IsCCBHCByProcedureCode = 'Y'  THEN 'CCBHC'
                         WHEN r.CoveragePlanIdByCoverage IN (308,309,310,311,320,376,389) AND r.IsCCBHCByCoverage = 'Y' THEN 'HMP' <--POW worked like a charm
						 WHEN r.CoveragePlanIdByCoverage IN (308,309,310,311,320,376,389) AND r.IsCCBHCByProcedureCode = 'Y' THEN 'HMP' <-- Pow worked like a charm
						 WHEN r.IsMedicaidByCoverage = 'Y' THEN 'Medicaid'
                         WHEN r.IsAutismMedicaidByCoverage = 'Y' THEN 'Autism Medicaid'
                         WHEN r.IsMedicaidSUDByCoverage = 'Y' THEN 'Medicaid SUD'
                         WHEN r.IsGFByCoverage = 'Y' THEN 'GF'
                         WHEN r.IsABWByCoverage = 'Y' THEN 'ABW'
                         WHEN r.IsMIChildByCoverage = 'Y' THEN 'MI Child'
                         WHEN r.IsAutismMIChildByCoverage = 'Y' THEN 'Autism MI Child'
                         WHEN r.IsQHPByCoverage = 'Y' THEN 'QHP'
                         WHEN r.IsHealthyMIByCoverage = 'Y' THEN 'Healthy MI'
                         WHEN r.IsHealthyMISUDByCoverage = 'Y' THEN 'Healthy MI SUD'
                         WHEN r.IsABWSUDByCoverage = 'Y' THEN 'ABW SUD'
                         WHEN r.IsMIChildSUDByCoverage = 'Y' THEN 'MI Child SUD'
                         WHEN r.IsBlockGrantSUDByCoverage = 'Y' THEN 'Block Grant SUD'
                         WHEN r.IsOtherByCoverage = 'Y' THEN 'Other' --> Here is other, when they don't meet the earlier requirements
                         WHEN r.IsChildWaiverByCoverage = 'Y' THEN 'Children Waiver'
                         WHEN r.IsChildWaiverSEDByCoverage = 'Y' THEN 'Children Waiver SED'
                         WHEN r.IsChildWaiverSEDDHSByCoverage = 'Y' THEN 'Children Waiver SED DHS'
                    END AS UBCCBucket
                ,   ISNULL(r.SpendDown, 'N') AS Spenddown
                ,   r.SpendDownMet
                ,   r.SpendDownDateMet
				,	ST.FirstName + ' ' + ST.LastName AS ClinicianName
				--,	CHWB.Modifier1 AS Mod1
				--,	CHWB.Modifier2 AS Mod2
				--,	CHWB.Modifier3 AS Mod3
				--,	CHWB.Modifier4 AS Mod4
				,	SSS.Unit AS ServiceMinutes
                FROM #Report r
                    JOIN Programs p ON p.ProgramId = r.ProgramId
                    JOIN Clients c ON c.ClientId = r.ClientId
                    JOIN ProcedureCodes pc ON pc.ProcedureCodeId = r.ProcedureCodeId
                    JOIN ( SELECT ISNULL(Subaccount, 'Unknown') AS Account
                            ,   COUNT(DISTINCT ProgramId) AS AccountProgramsCount
                            FROM #Report
                            GROUP BY ISNULL(Subaccount, 'Unknown') ) apc ON apc.Account = ISNULL(r.Subaccount, 'Unknown')
                    LEFT JOIN CoveragePlans cp ON cp.CoveragePlanId = r.CoveragePlanIdByCoverage
					
					LEFT JOIN Services SSS on r.ServiceId = SSS.ServiceId -- Warwick Added to test
					LEFT JOIN Staff ST on sss.ClinicianId = ST.StaffId
					--LEFT JOIN Charges CHWB on SSS.ServiceId = CHWB.ServiceId
				WHERE p.ProgramName like 'KCMHSAS%' -- Added by CHernandez 03/19/2018 to filter down to just direct ops programs
                ORDER BY CASE WHEN r.Subaccount IS NULL THEN 1
                              ELSE 2
                         END
                ,   p.ProgramName
                ,   r.Subaccount
                ,   r.ClientId
                ,   r.DateOfService


select * from #Report
where ServiceId in (
1059626,
1152404) --404 is the HMP and then other

select Distinct(CoveragePlanIdByCoverage) from #Report
where ServiceId in (
1152404,
1118922,
1152603,
1153843,
1100932,
1132856,
1063332,
1063337,
1063342,
1063347,
1063352,
1063362,
1139423,
1062633,
1063404,
1063414,
1063419,
1063339,
1063344,
1063349,
1063354,
1063364,
1150694,
1062632,
1063403,
1063418,
1063428,
1063443,
1063453,
1063366,
1063374,
1063390,
1140123)

select * from CoveragePlans
where coverageplanid in (
308,
310,
311,
320,
376)


select * From CoveragePlans
where CoveragePlanId = 428

select * from #Report
where ServiceId in (
1152404,
1118922,
1152603,
1153843,
1100932,
1132856,
1063332,
1063337,
1063342,
1063347,
1063352,
1063362,
1139423,
1062633,
1063404,
1063414,
1063419,
1063339,
1063344,
1063349,
1063354,
1063364,
1150694,
1062632,
1063403,
1063418,
1063428,
1063443,
1063453,
1063366,
1063374,
1063390,
1140123)

select Distinct(CoveragePlanIdByCoverage) from #Report
where ServiceId in (
1092933,
1126780,
1116629,
1150460,
1060487,
1074005,
1058607,
1041970,
1095599,
1128066,
1047572,
1065504,
1092822,
1093349,
1103615,
1122093,
1134118,
1099341,
1099375,
1153167,
1095377,
1114179,
1141966,
1050373,
1068959,
1137065,
1050612,
1069292,
1111068,
1066943,
1103689
)