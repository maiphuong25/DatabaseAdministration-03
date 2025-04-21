﻿-- Tạo cơ sở dữ liệu DQNN
CREATE DATABASE DQNN;
GO

USE DQNN;
GO

-- Bảng: SanPham
CREATE TABLE SanPham 
(
    MaSP VARCHAR(20) PRIMARY KEY,      
    TenSP VARCHAR(100) NOT NULL,             
    SoLuongSP INT CHECK (SoLuongSP >= 0),              -- Kiểm tra số lượng sản phẩm không âm
    DGia FLOAT CHECK (DGia >= 0),        -- Kiểm tra đơn giá không âm
    MoTa VARCHAR(255)                   
);
GO

-- Bảng: KhachHang
CREATE TABLE KhachHang 
(
    MaKH VARCHAR(20) PRIMARY KEY,     
    TenKH VARCHAR(100) NOT NULL,           
    DiaChi NVARCHAR(255) NOT NULL,        
    SDT VARCHAR(10),              -- Số điện thoại có thể để trống
    NSinh DATETIME                
);
GO

-- Bảng: NhanVien
CREATE TABLE NhanVien
(
    MaNV VARCHAR(20) PRIMARY KEY,      
    HTen VARCHAR(100) NOT NULL,             
    SDT VARCHAR(20),                -- Số điện thoại có thể để trống
    NSinh DATETIME,                -- Ngày sinh có thể để trống
    ChucVu VARCHAR(50)              
);
GO

-- Bảng: HoaDon
CREATE TABLE HoaDon 
(
    MaDH VARCHAR(20) PRIMARY KEY,      
    MaNV VARCHAR(20) NOT NULL,                  -- Bắt buộc phải có nhân viên
    Ngtao DATE NOT NULL,                -- Ngày tạo không thể để trống
    MaKH CHAR(20) NOT NULL,                -- Khách hàng không thể để trống
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH) ON DELETE CASCADE,   -- Xóa hóa đơn khi xóa khách hàng
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV) ON DELETE CASCADE    
);
GO

-- Bảng: HoaDonChiTiet
CREATE TABLE HoaDonChiTiet 
(
    MaDH VARCHAR(20) NOT NULL,                  
    MaSP VARCHAR(20) NOT NULL,  
    Soluong INT CHECK (Soluong > 0),  -- Kiểm tra số lượng lớn hơn 0
	TongTien FLOAT,
    PRIMARY KEY (MaDH, MaSP),         
    FOREIGN KEY (MaDH) REFERENCES HoaDon(MaDH) ON DELETE CASCADE,  
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP) ON DELETE CASCADE  
);
GO

-- Bảng: ChuongTrinhKhuyenMai
CREATE TABLE ChuongTrinhKhuyenMai
(
    MaCT VARCHAR(20) PRIMARY KEY,      
    TenCT VARCHAR(100) NOT NULL,       
    NgayKT DATETIME NOT NULL,
    NgayBD DATETIME NOT NULL,
    PTram FLOAT CHECK (PTram >= 0 AND PTram <= 100),  -- Kiểm tra phần trăm giảm giá hợp lệ
    MaSP VARCHAR(20),              -- Mã sản phẩm có thể để trống
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP) ON DELETE SET NULL  
);
GO