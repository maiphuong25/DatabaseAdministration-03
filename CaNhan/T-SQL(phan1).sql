use Bank

/*1.	Viết đoạn code thực hiện việc chuyển đổi đầu số điện thoại di động 
theo quy định của bộ Thông tin và truyền thông cho một khách hàng bất kì, 
ví dụ với: Dương Ngọc Long*/
/*input: ten kh: DNL
--output: so dien thoai moi
--process:	b1: nhap vao so dien thoai cu cua kh DNL
			b2:doi so dien thoai voi dieu kien:
				neu dau so la 012 thi doi thanh 07
				neu dau so la 018 thi doi thanh 05
				neu dau so la 016 thi doi thanh 03
				neu dau so la 019 thi doi thanh 02
			b3: luu va in ra so moi*/
declare @sdtcu varchar(11), @sdtmoi varchar(10)
select @sdtcu=cust_phone
from customer
where cust_name=N'Dương Ngọc Long'
if len(@sdtcu)=11
begin
	set @sdtmoi = case when left(@sdtcu,3) ='012'
						then '07'
						when left(@sdtcu,3) ='018'
						then '05'
						when left(@sdtcu,3) ='016'
						then '03'
						when left(@sdtcu,3) ='019'
						then '02'
					end
end
print @sdtmoi +right(@sdtcu,len(@sdtcu)-3)
update customer 
		set cust_phone=@sdtmoi
		where cust_name=N'Dương Ngọc Long'



declare @phone2 varchar(10), @cust_phone varchar(15)
select @cust_phone=Cust_phone from customer where Cust_name=N'Dương Ngọc Long'
if len(@cust_phone)>10
begin
	set @phone2=case left(@cust_phone,3)
				when '012' then '07'
				when '018' then '05'
				when '016' then '03'
				end
print @phone2 + right(@cust_phone, len(@cust_phone)-3) --số mới đổi+ bên phải của sđt trừ 3 số đầu
end
else
begin
	print N'Không cần sửa'
end

/*2.	Trong vòng 10 năm trở lại đây Nguyễn Lê Minh Quân 
có thực hiện giao dịch nào không? Nếu có, 
hãy trừ 50.000 phí duy trì tài khoản. */
/*input: ten khach hang: LMQ
		thoi gian 10 nam gan day
--output: co thuc hien giao dich nao khong?
			neu co thi tru 50000
--procsess:*/
declare @tl nvarchar(6), @GD varchar(50), @sodu int, @dem int, @thoigian int
select	@GD = t.t_id,
		@sodu= a.ac_balance,
		@dem = count(@GD),
		@thoigian = year(t.t_date)
from transactions t join account a on t.ac_no=a.ac_no
					join customer c on  a.cust_id=c.cust_id
where cust_name=N'Nguyễn Lê Minh Quân'
	and @thoigian between year(getdate()-10) and year(getdate())
group by a.ac_balance, t.t_id, t.t_date
if @dem > 0
begin	set	@tl = N'có'  
		set @sodu =@sodu - 50000 end
else 
begin set @tl = N'không' end 
print  concat(N'Trong vòng 10 năm trở lại đây Nguyễn Lê Minh Quân ',  @tl, N' thực hiện giao dịch.')

/*3. Trần Quang Khải thực hiện giao dịch gần đây nhất vào thứ mấy?
(thứ hai, thứ ba, thứ tư,…, chủ nhật) 
và vào mùa nào (mùa xuân, mùa hạ, mùa thu, mùa đông)?*/
/*input: Ten KH: TQK
--output: GD gan day nhat vao thu may, mua nao
--process:	b1: tim ngay dien ra gd gan day nhat cua TQK do
			b2: xd do la thu may va mua nao
			b3: in ra kq*/
declare @thu nvarchar(10), @mua nvarchar(10), @ngayGD varchar(50)
select @ngayGD=t_date
from customer	join account on customer.cust_id=account.cust_id
				join transactions on transactions.ac_no=account.ac_no
where cust_name = N'Trần Quang Khải'
set @thu = case datepart(dw,@ngayGD) when 1 
				then N'Thứ 2'
				when 2
				then N'Thứ 3'
				when 3 
				then N'Thứ 4'
				when 4
				then N'Thứ 5'
				when 5
				then N'Thứ 6'
				when 6
				then N'Thứ 7'
				when 7
				then N'Chủ nhật'
			end
