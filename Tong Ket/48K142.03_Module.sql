--1: Kiểm tra dữ liệu khi thêm mới khách hàng
CREATE OR ALTER TRIGGER KiemTraThemKhachHang
ON KhachHang
INSTEAD OF INSERT, UPDATE
AS
BEGIN
        DECLARE @TenKH VARCHAR(100),
                @DiaChi NVARCHAR(255),
                @SDT VARCHAR(20)

        -- Lấy các giá trị của hàng vừa được chèn vào
        SELECT @TenKH = TenKH, @DiaChi = DiaChi, @SDT = SDT
        FROM inserted

        -- Kiểm tra nếu tên khách hàng để trống
        IF @TenKH = '' OR @TenKH IS NULL
        BEGIN
           PRINT N'Tên khách hàng không được để trống.'
            ROLLBACK;
			RETURN;
        END

        -- Kiểm tra nếu địa chỉ để trống
        ELSE IF @DiaChi = '' OR @DiaChi IS NULL
        BEGIN
			PRINT N'Địa chỉ không được để trống.'
            ROLLBACK;
			RETURN;
        END

        -- Kiểm tra nếu số điện thoại không có đúng 10 chữ số
        ELSE IF LEN(@SDT) != 10 OR @SDT NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        BEGIN
			PRINT N'Số điện thoại phải có đúng 10 chữ số.'
            ROLLBACK; 
			RETURN;
        END
		ELSE
		BEGIN
        -- Nếu tất cả điều kiện đều thỏa mãn, tiến hành chèn dữ liệu khách hàng mới
			INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SDT, NSinh)
			SELECT * FROM inserted
			PRINT N'Dữ liệu được nhập thành công'
		END
END;
GO

--Test
INSERT INTO KhachHang VALUES ('KH1076','','Cẩm Lệ','0986578989','2002-05-05')

select * from KhachHang

--2: Tạo Hoá đơn mới (Kiểm tra khách hàng đã có trong cơ sở dữ liệu chưa? Nếu chưa thì tạo mã khách hàng mới, nếu rồi thì sử dụng tiếp mã khách hàng đã có.)
﻿CREATE FUNCTION fTaoMaDHvaMaKH (
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
        SET @IsNewKH = 1; -- 1: khách hàng mới chưa có mã khách hàng
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


﻿--3: Tạo hoặc cập nhật thủ tục sp_TaoHoaDonMoi﻿
CREATE OR ALTER PROCEDURE sp_TaoHoaDonMoi
    @TenKH NVARCHAR(100),   
    @MaNV VARCHAR(20)      
AS
BEGIN
    DECLARE @MaDH VARCHAR(20),
            @MaKH CHAR(20),
            @NgayTao DATE = GETDATE(),  
            @TongTien FLOAT = 0,        
            @PTram FLOAT = 100,
			@IsNewKH BIT
    SELECT	@MaDH = MaDH, 
			@MaKH = MaKH,
			@IsNewKH = IsNewKH
    FROM fTaoMaDHvaMaKH(@TenKH, @NgayTao);
	IF @IsNewKH = 1
	BEGIN
    INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SDT, NSinh)
    VALUES (@MaKH, @TenKH, N'null', N'0000000000', GETDATE());
	END
	ELSE
	BEGIN
		SET @IsNewKH = 0
	END
    INSERT INTO HoaDon (MaDH, MaNV, MaKH, Ngtao)
    VALUES (@MaDH, @MaNV, @MaKH, @NgayTao);
    DECLARE @MaSP VARCHAR(20),
            @SoLuong INT,
            @DGia FLOAT;
    DECLARE product_cursor CURSOR FOR
    SELECT MaSP, SoLuong FROM #Products; 
    OPEN product_cursor;
    FETCH NEXT FROM product_cursor INTO @MaSP, @SoLuong;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @TenSP NVARCHAR(100);
        SELECT @TenSP = TenSP, @DGia = DGia
        FROM SanPham 
        WHERE MaSP = @MaSP;
        SELECT @PTram = ISNULL(PTram, 100) 
        FROM ChuongTrinhKhuyenMai 
        WHERE MaSP = @MaSP;
        IF @TenSP IS NOT NULL 
        BEGIN
            SET @TongTien = @TongTien + (@DGia * @SoLuong * (@PTram / 100));
            INSERT INTO HoaDonChiTiet (MaDH, MaSP, SoLuong)
            VALUES (@MaDH, @MaSP, @SoLuong);
        END
        ELSE
        BEGIN
            PRINT N'Sản phẩm ' + @MaSP + N' không tồn tại!';
        END

        FETCH NEXT FROM product_cursor INTO @MaSP, @SoLuong;
    END
    CLOSE product_cursor;
    DEALLOCATE product_cursor;
