﻿--Bảng KhachHang
CREATE OR ALTER PROCEDURE ThemKhachHang
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @Ho NVARCHAR(50), @HoLot NVARCHAR(50), @Ten NVARCHAR(50), @Duong NVARCHAR(50);
    
    -- Bảng tạm để lưu tên và địa chỉ ngẫu nhiên
    DECLARE @DanhSachHo TABLE (ID INT IDENTITY(1,1), Ho NVARCHAR(50));
    DECLARE @DanhSachHoLot TABLE (ID INT IDENTITY(1,1), HoLot NVARCHAR(50));
    DECLARE @DanhSachTen TABLE (ID INT IDENTITY(1,1), Ten NVARCHAR(50));
    DECLARE @DanhSachDuong TABLE (ID INT IDENTITY(1,1), Duong NVARCHAR(50));
    
    -- Thêm dữ liệu vào bảng tạm
    INSERT INTO @DanhSachHo (Ho) VALUES 
        (N'Nguyen'), (N'Tran'), (N'Pham'), (N'Truong'), (N'Vo'), (N'Đinh'), (N'Ngo');
    
    INSERT INTO @DanhSachHoLot (HoLot) VALUES 
        (N'Đinh'), (N'Anh'), (N'Van'), (N'Cong'), (N'Hoang'), (N'Đuc');
    
    INSERT INTO @DanhSachTen (Ten) VALUES 
        (N'Tuan'), (N'Tu'), (N'Nguyen'), (N'Bao'), (N'Cuong'), (N'My'), (N'Sang');
    
    INSERT INTO @DanhSachDuong (Duong) VALUES 
        (N'Le Loi'), (N'Tran Cao Van'), (N'Le Duan'), (N'Đo Ba'), (N'An Thuong'), (N'Phan Tu');
    
    WHILE @i <= 1000
    BEGIN
        -- Lấy chỉ số ngẫu nhiên cho từng bảng
        DECLARE @RandomHo INT = ABS(CHECKSUM(NEWID()) % 7) + 1;      
        DECLARE @RandomHoLot INT = ABS(CHECKSUM(NEWID()) % 6) + 1;   
        DECLARE @RandomTen INT = ABS(CHECKSUM(NEWID()) % 7) + 1;     
        DECLARE @RandomDuong INT = ABS(CHECKSUM(NEWID()) % 6) + 1;   
        
        -- Lấy giá trị ngẫu nhiên từ các bảng tạm
        SELECT @Ho = Ho FROM @DanhSachHo WHERE ID = @RandomHo;
        SELECT @HoLot = HoLot FROM @DanhSachHoLot WHERE ID = @RandomHoLot;
        SELECT @Ten = Ten FROM @DanhSachTen WHERE ID = @RandomTen;
        SELECT @Duong = Duong FROM @DanhSachDuong WHERE ID = @RandomDuong;
        
        -- Thêm vào bảng KhachHang
        INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SDT, NSinh)
        VALUES (
            'KH' + RIGHT('0000' + CAST(@i AS VARCHAR), 4), 
            @Ho + ' ' + @HoLot + ' ' + @Ten,                         
            N'So ' + CAST(ABS(CHECKSUM(NEWID()) % 300) AS VARCHAR) + N' Duong ' + @Duong + N', Da Nang',  
            '0' + FORMAT(ABS(CHECKSUM(NEWID()) % 1000000000), '000000000'),  
            DATEADD(YEAR, -18 - ABS(CHECKSUM(NEWID()) % 32), GETDATE())  
        );
        
        SET @i = @i + 1;  -- Tăng biến đếm
    END;
END;


EXEC ThemKhachHang;

-- Bảng SanPham
CREATE OR ALTER PROCEDURE ThemSanPham
AS
BEGIN
    DECLARE @i INT = 1;
    
    WHILE @i <= 1000
    BEGIN
        INSERT INTO SanPham (MaSP, TenSP, SoLuongSP, DGia, MoTa)
        VALUES (
            'SP' + RIGHT('0000' + CAST(@i AS VARCHAR), 4),
            N'San pham ' + CAST(@i AS VARCHAR),
            ABS(CHECKSUM(NEWID()) % 200),  -- Số lượng ngẫu nhiên từ 0 đến 199
            ABS(CHECKSUM(NEWID()) % 9900001 + 100000), -- Giá ngẫu nhiên từ 100,000 đến 10,000,000
            N'Mo ta san pham ' + CAST(@i AS VARCHAR)
        );
        SET @i = @i + 1;  -- Tăng biến đếm
    END;
END;

EXEC ThemSanPham;

