--Vi?t th? t?c th?c hi?n vi?c nêu d??i ?ây:

/*1.	Chuy?n ??i ??u s? ?i?n tho?i di ??ng theo quy ??nh c?a
b? Thông tin và truy?n thông n?u bi?t mã khách c?a h?.*/
/*input: ma KH
--output: sdt da chuyen doi
--process:	b1: lay ra sdt cu cua kh
			b2: chuyen doi dau so theo quy dinh: 
				- neu dau so la 012 thi doi thanh 07
				- neu dau so la 018 thi doi thanh 05
				- neu dau so la 016 thi doi thanh 03
				- neu dau so la 019 thi doi thanh 02
			b3: in kq*/
create proc chuyendoi	(@cust_id varchar(20), 
						@sdtmoi varchar(10) output)
as
begin
	declare @sdt varchar(11), @dauso varchar(3)
	select @sdt=cust_phone
	from customer
	where @cust_id = cust_id
	set @dauso = case	when left(@sdt,3) = '012' 
						then '07'
						when left(@sdt,3) = '018'
						then '05'
						when left(@sdt,3) = '016'
						then '03'
						when left(@sdt,3) = '019'
						then '02'
				end
	set @sdtmoi=@dauso + right(@sdt,8)
	update customer
	set cust_phone = @sdtmoi
end

declare @a varchar(10)
exec chuyendoi '000001' , @a output 
print @a

select *from customer
drop proc chuyendoi

/*2.	Ki?m tra trong vòng 10 n?m tr? l?i ?ây khách hàng có th?c hi?n giao d?ch nào không,
n?u bi?t mã khách c?a h?? N?u có, hãy tr? 50.000 phí duy trì tài kho?n.*/
create proc kiemtra (@maKH varchar(15) , @kq nvarchar(100) output)
as
begin
	declare @tg date
	select @tg=max(t_date)
	from transactions t join account a on t.ac_no=a.ac_no
					join customer c on  a.cust_id=c.cust_id
	where c.cust_id=@maKH
	if year(getdate())-year(@tg)<=10
	begin 
		update account
		set ac_balance = ac_balance -50000
		set @kq= N'trong vòng 10 n?m tr? l?i ?ây khách hàng co thuc hien giao dich va da tru 50.000'
	end
	else 
	begin 
		set @kq = N'trong vòng 10 n?m tr? l?i ?ây khách hàng khong thuc hien giao dich'
	end
end

declare @a nvarchar(100)
exec kiemtra '000008', @a output
print @a

	
3.	Ki?m tra khách th?c hi?n giao d?ch g?n ?ây nh?t vào th? m?y? (th? hai, th? ba, th? t?,…, ch? nh?t) và vào mùa nào (mùa xuân, mùa h?, mùa thu, mùa ?ông) n?u bi?t mã khách.
/*4.	??a ra nh?n xét v? nhà m?ng c?a khách hàng ?ang s? d?ng n?u bi?t mã khách? 
(Viettel, Mobi phone, Vinaphone, Vietnamobile, khác)*/
create proc nhanxet (@maKH varchar(15), @kq nvarchar(100) output)
as
begin
	declare @sdt varchar(15);
	select @sdt = cust_phone
	from customer
	where cust_id = @maKH;
	set @kq = case	when left(@sdt,4) in ('0162','0163','0164','0165','0166','0167','0168','0169')
						then N'Lê Anh Huy ?ang s? d?ng nhà m?ng Viettel'
						when left(@sdt,4) in ('0123','0124','0125','0127','0129')
						then N'Lê Anh Huy ?ang s? d?ng nhà m?ng Vinaphone'
						when left(@sdt,4) in ('0120','0121','0122','0126','0128')
						then N'Lê Anh Huy ?ang s? d?ng nhà m?ng Mobi phone'
						when left(@sdt,4) in ('0182','0186','0188')
						then N'Lê Anh Huy ?ang s? d?ng nhà m?ng Vietnamobile'
						else N'Lê Anh Huy ?ang s? d?ng nhà m?ng khác'
				end;
end

