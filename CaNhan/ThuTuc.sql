--Vi?t th? t?c th?c hi?n vi?c n�u d??i ?�y:

/*1.	Chuy?n ??i ??u s? ?i?n tho?i di ??ng theo quy ??nh c?a
b? Th�ng tin v� truy?n th�ng n?u bi?t m� kh�ch c?a h?.*/
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

/*2.	Ki?m tra trong v�ng 10 n?m tr? l?i ?�y kh�ch h�ng c� th?c hi?n giao d?ch n�o kh�ng,
n?u bi?t m� kh�ch c?a h?? N?u c�, h�y tr? 50.000 ph� duy tr� t�i kho?n.*/
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
		set @kq= N'trong v�ng 10 n?m tr? l?i ?�y kh�ch h�ng co thuc hien giao dich va da tru 50.000'
	end
	else 
	begin 
		set @kq = N'trong v�ng 10 n?m tr? l?i ?�y kh�ch h�ng khong thuc hien giao dich'
	end
end

declare @a nvarchar(100)
exec kiemtra '000008', @a output
print @a

	
3.	Ki?m tra kh�ch th?c hi?n giao d?ch g?n ?�y nh?t v�o th? m?y? (th? hai, th? ba, th? t?,�, ch? nh?t) v� v�o m�a n�o (m�a xu�n, m�a h?, m�a thu, m�a ?�ng) n?u bi?t m� kh�ch.
/*4.	??a ra nh?n x�t v? nh� m?ng c?a kh�ch h�ng ?ang s? d?ng n?u bi?t m� kh�ch? 
(Viettel, Mobi phone, Vinaphone, Vietnamobile, kh�c)*/
create proc nhanxet (@maKH varchar(15), @kq nvarchar(100) output)
as
begin
	declare @sdt varchar(15);
	select @sdt = cust_phone
	from customer
	where cust_id = @maKH;
	set @kq = case	when left(@sdt,4) in ('0162','0163','0164','0165','0166','0167','0168','0169')
						then N'L� Anh Huy ?ang s? d?ng nh� m?ng Viettel'
						when left(@sdt,4) in ('0123','0124','0125','0127','0129')
						then N'L� Anh Huy ?ang s? d?ng nh� m?ng Vinaphone'
						when left(@sdt,4) in ('0120','0121','0122','0126','0128')
						then N'L� Anh Huy ?ang s? d?ng nh� m?ng Mobi phone'
						when left(@sdt,4) in ('0182','0186','0188')
						then N'L� Anh Huy ?ang s? d?ng nh� m?ng Vietnamobile'
						else N'L� Anh Huy ?ang s? d?ng nh� m?ng kh�c'
				end;
end

