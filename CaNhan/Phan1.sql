use Bank

select * from Branch
select * from Bank
select * from account
select * from customer
select * from transactions

-- 1.Liệt kê danh sách khách hàng ở Đà Nẵng
select Cust_id , Cust_name , Cust_phone , Cust_ad, cust.Br_id
from customer cust, Branch B
where B.BR_name like N'%Đà Nẵng' and B.BR_id = cust.Br_id;

select 

--2.Liệt kê những tài khoản loại VIP (type = 1)
select ac_type, a.cust_id, Cust_name, Ac_no, ac_balance
from account a, customer c
where ac_type=1 and a.cust_id=c.Cust_id;

-- 3.Liệt kê những khách hàng không sử dụng số điện thoại của Mobi phone
select *
from customer
where Cust_phone not in ( '090', '093', '089', '070', '079', '077', '076', '078');

-- 4.	Liệt kê những khách hàng họ Phạm
select *
from customer
except select * from customer where Cust_name like N'Phạm%';

--5.	Liệt kê những khách hàng tên chứa chữ g
select * 
from customer
where Cust_name like N'%g%';

--6.	Liệt kê những khách hàng chữ cái thứ 2 của tên là chữ H, T, A, Ê
select * 
from customer
where Cust_name like N'_[H,T,A,Â,Ê]%'

--7.	Liệt kê những giao dịch diễn ra trong quý IV năm 2016
select *
from transactions
where t_date between '2016-10-01' and '2016-12-31';

--8.	Liệt kê những giao dịch diễn ra trong mùa thu năm 2016
select * 
from transactions 
where year(t_date)=2016 and month(t_date) in(7,8,9)

--9.	Liệt kê những khách hàng không thuộc các chi nhánh miền bắc
select *
from customer 
where Br_id not like 'VB%'
--10.	Liệt kê những tài khoản nhiều hơn 100 triệu trong tài khoản
select *
from account
where ac_balance>100000000

--11.	Liệt kê những giao dịch gửi tiền diễn ra ngoài giờ hành chính
select *
from transactions
where (t_time not between '08:00:00' and '11:30:00') and (t_time not between '13:30:00' and '16:30:00');

--12.	Liệt kê những giao dịch rút tiền diễn ra vào khoảng từ 0-3h sáng
select *
from transactions
where t_time between '00:00:00' and '03:00:00';

--13.	Tìm những khách hàng có địa chỉ ở Ngũ Hành Sơn – Đà nẵng
select * 
from customer
where Cust_ad like N'%Ngũ Hành Sơn%'  
	and Cust_ad like N'%Đà Nẵng%';

--14.	Liệt kê những chi nhánh chưa có địa chỉ
select *
from Branch
where BR_ad like N'' or BR_ad is null;

--15.	Liệt kê những giao dịch rút tiền bất thường (nhỏ hơn 50.000)
select *
from transactions
where t_amount < 50000;

--16.	Liệt kê các giao dịch gửi tiền diễn ra trong năm 2017.
select *
from transactions
where year(t_date)=2017;

--17.	Liệt kê những giao dịch bất thường (tiền trong tài khoản âm)
select a.Ac_no, ac_balance, ac_type, cust_id, t_amount
from account a, transactions t
where a.Ac_no=t.ac_no and ac_balance<0;

--18.	Hiển thị tên khách hàng và tên tỉnh/thành phố mà họ sống
select Cust_name , reverse(left(reverse(Cust_ad),charindex(',', reverse(Cust_ad)))) 'Tỉnh/Thành phố'
from customer

select right(Cust_ad,charindex(',', reverse(Cust_ad))) 'Tỉnh/Thành phố'
from customer

SELECT 
    Cust_name AS 'Tên khách hàng',
    LTRIM(RTRIM(RIGHT(Cust_ad, CHARINDEX(',', REVERSE(Cust_ad)) - 1))) AS 'Tỉnh/Thành phố'
FROM 
    customer;

--19.	Hiển thị danh sách khách hàng có họ tên không bắt đầu bằng chữ N, T
select * 
from customer
where Cust_name not like N'N%' and Cust_name not like N'T%'

--20.	Hiển thị danh sách khách hàng có kí tự thứ 3 từ cuối lên là chữ a, u, i
select Cust_id, Cust_name
from customer
where Cust_name like N'%[a,á,â,à,ă,ạ,u,ú,ù,ụ,ũ,i,í,ì,ị,ĩ]__'

--21.	Hiển thị khách hàng có tên đệm là Thị hoặc Văn
select *
from customer
where Cust_name like N'%_Thị_%' or Cust_name like N'%_Văn_%'

--22.	Hiển thị khách hàng có địa chỉ sống ở vùng nông thôn. Với quy ước: nông thôn là vùng mà địa chỉ chứa: thôn, xã, xóm
select * 
from customer
where Cust_ad like N'%thôn%' 
	or (Cust_ad like N'%xã%' and Cust_ad not like N'thị xã') 
	or Cust_ad like N'%xóm%' 

--23.	Hiển thị danh sách khách hàng có kí tự thứ hai của TÊN là chữ u hoặc ũ hoặc a. Chú ý: TÊN là từ cuối cùng của cột cust_name
select reverse(left(reverse(Cust_name),charindex(' ',reverse(Cust_name))-1)) 'Ten KH'
from customer
where reverse(left(reverse(Cust_name),charindex(' ',reverse(Cust_name))-1)) like N'_[u,ũ,a]%'








