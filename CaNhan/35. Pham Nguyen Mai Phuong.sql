--DIEM GK CHIEM 30%

--CAU1
/*INPUT: N/A
OUTPUT: Ma san pham moi
PROCESS:	b1: lay ra ma san pham lon nhat dang co trong bang product
			b2: cong them 1 cho ma vua lay ra
			b3: tra ve ma vua tao
*/
CREATE OR ALTER FUNCTION fTaoMaSP()
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @MaSP VARCHAR(20)
	SET @MaSP = (SELECT MAX(product_id) +1 
				FROM production.products)
	RETURN @MaSP
END

--test
SELECT dbo.fTaoMaSP()


SELECT * FROM production.products

--CAU 2:
/*INPUT: ten san pham, ma thuong hieu, loai ma, nam san xuat, gia
OUTPUT: san pham duoc them vao bang product
PROCESS:	1. kiem tra nam san xuat:
			 - neu nam san xuat > nam hien tai --> thong bao loi va ket thuc
			 - neu bang hoac nho hon --> tiep tuc
			2. Kiem tra ten san pham:
			 (ten san pham gom chuoi + 4 chu so)
			  - neu 4 chu so cuoi = nam san xuat --> tiep tuc
			  - nguoc lai --> thong bao loi va ket thuc
			 3. Kiem tra ma thuong hieu:
			  - neu ma thuong hieu ton tai trong bang thuong hieu --> tiep tuc
			  - nguoc lai --> thong bao loi va ket thuc
			 4. Kiem tra ma loai:
			  - neu ma loai co trong bang loai san pham --> tiep tuc
			  - nguoc lai --> thong bao loi va ket thuc
			 5. Them san pham vao bang products
			  - thong bao ket qua them vao 
			   + neu @@rowcount >0 thanh cong 
			   + neu @@rowcount =0 khong thanh cong
			   */
CREATE OR ALTER PROC spThemSP(
		@TenSP NVARCHAR(100),
		@brand_id VARCHAR(20),
		@categiry_id INT,
		@model_year INT,
		@list_price FLOAT)
AS
BEGIN
--1
	IF @model_year > YEAR(GETDATE())
	BEGIN
		PRINT N'Nam khong hop le'
		RETURN
	END
--2
	IF RIGHT(@TenSP,4) <> @model_year
	BEGIN
		PRINT N'Ten san pham khong hop le'
		RETURN
	END 
--3
	IF (SELECT COUNT(*)
		FROM production.brands
		WHERE brand_id = @brand_id) = 0
	BEGIN
		PRINT N'Ma thuong hieu khong ton tai'
		RETURN
	END
--4
	IF (SELECT COUNT(*)
		FROM production.categories
		WHERE category_id = @categiry_id) =0 
	BEGIN
		PRINT N'Ma loai khong ton tai'
		RETURN
	END
--5
	DECLARE @MaSP VARCHAR(20)
	SET @MaSP = dbo.fTaoMaSP()
	INSERT production.products (product_name, brand_id, category_id, model_year, list_price)
	VALUES (@TenSP, @brand_id, @categiry_id, @model_year, @list_price)
	IF @@ROWCOUNT > 0
	PRINT N'Them san pham thanh cong'
	ELSE
	PRINT N'Them san pham that bai'
END

--test
EXEC spThemSP 'Hello-2024', 3, 7, 2024, 500
EXEC spThemSP 'Sanphammoihehe - 2024',1,3,'2024',9999
EXEC spThemSP 'newspspsps-2023',5,4,'2024',999.999

select * from production.products
select * from production.categories


--CAU3
/*LOAI: TRIGGER
LOAI TRIGGER: I
INPUT: N/A
OUTPUT: Thong bao ten loai san pham co hop le khong
PROCESS:	b1: tim ten loai san pham duoc nhap vao co trong bang categories va dem so luong ban ghi 
			 - neu = 0 thi thong bao hop le va tra ve ten loai san pham 
			 - neu > 0 thi thong bao ten loai san pham da ton tai		
*/
CREATE TRIGGER tgCheckTenLSP
ON production.categories
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @TenLSP NVARCHAR(100)
	SELECT @TenLSP = category_name
	FROM inserted
	IF	(SELECT COUNT(*)
		FROM production.categories
		WHERE @TenLSP = category_name) > 0
	BEGIN
		PRINT N'Ten loai san pham khong hop le'
		ROLLBACK
	END
	ELSE
	BEGIN
		PRINT N'Ten san pham hop le'
	END
END

--test
INSERT production.categories
VALUES ('Hello')

INSERT production.categories
VALUES ('Road Bikes')

-------------------------------------------------------------------------
/*CHỮA BÀI*/
--Nếu muốn để <chuỗi> - <4 chữ số> thì viết code là:
if not (@product_name like '% - [0-9][0-9][0-9][0-9]' and
	cast(right(@product_name, 4) as int ) = @model_year


---------------------------
/*Cau2: (de lop khac)*/
/*INPUT: @customer_id, @requied_date, @store_id, #staff_id
OUTPUT: thong tin duoc them vao bang dat hang
PROCESS: b1: kiem tra hop le cua ma KH: 
			- neu chua ton tai trong bang khach hang --> khong hop le: dung ct
			- nguoc lai: tiep tuc
		b2: kiem tra hop le cua ma cua hang:
			- neu chua ton tai trong bang cua hang --> khong hop le: dung ct
			- nguoc lai: tiep tuc
		b3: kiem tra ngay dat hang:
			phai la ngay hien tai
			@oder_status mac dinh la 1
		b4: them moi thong tin dat hang vao bang dat hang*/
GO
CREATE OR ALTER PROC spAddDH (@customer_id int,
					@requied_date date,
					@store_id int, 
					@staff_id int)

AS
BEGIN
	DECLARE @oder_status tinyint

--1
	IF (SELECT COUNT(*)
		FROM sales.customers
		WHERE customer_id = @customer_id) = 0
	BEGIN
		PRINT 'Ma khach hang khong hop le'
		RETURN
	END
--2
	IF (SELECT COUNT(*)
	FROM sales.stores
	WHERE store_id = @store_id) = 0
	BEGIN
		PRINT 'Ma cua hang khong hop le'
		RETURN
	END
--3
	IF @requied_date <> cast ( GETDATE() AS DATE)
	BEGIN
		PRINT 'Ngay khong hop le'
		RETURN
	END
	ELSE
	BEGIN
		SET @oder_status = 1
	END
--4
	 INSERT sales.orders(customer_id, order_status, required_date, store_id, staff_id)
	 VALUES (@customer_id, @oder_status, @requied_date, @store_id, @staff_id)
	 IF @@ROWCOUNT > 0 
	 PRINT ' Them don hang thanh cong'
	 ELSE
	 PRINT ' Them don hang that bai'
END

EXEC spAddDH 15,'2024-10-28',2,3
SELECT * FROM sales.orders
										