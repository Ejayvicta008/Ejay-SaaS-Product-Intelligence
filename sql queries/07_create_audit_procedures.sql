
-- =============================================
-- 1. START EXECUTION
-- =============================================
CREATE OR ALTER PROCEDURE audit.usp_StartExecution
    @ProcessName VARCHAR(200),
    @ExecutionID UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @ExecutionID = NEWID();

    INSERT INTO audit.ExecutionLog
    (
        ExecutionID,
        ProcessName,
        StartTime,
        ExecutionStatus
    )
    VALUES
    (
        @ExecutionID,
        @ProcessName,
        GETDATE(),
        'RUNNING'
    );
END;
GO


-- =============================================
-- 2. LOG DATA QUALITY CHECK
-- =============================================
CREATE OR ALTER PROCEDURE audit.usp_LogDataQualityCheck
    @ExecutionID UNIQUEIDENTIFIER,
    @CheckName VARCHAR(200),
    @TableName VARCHAR(200),
    @CheckCategory VARCHAR(100),
    @ExpectedValue VARCHAR(500) = NULL,
    @ActualValue VARCHAR(500) = NULL,
    @CheckStatus VARCHAR(20),
    @ErrorMessage VARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CheckStatus NOT IN ('PASS', 'FAIL', 'WARNING')
    BEGIN
        THROW 50001, 'Invalid check status. Use PASS, FAIL, or WARNING.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM audit.ExecutionLog
        WHERE ExecutionID = @ExecutionID
    )
    BEGIN
        THROW 50002, 'ExecutionID does not exist.', 1;
    END;

    INSERT INTO audit.DataQualityResults
    (
        ExecutionID,
        CheckName,
        TableName,
        CheckCategory,
        ExpectedValue,
        ActualValue,
        CheckStatus,
        ErrorMessage
    )
    VALUES
    (
        @ExecutionID,
        @CheckName,
        @TableName,
        @CheckCategory,
        @ExpectedValue,
        @ActualValue,
        @CheckStatus,
        @ErrorMessage
    );
END;
GO


-- =============================================
-- 3. END EXECUTION
-- =============================================
CREATE OR ALTER PROCEDURE audit.usp_EndExecution
    @ExecutionID UNIQUEIDENTIFIER,
    @ErrorMessage VARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @TotalChecks INT,
        @PassedChecks INT,
        @FailedChecks INT,
        @WarningChecks INT,
        @ExecutionStatus VARCHAR(20);

    SELECT
        @TotalChecks = COUNT(*),
        @PassedChecks = SUM(CASE WHEN CheckStatus = 'PASS' THEN 1 ELSE 0 END),
        @FailedChecks = SUM(CASE WHEN CheckStatus = 'FAIL' THEN 1 ELSE 0 END),
        @WarningChecks = SUM(CASE WHEN CheckStatus = 'WARNING' THEN 1 ELSE 0 END)
    FROM audit.DataQualityResults
    WHERE ExecutionID = @ExecutionID;

    SET @TotalChecks = ISNULL(@TotalChecks, 0);
    SET @PassedChecks = ISNULL(@PassedChecks, 0);
    SET @FailedChecks = ISNULL(@FailedChecks, 0);
    SET @WarningChecks = ISNULL(@WarningChecks, 0);

    SET @ExecutionStatus =
        CASE
            WHEN @ErrorMessage IS NOT NULL OR @FailedChecks > 0
                THEN 'FAILED'
            WHEN @WarningChecks > 0
                THEN 'WARNING'
            ELSE 'SUCCESS'
        END;

    UPDATE audit.ExecutionLog
    SET
        EndTime = GETDATE(),
        ExecutionStatus = @ExecutionStatus,
        TotalChecks = @TotalChecks,
        PassedChecks = @PassedChecks,
        FailedChecks = @FailedChecks,
        ErrorMessage = @ErrorMessage
    WHERE ExecutionID = @ExecutionID;

    IF @@ROWCOUNT = 0
        THROW 50003, 'ExecutionID does not exist.', 1;
END;
GO