set @mua = case when datepart(qq,@ngayGD) in (1,2,3)
				then N'Mùa xuân'
				when datepart(qq,@ngayGD) in (4,5,6)
				then N'Mùa hạ'
				when datepart(qq,@ngayGD) in (7,8,9)
				then N'Mùa thu'
				when datepart(qq,@ngayGD) in (10,11,12)
				then N'Mùa đông'
			end

print N'Trần Quang Khải thực hiện giao dịch gần đây nhất vào ' + @thu + N' và vào mùa ' + @mua 



/*4.	Đưa ra nhận xét về nhà mạng mà Lê Anh Huy đang sử dụng? 
(Viettel, Mobi phone, Vinaphone, Vietnamobile, khác)*/
/*input: ten KH
--output: nhan xet nha mang LAH dang sd
--process: b1: tim so dien thoai cua LAH
			b2: xac dinh nha mang: 016 --> viettel
									0123-0129 -->vinaphone
									0120,0121,0122,0126,0128 -->mobiphone
									018 --> vietnammobile
			b3: in ra nhan xet*/
declare @tenM nvarchar(100), 
		@sdt varchar(15);
select @sdt = cust_phone
from customer
where cust_name = N'Lê Anh Huy';
set @tenM = case	when left(@sdt,4) in ('0162','0163','0164','0165','0166','0167','0168','0169')
					then N'Viettel'
					when left(@sdt,4) in ('0123','0124','0125','0127','0129')
					then N'Vinaphone'
					when left(@sdt,4) in ('0120','0121','0122','0126','0128')
					then N'Mobi phone'
					when left(@sdt,4) in ('0182','0186','0188')
					then N'Vietnamobile'
					else N'khác'
			end;
print N'Lê Anh Huy đang sử dụng nhà mạng ' + @tenM 



/*5. Số điện thoại của Trần Quang Khải là số tiến, số lùi hay số lộn xộn. 
Định nghĩa: trừ 3 số đầu tiên, các số còn lại tăng dần gọi là số tiến, 
ví dụ: 098356789 là số tiến*/
/*input: ten KH: TQK
--output:sdt cua TQK la so tien, lui hay lon xon
--process:	b1: lay ra sdt cua TQK
			b2: so sanh cac so dien thoai tru 3 so dau tien: 
				- neu so dung truoc nho hon so dung sau la so TIEN
				- neu so dung truoc lon hon so dung sau la so LUI
				- neu cac so khong dap ung 1 trong 2 dk tren thi la so LON XON
			b3: in kq*/
declare @sdt varchar(11), @i int, @a bit, @b bit
select @sdt=right(cust_phone,len(cust_phone)-3)
from customer
where cust_name = N'Trần Quang Khải'
set @i=1
set @a=0
set @b=0
while @i<8
begin
	if substring(@sdt,@i,1) < substring(@sdt,@i+1,1)
		set @a=1
	if substring(@sdt,@i,1) > substring(@sdt,@i+1,1)
		set @b=1
	set @i=@i+1
end

if @a=1
print N'Số điện thoại của Trần Quang Khải là số tiến'
else if @b=1
print N'Số điện thoại của Trần Quang Khải là số lùi'
else 
print N'Số điện thoại của Trần Quang Khải là số lộn xộn'

/*6.	Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi nào(sáng, trưa, chiều, tối, đêm)?*/
/*input: ten KH: HCL
--output: GD gan nhat thuc hien vao buoi nao
--process:	b1: lay ra thoi gian GD gan nhat cua HCL
			b2: xac dinh GD do dien ra vao thoi gian nao:
				- 4-9h: sang
				- 9-12h: trua
				- 12- 18h: chieu
				- 18h-23h: toi
				- 23h-4h: dem
			b3: in kq*/
declare @tgGD time, @ngayGD date 
select	@ngayGD = max(t_date),
		@tgGD=t_time
from transactions join account on transactions.ac_no=account.ac_no
					join customer on account.cust_id=account.cust_id
where cust_name = N'Hà Công Lực'
group by t_time
if datepart(hh,@tgGD) between 4 and 9
print N'Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi sáng'
else if datepart(hh,@tgGD) between 9 and 12
print N'Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi trưa'
else if datepart(hh,@tgGD) between 12 and 18
print N'Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi chiều'
else if datepart(hh,@tgGD) between 18 and 23
print N'Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi tối'
else 
print N'Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi đêm'

select top 1 t_date, t_time
from transactions join account on transactions.ac_no=account.ac_no
					join customer on account.cust_id=account.cust_id
where cust_name = N'Hà Công Lực'
order by t_date desc