END
GO


--test
-- Tạo bảng tạm để chứa sản phẩm cho hóa đơn
CREATE TABLE #Products
(
    MaSP VARCHAR(20), 
    SoLuong INT       
);
GO

-- Thêm sản phẩm vào bảng tạm
INSERT INTO #Products (MaSP, SoLuong) VALUES ('SP0001', 2);  
INSERT INTO #Products (MaSP, SoLuong) VALUES ('SP0002', 9);
INSERT INTO #Products (MaSP, SoLuong) VALUES ('SP0003', 1);
GO

EXEC sp_TaoHoaDonMoi @TenKH = 'Pham Mai Phuong Uyen', @MaNV = 'NV00000004';
GO

-- Xóa bảng tạm sau khi sử dụng
DROP TABLE #Products;
GO
 select * from KhachHang


﻿--4. Tạo Stored Procedure để thêm sản phẩm vào hóa đơn
CREATE OR ALTER PROCEDURE AddProductToInvoice
    @MaDH VARCHAR(20),   -- Mã Hóa Đơn
    @MaSP VARCHAR(20),   -- Mã Sản Phẩm
    @SoLuong INT        -- Số Lượng Thêm Vào
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Bắt đầu Transaction
        BEGIN TRANSACTION;

        -- 1. Kiểm tra sự tồn tại của Hóa Đơn
        IF NOT EXISTS (SELECT 1 FROM HoaDon WHERE MaDH = @MaDH)
        BEGIN
            RAISERROR(N'Hóa đơn với mã %s không tồn tại.', 16, 1, @MaDH);
            ROLLBACK;
        END

        -- 2. Kiểm tra sự tồn tại của Sản Phẩm
        IF NOT EXISTS (SELECT 1 FROM SanPham WHERE MaSP = @MaSP)
        BEGIN
            RAISERROR(N'Sản phẩm với mã %s không tồn tại.', 16, 1, @MaSP);
            ROLLBACK;
        END

        -- 3. Kiểm tra số lượng sản phẩm có sẵn
        DECLARE @SoLuongCon INT;
        SELECT @SoLuongCon = SoLuongSP FROM SanPham WHERE MaSP = @MaSP;

        IF @SoLuongCon < @SoLuong
        BEGIN
            RAISERROR(N'Sản phẩm với mã %s chỉ còn %d sản phẩm trong kho.', 16, 1, @MaSP, @SoLuongCon);
            ROLLBACK;
        END

        -- 4. Kiểm tra xem sản phẩm đã có trong hóa đơn chưa
        IF EXISTS (SELECT 1 FROM HoaDonChiTiet WHERE MaDH = @MaDH AND MaSP = @MaSP)
        BEGIN
            -- Nếu đã có, cập nhật số lượng
            UPDATE HoaDonChiTiet
            SET SoLuong = SoLuong + @SoLuong
            WHERE MaDH = @MaDH AND MaSP = @MaSP;
        END
        ELSE
        BEGIN
            -- Nếu chưa có, chèn mới
            INSERT INTO HoaDonChiTiet (MaDH, MaSP, SoLuong)
            VALUES (@MaDH, @MaSP, @SoLuong);
        END

        -- 5. Cập nhật tổng tiền của hóa đơn
        DECLARE @DonGia FLOAT;
        SELECT @DonGia = DGia FROM SanPham WHERE MaSP = @MaSP;

        DECLARE @TongTien FLOAT;
        SELECT @TongTien = ISNULL(TongTien, 0) + (@DonGia * @SoLuong)
        FROM HoaDonChiTiet
        WHERE MaDH = @MaDH;

        UPDATE HoaDonChiTiet
        SET TongTien = @TongTien
        WHERE MaDH = @MaDH;

        -- 6. Cập nhật số lượng sản phẩm trong kho
        UPDATE SanPham
        SET SoLuongSP = SoLuongSP - @SoLuong
        WHERE MaSP = @MaSP;

        -- 7. Commit Transaction
        COMMIT TRANSACTION;

        PRINT N'Thêm sản phẩm vào hóa đơn thành công.';
    END TRY
    BEGIN CATCH
        -- Xử lý lỗi và rollback nếu có lỗi xảy ra
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

--Test
EXEC AddProductToInvoice 'DC0001' ,'SP0001',1
EXEC AddProductToInvoice 'DH0001' ,'SK0001',1

