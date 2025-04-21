-------------------------------ÔN TẬP GIỮA KÌ--------------------------------
/*1. HÀM (2đ)
10.	Trả về mã giao dịch mới. 
Mã giao dịch tiếp theo được tính như sau: 
MAX(mã giao dịch đang có) + 1. 
Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch*/
-----PHÂN TÍCH--------
/*INPUT: N/A
OUTPUT: mã giao dịch mới 
PROCESS:	b1: Tìm mã giao dịch lớn nhất hiện có
			b2: Trong một chuỗi kí tự mã giao dịch:
				TH1: những kí tự đầu tiên bắt đầu bằng số khác 0: chỉ việc +1 vào số đó
				TH2: những kí tự đầu tiên bắt đầu bằng số 0: 
				 - Tìm vị trí đầu tiên của số khác 0
				 - lấy chuỗi có vị trí bắt đầu này đến hết chuỗi +1
				 - thêm các số 0 vào trước chuỗi để đảm bảo độ dài ban đầu 
			b3: in ra và lưu lại mã giao dịch mới*//
----CODE------
create or alter function fCreateNewID()
returns nvarchar(20)
as
begin
	declare @idcu varchar(20),
			@idmoi varchar(20)
	select @idcu = max(t_id)
	from transactions 
	if PATINDEX('%[^0]%', @idcu)=1
	begin 
		set @idmoi = @idcu + 1
	end
	else 
	begin
		set @idmoi= concat(replicate('0',len(@idcu)-(patindex('%[^0]%',@idcu)+1)), (right(@idcu,(len(@idcu)-patindex('%[^0]%',@idcu)+1)))+1)
	end
	return @idmoi
end

--test
select dbo.fCreateNewID()
select max(t_id)
from transactions

/*2. Thủ tục (6đ)
/*11.	Thêm một bản ghi vào bảng TRANSACTIONS nếu biết các thông tin ngày giao dịch,
thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch. Công việc cần làm bao gồm:
a.	Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lý
b.	Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý
c.	Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý
d.	Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
e.	Tính mã giao dịch mới
f.	Thêm mới bản ghi vào bảng TRANSACTIONS
g.	Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch
*/
-------PHÂN TÍCH-------
/*INPUT:	ngày giao dịch (@ngayGD),
			thời gian giao dịch (@tgGD),
			số tài khoản (@stk),
			loại giao dịch (@loaiGD),
			số tiền giao dịch (@sotien)
OUTPUT: ket qua thuc hien @check
PROCESS: 
		a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không:
			(ngày và thời gian giao dịch không được lớn hơn ngày hiện tại )
			- TH1: ngày > hiện tại --> ngừng xử lý -- thông báo N'ngày lớn hơn ngày hiện tại'
			- TH2: ngày = hiện tại NHƯNG giờ > hiện tại --> ngừng xử lý N'thời gian lớn hơn thời gian hiện tại'
			- TH3: ngày & giờ <= hiện tại : set @check =1
		b. Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không?
			tìm stk nhập vào trong bảng account 
			- nếu không tìm thấy --> ngừng xử lý -- thông báo N'Số tài khoản không tồn tại'
			- nếu tìm thấy --> set @check = 1
		c. Kiểm tra loại giao dịch có phù hợp không? 
			- nếu loại giao dịch không phải là loại 1--gửi tiền  và 0-- rút tiền --> ngừng xử lý
			- nếu là 1 trong 2 loại trên --> set @check = 1
		d. Kiểm tra số tiền có hợp lệ không (lớn hơn 0)?
			- nếu số tiền <= 0 --> ngừng xử lý
			- ngược lại: set @check = 1
		e. Tính mã giao dịch mới
			sd hàm đã tạo :
			dbo.fCreateNewID()
		f. Thêm mới bản ghi vào bảng TRANSACTIONS
			 insert into transactions (t_date, t_time, ac_no, t_type, t_amount)
			 value (@ngayGD, @tgGD, @stk, @loaiGD, @sotien)
		g. Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch
			tùy theo loại giao dịch
			- nếu là loại giao dịch gửi thì cộng @sotien vào ac_balance
			- nếu là loại giao dịch rút thì trừ @sotien từ ac_balance*/
----CODE-----*/
create or alter proc spAddRecod (@ngayGD date,
								@tgGD time,
								@stk varchar(20),
								@loaiGD bit,
								@sotien int,
								@check bit out)
