-- count, sum, avg, max, min sẽ phải dùng group by --> các cột?? chac khong
use Bank
--1.	Có bao nhiêu người có tài khoản bất thường 
select count(*) as 'SL TK bat thuong'
from account
where ac_balance<0

--2.	Thống kê số lượng giao dịch, số tiền giao dịch theo loại giao dịch
select t_type , count(t_type) as 'SL giao dich', sum(t_amount) as 'so tien GD'
from transactions
group by t_type

--3.	Có bao nhiêu khách hàng có địa chỉ ở Huế
select count(*) 'SL KH'
from customer
where Cust_ad like N'%Huế'

--4.	Số tiền trong các tài khoản nhiều nhất là bao nhiêu
SELECT MAX(ac_balance) AS Max_Balance
FROM Account;


--5.	Ngày giao dịch gần đây nhất là ngày bao nhiêu
select max(t_date) 'Ngày GD gần nhất'
from transactions

--6.	Có bao nhiêu khách hàng họ Trần và tên Dũng
select count(*) 'SL'
from customer
where Cust_name like N'Trần%' and Cust_name like N'%Dũng'

--7.	Trong năm 2016 và 2017 tổng lượng tiền gửi vào ngân hàng là bao nhiêu
select sum(t_amount) 'Tổng'
from transactions
where t_type = 0 and year(t_date) between 2016 and 2017

--8.	Thống kê số lượng tài khoản, số tiền trung bình trong tài khoản theo từng loại 
select  ac_type, count(Ac_no) as 'SL TK', avg(ac_balance) as 'so tien TB'
from account
group by ac_type

--9.	Có bao nhiêu khách họ Hồ sử dụng dịch vụ di động của Viettel
SELECT COUNT(*) AS so_luong_khach_hang_ho_Ho_Viettel
FROM customer
WHERE Cust_name LIKE N'Hồ%'
  AND Cust_phone LIKE '097%' -- Viettel: 097x, 098x, 096x, 086x, 032x, 033x, 034x, 035x, 036x, 037x, 038x, 039x
  OR Cust_phone LIKE '098%'
  OR Cust_phone LIKE '096%'
  OR Cust_phone LIKE '086%'
  OR Cust_phone LIKE '032%'
  OR Cust_phone LIKE '033%'
  OR Cust_phone LIKE '034%'
  OR Cust_phone LIKE '035%'
  OR Cust_phone LIKE '036%'
  OR Cust_phone LIKE '037%'
  OR Cust_phone LIKE '038%'
  OR Cust_phone LIKE '039%';

--10.	Ngân hàng Vietcombank có tổng cộng bao nhiêu chi nhánh
select count(BR_name) as 'SL chi nhanh'
from Branch

--11.	Có bao nhiêu khách hàng không ở Quảng Nam
select count(*) as 'sl KH khong o Quang Nam'
from customer
where Cust_ad not like N'%Quảng Nam%'

--12.	Có bao nhiêu tài khoản nhiều hơn 300 triệu, tổng tiền trong số các tài khoản đó là bao nhiêu?
select count(*) as 'sl TK', sum(ac_balance) as 'Tong so tien'
from account
where ac_balance>300000000

--13.	Số tiền trung bình của mỗi lần thực hiện giao dịch rút tiền trong năm 2017 là bao nhiêu
select avg(t_amount) as 'so tien TB'
from transactions
where year(t_date)=2017

--14.	Có bao nhiêu khách hàng có dia chi ở Quảng Nam nhung thuộc chi nhánh ngân hàng Vietcombank Đà Nẵng
select count(*) as 'SL khach hang'
from customer
where	Br_id= (select BR_id
				from Branch
				where BR_name like N'Vietcombank Đà Nẵng')
		and Cust_ad like N'%Quảng Nam'