--5﻿: Xoá hoá đơn 
CREATE OR ALTER PROCEDURE sp_XoaHoaDon
    @MaDH VARCHAR(20)  -- Mã hóa đơn cần xóa
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem hóa đơn có tồn tại hay không
    IF EXISTS (SELECT 1 FROM HoaDon WHERE MaDH = @MaDH)
    BEGIN
        -- Xóa các chi tiết hóa đơn liên quan
        DELETE FROM HoaDonChiTiet WHERE MaDH = @MaDH;

        -- Xóa hóa đơn
        DELETE FROM HoaDon WHERE MaDH = @MaDH;

        PRINT N'Hóa đơn với mã ' + @MaDH + N' đã được xóa thành công.';
    END
    ELSE
    BEGIN
        PRINT N'Hóa đơn với mã ' + @MaDH + N' không tồn tại.';
    END
END
GO

-- Test
EXEC sp_XoaHoaDon @MaDH = 'HD1005';  
GO

--6:Module xem hoá đơn
﻿CREATE OR ALTER PROCEDURE sp_XemHoaDon
    @MaDH VARCHAR(20)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM HoaDon WHERE MaDH = @MaDH)
    BEGIN
        SELECT 
            h.MaDH AS 'Mã Đơn Hàng',
            h.Ngtao AS 'Ngày Tạo',
            nv.HTen AS 'Tên Nhân Viên',
            kh.TenKH AS 'Tên Khách Hàng',
            kh.SDT AS 'Số Điện Thoại',
            ISNULL(ctkm.TenCT, N'Không có') AS 'Tên Chương Trình Khuyến Mãi',
            ISNULL(ctkm.PTram, 0) AS 'Phần Trăm Giảm Giá',
            SUM(hdct.Soluong * sp.DGia) * (1 - ISNULL(ctkm.PTram, 0) / 100) AS 'Tổng Tiền'
        FROM HoaDon h
        JOIN KhachHang kh ON h.MaKH = kh.MaKH
        JOIN NhanVien nv ON h.MaNV = nv.MaNV
        LEFT JOIN HoaDonChiTiet hdct ON h.MaDH = hdct.MaDH
        LEFT JOIN SanPham sp ON hdct.MaSP = sp.MaSP
        LEFT JOIN ChuongTrinhKhuyenMai ctkm ON ctkm.MaSP = sp.MaSP
        WHERE h.MaDH = @MaDH
        GROUP BY h.MaDH, h.Ngtao, nv.HTen, kh.TenKH, kh.SDT, ctkm.TenCT, ctkm.PTram;
        SELECT 
            hdct.MaSP AS 'Mã Sản Phẩm',
            sp.TenSP AS 'Tên Sản Phẩm',
            hdct.Soluong AS 'Số Lượng',
            sp.DGia AS 'Đơn Giá',
            (hdct.Soluong * sp.DGia) * (1 - ISNULL(ctkm.PTram, 0) / 100) AS 'Thành Tiền'
        FROM HoaDonChiTiet hdct
        JOIN SanPham sp ON hdct.MaSP = sp.MaSP
        LEFT JOIN ChuongTrinhKhuyenMai ctkm ON ctkm.MaSP = sp.MaSP
        WHERE hdct.MaDH = @MaDH;
    END
    ELSE
    BEGIN
        PRINT N'Hóa đơn với mã ' + @MaDH + N' không tồn tại.';
    END
END
GO


-- Test
EXEC sp_XemHoaDon @MaDH = 'DH0002';  
GO