as
begin
	declare @ngayHT date,
			@gioHT time,
			@maGD varchar(20)
--a
	set @ngayHT = cast(getdate() as date) 
	set @gioHT = cast(getdate() as time)
	set @check =	case	when @ngayHT < @ngayGD
							then 1
							when @ngayHT > @ngayGD
							then 0
							when @ngayHT = @ngayGD and @gioHT < @tgGD
							then 0
							when @ngayHT = @ngayGD and @gioHT >= @tgGD
							then 1
					end
--b	
	if @stk not in (select ac_no from account)
	set @check = 0
	else 
	set @check = 1
--c
	if @loaiGD not in (0,1)
	set @check = 0
	else 
	set @check = 1
--d
	if @sotien <= 0
	set @check = 0 
	else 
	set @check = 1
--e
	if @check = 1
	set @maGD = dbo.fCreateNewID()
	else
	return
--f
	if @check = 1
	insert into transactions (t_id,t_date, t_time, ac_no, t_type, t_amount)
	values (@maGD,@ngayGD, @tgGD, @stk, @loaiGD, @sotien)
	else
	return
	
--g 
	if @check = 1
	begin
		if @loaiGD = 1
		update account 
		set ac_balance += @sotien
		where @stk = ac_no
		else
		update account 
		set ac_balance -= @sotien
		where @stk = ac_no
	end
	else
	return
end

declare @a bit 
exec spAddRecod '2024-01-25','20:00:00','1000000001',1,1, @a out
print @a

/*12.	Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. Bao gồm những công việc sau:
a.	Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
b.	Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
c.	Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
d.	Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
e.	Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có.*/
-----------PHÂN TÍCH-----------
/*INPUT: mã khách hàng, loại tài khoản, số tiền trong tài khoản
OUTPUT: Tài khoản mới (ac_no mới)
PROCESS: a. tìm @maKH trong bảng customer 
			- nếu không tìm được: ngừng xử lý
			- nếu tìm được: tiếp tục xử lý
		 b. Nếu @LoaiTK không phải 0 hoặc 1 thì ngừng xử lý, ngược lại: tiếp tục xử lý
		 c. Nếu null thì set @SoTien là 50000
			Nếu <0 thì ngừng xử lý
		 d. Tìm số tài khoản lớn nhất đang có trong bảng account rồi +1 để tạo stk mới 
		 e. Thêm mới dữ liệu vào account.*/
CREATE OR ALTER PROC spThemTKmoi (
		@MaKH VARCHAR(20),
		@LoaiTK BIT,
		@SoTien INT,
		@check BIT out) -- @check = 1: thanh cong, = 0: khong thanh cong
AS
BEGIN
	SET @check = 0

	IF NOT EXISTS (SELECT 1 FROM customer WHERE cust_id = @MaKH)
	BEGIN
		RETURN
	END

	IF @LoaiTK NOT IN (0,1)
	BEGIN
		RETURN
	END

	IF @SoTien IS NULL 
	SET @SoTien = 50000
	ELSE IF @SoTien < 0
	BEGIN
		RETURN
	END

	DECLARE @STK VARCHAR(20)
	SELECT @STK = MAX(ac_no) +1
	FROM account
	
	INSERT account 
	VALUES (@STK, @SoTien, @LoaiTK, @MaKH)
	SET @check = 1
END

DECLARE @a BIT 
EXEC spThemTKmoi '000001' ,0,12, @a out
print @a

select * from account
where cust_id = '000001'


/*--2.Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
--a.Kiểm tra trạng thái tài khoản của giao dịch hiện hành. 
--Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
--i.Nếu là giao dịch gửi: số dư = số dư + tiền gửi.
--ii. Nếu là giao dịch rút: số dư = số dư – tiền rút. Nếu số dư sau khi thực hiện giao dịch < 50.000 
--thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.

-- Ko co input output; 
-- a) sk theo bảng nào thì trigger trên bảng đó.

-- bang: transactions
-- loai: after
-- su kien: insert
-- process: 1. lấy ac_no, t_type, t_amount đang insert ở bảng inserted --> @ac_no, @t_type, @t_amount
		--  2. lay ac_type, ac_balance trong bang account, dk: ac_no = @ac_no --> @ac_type, @ac_balance
		-- 3. nếu @ac_type=9 thì thông báo 'tk bị xóa' và hủy thao tác --> Rollback
		-- 4. Ngược lại:
			--4.1: nếu @t_type=1: update account: ac_balance = ac_balance + @t_amount
								-- dkien: ac_no = @ac_no
			--4.2: nế @t_type= 0:
				-- Neu @ac_balance - @t_amount <50000 -> tbao: 'khong đủ tiền' -> rollback
				-- nguoc lai --> cap nhat: update account, ac_balance= ac_balance - @t_amount
															-- dk: ac_no=@ac_no.*/	
															

