CREATE FUNCTION fTaoMaDHvaMaKH (
	@TenKH NVARCHAR(100),
	@NgayTao DATE)
RETURNS @HoaDonMoi TABLE
(
	MaDH VARCHAR(20),
	MaKH VARCHAR(20),
	TenKH NVARCHAR(100),
	NgTao DATE,
	IsNewKH BIT)
AS
BEGIN
	DECLARE @MaKH VARCHAR(20),
			@IsNewKH BIT = 0,
			@MaDH VARCHAR(20)
	SELECT	@MaDH = 'HD' + RIGHT('0000' + CAST(ISNULL(MAX(CAST(SUBSTRING(MaDH, 3, LEN(MaDH) - 2) AS INT)), 0) + 1 AS VARCHAR), 4)
    FROM HoaDon
	IF EXISTS (SELECT 1 FROM KhachHang WHERE TenKH = @TenKH)
    BEGIN
        SELECT @MaKH = MaKH FROM KhachHang WHERE TenKH = @TenKH;
    END
    ELSE
    BEGIN
        SELECT @MaKH = 'KH' + RIGHT('0000' + CAST(COUNT(*) + 1 AS VARCHAR(4)), 4)
        FROM KhachHang;
        SET @IsNewKH = 1;
    END
	INSERT INTO @HoaDonMoi (MaDH, MaKH, TenKH, NgTao, IsNewKH)
    VALUES (@MaDH, @MaKH, @TenKH, @NgayTao, @IsNewKH);
	RETURN 
END

SELECT * 
FROM dbo.fTaoMaDHvaMaKH( 
    N'Pham Dinh Khoi Nguyen',   -- Tên khách hàng mới
    '2024-10-20'
);

select * from HoaDon
where MaDH='HD1018'