--15.	Hiển thị danh sách khách hàng thuộc chi nhánh Vũng Tàu và số dư trong tài khoản của họ.
-- lưu ý 1 khách hàng có thể có nhiều tài khoản --> có nhiều ac_balance 
select * from Branch
select * from customer
select * from account
/* COT: id khach hang, ten khach hang, ten chi nhanh, so du tai khoan
---BANG: customer, Branch, account
---DIEU KIEN: thuoc chi nhanh VUNG TAU*/


select c.Cust_id, c.Cust_name, b.BR_name, sum(a.ac_balance) 'tong so du tai khoan'
from customer c join account a on c.Cust_id=a.cust_id
				join Branch b on c.Br_id=b.BR_id
where b.BR_name like N'%Vũng Tàu'
group by c.Cust_id, c.Cust_name, b.BR_name

select c.Cust_name, a.ac_balance
from customer c, account a
where c.Cust_id=a.cust_id 
	and c.Br_id=(	select BR_id
					from Branch
					where BR_name like N'%Vũng Tàu')

--16.	Trong quý 1 năm 2012, có bao nhiêu khách hàng thực hiện giao dịch rút tiền tại Ngân hàng Vietcombank?
select count(*) as 'SL KH rut tien'
from transactions
where year(t_date)=2012 
	and month(t_date) in (1,2,3)
	and t_type=0
	--SAI
	-------------------
/* Cô chữa bài ở lớp
cột : số lượng khách hàng ---> count
bảng : customer, transactions, bank, account,branch 
điều kiện : 1. rút tiền -->type=0
			2. quý 1 năm 2012 --> t_date
			3. ngân hàng VCB

VIDU: OneNote*/
select count(*) 'SL KH'
from transactions t, 


--17.	Thống kê số lượng giao dịch, tổng tiền giao dịch trong từng tháng của năm 2014
select  month(t_date) as 'thang GD', count(*) as 'sl GD', sum(t_amount) as 'tong so tien GD'
from transactions
where year(t_date)=2014
group by month(t_date)

--18.	Thống kê tổng tiền khách hàng gửi của mỗi chi nhánh, sắp xếp theo thứ tự giảm dần của tổng tiền
select * from Branch
select * from transactions
select * from customer
select * from account

/*	COT: tong so tien gui cua khach hang o moi chi nhanh theo thu tu giam dan
	BANG: account, Branch, transactions, customer
	DIEU KIEN: tien gui */

select b.BR_name,sum(t.t_amount) as 'so tien KH gui'
from transactions t, Branch b, customer c, account a
where b.BR_id=c.Br_id 
	and c.Cust_id=a.cust_id
	and a.Ac_no=t.ac_no
	and t.t_type=0
group by BR_name
order by sum(t.t_amount) desc



##--19.	Chi nhánh Sài Gòn có bao nhiêu khách hàng không thực hiện bất kỳ giao dịch nào trong vòng 10 năm trở lại đây. 
--Hãy hiển thị tên và số điện thoại của các khách đó để phòng marketing xử lý.
select Cust_name, Cust_phone, Br_id
from transactions t, customer c, account a
where t.ac_no=a.Ac_no
	and c.Cust_id=a.cust_id
	and t.t_date between getdate()-10 and getdate()
	and 


--20.Thống kê thông tin giao dịch theo mùa, nội dung thống kê gồm: 
--số lượng giao dịch, lượng tiền giao dịch trung bình, tổng tiền giao dịch, 
--lượng tiền giao dịch nhiều nhất, lượng tiền giao dịch ít nhất. 

-- CỘT: mùa(quý), Số lượng giao dịch, Tổng số tiền, Giao dịch lớn nhất, Giao dịch nhỏ nhất
-- BẢNG: TRANSACTION
-- ĐIỀU KIỆN: không có

SELECT 
    DATEPART(qq, t_date) AS 'Mùa',
    COUNT(t_id) AS 'Số lượng giao dịch',
	avg (t_amount) as 'lượng tiền gd tb',
    SUM(t_amount) AS 'Tổng số tiền',
    MAX(t_amount) AS 'Giao dịch lớn nhất',
    MIN(t_amount) AS 'Giao dịch nhỏ nhất'
