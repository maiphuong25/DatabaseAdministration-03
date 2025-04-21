
CREATE  OR ALTER PROC LayChuongTrinhKhuyenMaiTheoSanPham
    @MaSP VARCHAR(20)
AS
BEGIN
    SELECT 
        MaCT AS MaChuongTrinh,
        TenCT AS TenChuongTrinh,
        NgayBD AS NgayBatDau,
        NgayKT AS NgayKetThuc,
        PTram AS PhanTramGiamGia
    FROM ChuongTrinhKhuyenMai
    WHERE MaSP = @MaSP
    ORDER BY NgayBD; 
END;
GO


EXEC LayChuongTrinhKhuyenMaiTheoSanPham @MaSP = 'SP0050';

select * from ChuongTrinhKhuyenMai
where MaSP = 'SP0050'



