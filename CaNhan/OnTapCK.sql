/*Module 1: Ktra du lieu khi them moi khach hang
- Ten, dia chi, sdt khong duoc bo trong va so dien thoai phai co dung 10 chu so*/

/*input: Tên khách hàng, Địa chỉ, số điện thoại
output: dữ liệu Tên khách hàng, Địa chỉ, số điện thoại được nhập vào không được bỏ trống
	số điện thoải đủ 10 kí tự với định dạng số
process: 1.	Lấy TenKH, DiaChi, SDT từ bảng inserted với @TenKH, @DiaChi, @SDT
		2.	Kiểm tra so với điều kiện
		2.1. Nếu tên khách hàng bỏ trống thì in ra thông báo ‘Tên khách hàng không được để trống.’ và rollback
		2.2. Nếu địa chỉ khách hàng bỏ trống thì in ra thông báo ‘Địa chỉ không được để trống.’ và rollback
		2.3. Nếu số điện thoại không đủ 10 số thì in ra thông báo ‘Số điện thoại phải có đúng 10 số.’ và rollback
		Ngược lại 
		2.4. Thực hiện thêm dữ liệu vào bảng KhachHang và đưa ra thông báo ‘Dữ liệu được nhập thành công’
*/
create or alter trigger tg_CheckAddKH
on KhachHang
instead of insert
as
begin
	declare @TenKH varchar(100),
			@DiaChi varchar(225),
			@SDT char(10)
	select @TenKH = TenKH, 
			@DiaChi = DiaChi,
			@SDT = SDT
	from inserted

	if @TenKH = '' or @TenKH is null
		begin
			print 'Ten khach hang khong duoc bo trong';
			rollback transaction;
			return
		end
	else if @DiaChi = '' or @DiaChi is null
		begin
			print 'Dia chi khong duoc bo trong'
			rollback transaction;
			return
		end
	else if @SDT not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		begin
			print 'SDT phai co dung 10 chu so'
			rollback transaction;
			return
		end
	else 
		begin
			insert into KhachHang ( MaKH, TenKH, DiaChi, SDT, NSinh)
			select * from inserted
			if @@rowcount <1
				print ' Du lieu chua duoc nhap vao he thong'
			else 
				print 'Du lieu da duoc nhap vao he thong'
		end	
end

insert into KhachHang values ('KH1007', 'Maiii','Da Nang', '0987854610','')

ALTER TABLE KhachHang
DISABLE trigger KiemTraThemKhachHang

/*Module 2: Ktra KH da co trong CSDL hay chua 
neu chua thi tao ma KH moi, 
neu roi thi tiep tuc su dung maKH do
tao ma hoa don moi khi ham duoc goi*/
/*input: TenKH
output: MaDH, MaKH, loai khach hang (moi: 0, cu: 1)
process: 
1.	Tạo mã đơn hàng mới
1.1.	Tìm mã đơn hàng lớn nhất hiện tại trong bảng HoaDon
1.2.	Lấy độ dài của mã hóa đơn trừ đi 2 kí tự ‘HD’ đầu chuỗi. Chuyển các chữ số sau đó thành kiểu số int.  Thêm số 0 vào giữa ‘HD’ và kí tự kiểu int để đảm bảo độ dài chuỗi
1.3.	Lưu vào biến @MaDH
2.	Kiểm tra khách hàng đã có mã khách hàng hay chưa
2.1.	Từ tên của khách hàng được nhập vào, tìm trong bảng KhachHang xem khách hàng này có tồn tại không?
-	Nếu có: sử dụng mã khách hàng đã tồn tại
-	Nếu chưa có: tạo mã khách hàng mới
+ Đếm số lượng khách hàng hiện có, cộng thêm một. Đặt kí tự ‘KH’ ở đầu chuỗi, thêm số lượng số 0 phù hợp vào giữa KH và số thứ tự khách hàng. 
+ Lưu biến vào @MaKH
*/

create or alter function f_TaoMaDHvaMaKH (@TenKH varchar(100))
returns @HoaDonMoi table (
							MaDH varchar(20),
							MaKH varchar(20),
							TenKH varchar(100),
							IsNewKH bit)
