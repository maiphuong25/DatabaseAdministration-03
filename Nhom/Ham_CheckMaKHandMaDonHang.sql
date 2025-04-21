
CREATE OR ALTER FUNCTION fn_TaoHoaDonMoi
(
    @MaNV VARCHAR(20),            
    @TenKH NVARCHAR(100),         
    @NgayTao DATE                 
)
RETURNS TABLE
AS
RETURN(
    WITH CTE AS 
    (
        SELECT 
            'HD' + RIGHT('0000' + CAST(ISNULL(MAX(CAST(SUBSTRING(MaDH, 3, LEN(MaDH) - 2) AS INT)), 0) + 1 AS VARCHAR), 4) AS MaDH
        FROM HoaDon
    ),
    CTE_KhachHang AS
    (
        SELECT 
            CASE WHEN EXISTS (SELECT 1 FROM KhachHang WHERE TenKH = @TenKH)
                 THEN (SELECT MaKH FROM KhachHang WHERE TenKH = @TenKH)
                 ELSE 'KH' + RIGHT('0000' + CAST((SELECT COUNT(*) + 1 FROM KhachHang) AS VARCHAR(4)), 4)
            END AS MaKH,
            CASE WHEN NOT EXISTS (SELECT 1 FROM KhachHang WHERE TenKH = @TenKH)
                 THEN 1 ELSE 0 END AS IsNewKH
    )
    SELECT
        CTE.MaDH,               
        @MaNV AS MaNV,          
        CTE_KhachHang.MaKH,     
        @TenKH AS TenKH,       
        @NgayTao AS Ngtao,      
        CTE_KhachHang.IsNewKH   
    FROM CTE
    CROSS JOIN CTE_KhachHang
);
GO


--test
DECLARE @MaDH VARCHAR(20), @MaKH VARCHAR(20);
IF (SELECT IsNewKH FROM fn_TaoHoaDonMoi('NV00000744', N'Mai Phuong', '2024-10-20')) = 1
BEGIN
    INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SDT, NSinh)
    VALUES (@MaKH, N'Mai Phuong', N'null', N'0000000000', GETDATE());
END;
INSERT INTO HoaDon (MaDH, MaNV, MaKH, Ngtao)
SELECT MaDH, MaNV, MaKH, Ngtao FROM fn_TaoHoaDonMoi('NV00000744', N'Mai Phuong', '2024-10-20');