declare @t_date date ,@t_time time, @b nvarchar(100)
select DISTINCT top 1 @t_date=t_date , @t_time=t_time
from account a join customer c on c.cust_id=a.cust_id 
			 join transactions t on t.ac_no=a.ac_no
where cust_name=N'Hà Công Lực'
ORDER BY t_date DESC
print @t_date 
print @t_time
SET @b = CASE 
            WHEN @t_time BETWEEN '05:00:00' AND '11:00:00' THEN N'Sáng'
            WHEN @t_time BETWEEN '11:00:00' AND '13:00:00' THEN N'Trưa'
            WHEN @t_time BETWEEN '13:00:00' AND '17:00:00' THEN N'Chiều'
            WHEN @t_time BETWEEN '17:00:00' AND '21:00:00' THEN N'Tối'
            WHEN @t_time BETWEEN '21:00:00' AND '24:00:00' THEN N'Đêm'
         END
print @b

/*7.	Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc miền nào? 
Gợi ý: nếu mã chi nhánh là VN  miền nam, VT  miền trung, VB  miền bắc, còn lại: bị sai mã.*/
declare @mien nvarchar(20), @maM varchar(6)
select @maM = b.br_id
from customer c join branch b on c.br_id=b.br_id
where c.cust_name=N'Trương Duy Tường'
set @mien = case	when left(@maM,2) = 'VB'
					then N'miền bắc'
					when left(@maM,2) = 'VT'
					then N'miền trung'
					when left(@maM,2) = 'VN'
					then N'miền nam'
					else N'Bị sai mã'
			end
print N'Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc ' + @mien

/*8.	Căn cứ vào số điện thoại của Trần Phước Đạt, 
hãy nhận định anh này dùng dịch vụ di động của hãng nào: Viettel, Mobi phone, Vina phone, hãng khác.*/
declare @sdt varchar(11)
select @sdt = cust_phone
from customer
where cust_name = N'Trần Phước Đạt'
case when 
9.	Hãy nhận định Lê Anh Huy ở vùng nông thôn hay thành thị. Gợi ý: nông thôn thì địa chỉ thường có chứa chữ “thôn” hoặc “xóm” hoặc “đội” hoặc “xã” hoặc “huyện”
10.	Hãy kiểm tra tài khoản của Trần Văn Thiện Thanh, nếu tiền trong tài khoản của anh ta nhỏ hơn không hoặc bằng không nhưng 6 tháng gần đây không có giao dịch thì hãy đóng tài khoản bằng cách cập nhật ac_type = ‘K’
11.	Mã số giao dịch gần đây nhất của Huỳnh Tấn Dũng là số chẵn hay số lẻ? 
12.	Có bao nhiêu giao dịch diễn ra trong tháng 9/2016 với tổng tiền mỗi loại là bao nhiêu (bao nhiêu tiền rút, bao nhiêu tiền gửi)
13.	Ở Hà Nội ngân hàng Vietcombank có bao nhiêu chi nhánh và có bao nhiêu khách hàng? Trả lời theo mẫu: “Ở Hà Nội, Vietcombank có … chi nhánh và có …khách hàng”
/*14.	Tài khoản có nhiều tiền nhất là của ai, 
số tiền hiện có trong tài khoản đó là bao nhiêu? 
Tài khoản này thuộc chi nhánh nào?*/
/*input: 
--output: tenKh co nhieu tien nhat trong tk
			so du hien co trong tai khoan
			tai khoan thuoc chi nhanh nao
--process: b1: tim ra so tien lon nhat trong cac tai khoan
			b2: tim ra ten khach hang co do va in ra
			b4: in ra so tien trong tk cua khach hang nay
			b5: tim ra chi nhanh cua tai khoan va in ra*/
declare @tenKH nvarchar(50), @sodu int, @tenCN nvarchar(50)
select	@sodu = max(ac_balance), 
		@tenKH = cust_name, 
		@tenCN=Br_name
from account	join customer on account.cust_id=customer.cust_id
				join branch on customer.br_id=branch.br_id
group by cust_name, br_name
print N'Tài khoản có nhiều tiền nhất là của ' +@tenKH+N', 
số tiền hiện có trong tài khoản đó là: '+@sodu+ N'. 
Tài khoản này thuộc chi nhánh '+ @tenCN

/*15.	Có bao nhiêu khách hàng ở Đà Nẵng?*/
declare @SL int
select @SL = count(cust_id)
from customer
where cust_ad like N'%Đà Nẵng'
print N'Có '+ cast(@SL as varchar) +N' khách hàng ở Đà Nẵng'
--------------