as
begin
	declare @MaDH varchar(20),
			@MaKH varchar(20),
			@IsNewKH bit = 0;

	select  @MaDH = 'DH' + right('0000' + cast(max(cast(substring(MaDH,3,len(MaDH)-2) as int))+1 as varchar),4)
	from HoaDon

	if exists (select 1 from KhachHang where TenKH = @TenKH)
		begin
			select @MaKH = MaKH from KhachHang where TenKH = @TenKH
			set @IsNewKH = 1;
		end
	else
		begin
			select @MaKH = 'KH' + right( '0000' + cast(max(cast(substring(MaKH, 3, len(MaKH)-2) as int)) +1 as varchar),4)
			from KhachHang
			set @IsNewKH = 0;
		end
		insert into @HoaDonMoi (MaDH, MaKH, TenKH, IsNewKH)
		values (@MaDH, @MaKH, @TenKH, @IsNewKH)
		return 
end

select * from KhachHang
select * from dbo.f_TaoMaDHvaMaKH ('Lisa')



/*Module 3: Tao hoa don moi*/

create or alter proc sp_TaoHoaDonMoi @TenKH varchar(100),
									@MaNV varchar(20),
									@DChi varchar(225),
									@SDT char(10),
									@NSinh date
as
begin
	declare @MaDH varchar(20),
			@MaKH varchar(20),
			@MaSP varchar(20),
			@SoLuong int,
			@DGia float,
			@TongTien float,
			@PTram int,
			@IsNewKH bit,
			@NTao date = getdate()

	select @MaDH = MaDH,
			@MaKH = MaKH,
			@IsNewKH = IsNewKH
	from f_TaoMaDHvaMaKH(@TenKH);

	if @IsNewKH = 0
	begin
		insert into KhachHang
		values (@MaKH, @TenKH, @DChi, @SDT, @NSinh)
		set @IsNewKH = 1
		print 'Da nhap thong tin khach hang'
	end

	insert into HoaDon
	values (@MaDH, @MaNV, @NTao, @MaKH)
	print 'Da nhap thong tin hoa don'

	declare product_cursor cursor for
	select MaSP, SoLuong from #Products;
	open product_cursor;
	fetch next from product_cursor into @MaSP, @SoLuong;
	while @@FETCH_STATUS = 0
	begin
		select @DGia = DGia
		from SanPham
		where MaSP = @MaSP

		select @PTram = PTram
		from ChuongTrinhKhuyenMai
		where MaSP = @MaSP

		if @MaSP is not null
		begin
			set @TongTien += (@DGia * @SoLuong ) - (@DGia * @SoLuong * @PTram/100)

			insert into HoaDonChiTiet
			values (@MaDH, @MaSP, @SoLuong, @TongTien)
			print 'Da nhap thong tin hoa don chi tiet'
		end
		else 
		print 'San pham co ma ' +@MaSP + ' khong ton tai'
		fetch next from product_cursor into @MaSP, @SoLuong;
	end
	close product_cursor;
	deallocate product_cursor
end

/*test*/
create table #Products( MaSP varchar(20),
						SoLuong int)
go
insert into #Products values ('SP0101', 2)
insert into #Products values ('SP0202', 1)
go
exec sp_TaoHoaDonMoi @TenKH = 'Jennie', 
					@MaNV = 'NV00000010',
					@DChi = 'Korea',
					@SDT = '0987854610',
					@NSinh = '1978-12-11';
go
drop table #Products
go

select * from KhachHang

/*Module 4: Them san pham vao hoa don */
create or alter proc sp_addSPvaoHD
	@MaDH varchar(20),
	@MaSP varchar(20),
	@SoLuong int