-- Bảng NhanVien
CREATE OR ALTER PROCEDURE ThemNhanVien
AS
BEGIN
    DECLARE @i INT = 1;
    
    WHILE @i <= 1000
    BEGIN
        INSERT INTO NhanVien (MaNV, HTen, SDT, NSinh, ChucVu)
        VALUES (
            'NV' + RIGHT('00000000' + CAST(@i AS VARCHAR), 8),
            'Ten NV' + RIGHT('0000' + CAST(@i AS VARCHAR), 4),  -- Tên nhân viên ngẫu nhiên
            '0' + CAST(ABS(CHECKSUM(NEWID()) % 900000000 + 100000000) AS VARCHAR),  -- Số điện thoại
            DATEADD(YEAR, -18 - ABS(CHECKSUM(NEWID()) % 12), GETDATE()),  -- Ngày sinh từ 18 đến 30 tuổi
            CASE 
                WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN N'Nhân viên'
                ELSE N'Quản lý'
            END
        );
        SET @i = @i + 1;  -- Tăng biến đếm
    END;
END;

EXEC ThemNhanVien;

-- Bảng HoaDon
CREATE OR ALTER PROCEDURE ThemHoaDon
AS
BEGIN
    DECLARE @i INT = 1;
    
    WHILE @i <= 1000
    BEGIN
        INSERT INTO HoaDon (MaDH, MaNV, Ngtao, MaKH)
        VALUES (
            'DH' + RIGHT('0000' + CAST(@i AS VARCHAR), 4),  -- Mã hóa đơn
            (SELECT TOP 1 MaNV FROM NhanVien ORDER BY NEWID()),  -- Nhân viên ngẫu nhiên
            GETDATE() - ABS(CHECKSUM(NEWID()) % 365),  -- Ngày tạo ngẫu nhiên trong vòng 1 năm
            (SELECT TOP 1 MaKH FROM KhachHang ORDER BY NEWID())  -- Mã khách hàng ngẫu nhiên
        );
        
        SET @i = @i + 1;  -- Tăng biến đếm
    END;
END;

EXEC ThemHoaDon;

-- Bảng ChuongTrinhKhuyenMai
CREATE OR ALTER PROCEDURE ThemChuongTrinhKhuyenMai
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @NgayBD DATETIME, @NgayKT DATETIME;
    
    WHILE @i <= 1000
    BEGIN
        -- Ngày bắt đầu và kết thúc ngẫu nhiên
        SET @NgayBD = GETDATE() - ABS(CHECKSUM(NEWID()) % 100);
        SET @NgayKT = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 6 + 15), @NgayBD);  -- 15 đến 20 ngày khác nhau
        
        INSERT INTO ChuongTrinhKhuyenMai (MaCT, TenCT, NgayKT, NgayBD, PTram, MaSP)
        VALUES (
            'CT' + RIGHT('0000' + CAST(@i AS VARCHAR), 4),
            N'Chương trình ' + CAST(@i AS NVARCHAR),
            @NgayKT,
            @NgayBD,
            ABS(CHECKSUM(NEWID()) % 71) + 10,  -- Phần trăm ngẫu nhiên từ 10 đến 80
            'SP' + RIGHT('0000' + CAST((ABS(CHECKSUM(NEWID()) % 1000) + 1) AS VARCHAR), 4)  -- Mã sản phẩm ngẫu nhiên
        );
        SET @i = @i + 1;  -- Tăng biến đếm
    END;
END;

EXEC ThemChuongTrinhKhuyenMai;

-- Bảng HoaDonChiTiet
CREATE OR ALTER PROCEDURE ThemHoaDonChiTiet
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @MaSP VARCHAR(20);
    DECLARE @SoLuong INT;
    DECLARE @DGia FLOAT;
    DECLARE @TongTien FLOAT;

    WHILE @i <= 1000
    BEGIN
        -- Randomly select MaSP and SoLuong
        SET @MaSP = 'SP' + RIGHT('0000' + CAST((ABS(CHECKSUM(NEWID()) % 1000) + 1) AS VARCHAR), 4);
        SET @SoLuong = ABS(CHECKSUM(NEWID()) % 10) + 1;

        -- Retrieve DGia (price) from the SanPham table
        SELECT @DGia = DGia
        FROM SanPham
        WHERE MaSP = @MaSP;

        -- Calculate TongTien
        SET @TongTien = @SoLuong * @DGia;

        -- Insert into HoaDonChiTiet
        INSERT INTO HoaDonChiTiet (MaDH, MaSP, SoLuong, TongTien)
        VALUES (
            'DH' + RIGHT('0000' + CAST(@i AS VARCHAR), 4),  -- Mã hóa đơn tự động từ DH0001 đến DH1000
            @MaSP,  -- Mã sản phẩm ngẫu nhiên
            @SoLuong,  -- Số lượng ngẫu nhiên từ 1 đến 10
            @TongTien  -- Tổng tiền
        );

        -- Increase the counter
        SET @i = @i + 1;
    END;
END;
GO

EXEC ThemHoaDonChiTiet;

--check
select * from KhachHang
select * from SanPham
select * from NhanVien
select * from HoaDon
select * from HoaDonChiTiet
select * from ChuongTrinhKhuyenMai


delete from  KhachHang
delete from SanPham
delete from  HoaDon
delete from  NhanVien
delete from  HoaDonChiTiet
delete from  ChuongTrinhKhuyenMai