DROP TABLE IF EXISTS unified_logs;
CREATE TABLE IF NOT EXISTS unified_logs (
                                     Version varchar
                                    ,EventType int
                                    ,SubEventType int
                                    ,Date_Time varchar
                                    ,CookieId varchar
                                    ,SessionId varchar
                                    ,EventLinkId varchar
                                    ,IP varchar
                                    ,GeoCountry varchar
                                    ,OS varchar
                                    ,Browser varchar
                                    ,FingerPrint varchar
                                    ,GoogId varchar
                                    ,NTOKUserId varchar
                                    ,RandomSlot varchar
                                    ,Atok varchar
                                    ,Cmpid varchar
                                    ,BannerId varchar
                                    ,Variation varchar
                                    ,AdSize varchar
                                    ,AtokCountry varchar
                                    ,RawActionId varchar
                                    ,ConvActionId varchar
                                    ,Segment varchar
                                    ,RTBBidPrice varchar
                                    ,RTBWinPrice varchar
                                    ,RTBCurrency varchar
                                    ,ProductId varchar
                                    ,ProductName varchar
                                    ,ProductDesc varchar
                                    ,ClickedOrigin varchar
                                    ,ClickedSeqNo varchar
                                    ,Category varchar
                                    ,InStock varchar
                                    ,OldPrice varchar
                                    ,CurrentPrice varchar
                                    ,TransactionAmt varchar
                                    ,PriceCurrency varchar
                                    ,TransactionRef varchar
                                    ,ReferrerURL varchar
                                    ,URL varchar
                                    ,PlacementId varchar
                                    ,Fold varchar
                                    ,ImageUrl varchar
                                    ,UserData varchar
                                    ,MoreInfo varchar
                                    ,STID varchar
                                    ,STDateTime varchar
                                    ,SearchTerm varchar
                                    ,SearchCmpid varchar
                                    ,SearchScore varchar
                                    ,CRF varchar
                                    ,Categories varchar
                                    ,Recency varchar
                                    ,RecoProducts varchar
                                    ,ABTestGlobal varchar
                                    ,ABTestAtok varchar
                                    ,Channel varchar) ;


------------------------------------------------------------
--Get Retargeting Users
DROP TABLE IF EXISTS RetargetingUsers;
CREATE TABLE RetargetingUsers AS
SELECT DISTINCT 
       Imp.GoogId, 
       VIS.Atok
FROM unified_logs VIS
JOIN unified_logs IMP
ON  VIS.GoogId = IMP.GoogId
    AND VIS.Atok = IMP.Atok
WHERE VIS.EventType = 3
    AND IMP.EventType = 1
    AND VIS.Date_Time < IMP.Date_Time;


------------------------------------------------------------
-- Get Distinct Users Per Segment
DROP TABLE IF EXISTS UsersDetails;
CREATE TABLE  UsersDetails AS
SELECT DD.GoogId
        , MaxDate
        , UL.Segment
        , SUM(CASE WHEN EventType=1 THEN 1 ELSE 0 END) CountImp
        , SUM(CASE WHEN EventType=2 THEN 1 ELSE 0 END) CountClick
        , SUM(CASE WHEN EventType=3 THEN 1 ELSE 0 END) CountVisit
        , SUM(CASE WHEN EventType=4 THEN 1 ELSE 0 END) CountConv
        , DD.Atok
FROM ( SELECT R.Atok, R.GoogId, MAX(Date_Time) MaxDate
        FROM unified_logs L
        JOIN RetargetingUsers R
        ON L.GoogId = R.GoogId
        AND L.Atok = R.Atok
        GROUP BY R.Atok, R.GoogId
    )DD
JOIN unified_logs UL
ON DD.GoogId = UL.GoogId
    AND DD.Atok = UL.Atok
    AND DD.MaxDate = UL.Date_Time
GROUP BY DD.Atok, DD.GoogId, MaxDate, UL.Segment ;