FROM transactions
GROUP BY DATEPART(qq, t_date);
--date(qq,t_date) qq là quarter

--21.	Tìm số tiền giao dịch nhiều nhất trong năm 2016 của chi nhánh Huế. 
--Hãy đưa ra tên của khách hàng thực hiện giao dịch đó.
select c.Cust_name, max(t.t_amount) as 'so tien GD'
from customer c, transactions t, account a
where year(t.t_date)=2016
	and c.Br_id='VT011'
	and c.Cust_id=a.cust_id
	and t.ac_no=a.Ac_no
group by c.Cust_name

--22.	Tìm khách hàng có lượng tiền gửi nhiều nhất vào ngân hàng trong năm 

--23.	Tìm những khách hàng có cùng chi nhánh với ông Phan Nguyên Anh
/* COT: ten khach hang, id chi nhanh
---BANG: customer
---DIEU KIEN: cung chi nhanh voi PNA*/

select Cust_name, Br_id
from customer
where Br_id= (
	select Br_id
	from Customer
	where Cust_name=N'Phan Nguyên Anh')

--24.	Liệt kê những giao dịch thực hiện cùng giờ với giao dịch của ông Lê Nguyễn Hoàng Văn ngày 2016-12-02
select * from transactions

select t_id, t_time
from transactions
where datepart(hour, t_time)=(
	select datepart(hour,t_time) as 'giờ GD'
	from transactions t, customer c, account a
	where t.ac_no=a.Ac_no
		and c.Cust_id=a.cust_id
		and t.t_date= '2016-12-02'
		and c.Cust_name=N'Lê Nguyễn Hoàng Văn')


##--25.	Hiển thị danh sách khách hàng ở cùng thành phố với Trần Văn Thiện Thanh
select  * from customer

select Cust_id, Cust_name, Cust_ad
from Customer
where right(Cust_ad,charindex(',',reverse(Cust_ad))) like (
			select right(Cust_ad,charindex(',',reverse(Cust_ad))-1)
			from customer
			where Cust_name=N'Trần Văn Thiện Thanh')


select cust_id, cust_name, Cust_ad
from customer 
where REVERSE(LEFT(reverse(cust_ad), CHARINDEX(',', REVERSE(replace(cust_ad,'-', ',')))-1))
		in (select REVERSE(left(reverse(cust_ad), CHARINDEX(',', REVERSE(replace(cust_ad,'-', ',')))-1))
			from customer
			where cust_name= N'Trần Văn Thiện Thanh')

/*
cột: cust_id, cust_name,cust_ad
bảng: customer
đk: thành phố của cust_ad= (thành phố của trần văn thiện thanh)--> cột: thành phố của cust_ad
																	bảng: customer
																	đk: cust_name=TVTT*/


--26.	Tìm những giao dịch diễn ra cùng ngày với giao dịch có mã số 0000000217
select * from transactions

select t_id, t_date
from transactions
where t_date=(
	select t_date
	from transactions
	where t_id=0000000217)

--27.	Tìm những giao dịch cùng loại với giao dịch có mã số 0000000387
select t_id, t_type
from transactions
where t_type=(
	select t_type
	from transactions
	where t_id=0000000387)

--28.	Những chi nhánh nào thực hiện nhiều giao dịch gửi tiền trong tháng 12/2015 hơn chi nhánh Đà Nẵng


select count(*) as 'sl GD gui tien trong thang 12/2015 o DN'
from transactions t, account a,customer c
where br_id=(select BR_id
			from Branch
			where BR_name like N'%Đà Nẵng')
		and t.ac_no=a.Ac_no
		and c.Cust_id=a.cust_id
		and t.t_date between '2015-12-01' and '2015-12-31'
		and t.t_type=0

--29.	Hãy liệt kê những tài khoản trong vòng 6 tháng trở lại đây không phát sinh giao dịch
/* COT: id tai khoan
---BANG: transactions
---DIEU KIEN: 6 thang gan day khong phat sinh giao dich*/

