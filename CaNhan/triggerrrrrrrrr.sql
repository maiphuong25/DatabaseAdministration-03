--1.Khi xóa dữ liệu trong bảng account, hãy thực hiện thao tác cập nhật
--trạng thái tài khoản là 9 (không dùng nữa) thay vì xóa.
--table: account
--sự kiện: delete
--loại: after
create trigger tgDelAcc
on account
instead of delete
as 
begin
	--declare @ac_no char(10)
	update account set ac_type = '9' where ac_no = (select Ac_no from deleted)
end
--try
delete account where Ac_no = '1000000001'
--2.Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
--a.Kiểm tra trạng thái tài khoản của giao dịch hiện hành. 
--Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
--i.Nếu là giao dịch gửi: số dư = số dư + tiền gửi.
--ii. Nếu là giao dịch rút: số dư = số dư – tiền rút. Nếu số dư sau khi thực hiện giao dịch < 50.000 
--thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.
-- bang: transactions
-- su kien: insert
-- loai: for
create trigger tgNewTrans
on transactions
for insert
as
begin
	declare @t_type char(1),@ac_no char(10), @ac_balance numeric(15,0), @t_amount numeric(15,0)
	select @t_type = t_type, @t_amount = t_amount, @ac_no = ac_no from inserted
	set @ac_balance = (select ac_balance from account where Ac_no = @ac_no)
	if (select ac_type from account where Ac_no = @ac_no) = 9
	begin
		print N'Tài khoản đã bị xóa'
		rollback
		return
	end

	if @t_type = 1
		Update account set ac_balance = @ac_balance + @t_amount where ac_no = @ac_no
	else if @t_type = 0
	begin
		Update account set ac_balance = @ac_balance - @t_amount where ac_no = @ac_no
		if (select ac_balance from account where Ac_no = @ac_no) < 50000
		begin
			print N'Không số dư trong tài khoản'
			rollback
			return
		end
	end
end

--test
insert into transactions values ('0000000401','0',1528308,'2020-11-03','09:00:00','1000000998')
insert into transactions values ('0000000402','1',1528308,'2020-11-03','09:00:00','1000000001')
----------------------------------------
*12.	Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. Bao gồm những công việc sau:
a.	Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
b.	Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
c.	Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
d.	Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
e.	Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có.*/
/*
INPUT:	mã khách hàng, loại tài khoản, số tiền trong tài khoản
output: không hợp lệ thì ngừng chậy / thêm mới một tk vào bảng account
process:
a) nếu mã kh không có trong bảng account thì ngừng xử lý
b) nếu loại tài khoản khác 1 và 0 thì ngừng xử lý
c) Kiểm tra số tiền trong tài khoản
nếu số tiền trong tài khoản bé hơn 0 thì ngừng xử lý
nếu số tiền null thì cho mặc định là 50000
d) tính số tài khoản mới
lấy số tài khoản mới nhất cộng 1. Phải đảm bảo rằng đúng mặc định
e)theem mới bản ghi vào bảng tài khoảng bao gồm: mã khách hàng, loại tài khoản, số tiền trong tài khoản
*/
create or alter proc cau12 (	@cust_id varchar(10),
								@ac_type char(1),
						 		@ac_balance decimal(15,0),
								@kq bit out)
as 
begin
	--a
	if not exists (select Cust_id from customer where cust_id=@cust_id)
	begin
		set @kq=0
		return
	end
	--b
	if @ac_type not in (0,1)
	begin
		set @kq=0
		return
	end
	--c
	if @ac_balance<0
	begin
		set @kq=0
		return
	end
	else if @ac_balance is null
	begin
		set @ac_balance=50000
		return
	end
	--d
	/*create or alter function dbo.ftkmoi()
	returns varchar(10)
	as
	begin
		declare @tkmoi varchar(10)
		select @tkmoi = max(cast(ac_no as int))+1 from account
		return @tkmoi
	end
	select dbo.ftkmoi()*/

	declare @matkmoi varchar(10)
	set @matkmoi=dbo.ftkmoi()
	
	--e
	insert into account (cust_id, ac_type, ac_balance,ac_no)
	values (@cust_id, @ac_type, @ac_balance,@matkmoi)

	if @@rowcount<=0
	begin
		print 'insert k thành công'
		return
	end
	else
	begin
		print 'insert thành công'
		return
	end