--7: Module Kiểm tra tính Hợp Lệ Dữ Liệu Nhân Viên khi nhập vào: Kiểm Tra Tính Độc Nhất của Mã Nhân Viên,  Số Điện Thoại, Ngày Sinh, Chức Vụ
CREATE OR ALTER TRIGGER trg_KiemTraHopLeNhanVien
ON NhanVien
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaNV VARCHAR(20), @HTen VARCHAR(100), @SDT VARCHAR(10), 
            @NSinh DATETIME, @ChucVu VARCHAR(50);

    -- Lấy dữ liệu từ bảng inserted (dữ liệu vừa thêm hoặc cập nhật)
    SELECT	@MaNV = MaNV, 
			@HTen = HTen, 
			@SDT = SDT, 
			@NSinh = NSinh, 
			@ChucVu = ChucVu
    FROM inserted;

    -- Kiểm tra mã nhân viên có trùng lặp
    IF EXISTS (
        SELECT MaNV FROM NhanVien
        WHERE MaNV = @MaNV
        GROUP BY MaNV
        HAVING COUNT(*) > 1
    )
    BEGIN
        PRINT N'Lỗi: Mã nhân viên bị trùng.';
        ROLLBACK;
    END

    -- Kiểm tra số điện thoại hợp lệ
    IF NOT (@SDT LIKE '[0-9]%' AND LEN(@SDT) = 10)
    BEGIN
        PRINT N'Lỗi: Số điện thoại không hợp lệ.';
        ROLLBACK;
    END

    -- Kiểm tra ngày sinh hợp lệ
    IF @NSinh > GETDATE() OR YEAR(@NSinh) < 1950
    BEGIN
        PRINT N'Lỗi: Ngày sinh không hợp lệ.';
        ROLLBACK;
    END

    -- Kiểm tra chức vụ hợp lệ
    IF @ChucVu NOT IN ('Nhân viên', 'Quản lý')
    BEGIN
        PRINT N'Lỗi: Chức vụ không hợp lệ.';
        ROLLBACK;
    END

    -- Kiểm tra thiếu thông tin bắt buộc (SĐT hoặc Chức vụ)
    IF @SDT IS NULL OR @ChucVu IS NULL
    BEGIN
        PRINT N'Lỗi: Thiếu thông tin bắt buộc (SĐT hoặc Chức vụ).';
        ROLLBACK;
    END
    PRINT N'Thông tin nhân viên hợp lệ.';
END;
GO

--Test
INSERT INTO NhanVien (MaNV, HTen, SDT, NSinh, ChucVu)
VALUES ('NV0046', 'Tran Van B', '123ABC789', '1990-03-15', 'Nhân viên');

--8:Trigger để kiểm tra bảng sản phẩm:
CREATE or alter  TRIGGER trg_CheckSanPhamInput
ON SanPham
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra dữ liệu nhập vào
    IF EXISTS (
        SELECT * 
        FROM inserted 
        WHERE SoLuongSP < 0 OR DGia < 0 OR TenSP IS NULL OR TenSP = '' OR MoTa IS NULL OR MoTa = ''
    )
    BEGIN
        PRINT N'Lỗi: Số lượng sản phẩm và giá không được âm. Tên và mô tả sản phẩm không được để trống.'
        ROLLBACK TRANSACTION;  -- Hoàn tác giao dịch
        RETURN;
    END

    -- Nếu dữ liệu hợp lệ, cho phép chèn hoặc cập nhật
    INSERT INTO SanPham (MaSP, TenSP, SoLuongSP, DGia, MoTa)
    SELECT MaSP, TenSP, SoLuongSP, DGia, MoTa
    FROM inserted;
END;
GO

--test
select*from sanpham
-- Thử chèn sản phẩm hợp lệ
INSERT INTO SanPham (MaSP, TenSP, SoLuongSP, DGia, MoTa)
VALUES ('SP199998', N'Sản phẩm C', 10, 10000, 'Mô tả sản phẩm C');
-- Thử chèn sản phẩm không hợp lệ (giá âm)
INSERT INTO SanPham (MaSP, TenSP, SoLuongSP, DGia, MoTa)
VALUES ('SP1001', 'Sản phẩm B', 5, -5000, 'Mô tả sản phẩm B');
select * from SanPham
SELECT * FROM HoaDonChiTiet

--9:Kiểm tra các sản phẩm không còn được giao dịch trong một thời gian dài (ví dụ hơn 4 tháng). 
CREATE or alter  FUNCTION fn_KiemTraSanPhamKhongGiaoDich()
RETURNS @KetQua TABLE
(
    MaSP VARCHAR(20),
    TenSP VARCHAR(100),
    LanGiaoDichCuoi DATE
)
AS
BEGIN
    -- Chèn dữ liệu vào bảng kết quả
    INSERT INTO @KetQua
    SELECT SP.MaSP, SP.TenSP, MAX(HD.Ngtao) AS LanGiaoDichCuoi
    FROM SanPham SP
    LEFT JOIN HoaDonChiTiet HDCT ON SP.MaSP = HDCT.MaSP
    LEFT JOIN HoaDon HD ON HDCT.MaDH = HD.MaDH
    GROUP BY SP.MaSP, SP.TenSP
    HAVING DATEDIFF(MONTH, MAX(HD.Ngtao), GETDATE()) > 4 OR MAX(HD.Ngtao) IS NULL;

    RETURN;
END;
GO

--test
SELECT * FROM fn_KiemTraSanPhamKhongGiaoDich();


