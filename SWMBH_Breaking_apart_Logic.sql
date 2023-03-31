    BEGIN
	    DECLARE @FROMDATE DATETIME
		DECLARE @ToDate DATETIME
		SET @FROMDATE= '01/01/2022'
		SET @ToDate = '01/31/2022'

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

end


---Testing this entire script
--select * from #ClaimLines
--select * from #Report
--select * from #Groups

--drop table #ClaimLines
--drop table #Report
--drop table #Groups

--drop if necessary

--next section
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
							--AND p.ProgramName not like 'DCO%' --Added 3.21 per finance request to not include services from claims
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
								

---Testing this entire script
--select * from #ClaimLines --so at this point unpopulated
--select * from #Report
--select * from #Groups

--drop table #ClaimLines
--drop table #Report
--drop table #Groups

--drop if necessary

--next section---------------------------------------------------

--CoveragePlanColumn needs to be
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



--select * from #ClaimLines 
--select * from #Report
--select * from #Groups

--drop table #ClaimLines
--drop table #Report
--drop table #Groups
----SO HERE WE GO NEXT CTE COV INFO
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


--Results after the 2nd CTE for Coverage
--select * from #ClaimLines --still empty
--select * from #Report
--select * from #Groups

--drop table #ClaimLines
--drop table #Report
--drop table #Groups

--This is b4 the third CTE
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
                    LEFT JOIN ClientCoveragePlans ccp ON ccp.ClientCoveragePlanId = c.ClientCoveragePlanId --and ccp.CoveragePlanId <> 428 --Added for testing 3.29 for finance requests.
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
                                        WHERE c2.ServiceId = r.ServiceId
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
                                                                       END) <> 0 ) )

--Results after the 2nd CTE for Coverage
--select * from #ClaimLines --still empty
--select * from #Report
--select * from #Groups

--drop table #ClaimLines
--drop table #Report
--drop table #Groups