/*16.	Có bao nhiêu khách hàng ở Quảng Nam nhưng mở tài khoản Sài Gòn*/
declare @SL int
select @SL=count(cust_id)
from customer c join branch b on c.br_id=b.br_id
where c.cust_ad like N'%Quảng Nam' 
	and b.br_name like N'%Sài Gòn'
print N'Có ' + cast(@SL as varchar) + N' khách hàng ở Quảng Nam nhưng mở tài khoản Sài Gòn'

/*17.	Ai là người thực hiện giao dịch có mã số 0000000387, 
thuộc chi nhánh nào? Giao dịch này thuộc loại nào?*/
declare @nguoiTH nvarchar(100), 
		@chinhanh nvarchar(100), 
		@loaiGD nvarchar(50),
		@type int
select	@nguoiTH = c.cust_name,
		@chinhanh=b.br_name,
		@type=t.t_type
from transactions t join account a on t.ac_no=a.ac_no
					join customer c on a.cust_id=c.cust_id
					join branch b on c.br_id=b.br_id
where t.t_id='0000000387'
if @type=1
begin
set @loaiGD = N'Gửi tiền'
end
else
begin
set @loaiGD = N'Rút tiền'
end
print concat(@nguoiTH ,N' là người thực hiện giao dịch có mã số 0000000387, 
thuộc chi nhánh ',@chinhanh,N' Giao dịch này thuộc loại', @loaiGD)


18.	Hiển thị danh sách khách hàng gồm: họ và tên, số điện thoại, số lượng tài khoản đang có và nhận xét. Nếu < 1 tài khoản  “Bất thường”, còn lại “Bình thường”
19.	Viết đoạn code nhận xét tiền trong tài khoản của ông Hà Công Lực. <100.000: ít, < 5.000.000  trung bình, còn lại: nhiều
20.	Hiển thị danh sách các giao dịch của chi nhánh Huế với các thông tin: mã giao dịch, thời gian giao dịch, số tiền giao dịch, loại giao dịch (rút/gửi), số tài khoản. Ví dụ:
Mã giao dịch	Thời gian GD	Số tiền GD	Loại GD	Số tài khoản
00133455	2017-11-30 09:00	3000000	Rút	04847374948

21.	Kiểm tra xem khách hàng Nguyễn Đức Duy có ở Quang Nam hay không?
22.	Điều tra số tiền trong tài khoản ông Lê Quang Phong có hợp lệ hay không? (Hợp lệ: tổng tiền gửi – tổng tiền rút = số tiền hiện có trong tài khoản). Nếu hợp lệ, đưa ra thông báo “Hợp lệ”, ngược lại hãy cập nhật lại tài khoản sao cho số tiền trong tài khoản khớp với tổng số tiền đã giao dịch (ac_balance = sum(tổng tiền gửi) – sum(tổng tiền rút)
23.	Chi nhánh Đà Nẵng có giao dịch gửi tiền nào diễn ra vào ngày chủ nhật hay không? Nếu có, hãy hiển thị số lần giao dịch, nếu không, hãy đưa ra thông báo “không có”
24.	Kiểm tra xem khu vực miền bắc có nhiều phòng giao dịch hơn khu vực miền trung ko? Miền bắc có mã bắt đầu bằng VB, miền trung có mã bắt đầu bằng VT
VÒNG LẶP
1.	In ra dãy số lẻ từ 1 – n, với n là giá trị tự chọn
2.	In ra dãy số chẵn từ 0 – n, với n là giá trị tự chọn
3.	In ra 100 số đầu tiền trong dãy số Fibonaci
4.	In ra tam giác sao: 1 tam giác vuông, 1 tam tam giác cân như ví dụ dưới đây:
*
**
***
****
*****



5.	In bảng cửu chương
6.	Viết đoạn code đọc số. Ví dụ: 1.234.567  Một triệu hai trăm ba mươi tư ngàn năm trăm sáu mươi bảy đồng. (Giả sử số lớn nhất là hàng trăm tỉ)
7.	Kiểm tra số điện thoại của Lê Quang Phong là số tiến hay số lùi. 
Gợi ý:
Với những số điện thoại có 10 số, thì trừ 3 số đầu tiên, nếu số sau lớn hơn hoặc bằng số trước thì là số tiến, ngược lại là số lùi. Ví dụ: 0981.244.789 (tiến), 0912.776.541 (lùi), 0912.563.897 (lộn xộn)
Với những số điện thoại có 11 số thì trừ 4 số đầu tiên. 