select ac_no
from transactions
where month(t_date) not between month(getdate()) and month(getdate())-6



--30.Ông Phạm Duy Khánh thuộc chi nhánh nào? 
--Từ 01/2015 đến nay ông Khánh đã thực hiện bao nhiêu giao dịch gửi tiền vào ngân hàng 
--với tổng số tiền là bao nhiêu.
select BR_name
from Branch b
where b.BR_id=(
	select Br_id
	from customer
	where Cust_name=N'Phạm Duy Khánh')

select count(*) as 'SL GD', sum(t_amount) as 'Tong so tien da gui vao NH'
from transactions t, account a
where a.cust_id=(select Cust_id
				from customer
				where Cust_name=N'Phạm Duy Khánh')
		and t_type=0
		and t.ac_no=a.Ac_no

	---------------------------------
/*	COT: 1. BR_name
		 2. (SL GD cua PDK tu 01/2015 den nay:
			COT: count(t_id)
			BANG: transactions, customer, account
			DIEU KIEN:	1. Cust_name=N'PDK'
						2. t_date>= '01/01/2015'
						3. t_type=1)
		 3. (Tong so tien gui cua PDK tu 01/2015 den nay:
			COT: sum(t_amount)
			BANG: transactions, customer, account
			DIEU KIEN: Cust_name=PDK
	BANG: Branch, customer
	DIEU KIEN: Cust_name=N'PDK' */

select	BR_name, 
		(	select count(t_id)
			from transactions t, customer c, account a
			where	t.ac_no=a.Ac_no
					and a.cust_id=c.Cust_id
					and Cust_name= N'Phạm Duy Khánh'
					and t_date>= '2015-01-01'
					and t_type=1) as ' So luong giao dich',
		(	select sum(t_amount)
			from transactions t, customer c, account a
			where	t.ac_no=a.Ac_no
					and a.cust_id=c.Cust_id
					and Cust_name= N'Phạm Duy Khánh'
					and t_date>= '2015-01-01'
					and t_type=1)  as 'Tong so tien gui'
from Branch b, customer c
where	b.BR_id=c.Br_id
		and Cust_name=N'Phạm Duy Khánh'

--31.	Thống kê giao dịch theo từng năm, nội dung thống kê gồm: số lượng giao dịch, lượng tiền giao dịch trung bình
select year(t_date) as 'nam', count(*) as 'so luong giao dich', avg(t_amount) as 'luong tien giao dich TB' 
from transactions
group by year(t_date)

--32.	Thống kê số lượng giao dịch theo ngày và đêm trong năm 2017 ở chi nhánh Hà Nội, Sài Gòn
select count(*)
from transactions



--33.	Hiển thị danh sách khách hàng không thực hiện giao dịch nào trong năm 2016?
/* COT: id khach hang, ten khach hang, so dien thoai khach hang
---BANG: customer, account, transactions
---DIEU KIEN: khong thuc hien giao dich nao trong nam 2016*/
select Cust_name
from customer
where Cust_id not in (select cust_id
						from transactions t join account a on a.ac_no=t.ac_no
						where year(t.t_date)='2016')


SELECT CUST_NAME
FROM CUSTOMER C 
WHERE CUST_ID NOT IN (SELECT distinct CUST_ID
					FROM TRANSACTIONS T JOIN ACCOUNT A ON T.AC_NO=A.AC_NO
					WHERE YEAR(T_DATE)='2016')

select Cust_name
from customer c
where Cust_id not in (select cust_id
						from transactions t join accoount a on t.ac_no=a.ac_no
						where year(t.t_date)=2016)

--34.Hiển thị những giao dịch trong mùa xuân của các chi nhánh miền trung. 
--Gợi ý: giả sử một năm có 4 mùa, mỗi mùa kéo dài 3 tháng; 
--chi nhánh miền trung có mã chi nhánh bắt đầu bằng VT.
select t.t_id, t.t_date,c.Br_id
from transactions t, customer c, account a
where t.ac_no=a.Ac_no and c.Cust_id=a.cust_id and c.Br_id=BR_id
	and Br_id in (
		select BR_id
		from Branch
		where BR_id like 'VT%')
	and month(t.t_date) in (1,2,3)