---
-- Get actions per segment, based on the user's segment at the last event
SELECT  S.Atok
        , S.Segment
        , COUNT(S.GoogId) DistinctUsers
        , SUM(CountImp) AllImp
        , SUM(CASE WHEN CountImp   > 0 THEN 1 ELSE 0 END)  DistImp
        , SUM(CountClick) AllClick
        , SUM(CASE WHEN CountClick > 0 THEN 1 ELSE 0 END)  DistClick
        , SUM(CountVisit) AllVisit
        , SUM(CASE WHEN CountVisit > 0 THEN 1 ELSE 0 END)  DistVisit
        , SUM(CountConv) AllConv
        , SUM(CASE WHEN CountConv  > 0 THEN 1 ELSE 0 END)  DistConv
FROM UsersDetails S
JOIN unified_logs UL
ON  S.GoogId = UL.GoogId
    AND S.Atok = UL.Atok
GROUP BY S.Atok, S.Segment ;


-----------------------------
-- Get counters Per Segment, based on the segment at the current event
SELECT Atok 
    , Segment
    , COUNT(GoogId) DistinctUsers
    , SUM(CountImp) AllImp
    , SUM(CASE WHEN CountImp>0 THEN 1 ELSE 0 END)   DistImp
    , SUM(CountClick) AllClick
    , SUM(CASE WHEN CountClick>0 THEN 1 ELSE 0 END) DistClick
    , SUM(CountVisit) AllVisit
    , SUM(CASE WHEN CountVisit>0 THEN 1 ELSE 0 END) DistVisit
    , SUM(CountConv) AllConv
    , SUM(CASE WHEN CountConv>0 THEN 1 ELSE 0 END)  DistConv       
FROM 
    (SELECT L.Atok
            , L.GoogId
            , L.Segment
            , SUM(CASE WHEN EventType=1 THEN 1 ELSE 0 END) CountImp
            , SUM(CASE WHEN EventType=2 THEN 1 ELSE 0 END) CountClick
            , SUM(CASE WHEN EventType=3 THEN 1 ELSE 0 END) CountVisit
            , SUM(CASE WHEN EventType=4 THEN 1 ELSE 0 END) CountConv
    FROM unified_logs L
    JOIN RetargetingUsers R
    ON  L.GoogId = R.GoogId
        AND L.Atok = R.Atok
    GROUP BY L.Atok, L.GoogId, L.Segment
    )A
GROUP BY Atok, Segment ;


------------------------------------------------------------
-- Get histograms of users
DROP TABLE IF EXISTS usersForHistograms;
CREATE TABLE IF NOT EXISTS usersForHistograms AS
SELECT C.GoogId
        , SUM(CASE WHEN EventType=1 THEN 1 ELSE 0 END) CountImpBeforeConv
        , SUM(CASE WHEN EventType=2 THEN 1 ELSE 0 END) CountClickBeforeConv
        , SUM(CASE WHEN EventType=3 THEN 1 ELSE 0 END) CountVisitBeforeConv
        , UL.Atok
FROM
( SELECT R.Atok, R.GoogId, Date_Time ConvDate
    FROM RetargetingUsers R
    JOIN unified_logs UL
    ON R.GoogId = UL.GoogId
        AND R.Atok = UL.Atok
    WHERE UL.EventType = 4
)C
JOIN unified_logs UL
ON C.GoogId = UL.GoogId
    AND C.Atok = UL.Atok
WHERE C.ConvDate > UL.Date_Time
GROUP BY UL.Atok, C.GoogId ;



SELECT Atok, CountImpBeforeConv, COUNT(*) CntUsers
FROM usersForHistograms
GROUP BY Atok, CountImpBeforeConv ;

SELECT Atok, CountClickBeforeConv, COUNT(*) CntUsers
FROM usersForHistograms
GROUP BY Atok, CountClickBeforeConv ;

SELECT Atok, CountVisitBeforeConv, COUNT(*) CntUsers
FROM usersForHistograms
GROUP BY Atok, CountVisitBeforeConv ;