as
begin

	if not exists (select 1 from HoaDon where MaDH = @MaDH)
        begin
            print 'Khong ton tai don hang co ma: ' +@MaDH
            rollback;
        end

    if not exists (select 1 from SanPham where MaSP = @MaSP)
    begin
        print 'Khong ton tai san pham co ma: ' +@MaSP
        rollback;
    end

    declare @soluongcon int;
    select @soluongcon = SoLuongSP from SanPham where MaSP = @MaSP;

    if @soluongcon < @SoLuong
    begin
        print 'San pham co ma: ' + @MaSP + ' chi con trong kho voi so luong: ' + @soluongcon
        rollback;
    end

    if exists (select 1 from HoaDonChiTiet where MaDH = @MaDH and MaSP = @MaSP)
    begin
        update HoaDonChiTiet
        set SoLuong += @SoLuong
        where MaDH = @MaDH and MaSP = @MaSP;
    end
    else
    begin
        insert into HoaDonChiTiet (MaDH, MaSP, SoLuong)
        values (@MaDH, @MaSP, @SoLuong);
    end
    declare @dongia float;
    select @dongia = DGia from SanPham where MaSP = @MaSP;

    declare @tongtien float;
    select @tongtien = isnull(TongTien, 0) + (@dongia * @SoLuong)
    from HoaDonChiTiet
    where MaDH = @MaDH;

    update HoaDonChiTiet
    set TongTien = @tongtien
    where MaDH = @MaDH;

    update SanPham
    set SoLuongSP -= @soluong
    where MaSP = @MaSP;
end

exec sp_addSPvaoHD 'DH1010' , 'SP0002', 1


select * from SanPham
select * from HoaDonChiTiet

/* Module 5: Xoa hoa don*/
create or alter proc sp_XoaHoaDon
	@MaDH varchar(20)
as
begin
	if exists (select 1 from HoaDon where MaDH = @MaDH)
	begin
		delete from HoaDonChiTiet where MaDH = @MaDH
		delete from HoaDon where MaDH = @MaDH
		print N'Da xoa thanh cong hoa don: ' + @MaDH
	end
	else
	print 'Khong ton tai hoa don co ma: ' + @MaDH
end

exec sp_XoaHoaDon 'DH1010'
select *from HoaDonChiTiet
/*Module 6: Xem hoa don*/
create or alter proc sp_XemHoaDon
	@MaDH varchar(20)
as
begin
	if exists (select 1 from HoaDon where MaDH  = @MaDH)
	begin
		select 
			h.MaDH as 'Mã Đơn Hàng',
            h.Ngtao as 'Ngày Tạo',
            nv.HTen as 'Tên Nhân Viên',
            kh.TenKH as 'Tên Khách Hàng',
            kh.SDT as 'Số Điện Thoại',
            ISNULL(ctkm.TenCT, N'Không có') as 'Tên Chương Trình Khuyến Mãi',
            ISNULL(ctkm.PTram, 0) as 'Phần Trăm Giảm Giá(%)',
            SUM(hdct.Soluong * sp.DGia) * (1 - ISNULL(ctkm.PTram, 0) / 100) as 'Tổng Tiền'
        from HoaDon h
        join KhachHang kh on h.MaKH = kh.MaKH
        join NhanVien nv on h.MaNV = nv.MaNV
        left join HoaDonChiTiet hdct on h.MaDH = hdct.MaDH
        left join SanPham sp on hdct.MaSP = sp.MaSP
        left join ChuongTrinhKhuyenMai ctkm on ctkm.MaSP = sp.MaSP
        where h.MaDH = @MaDH
        group by h.MaDH, h.Ngtao, nv.HTen, kh.TenKH, kh.SDT, ctkm.TenCT, ctkm.PTram;
        select
            hdct.MaSP as 'Mã Sản Phẩm',
            sp.TenSP as 'Tên Sản Phẩm',
            hdct.Soluong as 'Số Lượng',
            sp.DGia as 'Đơn Giá',
            (hdct.Soluong * sp.DGia) * (1 - ISNULL(ctkm.PTram, 0) / 100) as 'Thành Tiền'
        from HoaDonChiTiet hdct
        join SanPham sp on hdct.MaSP = sp.MaSP
        left join ChuongTrinhKhuyenMai ctkm on ctkm.MaSP = sp.MaSP
        where hdct.MaDH = @MaDH;
    end
    else
    begin
        print N'Hóa đơn với mã ' + @MaDH + N' không tồn tại.';
    end