declare @a nvarchar(100)
exec nhanxet '000001', @a output
print @a
5.	N?u bi?t mã khách, hãy ki?m tra s? ?i?n tho?i c?a h? là s? ti?n, s? lùi hay s? l?n x?n. ??nh ngh?a: tr? 3 s? ??u tiên, các s? còn l?i t?ng d?n g?i là s? ti?n, ví d?: 098356789 là s? ti?n
6.	N?u bi?t mã khách, hãy ki?m tra xem khách th?c hi?n giao d?ch g?n ?ây nh?t vào bu?i nào(sáng, tr?a, chi?u, t?i, ?êm)?
7.	N?u bi?t s? ?i?n tho?i c?a khách, hãy ki?m tra chi nhánh ngân hàng mà h? ?ang s? d?ng thu?c mi?n nào? G?i ý: n?u mã chi nhánh là VN ? mi?n nam, VT ? mi?n trung, VB ? mi?n b?c, còn l?i: b? sai mã.
8.	C?n c? vào s? ?i?n tho?i c?a khách, hãy nh?n ??nh v? khách này dùng d?ch v? di ??ng c?a hãng nào: Viettel, Mobi phone, Vina phone, hãng khác.
9.	Hãy nh?n ??nh khách hàng ? vùng nông thôn hay thành th? n?u bi?t mã khách hàng c?a h?. G?i ý: nông thôn thì ??a ch? th??ng có ch?a ch? “thôn” ho?c “xóm” ho?c “??i” ho?c “xã” ho?c “huy?n”
10.	Hãy ki?m tra tài kho?n c?a khách n?u bi?t s? ?i?n tho?i c?a h?. N?u ti?n trong tài kho?n c?a h? nh? h?n không ho?c b?ng không nh?ng 6 tháng g?n ?ây không có giao d?ch thì hãy ?óng tài kho?n b?ng cách c?p nh?t ac_type = ‘K’
11.	Ki?m tra mã s? giao d?ch g?n ?ây nh?t c?a khách là s? ch?n hay s? l? n?u bi?t mã khách. 
12.	Tr? v? s? l??ng giao d?ch di?n ra trong kho?ng th?i gian nh?t ??nh (tháng, n?m), t?ng ti?n m?i lo?i giao d?ch là bao nhiêu (bao nhiêu ti?n rút, bao nhiêu ti?n g?i)
13.	Tr? v? s? l??ng chi nhánh ? m?t ??a ph??ng nh?t ??nh.
14.	Tr? v? tên khách hàng có nhi?u ti?n nh?t là trong tài kho?n, s? ti?n hi?n có trong tài kho?n ?ó là bao nhiêu? Tài kho?n này thu?c chi nhánh nào?
15.	Tr? v? s? l??ng khách c?a m?t chi nhánh nh?t ??nh.
16.	Tìm tên, s? ?i?n tho?i, chi nhánh c?a khách th?c hi?n giao d?ch, n?u bi?t mã giao d?ch.
17.	Hi?n th? danh sách khách hàng g?m: h? và tên, s? ?i?n tho?i, s? l??ng tài kho?n ?ang có và nh?n xét. N?u < 1 tài kho?n ? “B?t th??ng”, còn l?i “Bình th??ng”
18.	Nh?n xét ti?n trong tài kho?n c?a khách n?u bi?t s? ?i?n tho?i. <100.000: ít, < 5.000.000 ? trung bình, còn l?i: nhi?u
19.	Ki?m tra khách hàng ?ã m? tài kho?n t?i ngân hàng hay ch?a n?u bi?t h? tên và s? ?i?n tho?i c?a h?.
20.	?i?u tra s? ti?n trong tài kho?n c?a khách có h?p l? hay không n?u bi?t mã khách? (H?p l?: t?ng ti?n g?i – t?ng ti?n rút = s? ti?n hi?n có trong tài kho?n). N?u h?p l?, ??a ra thông báo “H?p l?”, ng??c l?i hãy c?p nh?t l?i tài kho?n sao cho s? ti?n trong tài kho?n kh?p v?i t?ng s? ti?n ?ã giao d?ch (ac_balance = sum(t?ng ti?n g?i) – sum(t?ng ti?n rút)
21.	Ki?m tra chi nhánh có giao d?ch g?i ti?n nào di?n ra vào ngày ch? nh?t hay không n?u bi?t mã chi nhánh? N?u có, tr? v? l?n giao d?ch.
22.	In ra dãy s? l? t? 1 – n, v?i n là giá tr? t? ch?n
23.	In ra dãy s? ch?n t? 0 – n, v?i n là giá tr? t? ch?n
24.	In ra 100 s? ??u ti?n trong dãy s? Fibonaci
25.	In ra tam giác sao: 
a)	tam giác vuông
*
**
***
****
*****
b)	tam giác cân

       *
     ***
   *****
 *******
********


c)	In b?ng c?u ch??ng
d)	Vi?t ?o?n code ??c s?. Ví d?: 1.234.567 ? M?t tri?u hai tr?m ba m??i t? ngàn n?m tr?m sáu m??i b?y ??ng. (Gi? s? s? l?n nh?t là hàng tr?m t?)
e)	Ki?m tra s? ?i?n tho?i c?a khách là s? ti?n hay s? lùi n?u bi?t mã khách. 
G?i ý:
V?i nh?ng s? ?i?n tho?i có 10 s?, thì tr? 3 s? ??u tiên, n?u s? sau l?n h?n ho?c b?ng s? tr??c thì là s? ti?n, ng??c l?i là s? lùi. Ví d?: 0981.244.789 (ti?n), 0912.776.541 (lùi), 0912.563.897 (l?n x?n)
V?i nh?ng s? ?i?n tho?i có 11 s? thì tr? 4 s? ??u tiên. 

