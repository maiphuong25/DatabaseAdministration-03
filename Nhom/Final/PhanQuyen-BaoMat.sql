/*Phân quyền cho quản lý có toàn bộ quyền đối với CSDL;
Nhân viên có quyền xem tất cả các bảng;
		có quyền sửa đối với bảng (HoaDon), (HoaDonChiTiet), (KhachHang), (SanPham);
		có quyền tạo đối với các bảng (HoaDon), (HoaDonChiTiet), (KhachHang)*/

-- Tạo Login
CREATE LOGIN quanly WITH PASSWORD = 'quanly';
CREATE LOGIN nhanvien1 WITH PASSWORD = 'nhanvien1';
CREATE LOGIN nhanvien2 WITH PASSWORD = 'nhanvien2';

-- Tạo User trong cơ sở dữ liệu
CREATE USER quanly FOR LOGIN quanly;
CREATE USER nhanvien1 FOR LOGIN nhanvien1;
CREATE USER nhanvien2 FOR LOGIN nhanvien2;

-- Phân quyền toàn quyền (CONTROL) cho Quản lý
GRANT CONTROL ON DATABASE::DQNN TO quanly;

-- Phân quyền SELECT (xem) cho Nhân viên
GRANT SELECT ON dbo.HoaDon TO nhanvien1;
GRANT SELECT ON dbo.HoaDonChiTiet TO nhanvien1;
GRANT SELECT ON dbo.KhachHang TO nhanvien1;
GRANT SELECT ON dbo.NhanVien TO nhanvien1;
GRANT SELECT ON dbo.ChuongTrinhKhuyenMai TO nhanvien1;
GRANT SELECT ON dbo.SanPham TO nhanvien1;



GRANT SELECT ON dbo.HoaDon TO nhanvien2;
GRANT SELECT ON dbo.HoaDonChiTiet TO nhanvien2;
GRANT SELECT ON dbo.KhachHang TO nhanvien2;
GRANT SELECT ON dbo.NhanVien TO nhanvien2;
GRANT SELECT ON dbo.ChuongTrinhKhuyenMai TO nhanvien2;
GRANT SELECT ON dbo.SanPham TO nhanvien2;

-- Phân quyền INSERT (thêm) cho Nhân viên
GRANT INSERT ON dbo.HoaDon TO nhanvien1;
GRANT INSERT ON dbo.HoaDonChiTiet TO nhanvien1;
GRANT INSERT ON dbo.KhachHang TO nhanvien1;

GRANT INSERT ON dbo.HoaDon TO nhanvien2;
GRANT INSERT ON dbo.HoaDonChiTiet TO nhanvien2;
GRANT INSERT ON dbo.KhachHang TO nhanvien2;


-- Phân quyền UPDATE (sửa) cho Nhân viên
GRANT UPDATE ON dbo.HoaDon TO nhanvien1;
GRANT UPDATE ON dbo.HoaDonChiTiet TO nhanvien1;
GRANT UPDATE ON dbo.KhachHang TO nhanvien1;
GRANT UPDATE ON dbo.SanPham TO nhanvien1;

GRANT UPDATE ON dbo.HoaDon TO nhanvien2;
GRANT UPDATE ON dbo.HoaDonChiTiet TO nhanvien2;
GRANT UPDATE ON dbo.KhachHang TO nhanvien2;
GRANT UPDATE ON dbo.SanPham TO nhanvien2;

--Phân quyền gọi tất cả các hàm và thủ tục cho nhân viên
GRANT EXECUTE TO nhanvien1;
GRANT EXECUTE TO nhanvien2;



-- Kiểm tra quyền của nhanvien
SELECT dp.name AS UserName, p.permission_name, p.state_desc, o.name AS ObjectName
FROM sys.database_permissions p
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects o ON p.major_id = o.object_id
WHERE dp.name = 'nhanvien1';


select * from sys.database_permissions
select * from sys.database_principals
select * from sys.objects