CREATE OR ALTER TRIGGER tgThemDuLieu
ON transactions
FOR INSERT
AS 
BEGIN
	DECLARE @ac_no VARCHAR(20),
			@t_type BIT,
			@t_amount INT,
			@ac_type BIT,
			@ac_balance INT

	SELECT	@ac_no = ac_no,
			@t_type = t_type,
			@t_amount = t_amount
	FROM INSERTED

	SELECT	@ac_type = ac_type,
			@ac_balance = ac_balance
	FROM account
	WHERE @ac_no = ac_no
	IF @ac_type = 9
	BEGIN
		PRINT N'Tài khoản đã bị xóa'
		ROLLBACK
	END
	ELSE
	BEGIN
		IF @t_type = 1
		BEGIN
			UPDATE account
			SET ac_balance = ac_balance +  @t_amount
			WHERE ac_no = @ac_no
		END
		ELSE
		BEGIN
			IF @ac_balance - @t_amount <50000
			BEGIN
				PRINT N'Khong du tien'
				ROLLBACK
			END
			ELSE
			BEGIN
				UPDATE account
				SET ac_balance -= @t_amount
				WHERE ac_no = @ac_no
			END
		END
	END
	IF @@ROWCOUNT >= 1 
	PRINT N'nhap du lieu thanh cong'
	ELSE
	PRINT N'Nhap  du lieu that bai'
END

INSERT INTO transactions
VALUES ('3900000201',0,300000,'2024-10-20','10:00:00','1000000063')

insert into transactions values ('0000000401','0',1528308,'2020-11-03','09:00:00','1000000998')
insert into transactions values ('0000000402','1',1528308,'2020-11-03','09:00:00','1000000001')

SELECT * FROM account
where ac_no = '1000000063'
SELECT * FROM transactions

-------------------------------------------------------------------------------------------------------------------------------------------------------
/*CẤU TRÚC CỦA PROC

CREATE  PROC spten thu tuc (@tham so input/output)
AS
BEGIN
	-
	-
	-
	
mọi lệnh DML
	nếu có RETURN các câu lệnh sẽ dừng ngay tại đó và bỏ qua các lệnh phía sau
END

gọi tường minh: EXEC
thường là các câu lệnh thay đổi dữ liệu
trả về nhiều hơn một giá trị đầu ra

//////////////////////////////////////////////////////
CẤU TRÚC CỦA HÀM 

CREATE FUNCTION ften ham (@tham so input)
RETURNS type_data tra ve
AS
BEGIN
           -
           -
           -

          chỉ dùng lệnh SELECT
		  RETURN
END

gọi nhúng vào mọi phép toán thông qua: SELECT, JOIN, WHERE, FROM

//////////////////////////////
CẤU TRÚC CỦA TRIGGER 

CREATE TRIGGER Tên trigger
ON tên bảng áp dụng trigger
ALTER (FOR) | INSTEAD OF INSERT, DELETE, UPDATE 
AS
BEGIN
	Các lệnh của trigger
END
------
INSERTED 	chứa bản copy dữ liệu được insert
DELETED		chứa bản copy dữ liệu bị xóa
------
Ý nghĩa: 
	- ALTER  INSERT, DELETE, UPDATE 
tức là  INSERT, DELETE, UPDATE  xong mới chạy trigger
có thể Ctrl+C bằng lệnh ROLLBACK  hihi
	-  INSTEAD OF INSERT, DELETE, UPDATE 
tức là thay vì  INSERT, DELETE, UPDATE thì tui làm việc khác nhó kkk GIỐNG NHƯ CẬP NHẬT VIEW THÔI CHỚ BACK-END thì NO!!!!!!!!
------
Bật tắt 1 trigger: 
ALTER TABLE Tên bảng
DISABLE / ENABLE Tên trigger nếu mún tắt hết thì để là ALL nhó