--10: Module kiểm tra các sản phẩm đã hết hàng: Kiểm tra và liệt kê các sản phẩm gần/hết hàng.
CREATE or alter  PROCEDURE KiemTraSanPhamGanHetHang
AS
BEGIN
    

    SELECT MaSP, TenSP, SoLuongSP
    FROM SanPham
    WHERE SoLuongSP < 10;

    IF NOT EXISTS (SELECT 1 FROM SanPham WHERE SoLuongSP < 10)
    BEGIN
        PRINT 'Không có sản phẩm nào gần/hết hàng.';
    END
END;
GO

--test
EXEC KiemTraSanPhamGanHetHang;

--11:Kiểm tra mã chương trình khuyến mãi có tồn tại không:
CREATE OR ALTER PROCEDURE UpdateChuongTrinhKhuyenMai
    @MaCT VARCHAR(20),
    @TenCT NVARCHAR(100),
    @NgayBD DATE,
    @NgayKT DATE,
    @PTram FLOAT,
    @MaSP VARCHAR(20)
AS
BEGIN
    -- Kiểm tra mã chương trình khuyến mãi có tồn tại hay không
    IF NOT EXISTS (SELECT 1 FROM ChuongTrinhKhuyenMai WHERE MaCT = @MaCT)
    BEGIN
        RAISERROR ('MaCT không có trong ChuongTrinhKhuyenMai.', 16, 1);
        RETURN;
    END
    ELSE
    BEGIN
        -- Nếu tồn tại, thực hiện cập nhật
        UPDATE ChuongTrinhKhuyenMai
        SET TenCT = @TenCT,
            NgayBD = @NgayBD,
            NgayKT = @NgayKT,
            PTram = @PTram,
            MaSP = @MaSP
        WHERE MaCT = @MaCT;
    END
END;
GO


--test
EXEC UpdateChuongTrinhKhuyenMai
    @MaCT = 'CT0003',
    @TenCT = N'Khuyến mãi mùa hè',
    @NgayBD = '2024-06-01',
    @NgayKT = '2024-07-01',
    @PTram = 20,
    @MaSP = 'SP0001';


--12: Kiểm tra thời gian hiệu lực của chương trình khuyến mãi và Kiểm tra phần trăm khuyến mãi (PTram) có hợp lệ và Kiểm tra sản phẩm có được áp dụng khuyến mãi không?
CREATE OR ALTER TRIGGER KTKhuyenMai
ON ChuongTrinhKhuyenMai
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NgayBD DATETIME, @NgayKT DATETIME;
    DECLARE @PTram FLOAT;
    DECLARE @MaSP VARCHAR(20);

    -- Kiểm tra từng hàng trong bảng inserted
    DECLARE product_cursor CURSOR FOR
    SELECT NgayBD, NgayKT, PTram, MaSP FROM inserted;

    OPEN product_cursor;
    FETCH NEXT FROM product_cursor INTO @NgayBD, @NgayKT, @PTram, @MaSP;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Kiểm tra thời gian hiệu lực
        IF @NgayBD > @NgayKT
        BEGIN
            RAISERROR (N'Không hợp lệ. Ngày bắt đầu phải sớm hơn ngày kết thúc', 16, 1);
            ROLLBACK TRANSACTION;
            CLOSE product_cursor;
            RETURN; -- Dừng thực hiện trigger
        END

        -- Kiểm tra phần trăm khuyến mãi
        IF @PTram < 0 OR @PTram > 100
        BEGIN
            RAISERROR ('Invalid discount percentage: PTram must be between 0 and 100.', 16, 1);
            ROLLBACK TRANSACTION;
            CLOSE product_cursor;
            RETURN; -- Dừng thực hiện trigger
        END

        -- Kiểm tra nếu MaSP không tồn tại trong bảng SanPham
        IF NOT EXISTS (SELECT 1 FROM SanPham WHERE MaSP = @MaSP)
        BEGIN
            RAISERROR (N'Sản phẩm %s không tồn tại trong bảng SanPham.', 16, 1, @MaSP);
            ROLLBACK TRANSACTION;
            CLOSE product_cursor;
            RETURN; -- Dừng thực hiện trigger
        END

        FETCH NEXT FROM product_cursor INTO @NgayBD, @NgayKT, @PTram, @MaSP;
    END

    CLOSE product_cursor;
    DEALLOCATE product_cursor;
END;
GO

INSERT INTO ChuongTrinhKhuyenMai (MaCT, TenCT, NgayBD, NgayKT, PTram, MaSP)
VALUES ('KM00099', 'Khuyến mãi mùa thu', '2024-11-01', '2024-11-30', 15, 'SP0004');
select * from ChuongTrinhKhuyenMai
delete from ChuongTrinhKhuyenMai where MaCT = 'KM00078'