declare @a nvarchar(100)
exec nhanxet '000001', @a output
print @a
5.	N?u bi?t m� kh�ch, h�y ki?m tra s? ?i?n tho?i c?a h? l� s? ti?n, s? l�i hay s? l?n x?n. ??nh ngh?a: tr? 3 s? ??u ti�n, c�c s? c�n l?i t?ng d?n g?i l� s? ti?n, v� d?: 098356789 l� s? ti?n
6.	N?u bi?t m� kh�ch, h�y ki?m tra xem kh�ch th?c hi?n giao d?ch g?n ?�y nh?t v�o bu?i n�o(s�ng, tr?a, chi?u, t?i, ?�m)?
7.	N?u bi?t s? ?i?n tho?i c?a kh�ch, h�y ki?m tra chi nh�nh ng�n h�ng m� h? ?ang s? d?ng thu?c mi?n n�o? G?i �: n?u m� chi nh�nh l� VN ? mi?n nam, VT ? mi?n trung, VB ? mi?n b?c, c�n l?i: b? sai m�.
8.	C?n c? v�o s? ?i?n tho?i c?a kh�ch, h�y nh?n ??nh v? kh�ch n�y d�ng d?ch v? di ??ng c?a h�ng n�o: Viettel, Mobi phone, Vina phone, h�ng kh�c.
9.	H�y nh?n ??nh kh�ch h�ng ? v�ng n�ng th�n hay th�nh th? n?u bi?t m� kh�ch h�ng c?a h?. G?i �: n�ng th�n th� ??a ch? th??ng c� ch?a ch? �th�n� ho?c �x�m� ho?c �??i� ho?c �x� ho?c �huy?n�
10.	H�y ki?m tra t�i kho?n c?a kh�ch n?u bi?t s? ?i?n tho?i c?a h?. N?u ti?n trong t�i kho?n c?a h? nh? h?n kh�ng ho?c b?ng kh�ng nh?ng 6 th�ng g?n ?�y kh�ng c� giao d?ch th� h�y ?�ng t�i kho?n b?ng c�ch c?p nh?t ac_type = �K�
11.	Ki?m tra m� s? giao d?ch g?n ?�y nh?t c?a kh�ch l� s? ch?n hay s? l? n?u bi?t m� kh�ch. 
12.	Tr? v? s? l??ng giao d?ch di?n ra trong kho?ng th?i gian nh?t ??nh (th�ng, n?m), t?ng ti?n m?i lo?i giao d?ch l� bao nhi�u (bao nhi�u ti?n r�t, bao nhi�u ti?n g?i)
13.	Tr? v? s? l??ng chi nh�nh ? m?t ??a ph??ng nh?t ??nh.
14.	Tr? v? t�n kh�ch h�ng c� nhi?u ti?n nh?t l� trong t�i kho?n, s? ti?n hi?n c� trong t�i kho?n ?� l� bao nhi�u? T�i kho?n n�y thu?c chi nh�nh n�o?
15.	Tr? v? s? l??ng kh�ch c?a m?t chi nh�nh nh?t ??nh.
16.	T�m t�n, s? ?i?n tho?i, chi nh�nh c?a kh�ch th?c hi?n giao d?ch, n?u bi?t m� giao d?ch.
17.	Hi?n th? danh s�ch kh�ch h�ng g?m: h? v� t�n, s? ?i?n tho?i, s? l??ng t�i kho?n ?ang c� v� nh?n x�t. N?u < 1 t�i kho?n ? �B?t th??ng�, c�n l?i �B�nh th??ng�
18.	Nh?n x�t ti?n trong t�i kho?n c?a kh�ch n?u bi?t s? ?i?n tho?i. <100.000: �t, < 5.000.000 ? trung b�nh, c�n l?i: nhi?u
19.	Ki?m tra kh�ch h�ng ?� m? t�i kho?n t?i ng�n h�ng hay ch?a n?u bi?t h? t�n v� s? ?i?n tho?i c?a h?.
20.	?i?u tra s? ti?n trong t�i kho?n c?a kh�ch c� h?p l? hay kh�ng n?u bi?t m� kh�ch? (H?p l?: t?ng ti?n g?i � t?ng ti?n r�t = s? ti?n hi?n c� trong t�i kho?n). N?u h?p l?, ??a ra th�ng b�o �H?p l?�, ng??c l?i h�y c?p nh?t l?i t�i kho?n sao cho s? ti?n trong t�i kho?n kh?p v?i t?ng s? ti?n ?� giao d?ch (ac_balance = sum(t?ng ti?n g?i) � sum(t?ng ti?n r�t)
21.	Ki?m tra chi nh�nh c� giao d?ch g?i ti?n n�o di?n ra v�o ng�y ch? nh?t hay kh�ng n?u bi?t m� chi nh�nh? N?u c�, tr? v? l?n giao d?ch.
22.	In ra d�y s? l? t? 1 � n, v?i n l� gi� tr? t? ch?n
23.	In ra d�y s? ch?n t? 0 � n, v?i n l� gi� tr? t? ch?n
24.	In ra 100 s? ??u ti?n trong d�y s? Fibonaci
25.	In ra tam gi�c sao: 
a)	tam gi�c vu�ng
*
**
***
****
*****
b)	tam gi�c c�n

       *
     ***
   *****
 *******
********


c)	In b?ng c?u ch??ng
d)	Vi?t ?o?n code ??c s?. V� d?: 1.234.567 ? M?t tri?u hai tr?m ba m??i t? ng�n n?m tr?m s�u m??i b?y ??ng. (Gi? s? s? l?n nh?t l� h�ng tr?m t?)
e)	Ki?m tra s? ?i?n tho?i c?a kh�ch l� s? ti?n hay s? l�i n?u bi?t m� kh�ch. 
G?i �:
V?i nh?ng s? ?i?n tho?i c� 10 s?, th� tr? 3 s? ??u ti�n, n?u s? sau l?n h?n ho?c b?ng s? tr??c th� l� s? ti?n, ng??c l?i l� s? l�i. V� d?: 0981.244.789 (ti?n), 0912.776.541 (l�i), 0912.563.897 (l?n x?n)
V?i nh?ng s? ?i?n tho?i c� 11 s? th� tr? 4 s? ??u ti�n. 