--35.	Hiển thị họ tên và các giao dịch của khách hàng sử dụng số điện thoại có 3 số đầu là 093 và 2 số cuối là 02. 
select c.Cust_name, t.t_id
from customer c, transactions t, account a
where c.Cust_id=a.cust_id and t.ac_no=a.Ac_no
	and c.cust_id=(
		select Cust_id
		from customer
		where Cust_phone like '093%' and Cust_phone like '%02')


--36.	Hãy liệt kê 2 chi nhánh làm việc kém hiệu quả nhất trong toàn hệ thống 
--(số lượng giao dịch gửi tiền ít nhất) trong quý 3 năm 2017

select b.BR_name, count(t.t_id)
from transactions t, account a, customer c, Branch b
where t.ac_no=a.Ac_no 
	and a.cust_id=c.Cust_id
	and c.Br_id =b.BR_id
	and t.t_type=0

group by b.BR_name
order by count(t_id) asc


select c.Br_name
from transactions t, account a, customer c, Branch b
where t.ac_no=a.Ac_no 
	and a.cust_id=c.Cust_id
	and c.Br_id =b.BR_id
	and t.t_type=0
	and t.t_date between '2017-07-01' and '2017-09-30'
group by b.BR_id
order by count(t_id) asc






--37.Hãy liệt kê 2 chi nhánh có bận mải nhất hệ thống (thực hiện nhiều giao dịch gửi tiền nhất) trong năm 2017. 
select top 2 b.BR_name, count(t.t_id)
from transactions t, account a, customer c, Branch b
where t.ac_no=a.Ac_no 
	and a.cust_id=c.Cust_id
	and c.Br_id =b.BR_id
	and t.t_type=0
	and year(t.t_date)=2017
group by b.BR_name
order by count(t_id) desc

--38.	Tìm giao dịch gửi tiền nhiều nhất trong mùa đông. 
--Hãy đưa ra tên của người thực hiện giao dịch và chi nhánh.
select top 1 t.t_amount, t.t_id, c.Cust_name, b.BR_name
from transactions t, account a, customer c, Branch b
where t.ac_no=a.Ac_no
	and a.cust_id=c.Cust_id
	and c.Br_id=b.BR_id
	and month(t.t_date) in (10,11,12)	 
order by t.t_amount desc


--39.	Để bổ sung nhân sự cho các chi nhánh, cần có kết quả phân tích về cường độ làm việc của họ. 
--Hãy liệt kê những chi nhánh phải làm việc qua trưa và loại giao dịch là gửi tiền.
select b.BR_id, b.BR_name
from Branch b, customer c, account a, transactions t
where t.ac_no=a.Ac_no 
	and a.cust_id=c.Cust_id
	and c.Br_id=b.BR_id
	and t.t_time <= '14:00:00' and t.t_time >= '11:00:00'
	and t.t_type = 0
group by b.BR_id, b.BR_name


--40.	Hãy liệt kê các giao dịch gửi tiền bất thường.
--Gợi ý: là các giao dịch gửi tiền những được thực hiện ngoài khung giờ làm việc
select t_id, t_time
from transactions
where (t_time not between '07:00:00' and '11:30:00') and (t_time not between '13:30:00' and '17:30:00')
	and t_type = 0

--41.	Hãy điều tra những giao dịch bất thường trong năm 2017. 
--Giao dịch bất thường là giao dịch diễn ra trong khoảng thời gian từ 12h đêm tới 3 giờ sáng.
/* COT: id giao dich, thoi gian giao dich, id tai khoan giao dich
---BANG: transactions
---DIEU KIEN:	nam 2017
				12h dem den 3h sang*/
select t_id, t_time, ac_no
from transactions
where t_time between '00:00:00' and '03:00:00'