end

exec sp_XemHoaDon @MaDH = 'DH0002';  




/*Module 7:  Module Kiểm tra tính Hợp Lệ Dữ Liệu Nhân Viên khi nhập vào: 
Kiểm Tra Tính Độc Nhất của Mã Nhân Viên,  Số Điện Thoại, Ngày Sinh, Chức Vụ*/
create or alter trigger trg_KiemTraHopLeNhanVien
on NhanVien
after insert, update
as
begin
	declare @MaNV varchar(20), 
			@HTen varchar(100), 
			@SDT varchar(10),
			@NSinh date,
			@ChucVu varchar(50)
	select @MaNV = MaNV,
			@HTen = HTen, 
			@SDT = SDT, 
			@NSinh = NSinh, 
			@ChucVu = ChucVu
    from inserted;

	if exists ( select MaNV 
				from NhanVien
				where MaNV = @MaNV
				group by MaNV
				having count(*) > 1 )
	begin
		print 'Ma nhan vien bi trung'
		rollback
	end

	if @NSinh > getdate() or year(@NSinh) < 1950
	begin
		print 'Ngay sinh khong hop le'
		rollback
	end

	if @ChucVu not in (N'Nhân viên', N'Quản lý')
	begin
		print 'Chuc vu khong hop le'
		rollback
	end

	if @SDT is null or @ChucVu is null
	begin
		print 'Thieu thong tin bat buoc (sdt/ chuc vu)'
		rollback
	end
	print 'Thong tin nhan vien hop le'
end

insert into NhanVien(MaNV,HTen, SDT, ChucVu)
values ('NV0012', 'Nguyen Thi An', '0985462463',N'nhân viên')

/*Module 8: */
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

INSERT INTO SanPham (MaSP, TenSP, SoLuongSP, DGia, MoTa)
VALUES ('SP199998', N'Sản phẩm C', 10, 10000, 'Mô tả sản phẩm C');

INSERT INTO SanPham (MaSP, TenSP, SoLuongSP, DGia, MoTa)
VALUES ('SP1001', 'Sản phẩm B', 5, -5000, 'Mô tả sản phẩm B');
select * from SanPham
SELECT * FROM HoaDonChiTiet


--Module 9:Kiểm tra các sản phẩm không còn được giao dịch trong một thời gian dài (ví dụ hơn 4 tháng). 
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

/*Module 10: Module kiểm tra các sản phẩm đã hết hàng: Kiểm tra và liệt kê các sản phẩm gần/hết hàng.*/
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


/*Module 11:Kiểm tra mã chương trình khuyến mãi có tồn tại không:*/
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


/*Module 12: Kiểm tra thời gian hiệu lực của chương trình khuyến mãi và Kiểm tra phần trăm khuyến mãi (PTram) có hợp lệ và Kiểm tra sản phẩm có được áp dụng khuyến mãi không?*/
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

/*Phân quyền*/
--Tạo tài khoản và phân quyền cho quản lý
create login quanly2 with password = 'quanly2'
create user quanly2 for login quanly2
grant control on database::DQNN to quanly2;

--Tạo tài khoản cho nhân viên

create login nhanvien3 with password = 'nhanvien3';

create user nhanvien3 for login nhanvien3

grant insert on dbo.HoaDon to nhanvien3
grant insert on dbo.HoaDonChiTiet to nhanvien3
grant insert on dbo.KhachHang to nhanvien3

grant update on dbo.HoaDon to nhanvien3
grant update on dbo.HoaDonChiTiet to nhanvien3
grant update on dbo.KhachHang to nhanvien3

grant select on dbo.HoaDon to nhanvien3
grant select on dbo.HoaDonChiTiet to nhanvien3
grant select on dbo.KhachHang to nhanvien3
grant select on dbo.SanPham to nhanvien3
grant select on dbo.ChuongTrinhKhuyenMai to nhanvien3
grant select on dbo.NhanVien to nhanvien3







