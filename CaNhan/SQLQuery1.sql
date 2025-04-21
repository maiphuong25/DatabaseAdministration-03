/*2.	Trong vòng 10 năm trở lại đây Nguyễn Lê Minh Quân 
có thực hiện giao dịch nào không? Nếu có, 
hãy trừ 50.000 phí duy trì tài khoản. */
declare @GD varchar(50) , @thoigian date, @tl nvarchar(6),@sodu int
select @GD= t.t_type,
		@thoigian= t.t_date,
		@sodu = a.ac_balance
from transactions t join account a on t.ac_no = a.ac_no
					join customer c on c.cust_id=c.cust_id
where c.cust_name = N'Nguyễn Lê Minh Quân'
	and @thoigian between year(getdate() - 10) and year(getdate())
	
if count(@GD)>0
begin	set @tl = N' có'
		set @sodu= @sodu-50000 end
else 
begin	set @tl =N' không' end
print N'Trong vòng 10 năm trở lại đây Nguyễn Lê Minh Quân' +@tl + N'thực hiện giao dịch'
/*4.	Đưa ra nhận xét về nhà mạng mà Lê Anh Huy đang sử dụng? 
(Viettel, Mobi phone, Vinaphone, Vietnamobile, khác)*/

/*7.	Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc miền nào? 
Gợi ý: nếu mã chi nhánh là VN  miền nam, VT  miền trung, VB  miền bắc, còn lại: bị sai mã.*/