--42.	Có bao nhiêu người ở Đắc Lắc sở hữu nhiều hơn một tài khoản?
--COT: so luong khach hang
--BANG: account, customer
--DIEU KIEN: - o Dac Lac
			-- co nhieu hon 1 tai khoan


SELECT COUNT(C.Cust_id) AS So_luong_khach_hang
FROM Customer C
JOIN Account A ON C.Cust_id = A.cust_id
WHERE C.Cust_ad LIKE N'%Đăk Lăk%'
GROUP BY C.Cust_id
HAVING COUNT(A.Ac_no) > 1;

select count (c.Cust_id) as 'SL khach hang'
from account a join customer c on a.cust_id=c.Cust_id
where Cust_ad like N'%Đăk Lăk'
group by c.Cust_id
having count(a.ac_no)>1




--43.	Nếu mỗi giao dịch rút tiền ngân hàng thu phí 3.000 đồng, 
--hãy tính xem tổng tiền phí thu được từ thu phí dịch vụ từ năm 2012 đến năm 2017 là bao nhiêu?
select count(*) * 3000
from transactions
where year(t_date) between 2012 and 2017
		and t_type=1


--44.	Hiển thị thông tin các khách hàng họ Trần theo các cột sau: 
--Mã KH	Họ	Tên	Số dư tài khoản
select c.Cust_id as N'Mã KH', 
		left(c.Cust_name,charindex(' ',c.Cust_name)-1) as N'Họ',		
		right(c.Cust_name,charindex(' ',reverse(c.Cust_name))-1) as N'Tên',
		a.ac_balance as N'Số dư tài khoản'
from customer c, account a
where c.Cust_id=a.cust_id



			
Khó
--45.Cuối mỗi năm, nhiều khách hàng có xu hướng rút tiền khỏi ngân hàng 
--để chuyển sang ngân hàng khác hoặc chuyển sang hình thức tiết kiệm khác. 
--Hãy lọc những khách hàng có xu hướng rút tiền khỏi ngân hàng bằng cách 
--hiển thị những người rút gần hết tiền trong tài khoản 
--(tổng tiền rút trong tháng 12/2017 nhiều hơn 100 triệu và số dư trong tài khoản còn lại <= 100.000)



46.	Thời gian vừa qua, hệ thống CSDL của ngân hàng bị hacker tấn công (giả sử tí cho vui ), tổng tiền trong tài khoản bị thay đổi bất thường. Hãy liệt kê những tài khoản bất thường đó. Gợi ý: tài khoản bất thường là tài khoản có tổng tiền gửi – tổng tiền rút <> số tiền trong tài khoản
47.	Do hệ thống mạng bị nghẽn và hệ thống xử lý chưa tốt phần điều khiển đa người dùng nên một số tài khoản bị invalid. Hãy liệt kê những tài khoản đó. Gợi ý: tài khoản bị invalid là những tài khoản có số tiền âm. 
48.	(Giả sử) Gần đây, một số khách hàng ở chi nhánh Đà Nẵng kiện rằng: tổng tiền trong tài khoản không khớp với số tiền họ thực hiện giao dịch. Hãy điều tra sự việc này bằng cách hiển thị danh sách khách hàng ở Đà Nẵng bao gồm các thông tin sau: mã khách hàng, họ tên khách hàng, tổng tiền đang có trong tài khoản, tổng tiền đã gửi, tổng tiền đã rút, kết luận (nếu tổng tiền gửi – tổng tiền rút = số tiền trong tài khoản  OK, trường hợp còn lại  có sai)
49.	Ngân hàng cần biết những chi nhánh nào có nhiều giao dịch rút tiền vào buổi chiều để chuẩn bị chuyển tiền tới. Hãy liệt kê danh sách các chi nhánh và lượng tiền rút trung bình theo ngày (chỉ xét những giao dịch diễn ra trong buổi chiều), sắp xếp giảm giần theo lượng tiền giao dịch. 