end

--test
declare @cust_id varchar(10),
		@ac_type char(1),
		@ac_balance decimal(15,0),
		@kq bit
set @cust_id='000001'
set @ac_type='0'
set @ac_balance='1'
exec cau12 @cust_id, @ac_type, @ac_balance, @kq out
print @kq



select * from account where cust_id='000001'
--------------------------------------------------------------------------------------------------------
--2.Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
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
				--a) Lấy ac_balance từ bảng account (ko cần)
				--a) Neu @ac_balance - @t_amount <50000 -> tbao: 'khong đủ tiền' -> rollback
				--b) nguoc lai --> cap nhat: update account, ac_balance= ac_balance - @t_amount
															-- dk: ac_no=@ac_no.
create trigger tgNewTrans
on transactions
after insert
as
begin
	declare @ac_no char(10), @t_type char(1), @t_amount numeric(15,0)
	select @t_type = t_type, @t_amount = t_amount, @ac_no = ac_no
	from inserted

	declare @ac_balance numeric(15,0), @ac_type varchar(20)
	select @ac_balance = ac_balance from account where ac_no = @ac_no
	select @ac_type = ac_type from account where ac_no = @ac_no

	if @ac_type = 9
	begin
		print N'Tài khoản đã bị xóa'
		rollback
		return
	end

	--4.1: nếu @t_type=1: update account: ac_balance = ac_balance + @t_amount
								-- dkien: ac_no = @ac_no
	if @t_type = 1
	begin
		Update account
		set ac_balance = @ac_balance + @t_amount 
		where ac_no = @ac_no
	end

	else if @t_type = 0
	begin
		Update account
		set ac_balance = @ac_balance - @t_amount 
		where ac_no = @ac_no

		if @ac_balance - @t_amount <50000 
		begin
			print N'Không đủ tiền'
			rollback
			return
		end
	end
end

select * from account
select * from transactions 
where ac_no = '1000000001'
--test
insert into transactions values ('0000000666','0',1528308,'2012-01-03','09:00:00','1000000001')
 --3. Sau khi xóa dữ liệu trong transactions hãy tính lại số dư:

--a. Nếu là giao dịch rút

--Số dư = số dư cũ + t_amount

--b.  Nếu là giao dịch gửi

--Số dư = số dư cũ – t_amount
-- bang: transactions
-- su kien: insert
-- loai: for
create trigger tgDelTrans
on transactions
for delete
as
begin
	declare @t_type char(1),@ac_no char(10), @ac_balance numeric(15,0), @t_amount numeric(15,0)
	select @t_type = t_type, @t_amount = t_amount, @ac_no = ac_no from deleted
	set @ac_balance = (select ac_balance from account where Ac_no = @ac_no)
 

	if @t_type = 1
		Update account set ac_balance = @ac_balance - @t_amount where ac_no = @ac_no
	else if @t_type = 0
		Update account set ac_balance = @ac_balance + @t_amount where ac_no = @ac_no
end
--test
select *from transactions
select * from account where Ac_no = '1000000019'
delete transactions where t_id = '0000000202'
--4.Khi cập nhật hoặc sửa dữ liệu tên khách hàng, hãy đảm bảo tên khách không nhỏ hơn 5 kí tự.
--bang: customer
--su kien: Update
--loai: after
create trigger tgUpdCust
on customer
after update
as
begin
	declare @Cust_name nvarchar(100)
	select Cust_name = Cust_name from inserted
	if (Len(@Cust_name) < 5)
	begin
		print N'Không hợp lệ'
		rollback
	end
end

--test
update customer set Cust_name = 'Mit' where Cust_id = '000001'

--5.Khi xóa dữ liệu trong bảng account, hãy thực hiện thao tác cập nhật trạng thái tài khoản là 9 (không dùng nữa) thay vì xóa.
--table: account
--sự kiện: delete
--loại: instead ò
--Trùng câu 1

--6.Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:

--a.Kiểm tra trạng thái tài khoản của giao dịch hiện hành.
-- Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại: 

--  i.Nếu là giao dịch gửi: số dư = số dư + tiền gửi.

-- ii. Nếu là giao dịch rút: số dư = số dư – tiền rút. Nếu số dư sau khi thực hiện giao dịch < 50.000 thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.
--Trùng câu 2

--7.	Khi sửa dữ liệu trong bảng transactions hãy tính lại số dư trong bảng account:
--Số dư = số dư cũ + (t_amount mới – t_amount cũ)
--Số dư = số dư cũ + (số dữ mới – số dư cũ)
-- bang: transactions
-- su kien: update
-- loai: for
alter trigger tgUpdTrans
on transactions
for update
as
begin
	declare @t_amount1 numeric(15,0), @t_amount2 numeric(15,0),@ac_no char(10),@ac_balance numeric(15,0), @t_type char(1)
	select @t_amount1 = t_amount, @ac_no = ac_no, @t_type = t_type from deleted
	select @t_amount2 = t_amount from inserted
	select @ac_balance = ac_balance from account where Ac_no = @ac_no
	if @t_type = 1
		Update account set ac_balance = @ac_balance - @t_amount1 + @t_amount2 where Ac_no = @ac_no
	else Update account set ac_balance = @ac_balance + @t_amount1 - @t_amount2 where Ac_no = @ac_no
end
 --test
 Update transactions set t_amount = 100000 where t_id = '0000000202'
 select * from account where Ac_no = '1000000019'
--8.	Sau khi xóa dữ liệu trong transactions hãy tính lại số dư trong bảng account:
--a.	Nếu là giao dịch rút
--Số dư = số dư cũ + t_amount
--b.	Nếu là giao dịch gửi
--Số dư = số dư cũ – t_amount
-- trùng câu 3

--9.	Khi cập nhật hoặc sửa dữ liệu tên khách hàng, 
--hãy đảm bảo tên khách không nhỏ hơn 5 kí tự.
--trùng câu 4

--10.	Khi tác động đến bảng account (thêm, sửa, xóa), 
--hãy kiểm tra loại tài khoản. Nếu ac_type = 9 (đã bị xóa)
--thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy các thao tác vừa thực hiện.
create trigger tgAcc
on account
after delete, insert, update
as
begin
	if ((select ac_type from deleted) = '9')
	begin
		print N'Tài khoản đã bị xóa'
		rollback
	end
	else if((select ac_type from inserted) = '9')
	begin
		print N'Tài khoản đã bị xóa'
		rollback
	end
end

--test
update account set ac_type = 1 where Ac_no ='1000000001'
--11.	Khi thêm mới dữ liệu vào bảng customer, 
--kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng thì 
--đưa ra thông báo ‘đã tồn tại khách hàng’ và hủy toàn bộ thao tác.
--bang customer
--su kien: insert
-- loai: after
create trigger tgNewCus 
on customer
after insert
as
begin
	declare @Cust_name nvarchar(100), @cust_phone varchar(15)
	select @Cust_name = Cust_name, @cust_phone = Cust_phone from inserted
	if (select Count(*) from customer where Cust_name = @Cust_name and Cust_phone = @cust_phone) = 1
	begin
		print N'Đã tồn tại khách hàng'
		rollback
	end 
end

--test
insert into customer values ('123456','Hà Công Lực','01283388103','Dak Lak','VT010')
 --12.Khi thêm mới dữ liệu vào bảng account,
 --hãy kiểm tra mã khách hàng. Nếu mã khách hàng
 --chưa tồn tại trong bảng customer thì đưa ra thông báo ‘khách hàng chưa tồn tại,
 --hãy tạo mới khách hàng trước’ và hủy toàn bộ thao tác. 
 --bảng: account
--sự kiện: insert
-- loại after

create trigger tgNewAcc
  on account
  after insert
  as
  begin
		declare @cust_id char(6), @check int
		set @cust_id = (select cust_id from inserted)
		set @check = (select COUNT(*) from customer where Cust_id = @cust_id)
		if @check < 1
		begin
			print N'Không tồn tại khách hàng, hãy tạo mới khách hàng trước'
			rollback
		end
		else
			print N'Thêm mới thành công'
  end
  --test
  insert into account values ('1000056998',789654,'1','000111')