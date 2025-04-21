/*10.	Trả về mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: 
MAX(mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch*/
CREATE FUNCTION fMaGD()
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @last_t_id VARCHAR(10), @new_tid VARCHAR(10)
	SELECT @last_t_id=max(t_id) FROM transactions
	SET @new_tid=CAST(CAST(@last_t_id AS INT) + 1 AS VARCHAR(10))
	--SET @new_tid=right('0000000000'+@new_tid,10)
	SET @new_tid=REPLICATE('0',10-LEN(@new_tid))+@new_tid
	RETURN @new_tid
END

/*11.	Thêm một bản ghi vào bảng TRANSACTIONS 
nếu biết các thông tin ngày giao dịch, thời gian giao dịch, 
số tài khoản, loại giao dịch, số tiền giao dịch. Công việc cần làm bao gồm:*/
/*INPUT:	ngày giao dịch, 
			thời gian giao dịch, 
			số tài khoản, 
			loại giao dịch, 
			số tiền giao dịch
OUTPUT: Thêm bản ghi vào transactions 
PROCESS: 
a. Ngay GD & Thoi gian GD < HIEN TAI. co 2 TH: ngay GD> hien tai
												ngay GD= hien tai BUT gio GD> hien tai*/
CREATE OR ALTER PROC spADD (@ngay date,
							@thoigian time,
							@stk varchar(20),
							@loaiGD bit,
							@soTien int,
							@kq bit output) -- 0: khong hop le, 1: hop le
AS
BEGIN
	DECLARE @maGD
--a.	Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lý
IF @ngay<CAST(GETDATE() AS DATE)
BEGIN
	SET @kq=1
END
ELSE IF @ngay=CAST(GETDATE() AS DATE)
	BEGIN
		IF @thoigian<CAST(GETDATE() AS TIME)
		SET @kq=1
	END
ELSE 
BEGIN 
	SET @kq=0
	RETURN
END
--b.	Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý
IF @stk IN (SELECT ac_no FROM transactions)
BEGIN
	SET @kq=0
	RETURN
END
--c.	Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý
IF @loaiGD not in (0,1)
BEGIN
	SET @kq=1
END
ELSE SET @kq=0
--d.	Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
IF @soTien<0
BEGIN
	SET @kq=0
	RETURN
END
--e.	Tính mã giao dịch mới
IF @kq = 1
BEGIN
	SET @maGD=dbo.fMaGD()
END

--f.	Thêm mới bản ghi vào bảng TRANSACTIONS
g.	Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch
